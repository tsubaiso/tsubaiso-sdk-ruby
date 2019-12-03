require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class ReimbursementReasonMasterTest < Minitest::Test
  include CommonSetupTeardown

  def setup
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

end
