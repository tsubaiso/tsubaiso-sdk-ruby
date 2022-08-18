require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ApReportTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("ap_reports")
  end

  def test_list_ap_cashflow_schedule
    url = @api.instance_variable_get(:@base_url) + "/ap_reports/list_cashflow_schedule/2019/12"

    request_headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby',
      "Access-Token" => @api.instance_variable_get(:@access_token)
    }

    req_fixture_path = "test/stubbings/fixtures/ap_reports_list_cashflow_schedule_request.json"
    req_stubs = JSON.load(File.read(req_fixture_path))
    req_stubs.each do |params|
      params.merge!(format: 'json')
    end

    response_body = {}

    stub_request(:get, url)
    .with({ headers: request_headers }.merge({ body: req_stubs[0] }))
    .to_return({ status: 200 }.merge( { body: response_body.to_json } ))

    # Without pay_method option parameters
    schedule_list = @api.list_ap_cashflow_schedule(2019, 12)
    assert_equal 200, schedule_list[:status].to_i, schedule_list.inspect

    stub_request(:get, url)
    .with({ headers: request_headers }.merge({ body: req_stubs[1] }))
    .to_return({ status: 200 }.merge( { body: response_body.to_json } ))

    # With pay_method option parameters
    schedule_list_with_opts = @api.list_ap_cashflow_schedule(2019, 12,
                                                             { :pay_method => 'BANK_FB' })
    assert_equal 200, schedule_list_with_opts[:status].to_i, schedule_list_with_opts.inspect
  end
end
