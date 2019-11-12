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

  def stub_show
    @created_records.each_with_index do |record, index|
      stub_request(:get, ROOT_URL+ "bank_account_masters/" + "destroy/" + record[:id])
      .with(
        headers: COMMON_REQUEST_HEADERS
      )
      .to_return(
        status: 422,
        body: record.json
      )
    end
  end

  def stub_list
    stub_request(:get, ROOT_URL+ "bank_account_masters/" + "list/")
    .with(
      headers: COMMON_REQUEST_HEADERS
    )
    .to_return(
      status: 200,
      body: @created_records.to_json
    )
  end

  def stub_destroy
    @created_records.each_with_index do |record, index|
      stub_request(:post, ROOT_URL+ "bank_account_masters/" + "destroy/" + record[:id])
      .with(
        headers: COMMON_REQUEST_HEADERS
      )
      .to_return(
        status: 422
      )
    end
  end

  def stub_create(*expected_params)
    expected_params.each_with_index do |record, index|
      stub_request(:post, ROOT_URL + "bank_account_masters/" + "create/")
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

    Dir.glob("*.json", base: "./test/stubbings/fixtures").each do |fixtures|
      File.open("./test/stubbings/fixtures/#{fixtures}") do |hash|
        params = JSON.load(hash)
        stub_create(*params)
        stub_destroy
        stub_list
        stub_show
      end
    end
  end
end