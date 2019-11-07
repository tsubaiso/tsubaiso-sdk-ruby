require 'webmock'
include WebMock::API

WebMock.enable!
WebMock.disable_net_connect!

class Hash
  def add_date_and_id(index = 0)
    self.merge({
      :id => (990 + index).to_s,
      :created_at => Time.now.to_s,
      :updated_at => Time.now.to_s
    })
  end
end

class Stubbing
  def initialize(domain)
    @root_url = "https://tsubaiso.net/#{domain}"
    @common_request_headers = {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Access-Token'=>'6stryskt2i2fmm7j8qyv429zf-2sllzoej9ila018ryf2gllcl2',
    'Content-Type'=>'application/json',
    'User-Agent'=>'Ruby'
    }
    @created_records = []
    ["create","destroy","show","list","update"].each do |method|
      self.send(method)
    end
  end

  def destroy
    @created_records.each do |record|
      stub_request(:post, @root_url + "destroy/#{record[:id]}")
      .with(
        headers: @common_request_headers,
        body: {'format' => 'json'}
      )
      .to_return(
        status: 422
      )
    end
  end

  def show
    @created_records.each do |record|
      stub_request(:get, @root_url + "show/#{record[:id]}")
      .with(
        headers: @common_request_headers,
        body: {'format' => 'json'}
      )
      .to_return(
        status: 200,
        body: record.to_json
      )
    end
  end

  def list
    stub_request(:get, /#{@root_url}(index|list)/)
    .with(
      headers: @common_request_headers,
      body: {'format' => 'json'}
    )
    .to_return(
    status: 200,
    body: @created_records.to_json
    )
  end
end