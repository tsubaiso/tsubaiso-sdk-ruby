require "json"
require 'webmock'
include WebMock::API

WebMock.enable!
WebMock.disable_net_connect!

class Stubbing
  ROOT_URL = "https://tsubaiso.net/"

  COMMON_REQUEST_HEADERS = {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Access-Token'=>'6stryskt2i2fmm7j8qyv429zf-2sllzoej9ila018ryf2gllcl2',
    'Content-Type'=>'application/json',
    'User-Agent'=>'Ruby'
  }

  def add_id_and_dates(record, index)
    record.merge({
      :id => index.to_s,
      :created_at => Time.now.to_s,
      :updated_at => Time.now.to_s
    })
  end

  def stub_update(expected_params,domain)
    stub_request(:post, ROOT_URL + domain + "/update/#{@created_records[0][:id]}")
    .with(
      headers: COMMON_REQUEST_HEADERS,
      body: expected_params.merge({"format" => "json"})
    )
    .to_return(
      status: 200,
      body: @created_records[0].update(expected_params).update({:updated_at => Time.now.to_s}).to_json
    )
  end

  def stub_show(domain)
    @created_records.each_with_index do |record, index|
      stub_request(:get, ROOT_URL+ domain + "/show/" + record[:id])
      .with(
        headers: COMMON_REQUEST_HEADERS
      )
      .to_return(
        status: 422,
        body: record.to_json
      )
    end
  end

  def stub_list(domain)
    stub_request(:get, ROOT_URL+ domain + "/index/")
    .with(
      headers: COMMON_REQUEST_HEADERS
    )
    .to_return(
      status: 200,
      body: @created_records.to_json
    )
  end

  def stub_destroy(domain)
    @created_records.each_with_index do |record, index|
      stub_request(:post, ROOT_URL+ domain + "/destroy/" + record[:id])
      .with(
        headers: COMMON_REQUEST_HEADERS
      )
      .to_return(
        status: 422
      )
    end
  end

  def stub_create(*expected_params,domain)
    expected_params.each_with_index do |record, index|
      stub_request(:post, ROOT_URL + domain + "/create/")
      .with(
        headers: COMMON_REQUEST_HEADERS,
        body: record
      )
      .to_return(
        status: 200,
        body: add_id_and_dates(record, index).to_json,
      )
    @created_records << add_id_and_dates(record, index)
    end
  end

  def initialize
    @created_records = []

    request_body_1 = {
      "format" => "json",
      "bank_account_master_id" => 990,
      "start_timestamp" => "2019-06-30",
      "finish_timestamp" => "2019-07-30"
    }

    group_by_domain = Dir.glob("*.json", base: "./test/stubbings/fixtures").group_by{|file| file.split("_")[0..-3].join("_")}

    group_by_domain.each_key do |domain|
      # req_or_resp =  File.basename(json).delete(".json").split("_")[-1] # require or response
      # method =  File.basename(json).split("_")[-2]  # CURD methods

      File.open("./test/stubbings/fixtures/#{domain}_create_require.json") do |hash|
        params = JSON.load(hash)
        stub_create(*params, domain)
        stub_destroy(domain)
        stub_list(domain)
        stub_show(domain)
      end

      File.open("./test/stubbings/fixtures/#{domain}_update_require.json") do |hash|
        params = JSON.load(hash)
        stub_update(params, domain)
      end
    end
  end
end