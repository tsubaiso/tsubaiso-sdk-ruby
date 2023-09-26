require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ArReasonMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @ar_reason_master_1 = {
      reason_code: 'sdk_test_create',
      reason_name: 'SDK before update',
      dc: 'd',
      account_code: '100',
      is_valid: '0',
      memo: 'this is test before update',
      sort_number: '0',
      ar_reason_taxes: '免税・簡易・本則/国内/1/3001/210'
    }
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

  def test_create_ar_reason_master
    created_arm = @api.create_ar_reason_masters(@ar_reason_master_1)
    assert_equal 200, created_arm[:status].to_i, created_arm.inspect
    assert_equal @ar_reason_master_1[:reason_code], created_arm[:json][:reason_code]
    assert_equal @ar_reason_master_1[:ar_reason_taxes], created_arm[:json][:ar_reason_taxes]

    shown_arm = @api.show_ar_reason_master(created_arm[:json][:id].to_i)
    assert_equal 200, shown_arm[:status].to_i, shown_arm.inspect
    @ar_reason_master_1.each_pair do |key,val|
      assert_equal val, shown_arm[:json][key], "col :#{key},  #{val} was expected but #{shown_arm[:json][key]} was found."
    end
  end

  def test_update_ar_reason_master
    old_ar_reason_master = @api.create_ar_reason_masters(@ar_reason_master_1)
    options = {
      reason_name: "updating from API",
      memo: "updating memo from API",
      ar_reason_taxes: "免税・簡易・本則/国内/1/3001/210"
    }
    updated_ar_reason_master = @api.update_ar_reason_masters(old_ar_reason_master[:json][:id], options)

    assert_equal 200, updated_ar_reason_master[:status].to_i, updated_ar_reason_master.inspect
    assert_equal options[:reason_name], updated_ar_reason_master[:json][:reason_name]
    assert_equal options[:memo], updated_ar_reason_master[:json][:memo]
    assert_equal options[:ar_reason_taxes], updated_ar_reason_master[:json][:ar_reason_taxes]
    assert_equal old_ar_reason_master[:json][:reason_code], updated_ar_reason_master[:json][:reason_code]
  end
end
