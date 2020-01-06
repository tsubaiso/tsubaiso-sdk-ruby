require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class ReimbursementsTransactionsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @reimbursement_tx_1 = {
      transaction_timestamp: '2016-03-01',
      price_value: 10_000,
      dc: 'c',
      tax_type: 'tax',
      reason_code: 'SUPPLIES',
      brief: 'everyting going well',
      memo: 'easy',
      data_partner: { link_url: 'www.example.com/5', id_code: '5' }
    }

    @reimbursement_tx_2 = {
      transaction_timestamp: '2016-03-01',
      price_value: 20_000,
      dc: 'c',
      tax_type: 'tax',
      reason_code: 'SUPPLIES',
      brief: 'not well',
      memo: 'hard',
      data_partner: { link_url: 'www.example.com/6', id_code: '6' }
    }

    super("reimbursement_transactions")
  end

  def test_create_reimbursement_transaction
    options = @reimbursement_tx_1.merge({ :reimbursement_id => 300 })
    reimbursement_transaction = @api.create_reimbursement_transaction(options)
    assert_equal 200, reimbursement_transaction[:status].to_i, reimbursement_transaction.inspect
    assert_equal @reimbursement_tx_1[:price_value], reimbursement_transaction[:json][:price_value]
    assert_equal @reimbursement_tx_1[:data_partner][:id_code], reimbursement_transaction[:json][:data_partner][:id_code]
  end

  def test_update_reimbursement_transaction
    options = @reimbursement_tx_1.merge({ :reimbursement_id => 300 })
    reimbursement_transaction = @api.create_reimbursement_transaction(options)
    updates = { :id => reimbursement_transaction[:json][:id], :price_value => 9999, :reason_code => 'SUPPLIES', :data_partner => { :id_code => '500' } }

    updated_reimbursement_transaction = @api.update_reimbursement_transaction(updates)
    assert_equal 200, updated_reimbursement_transaction[:status].to_i, updated_reimbursement_transaction.inspect
    assert_equal updates[:id].to_i, updated_reimbursement_transaction[:json][:id].to_i
    assert_equal updates[:price_value].to_i, updated_reimbursement_transaction[:json][:price_value].to_i
    assert_equal updates[:reason_code], updated_reimbursement_transaction[:json][:reason_code]
    assert_equal updates[:data_partner][:id_code], updated_reimbursement_transaction[:json][:data_partner][:id_code]
  end

  def test_list_reimbursement_transactions
    options = { :reimbursement_id => 300 }
    reimbursement_transaction_1 = @api.create_reimbursement_transaction(@reimbursement_tx_1.merge(options))
    reimbursement_transaction_2 = @api.create_reimbursement_transaction(@reimbursement_tx_2.merge(options))

    reimbursement_transactions = @api.list_reimbursement_transactions(300)
    assert_equal 200, reimbursement_transactions[:status].to_i, reimbursement_transactions.inspect
    assert(reimbursement_transactions[:json].any? { |x| x[:id] == reimbursement_transaction_1[:json][:id] })
    assert(reimbursement_transactions[:json].any? { |x| x[:id] == reimbursement_transaction_2[:json][:id] })
  end

  def test_show_reimbursement_transaction
    options = { :reimbursement_id => 300 }
    reimbursement_transaction = @api.create_reimbursement_transaction(@reimbursement_tx_1.merge(options))
    reimbursement_transaction = @api.show_reimbursement_transaction(reimbursement_transaction[:json][:id])

    assert_equal 200, reimbursement_transaction[:status].to_i, reimbursement_transaction.inspect
    assert_equal options[:reimbursement_id], reimbursement_transaction[:json][:reimbursement_id]
  end


end
