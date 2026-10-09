#!/usr/bin/env python3
"""Convert SDP CSV output to SARIF 2.1.0 for GitHub Code Scanning.

Usage: csv_to_sarif.py <input.csv> <output.sarif>
CSV schema: file_path, function_name, predicted_defect[, start_line]
"""
import csv
import hashlib
import json
import sys
from pathlib import Path

RULE_ID = "sdp/predicted-defect"
# GitHub hard-caps results at 25,000 per run; stay safely under it.
MAX_RESULTS = 25_000

RULE = {
    "id": RULE_ID,
    "name": "PredictedDefect",
    "shortDescription": {"text": "Function predicted to be defect-prone"},
    "fullDescription": {
        "text": "A machine-learning model flagged this function as likely to "
                "contain a defect, based on change history and code metrics."
    },
    "help": {
        "text": "Review this function for correctness and consider adding tests.",
        "markdown": ("### Predicted defect\n\nThe SDP model flagged this function as "
                     "defect-prone. This is a **probabilistic signal**, not a confirmed "
                     "bug — prioritise review and test coverage here."),
    },
    "defaultConfiguration": {"level": "warning"},
    "properties": {"tags": ["defect-prediction", "machine-learning", "quality"]},
}


def normalise_uri(raw: str) -> str:
    """Produce a repo-root-relative, POSIX-style URI as SARIF requires."""
    return Path(raw.strip().replace("\\", "/")).as_posix().lstrip("./")


def fingerprint(file_uri: str, function_name: str) -> str:
    """Stable identity so alerts survive line-number shifts and refactors."""
    digest = hashlib.sha256(f"{file_uri}::{function_name}".encode()).hexdigest()
    return digest[:16]

def build_results(csv_path: Path) -> list[dict]:
    results = []
    with csv_path.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            # Check the "fixes" column: skip if it's not flagged (1)
            # (Also supports 'predicted_defect' as a fallback)
            is_defect = row.get("fixes") or row.get("predicted_defect") or ""
            if is_defect.strip() != "1":
                continue

            uri = normalise_uri(row["file_path"])
            func = (row.get("function_name") or "unknown").strip()

            # Parse the start_line emitted by your tool
            try:
                start_line = max(1, int(row.get("start_line") or 1))
            except ValueError:
                start_line = 1

            results.append({
                "ruleId": RULE_ID,
                "level": "warning",
                "message": {
                    "text": (
                        f"Function '{func}' is predicted to be defect-prone. "
                        "Review logic and test coverage."
                    )
                },
                "locations": [{
                    "physicalLocation": {
                        "artifactLocation": {
                            "uri": uri,
                            "uriBaseId": "%SRCROOT%"
                        },
                        "region": {"startLine": start_line},
                    }
                }],
                "partialFingerprints": {
                    "sdpFunctionId/v1": fingerprint(uri, func)
                },
                "properties": {"functionName": func},
            })
    return results

def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2

    csv_path, sarif_path = Path(sys.argv[1]), Path(sys.argv[2])
    results = build_results(csv_path)

    sarif = {
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "version": "2.1.0",
        "runs": [{
            "tool": {"driver": {
                "name": "SDP",
                "informationUri": "https://github.com/CarlosAndresRamirez/PoCs",
                "version": "0.1.1",
                "rules": [RULE],
            }},
            "results": results,
            # Tells GitHub the run succeeded even when there are zero results,
            # so it correctly closes previously-open alerts.
            "invocations": [{"executionSuccessful": True}],
        }],
    }

    sarif_path.write_text(json.dumps(sarif, indent=2), encoding="utf-8")
    print(f"Wrote {len(results)} result(s) to {sarif_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
