require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ApReasonMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("ap_reason_masters")
  end

  def test_show_ap_reason_master
    ap_reason_masters = @api.list_ap_reason_masters
    first_ap_reason_master = ap_reason_masters[:json].first
    ap_reason_master = @api.show_ap_reason_master(first_ap_reason_master[:id])

    assert_equal 200, ap_reason_master[:status].to_i, ap_reason_master.inspect
    assert_equal first_ap_reason_master[:reason_code], ap_reason_master[:json][:reason_code]
  end

  def test_list_ap_reason_masters
    ap_reason_masters_list = @api.list_ap_reason_masters
    assert_equal 200, ap_reason_masters_list[:status].to_i, ap_reason_masters_list.inspect
    assert ap_reason_masters_list[:json]
    assert !ap_reason_masters_list[:json].empty?
  end
end
