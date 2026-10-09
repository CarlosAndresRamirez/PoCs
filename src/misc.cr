
enum SpecialChar : UInt8

  #####
  # Special Characters
  # TODO: https://www.oreilly.com/library/view/learning-the-bash/1565923472/ch01s09.html
  #####
  Space
  Newline
  Carriage_Return
  Left_Paren
  Right_Paren
  Left_Brace
  Right_Brace
  Colon
  Semicolon
  Tilde
  Grave_Accent

  def space?
    self == Space
  end

  def newline?
    self == Newline
  end

  def carriage_return?
    self == Carriage_Return
  end

  def left_paren?
    self == Left_Paren
  end

  def right_paren?
    self == Right_Paren
  end

  def left_brace?
    self == Left_Brace
  end

  def right_brace?
    self == Right_Brace
  end

  def colon?
    self == Colon
  end

  def semicolon?
    self == Semicolon
  end

  def tilde?
    self == Tilde
  end

  def grave_accent?
    self == Grave_Accent
  end

  def to_s()
    case self
    when Space
      return " "
    when Newline
      return "\n"
    when Carriage_Return
      return "\r"
    when Left_Paren
      return "("
    when Right_Paren
      return ")"
    when Left_Brace
      return "{"
    when Right_Brace
      return "}"
    when Colon
      return ":"
    when Semicolon
      return ";"
    when Tilde
      return "~"
    when Grave_Accent
      return "`"
    else
      # TODO: Log + Error
      return ""
    end
  end
end

# Blind SQL queries?
enum SpecialString : UInt16
  Shellshock
  Http_V10
  Http_V11
  Http_V2_Upgrade

  Http_Header_Host
  Http_Header_Connection
  Http_Header_User_Agent
  Http_Header_Accept_Language

  def shellshock?
    self == Shellshock
  end
  def http_v10?
    self == Http_V10
  end

  def http_v11?
    self == Http_V11
  end

  def http_v2_upgrade?
    self == Http_V2_Upgrade
  end

  #####
  # TODO: All headers + their params
  # HTTP Headers
  #####
  def http_header_host?
    self == Http_Header_Host
  end

  def http_header_connection?
    self == Http_Header_Connection
  end

  def http_header_user_agent?
    self == Http_Header_User_Agent
  end

  def http_header_accept_language?
    self == Http_Header_Accept_Language
  end

  def to_s()
    case self
    when Shellshock
      return "() { :; }; "
    when Http_V10
      return "HTTP/1.0"
    when Http_V11
      return "HTTP/1.1"
    when Http_V2_Upgrade
      return "Connection: Upgrade, HTTP2-Settings\nUpgrade: h2c\nHTTP2-Settings:\n"
    when Http_Header_Host
      return "Host: "
    when Http_Header_Connection
      return "Connection: "
    when Http_Header_User_Agent
      return "User-Agent: "
    when Http_Header_Accept_Language
      return "Accept-Language: "
    else
      # TODO: Log + Error
      return ""
    end
  end
end
