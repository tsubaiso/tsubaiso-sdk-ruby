require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ReimbursementReasonMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @reimbursement_reason_master_1 = {
      reason_code: 'sdk_test_create',
      reason_name: 'SDK before update',
      dc: 'd',
      account_code: '100',
      is_valid: '0',
      memo: 'this is test before update',
      port_type: '0',
      sort_number: '0',
      reimbursement_reason_taxes: '免税・簡易・本則/国内/1/3001/210'
    }

    @reimbursement_reason_master_2 = {
      reason_code: "sdk_test_create2",
      reason_name: "TEST_REASON",
      dc: "d",
      account_code: "999",
      is_valid: "0",
      memo: "This is Test reason.",
      port_type: "0",
      sort_number: "0",
      reimbursement_reason_taxes: "免税・簡易・本則/国内/1/3001/210"
    }
    
    super("reimbursement_reason_masters")
  end

  def test_list_reimbursement_reason_masters
    reimbursement_reason_masters_list = @api.list_reimbursement_reason_masters
    assert_equal 200, reimbursement_reason_masters_list[:status].to_i, reimbursement_reason_masters_list.inspect
    assert reimbursement_reason_masters_list[:json]
    assert !reimbursement_reason_masters_list[:json].empty?
  end

  def test_show_reimbursement_reason_master
    reim_reason_msts = @api.list_reimbursement_reason_masters
    reim_reason_mst_id = reim_reason_msts[:json].first[:id]
    reim_reason_mst = @api.show_reimbursement_reason_master(reim_reason_mst_id)

    assert_equal 200, reim_reason_mst[:status].to_i, reim_reason_mst.inspect
    assert_equal reim_reason_mst[:json][:id], reim_reason_mst_id
  end

  def test_create_reimbursement_reason_master
    created_rrm = @api.create_reimbursement_reason_masters(@reimbursement_reason_master_1)
    assert_equal 200, created_rrm[:status].to_i, created_rrm.inspect
    assert_equal @reimbursement_reason_master_1[:reason_code], created_rrm[:json][:reason_code]
    assert_equal @reimbursement_reason_master_1[:reimbursement_reason_taxes], created_rrm[:json][:reimbursement_reason_taxes]

    shown_rrm = @api.show_reimbursement_reason_master(created_rrm[:json][:id].to_i)
    assert_equal 200, created_rrm[:status].to_i, created_rrm.inspect
    @reimbursement_reason_master_1.each_pair do |key,val|
      assert_equal val, shown_rrm[:json][key], "col :#{key},  #{val} was expected but #{shown_rrm[:json][key]} was found."
    end
  end

  def test_update_reimbursement_reason_master
    old_reimbursement_reason_master = @api.create_reimbursement_reason_masters(@reimbursement_reason_master_1)
    options = {
      reason_name: "updating from API",
      memo: "updating memo from API",
      reimbursement_reason_taxes: "免税・簡易・本則/国内/1/3001/210"
    }
    updated_reimbursement_reason_master = @api.update_reimbursement_reason_masters(old_reimbursement_reason_master[:json][:id], options)

    assert_equal 200, updated_reimbursement_reason_master[:status].to_i, updated_reimbursement_reason_master.inspect
    assert_equal options[:reason_name], updated_reimbursement_reason_master[:json][:reason_name]
    assert_equal options[:memo], updated_reimbursement_reason_master[:json][:memo]
    assert_equal options[:reimbursement_reason_taxes], updated_reimbursement_reason_master[:json][:reimbursement_reason_taxes]
    assert_equal old_reimbursement_reason_master[:json][:reason_code], updated_reimbursement_reason_master[:json][:reason_code]
  end
end
