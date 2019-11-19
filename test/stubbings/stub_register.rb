require "json"
require 'webmock'
require_relative '../../lib/url_builder.rb'
include WebMock::API

WebMock.enable!
WebMock.disable_net_connect!

class StubRegister
  include UrlBuilder

  def initialize(resource, root_url, token)
    @common_request_headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
    }
    @root_url = root_url
    @common_request_headers.merge!({"Access-Token" => token})
    @created_records = []

    stub_create(resource)
    stub_destroy(resource)
    stub_list(resource)
    stub_show(resource)
    stub_update(resource)
  end

  private

  def find_and_load_json(resource, method, req_or_res = "require")
    path = "test/stubbings/fixtures/#{resource}_#{method}_#{req_or_res}.json"
    return nil unless File.exist?(path)
    JSON.load(File.read(path))
  end

  def add_attributes_to_response(record, index, resource)
    new_attributs = {}
    new_params = find_and_load_json(resource, "create" ,"response")
    new_attributs.merge!(new_params) if new_params

    new_attributs.merge!({
      :id => index.to_s,
      :created_at => Time.now.to_s,
      :updated_at => Time.now.to_s
    })

    record.merge(new_attributs)
  end

  def stub_update(resource)
    if find_and_load_json(resource, "update")
      expected_params = find_and_load_json(resource, "update")
      stub_request(:post, url(@root_url,resource,"update") + @created_records[0][:id])
      .with(
        headers: @common_request_headers,
        body: expected_params.merge({"format" => "json"})
      )
      .to_return(
        status: 200,
        body: @created_records[0].merge(expected_params).to_json
      )
    end
  end

  def stub_show(resource)
    @created_records.each_with_index do |record, index|
      stub_request(:get, url(@root_url, resource, "show") + record[:id])
      .with(
        headers: @common_request_headers,
        body: {"format" => "json"}
      )
      .to_return(
        status: 200,
        body: record.to_json
      )
    end
  end

  def stub_list(resource)
    stub_request(:get, url(@root_url, resource, "list", 2019, 7))
    .with(
      headers: @common_request_headers
    )
    .to_return(
      status: 200,
      body: @created_records.to_json
    )
  end

  def stub_destroy(resource)
    @created_records.each_with_index do |record, index|
      stub_request(:post, url(@root_url, resource, "destroy") + record[:id])
      .with(
        headers: @common_request_headers
      )
      .to_return(
        status: 422
      )
    end
  end

  def stub_create(resource)
    expected_params = *find_and_load_json(resource, "create")
    expected_params.each_with_index do |record, index|
      stub_request(:post, url(@root_url, resource, "create"))
      .with(
        headers: @common_request_headers,
        body: record.merge({"format" => "json"})
      )
      .to_return(
        status: 200,
        body: add_attributes_to_response(record, index, resource).to_json,
      )
    @created_records << add_attributes_to_response(record, index, resource)
    end
  end

end

