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

  def find_and_load_json(domain, method, req_or_res = "require")
    path = "../stubbings/fixtures/#{domain}_#{method}_#{req_or_res}.json"
    if File.exist?(File.expand_path(path,"."))
      File.open(File.expand_path(path,".")) do |hash|
        return JSON.load(hash)
      end
    end
    return nil
  end

  def add_id_and_dates(record, index, domain)
    new_attributs = {}
    new_params = find_and_load_json(domain, "create" ,"response")
    new_attributs.merge!(new_params) if new_params

    new_attributs.merge!({
      :id => index.to_s,
      :created_at => Time.now.to_s,
      :updated_at => Time.now.to_s
    })

    record.merge(new_attributs)
  end

  def stub_update(domain)
    if find_and_load_json(domain, "update")
      expected_params = find_and_load_json(domain, "update")
      stub_request(:post, ROOT_URL + domain + "/update/#{@created_records[0][:id]}")
      .with(
        headers: COMMON_REQUEST_HEADERS,
        body: expected_params.merge({"format" => "json"})
      )
      .to_return(
        status: 200,
        body: @created_records[0].merge(expected_params).to_json
      )
    end
  end

  def stub_show(domain)
    @created_records.each_with_index do |record, index|
      stub_request(:get, ROOT_URL+ domain + "/show/" + record[:id])
      .with(
        headers: COMMON_REQUEST_HEADERS,
        body: {"format" => "json"}
      )
      .to_return(
        status: 200,
        body: record.to_json
      )
    end
  end

  def stub_list(domain)
    if domain == "bank_accounts"
      # bank_accountsのlistはこのpathに直接指定する方法しかない？
      # もし、jsonでも年月指定が可能なら .with(body{"month" => "7", "year" => "2019"})で対応したい。
      stub_request(:get, ROOT_URL + domain + "/list/2019/7")
      .with(
        headers: COMMON_REQUEST_HEADERS
      )
      .to_return(
        status: 200,
        body: @created_records.to_json
      )
    else
      stub_request(:get, ROOT_URL + domain + "/list/")
      .with(
        headers: COMMON_REQUEST_HEADERS
      )
      .to_return(
        status: 200,
        body: @created_records.to_json
      )
    end
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

  def stub_create(*expected_params, domain)
    expected_params.each_with_index do |record, index|
    stub_request(:post, ROOT_URL + domain + "/create/")
      .with(
        headers: COMMON_REQUEST_HEADERS,
        body: record.merge({"format" => "json"})
      )
      .to_return(
        status: 200,
        body: add_id_and_dates(record, index, domain).to_json,
      )
    @created_records << add_id_and_dates(record, index, domain)
    end
  end

  def initialize(domain)
    @created_records = []
    params = find_and_load_json(domain, "create")
    stub_create(*params, domain)
    stub_destroy(domain)
    stub_list(domain)
    stub_show(domain)
    stub_update(domain)
  end

end

