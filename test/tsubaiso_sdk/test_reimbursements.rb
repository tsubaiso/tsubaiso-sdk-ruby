require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ReimbursementsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @reimbursement_1 = {
      applicant: 'Irfan',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa'
    }

    @reimbursement_2 = {
      applicant: 'Matsuno',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa'
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
    request_body = {
      applicant: 'Matsuno',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa',
      pay_date: '2020-1-13',
      applicant_staff_code: 'test_applicant_code',
      transactions: [
        {
          transaction_timestamp: '2020-1-1',
          price_value: 1000,
          reason_code: 'SUPPLIES'
        }
      ]
    }

    reimbursement = @api.create_reimbursement(request)
    assert_equal 200, reimbursement[:status].to_i, reimbursement.inspect
    assert_equal request_body[:applicant], reimbursement[:json][:applicant]
    assert_equal request_body[:pay_date], reimbursement[:json][:pay_date]
    assert_equal request_body[:applicant_staff_code], reimbursement[:json][:applicant_staff_code]

    reimbursement_transactions = @api.list_reimbursement_transactions(reimbursement[:json][:id])
    assert_equal 200, reimbursement_transactions[:status].to_i, reimbursement_transactions.inspect
    assert_equal 1, reimbursement_transactions[:json].size
  end
end
