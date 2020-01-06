require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class PayrollsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("payrolls")
  end

  def test_show_payroll
    payrolls_list = @api.list_payrolls(2017, 2)
    first_payroll_id = payrolls_list[:json].first[:id]

    payroll = @api.show_payroll(first_payroll_id)
    assert_equal 200, payroll[:status].to_i, payroll.inspect
    assert_equal first_payroll_id, payroll[:json][:id]
  end

  def test_list_payrolls
    payrolls_list = @api.list_payrolls(2017, 2)

    assert_equal 200, payrolls_list[:status].to_i, payrolls_list.inspect
    assert !payrolls_list.empty?
  end
end
