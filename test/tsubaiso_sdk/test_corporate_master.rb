require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class CorporateMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super('corporate_masters')
  end

  def test_show_corporate_master
    # With HatagayaTest CorporateMaster ID Only
    shown_corporate_master = @api.show_corporate_master(0)
    assert_equal 3, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷建設株式会社', shown_corporate_master[:json][:name]

    # With HatagayaTest Corporate Code Only
    shown_corporate_master = @api.show_corporate_master(nil, { ccode: 3 })
    assert_equal 3, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷建設株式会社', shown_corporate_master[:json][:name]

    # With HatagayaTest Both CorporateMaster ID and Corporate Code
    shown_corporate_master = @api.show_corporate_master(0, { ccode: 3 })
    assert_equal 3, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷建設株式会社', shown_corporate_master[:json][:name]
  end
end
