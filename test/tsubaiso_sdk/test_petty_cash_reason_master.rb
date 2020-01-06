require 'minitest/autorun'
require_relative 'common_setup_and_teardown'

class PettyCashReasonMaster < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @petty_cash_reason_master_1 = {
      reason_code: 'sdk_test_create',
      reason_name: 'SDK before update',
      dc: 'd',
      account_code: '100',
      is_valid: '0',
      memo: 'this is test before update',
      port_type: '0',
      sort_number: '0'
    }

    @petty_cash_reason_master_2 = {
      reason_code: "sdk_test_create2",
      reason_name: "TEST_REASON",
      dc: "d",
      account_code: "999",
      is_valid: "0",
      memo: "This is Test reason.",
      port_type: "0",
      sort_number: "0"
    }
    super("petty_cash_reason_masters")
  end

  def test_create_petty_cash_reason_master
    created_pcrm = @api.create_petty_cash_reason_master(@petty_cash_reason_master_1)
    assert_equal 200, created_pcrm[:status].to_i, created_pcrm.inspect
    assert_equal @petty_cash_reason_master_1[:reason_code], created_pcrm[:json][:reason_code]

    shown_prcm = @api.show_petty_cash_reason_master(created_pcrm[:json][:id].to_i)
    assert_equal 200, created_pcrm[:status].to_i, created_pcrm.inspect
    @petty_cash_reason_master_1.each_pair do |key,val|
      assert_equal val, shown_prcm[:json][key], "col :#{key},  #{val} was expected but #{shown_prcm[:json][key]} was found."
    end
  end

  def test_update_petty_cash_reason_master
    old_petty_cash_reason_master = @api.create_petty_cash_reason_master(@petty_cash_reason_master_1)
    options = {
      reason_name: 'updating from API',
      memo: 'updating memo from API'
    }
    updated_petty_cash_reason_master = @api.update_petty_cash_reason_master(old_petty_cash_reason_master[:json][:id], options)

    assert_equal 200, updated_petty_cash_reason_master[:status].to_i, updated_petty_cash_reason_master.inspect
    assert_equal options[:reason_name], updated_petty_cash_reason_master[:json][:reason_name]
    assert_equal options[:memo], updated_petty_cash_reason_master[:json][:memo]
    assert_equal old_petty_cash_reason_master[:json][:reason_code], updated_petty_cash_reason_master[:json][:reason_code]
  end

  def test_list_petty_cash_reason_masters
    listed_pcrms = @api.list_petty_cash_reason_masters
    assert_equal listed_pcrms[:json].size, 2
    pcrm1 = listed_pcrms[:json].find{|record| record[:reason_code] == "sdk_test_create"}
    @petty_cash_reason_master_1.each_pair do |key, val|
      assert_equal val, pcrm1[key], "col :#{key},  #{val} was expected but #{pcrm1[key]} was found."
    end

    pcrm2 = listed_pcrms[:json].find{|record| record[:reason_code] == "sdk_test_create2"}
    @petty_cash_reason_master_2.each_pair do |key, val|
      assert_equal val, pcrm2[key], "col :#{key},  #{val} was expected but #{pcrm2[key]} was found."
    end
  end
end

