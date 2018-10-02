module TsubaisoAPI
  require "net/http"
  require "json"

  def initialize(options = {})
    @base_url = options[:base_url] || 'https://tsubaiso.net'
    @access_token = options[:access_token]
  end

  def list(resource, params = {})
    api_request(uri_parse(resource + '/list', "GET", params)
  end

  def show(resource, params = {})
    api_request(uri_parse(resource + '/show', "GET", params)
  end

  def create(resource, params = {})
    api_request(uri_parse(resource + '/create', "POST", params)
  end

  def update(resource, params = {})
    api_request(uri_parse(resource + '/update', "POST", params)
  end

  def destroy(resource, params = {})
    api_request(uri_parse(resource + '/destroy', "POST", params)
  end
  private

  def api_request(uri, http_verb, params)
    http = Net::HTTP.new(uri.host, uri.port)
    initheader = {'Content-Type' => 'application/json'}
    http.use_ssl = true if @base_url =~ /^https/
    if http_verb == "GET"
      request = Net::HTTP::Get.new(uri.path, initheader)
    else
      request = Net::HTTP::Post.new(uri.path, initheader)
    end
    request["Access-Token"] = @access_token
    request.body = params.to_json
    response = http.request(request)
    if response.body
      begin
        { status: response.code, json: JSON.parse(response.body) }
      rescue
        response.body
      end
    else
      response.code
    end
  end

  def url_parse(end_point)
    URI.parse(@base_url + end_point)
  end
end
