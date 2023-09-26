require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ApReasonMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @ap_reason_master_1 = {
      reason_code: 'sdk_test_create',
      reason_name: 'SDK before update',
      dc: 'd',
      account_code: '100',
      is_valid: '0',
      memo: 'this is test before update',
      port_type: '0',
      sort_number: '0',
      ap_reason_taxes: '免税・簡易・本則/国内/1/3001/210'
    }
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

  def test_create_ap_reason_master
    created_apm = @api.create_ap_reason_masters(@ap_reason_master_1)
    assert_equal 200, created_apm[:status].to_i, created_apm.inspect
    assert_equal @ap_reason_master_1[:reason_code], created_apm[:json][:reason_code]
    assert_equal @ap_reason_master_1[:ap_reason_taxes], created_apm[:json][:ap_reason_taxes]

    shown_apm = @api.show_ap_reason_master(created_apm[:json][:id].to_i)
    assert_equal 200, shown_apm[:status].to_i, shown_apm.inspect
    @ap_reason_master_1.each_pair do |key,val|
      assert_equal val, shown_apm[:json][key], "col :#{key},  #{val} was expected but #{shown_apm[:json][key]} was found."
    end
  end

  def test_update_ap_reason_master
    old_ap_reason_master = @api.create_ap_reason_masters(@ap_reason_master_1)
    options = {
      reason_name: "updating from API",
      memo: "updating memo from API",
      ap_reason_taxes: "免税・簡易・本則/国内/1/3001/210"
    }
    updated_ap_reason_master = @api.update_ap_reason_masters(old_ap_reason_master[:json][:id], options)

    assert_equal 200, updated_ap_reason_master[:status].to_i, updated_ap_reason_master.inspect
    assert_equal options[:reason_name], updated_ap_reason_master[:json][:reason_name]
    assert_equal options[:memo], updated_ap_reason_master[:json][:memo]
    assert_equal options[:ap_reason_taxes], updated_ap_reason_master[:json][:ap_reason_taxes]
    assert_equal old_ap_reason_master[:json][:reason_code], updated_ap_reason_master[:json][:reason_code]
  end
end
