require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ApiHistoryTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("api_histories")
  end

  def test_index_api_history
    index = @api.index_api_history
    assert_equal 200, index[:status].to_i, index.inspect
    assert !index[:json].empty?
  end

  def test_list_api_history
    options = {
      month: 12,
      year: 2019
    }
    list = @api.list_api_history(options)
    assert_equal 200, list[:status].to_i, list.inspect
    assert_equal list[:json].first[:controller], 'reimbursements'
    assert_equal list[:json].first[:method], 'create'
  end
end
