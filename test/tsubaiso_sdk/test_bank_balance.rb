require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class BankBalanceTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("bank_balances")
  end

  def test_index_bank_balance
    # 返却されるbank_balancesの数を求めるため、対象のbank_account_mastersを数える
    # bank_account_masters = @api.list_bank_account_masters
    # target_bam_count = 0
    # bank_account_masters.each do |bam|
    #   target_bam_count += 1 if (bam.start_ymd <= Date.new(2023, 5, 1)) && (bam.finish_ymd.blank? || bam.finish_ymd >= Date.new(2024, 2, 1))
    # end

    options = {
      start_y: 2023,
      start_m: 5,
      finish_y: 2023,
      finish_m: 6
    }

    bank_balances = @api.index_bank_balances(options)
    assert_equal 200, bank_balances[:status].to_i, bank_balances.inspect
    # assert_equal target_bam_count * 10, bank_balances.size # 10ヶ月分
  end
end
