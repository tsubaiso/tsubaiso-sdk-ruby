require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ReimbursementsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    txhash = {}
    txhash[:transaction_timestamp] = '2016-03-01'
    txhash[:price_value] = 20000
    txhash[:reason_code] = 'CONFERENCE_EXPENSES_SGA'
    txhash[:dc] = 'd'
    txhash[:brief] = '会議費'
    txhash[:memo] = 'memo'
    txhash[:tax_type] = '租税公課'

    @reimbursement_1 = {
      applicant: 'Irfan',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa',
      dept_code: 'SETSURITSU',
      applicant_staff_code: 'EP2001',
      pay_date: '2016-02-01'
    }

    @reimbursement_2 = {
      applicant: 'Matsuno',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa',
      dept_code: 'SETSURITSU',
      applicant_staff_code: 'EP2001',
      pay_date: '2016-02-01'
    }

    @reimbursement_3 = {
      applicant: 'Matsuno',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa',
      dept_code: 'SETSURITSU',
      applicant_staff_code: 'EP2001',
      pay_date: '2016-02-01',
      transactions: txhash
    }
    super("reimbursements")
  end

  def test_list_reimbursements
    reimbursement_a = @api.create_reimbursement(@reimbursement_1)
    reimbursement_b = @api.create_reimbursement(@reimbursement_2)

    reimbursement_a_id = reimbursement_a[:json][:id]
    reimbursement_b_id = reimbursement_b[:json][:id]

    reimbursements_list = @api.list_reimbursements(2016, 3)
    assert_equal 200, reimbursements_list[:status].to_i, reimbursements_list.inspect
    assert(reimbursements_list[:json].any? { |x| x[:id] == reimbursement_a_id })
    assert(reimbursements_list[:json].any? { |x| x[:id] == reimbursement_b_id })
  end

  def test_show_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    reimbursement = @api.show_reimbursement(reimbursement[:json][:id])

    assert_equal 200, reimbursement[:status].to_i, reimbursement.inspect
    assert_equal @reimbursement_1[:applicant], reimbursement[:json][:applicant]
  end

  def test_update_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = {
      applicant: 'test',
      dept_code: 'COMMON'
    }
    updated_reimbursement = @api.update_reimbursement(reimbursement[:json][:id], options)
    assert_equal 200, updated_reimbursement[:status].to_i, updated_reimbursement.inspect
    assert_equal options[:applicant], updated_reimbursement[:json][:applicant]
    assert_equal options[:dept_code], updated_reimbursement[:json][:dept_code]
  end

  def test_create_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    assert_equal 200, reimbursement[:status].to_i, reimbursement.inspect
    assert_equal @reimbursement_1[:applicant], reimbursement[:json][:applicant]
  end

  def test_create_reimbursement_and_transactions
    reimbursement = @api.create_reimbursement(@reimbursement_3)
    assert_equal 200, reimbursement[:status].to_i, reimbursement.inspect
    assert_equal @reimbursement_3[:applicant], reimbursement[:json][:applicant]
    assert_equal @reimbursement_3[:pay_date], reimbursement[:json][:pay_date]

  end
end
