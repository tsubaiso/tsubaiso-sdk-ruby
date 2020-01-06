require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class FixedAssetsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super('fixed_assets')
  end

  def test_list_fixed_assets
    list = @api.list_fixed_assets
    assert_equal 200, list[:status].to_i, list.inspect
    assert list[:json]
    assert !list[:json].empty?
  end

end
