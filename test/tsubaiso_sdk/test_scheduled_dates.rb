require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class ScheduledDatesTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    super('scheduled_dates')
  end

  def test_calc_scheduled_dates
    response = @api.scheduled_date('2019-01-02', '1m10', '5', 'before')
    assert_equal '200', response[:status]
    assert_equal '2019-01-10', response[:json][:scheduled_date]
  end
end