require "json"
require 'webmock'
require 'active_support'
require_relative '../../lib/tsubaiso_sdk.rb'

include WebMock::API

class StubRegister
  include TsubaisoSDK::UrlBuilder

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
    stub_find_or_create(resource)
  end

  private

  def find_and_load_json(resource, method, req_or_res = "require")
    path = "test/stubbings/fixtures/#{resource}_#{method}_#{req_or_res}.json"
    return nil unless File.exist?(path)
    JSON.load(File.read(path))
  end

  def add_attributes(record, index, resource)
    return_params = {}

    return_params.merge!(record) if record
    new_attributes = find_and_load_json(resource, "create" ,"response")
    return_params.deep_merge!(new_attributes) if new_attributes

    return_params.merge!({
      :id => index.to_s,
      :created_at => Time.now.to_s,
      :updated_at => Time.now.to_s
    })

    return_params["tag_list"] = record["tag_list"].split(",") if record["tag_list"]&.kind_of?(String)
    return return_params
  end

  def stub_find_or_create(resource)
    # NOTE: This stub support ar_receipts, ap_payments
    if find_and_load_json(resource, "find_or_create")
      expected_param = find_and_load_json(resource, "find_or_create")
      return_body    = add_attributes(expected_param, 99, resource)
      stub_requests(:post, url(@root_url, resource, 'find_or_create'), return_body, expected_param)
      @created_records << return_body
    end
  end

  def stub_update(resource)
    if find_and_load_json(resource, "update")
      expected_params = find_and_load_json(resource, "update")
      stub_requests(:post, url(@root_url, resource, 'update') + '/0', @created_records[0].merge(expected_params), expected_params)
    end
  end

  def stub_show(resource)
    @created_records.each do |record|
      stub_requests(:get, url(@root_url, resource, "show") + '/' + record[:id], record)

      case resource
      when "customer_masters"
        # NOTE: Serch by Code (support customer_master_show)
        stub_requests(:get, url(@root_url, resource, "show"), record, { code: record['code'] })
      when "staff_data"
        # NOTE: Serch by code and staff_id (support staff_data)
        expected_body = {
          staff_id: record['staff_id'],
          code: record['code'],
          time: record['start_timestamp']
        }
        stub_requests(:get, url(@root_url, resource, "show"), record, expected_body)
      end
    end
  end

  def stub_requests(http_method, url, response_body, expected_body = {}, &proc)
    response_body.select!(&proc) if proc
    expected_body.merge!( {"format" => "json"} )

    stub_request(http_method, url)
    .with(
      { headers: @common_request_headers }.merge({ body: expected_body })
    )
    .to_return(
      { status: 200 }.merge( { body: response_body.to_json } )
    )
  end

  def stub_list(resource)
    case resource
    when "bank_accounts"
      stub_requests(:get, url(@root_url, resource, "list", 2016, 8), @created_records)
    when "ar"
      stub_requests(:get, url(@root_url, resource, "list", 2016, 8), @created_records){ |record| record["realization_timestamp"] =~ /2016-08-\d{2}/}
    when "ap_payments"
      stub_requests(:get, url(@root_url, resource, "list", 2016, 8), @created_records){ |record| record["accrual_timestamp"] =~ /2016-08-\d{2}/}
    when "staff_data"
      stub_requests(:get, url(@root_url, resource, "list"), @created_records, { staff_id: 300 })
    when "bank_account_transactions"
      stub_requests(:get, url(@root_url, resource, "list"), @created_records, { bank_account_id: 0})
    else
      stub_requests(:get, url(@root_url, resource, "list"), @created_records)
    end
  end

  def stub_destroy(resource)
    @created_records.each_with_index do |record, index|
      stub_request(:post, url(@root_url, resource, "destroy") + "/" + record[:id])
      .with(
        headers: @common_request_headers
      )
      .to_return(
        status: 204
      )
    end
  end

  def stub_create(resource)
    expected_params = *find_and_load_json(resource, "create")

    expected_params.each_with_index do |record, index|
      return_body = add_attributes(record, index, resource)
      stub_requests(:post, url(@root_url, resource, "create"), return_body, record)
      @created_records << return_body
    end
  end

end

