
require "uri"

require "./misc.cr"

enum RequestMethod : UInt8
  Options
  Get
  Head
  Post
  Put
  Patch
  Delete
  Trace
  Connect
  Custom

  def options?
    self == RequestMethod::Options
  end

  def get?
    self == Get
  end

  def head?
    self == Head
  end

  def post?
    self == Post
  end

  def put?
    self == Put
  end

  def patch?
    self == Patch
  end

  def delete?
    self == Delete
  end

  def trace?
    self == Trace
  end

  def connect?
    self == Connect
  end

  def custom?
    self == Custom
  end

  def to_s()
    case self
    when Options
      return "OPTIONS"
    when Get
      return "GET"
    when Head
      return "HEAD"
    when Post
      return "POST"
    when Put
      return "PUT"
    when Patch
      return "PATCH"
    when Delete
      return "DELETE"
    when Trace
      return "TRACE"
    when Connect
      return "CONNECT"
    when Custom
      return "CUSTOM"
    else
      # TODO: Log + Error
      return ""
    end
  end
end

# Request-Line   = Method SP Request-URI SP HTTP-Version CRLF

class Request
  alias RequestLine = RequestMethod | SpecialChar | SpecialString | String

  # https://crystal-lang.org/api/0.36.1/URI.html
  getter uri : URI
  property request : Array(RequestLine)
  property method : RequestMethod
  property http_version : SpecialString

  def initialize()
    @method = RequestMethod::Get
    @http_version = SpecialString::Http_V11
    @uri = URI.parse ""
    @request = get_default_request_array

    @uri = set_url("")
  end

  def get_default_request_array
    tmp = Array(RequestLine).new

    add_http_header_to_request(tmp, SpecialString::Http_Header_Host, "localhost")
    add_http_header_to_request(tmp, SpecialString::Http_Header_Connection, "keep-alive")
    add_http_header_to_request(tmp, SpecialString::Http_Header_User_Agent, "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36")
    add_http_header_to_request(tmp, SpecialString::Http_Header_Accept_Language, "en-US,en;q=0.9")
    # CRLF
    tmp.push(SpecialChar::Carriage_Return)
    tmp.push(SpecialChar::Newline)

    tmp
  end

  def add_http_header_to_request(nrequest : Array(RequestLine), header : SpecialString, params)
    nrequest.push header
    nrequest.push params
    nrequest.push SpecialChar::Newline
    nrequest
  end

  def set_request_method()
    set_request_method( @request, @method, @uri.to_s, @http_version )
  end

  def set_request_method( nrequest : Array(RequestLine),
                          nmethod : RequestMethod,
                          url : String,
                          http_version : SpecialString )

    tmpuri = URI.parse url
    tmp = tmpuri.path
    unless tmpuri.query.nil?
      tmp += "?" + tmpuri.query.as(String)
    end

    if @request[0].is_a? RequestMethod
      #if @request[0].as(SpecialString).value != SpecialString::
      #puts "1st element SpecialString: #{@request[0].as(SpecialString).value}"
      #@request.delete_at(0, 1)
    end

    nrequest.insert(0, nmethod)
    nrequest.insert(1, SpecialChar::Space)
    nrequest.insert(2, tmp)
    nrequest.insert(3, SpecialChar::Space)
    nrequest.insert(4, http_version)
    nrequest.insert(5, SpecialChar::Newline)
    #nrequest.insert(6, SpecialChar::Newline)
    nrequest
  end

  def get_plain_request(nrequest : Array(RequestLine))
    tmp = ""
    nrequest.each { |str|
      tmp += str.to_s
    }
    tmp
  end

  def get_plain_request()
    get_plain_request(@request)
  end

  #####
  # URL
  #####
  def set_url(url : String)
    @uri = URI.parse url
    @uri
  end

  def get_url()
    @uri.to_s
  end

  def get_url_scheme()
    @uri.scheme
  end

  def get_url_host()
    @uri.host
  end

  def get_url_port()
    @uri.port
  end

  def get_url_path()
    @uri.path
  end

  def get_url_query()
    @uri.query
  end

  def get_url_query_params()
    @uri.query_params
  end

  def get_url_user()
    @uri.user
  end

  def get_url_password()
    @uri.password
  end

  def is_url_relative?()
    @uri.relative?
  end

end
