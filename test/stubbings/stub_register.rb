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
    @common_request_headers.merge!( {"Access-Token" => token} )
    @created_records = []

    stub_create(resource)
    stub_destroy(resource)
    stub_list(resource)
    resource == 'api_histories' ? stub_index(resource) : stub_show(resource)
    stub_balance(resource)
    stub_update(resource)
    stub_find_or_create(resource)
    stub_calc(resource)
  end

  private

  def load_json(resource, method, req_or_res = "require")
    path = "test/stubbings/fixtures/#{resource}_#{method}_#{req_or_res}.json"
    return nil unless File.exist?(path)
    JSON.load(File.read(path))
  end

  def add_attrs(record, index, resource)
    return_params = record ? record.dup : {}

    new_attributes = load_json(resource, 'create' ,'response')
    return_params.deep_merge!(new_attributes) if new_attributes

    return_params.merge!({
      :id => index.to_s,
      :created_at => Time.now.to_s,
      :updated_at => Time.now.to_s
    })

    return_params["tag_list"] = record["tag_list"].split(",") if record["tag_list"]&.kind_of?(String)
    return_params
  end

  def stub_calc(resource)
    return unless load_json(resource, 'calc', 'require')
    stub_requests(:get, url(@root_url, resource, 'calc'), {"scheduled_date": "2019-01-10"}, load_json(resource, 'calc', 'require'))
  end

  def stub_balance(resource)
    if load_json(resource, 'balance', 'require')
      expect_param = load_json(resource, 'balance')
      return_body  = load_json(resource, 'balance', 'response')
      stub_requests(:get, url(@root_url, resource, 'balance'), return_body, expect_param)
      stub_requests(:get, url(@root_url, resource, 'balance'), return_body, expect_param.merge({customer_master_id: 101})) { |record| record['customer_master_code'] == "101"}
    end
  end

  def stub_find_or_create(resource)
    # NOTE: This stub support ar_receipts, ap_payments
    if load_json(resource, "find_or_create")
      expected_param = load_json(resource, "find_or_create")
      return_body    = add_attrs(expected_param, 99, resource)
      stub_requests(:post, url(@root_url, resource, 'find_or_create'), return_body, expected_param)
      @created_records << return_body
    end
  end

  def stub_update(resource)
    if load_json(resource, 'update')
      param = load_json(resource, 'update')
      stub_requests(:post, url(@root_url, resource, 'update') + '/0', @created_records[0].merge(param), param)
    end
  end

  def stub_show(resource)
    @created_records.each do |record|
      stub_requests(:get, url(@root_url, resource, "show") + '/' + record[:id], record) unless resource == 'journals' || resource == 'corporate_masters'

      case resource
      when 'customer_masters', 'staff_datum_masters'
        # NOTE: Serch by Code (support customer_master_show & staff_datum_master_show & corporate_masters)
        stub_requests(:get, url(@root_url, resource, "show"), record, { code: record['code'] })
      when 'staff_data'
        # NOTE: Serch by code and staff_id (support staff_data)
        expected_body = {
          staff_id: record['staff_id'],
          code: record['code'],
          time: record['start_timestamp']
        }
        stub_requests(:get, url(@root_url, resource, "show"), record, expected_body)
      when 'corporate_masters'
        stub_requests(:get, url(@root_url, resource, "show") + '/' + record[:id], record, { ccode: record['corporate_code'] })
        stub_requests(:get, url(@root_url, resource, "show") + '/' + record[:id], record, { ccode: nil  })
        stub_requests(:get, url(@root_url, resource, "show"), record, { ccode: record['corporate_code'] })
      when 'journals'
        stub_requests(:get, url(@root_url, resource, "show") + '/' + record[:id], { 'record': record })
      end
    end
  end

  def stub_requests(http_method, url, created_records, expected_body = {}, &condition)
    response_body = condition ? created_records.select(&condition) : created_records

    stub_request(http_method, url)
    .with(
      { headers: @common_request_headers }.merge({ body: expected_body.merge(format: 'json') })
    )
    .to_return(
      { status: 200 }.merge( { body: response_body.to_json } )
    )
  end

  def stub_index(resource)
    # NOTE: for api_history
    stub_requests(:get, url(@root_url, resource, 'index'), load_json(resource, 'index', 'response'))
  end

  def stub_list(resource)
    if @created_records.size == 0
      # This conditions is for modules which support only list & show.
      load_json(resource,'list','response')&.each_with_index do |record, i|
        @created_records << add_attrs(record, i, resource)
      end
    end

    case resource
    when 'bank_accounts'
      stub_requests(:get, url(@root_url, resource, 'list', 2016, 8), @created_records)
    when 'manual_journals'
      stub_requests(:get, url(@root_url, resource, 'list', 2016, 4), @created_records)
    when 'payrolls'
      stub_requests(:get, url(@root_url, resource, 'list', 2017, 2), @created_records)
    when 'ar'
      stub_requests(:get, url(@root_url, resource, 'list', 2016, 8), @created_records){ |record| record["realization_timestamp"] =~ /2016-08-\d{2}/}
    when 'ap_payments'
      stub_requests(:get, url(@root_url, resource, 'list', 2016, 8), @created_records){ |record| record["accrual_timestamp"] =~ /2016-08-\d{2}/}
    when 'staff_data'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records, { staff_id: 300 })
    when 'bank_account_transactions'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records, { bank_account_id: 0})
    when 'reimbursements'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records, { year: 2016, month: 3})
    when 'api_histories'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records, { year: 2019, month: 12}){ |record| record['access_timestamp'] =~ /2019\/12\/\d{2}/}
    when 'reimbursement_transactions'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records, { id: 300 }) { |record| record['reimbursement_id'] == 300 }
    when 'tags'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records.group_by{ |record| record['tag_group_code'] })
    when 'bonuses'
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records, { target_year: 2016, bonus_no: 1 })
    when 'journals'
      stub_requests(:get, url(@root_url, resource, 'list'), {'records': @created_records}, { 'start_date': '2019-12-01', 'finish_date': '2019-12-31'} )
      stub_requests(:get, url(@root_url, resource, 'list'), {'records': @created_records}, { 'price_min': 10800, 'price_max': 10800} )
      stub_requests(:get, url(@root_url, resource, 'list'), {'records': @created_records}, { 'dept_code': 'SETSURITSU' } )
    else
      stub_requests(:get, url(@root_url, resource, 'list'), @created_records)
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
    load_json(resource, "create")&.each_with_index do |record, i|
      if resource == 'journal_distributions'
        return_body = add_attrs({}, i, resource)
      else
        return_body = add_attrs(record, i, resource)
      end
      stub_requests(:post, url(@root_url, resource, "create"), return_body, record)
      @created_records << return_body
    end
  end
end

