require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class BankReasonMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @bank_reason_master_1 = {
      sort_number: 1,
      reason_code: "create_from_API",
      reason_name: "New Bank Reason Created From API",
      dc: "d",
      is_valid: 0,
      memo: "This reason has been created form API",
      account_code: 1,
      bank_reason_taxes: "免税・簡易・本則/1/3001/210"
    }

    @bank_reason_master_2 = {
      sort_number: 1,
      reason_code: "create_from_API2",
      reason_name: "New Bank Reason Created From API2",
      dc: "c",
      is_valid: 0,
      memo: "This reason has been created form API2",
      account_code: 1,
      bank_reason_taxes: "免税・簡易・本則/1/3001/210"
    }

    @bank_reason_master_3 = {
      sort_number: 1,
      reason_code: "create_from_API3",
      reason_name: "New Bank Reason Created From API3",
      dc: "d",
      is_valid: 0,
      memo: "This reason has been created form API3",
      account_code: 1,
      bank_reason_taxes: "免税・簡易・本則/1/3001/210"
    }

    super("bank_reason_masters")
  end

  def test_list_bank_reason_masters
    created_bank_reason_master_1 = @api.create_bank_reason_masters(@bank_reason_master_1)
    created_bank_reason_master_2 = @api.create_bank_reason_masters(@bank_reason_master_2)
    created_bank_reason_master_3 = @api.create_bank_reason_masters(@bank_reason_master_3)

    assert_equal 200, created_bank_reason_master_1[:status].to_i
    assert_equal 200, created_bank_reason_master_2[:status].to_i
    assert_equal 200, created_bank_reason_master_3[:status].to_i

    created_master_id_1 = created_bank_reason_master_1[:json][:id]
    created_master_id_2 = created_bank_reason_master_2[:json][:id]
    created_master_id_3 = created_bank_reason_master_3[:json][:id]

    bank_reason_master_list = @api.list_bank_reason_masters
    assert_equal 200, bank_reason_master_list[:status].to_i, bank_reason_master_list.inspect
    assert(bank_reason_master_list[:json].any? { |x| x[:id] == created_master_id_1 })
    assert(bank_reason_master_list[:json].any? { |x| x[:id] == created_master_id_2 })
    assert(bank_reason_master_list[:json].any? { |x| x[:id] == created_master_id_3 })
  end

  def test_show_bank_reason_master
    created_bank_reason_master = @api.create_bank_reason_masters(@bank_reason_master_1)
    shown_bank_reason_master = @api.show_bank_reason_master(created_bank_reason_master[:json][:id])
    assert_equal @bank_reason_master_1[:sort_number], shown_bank_reason_master[:json][:sort_number]
    assert_equal @bank_reason_master_1[:reason_code], shown_bank_reason_master[:json][:reason_code]
    assert_equal @bank_reason_master_1[:reason_name], shown_bank_reason_master[:json][:reason_name]
  end

  def test_update_bank_reason_masters
    created_bank_reason_master = @api.create_bank_reason_masters(@bank_reason_master_1)
    assert_equal 200, created_bank_reason_master[:status].to_i

    updating_options = {
      id: created_bank_reason_master[:json][:id].to_i,
      sort_number: 2,
      reason_name: "updated reason name",
      memo: "This reason has been updated from API."
    }

    updated_bank_reason_master = @api.update_bank_reason_masters(updating_options)
    assert_equal 200, updated_bank_reason_master[:status].to_i
    assert_equal updating_options[:sort_number], updated_bank_reason_master[:json][:sort_number]
    assert_equal updating_options[:reason_name], updated_bank_reason_master[:json][:reason_name]
    assert_equal updating_options[:memo], updated_bank_reason_master[:json][:memo]

    assert_equal @bank_reason_master_1[:reason_code], updated_bank_reason_master[:json][:reason_code]
    assert_equal @bank_reason_master_1[:dc], updated_bank_reason_master[:json][:dc]
  end
end

