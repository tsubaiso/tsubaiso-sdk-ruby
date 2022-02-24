require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class PayrollAttendancesTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("payroll_attendances")
  end

  def test_list_payroll_attendances
    listed_timecards = @api.list_payroll_attendances(2020, 1)
    assert_equal 200, listed_timecards[:status].to_i, listed_timecards.inspect

    # 戻り値が配列でないので、list_responce のスタブを作れません。
  end

end
