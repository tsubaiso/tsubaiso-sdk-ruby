require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class PaidHolidaysTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @paid_holiday_1 = {
      staff_id: 2011,
      holiday: {
        start_timestamp: Date.new(2020, 8, 5),
        finish_timestamp: Date.new(2020, 8, 7),
        memo: '夏期休暇',
      },
      full_or_half: 'half'
    }

    @paid_holiday_2 = {
      staff_id: 2011
    }

    super("paid_holidays")
  end

  def test_list_paid_holidays
    res = @api.list_paid_holidays
    assert res
  end

  def test_list_forms_paid_holidays
    path = "test/stubbings/fixtures/paid_holidays_list_forms_response.json"
    res_body = JSON.load(File.read(path))

    base_url = @api.instance_variable_get(:@base_url)
    WebMock.stub_request(:get, "#{base_url}/paid_holidays/list_forms/2011").to_return(
      body: res_body.to_json,
      status: 200,
      headers: { 'Content-Type' =>  'application/json' }
    )

    res = @api.list_forms_paid_holidays(2011)
    assert res
  end

  def test_create_paid_holiday
    res = @api.create_paid_holiday(@paid_holiday_1)
    assert res

    res = @api.create_paid_holiday(@paid_holiday_2)
    assert res
  end

  def test_update_paid_holiday
    options = {
      holiday: {
        is_ok: 1,
        start_timestamp: Date.new(2020, 5, 1),
        finish_timestamp: Date.new(2020, 5, 2),
        memo: '申請時のメモ'
      },
      full_or_half: 'half'
    }
    res = @api.update_paid_holiday(0, options)
    assert res
  end

  def test_destroy_paid_holiday
    res = @api.destroy_paid_holiday(0)
    assert res
  end
end
