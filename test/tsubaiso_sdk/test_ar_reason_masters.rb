require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ArReasonMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("ar_reason_masters")
  end

  def test_list_ar_reason_masters
    ar_reason_masters_list = @api.list_ar_reason_masters
    assert_equal 200, ar_reason_masters_list[:status].to_i, ar_reason_masters_list.inspect
    assert ar_reason_masters_list[:json]
    assert !ar_reason_masters_list[:json].empty?
  end

  def test_show_ar_reason_master
    ar_reason_masters = @api.list_ar_reason_masters
    ar_reason_master_id = ar_reason_masters[:json].first[:id]
    ar_reason_master = @api.show_ar_reason_master(ar_reason_master_id)

    assert_equal 200, ar_reason_master[:status].to_i, ar_reason_master.inspect
    assert_equal ar_reason_master[:json][:id], ar_reason_master_id
  end
end
