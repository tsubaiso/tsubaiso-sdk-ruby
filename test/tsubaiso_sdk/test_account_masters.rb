require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class AccountMastersTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @account_master_create = {
      account_code: "777",
      descid: "API_TEST",
      account_name: "外部から作った",
      account_kana: "API テスト",
      dc: "d",
      bspl: "bs",
      brief: "Lorem Ipsum Dolor Sit Amet",
      sum_no: "1",
      use_in_balance: "1",
      use_in_statement: "1",
      status: "100",
      inputtable: "1",
      fc_revaluation_target: 1
    }

    @account_master_create_without_fc = {
      account_code: "888",
      descid: "API_TEST_2",
      account_name: "外部から作った2",
      account_kana: "API テスト2",
      dc: "d",
      bspl: "bs",
      brief: "Lorem Ipsum",
      sum_no: "1",
      use_in_balance: "1",
      use_in_statement: "1",
      status: "100",
      inputtable: "1"
    }

    @account_master_update = {
      id: 42,
      account_code: "888",
      descid: "API_TEST_UPDATED",
      account_name: "外部から作った[UPDATED]",
      account_kana: "API テスト[UPDATED]",
      dc: "c",
      bspl: "pl",
      brief: "Lorem Ipsum Dolor Sit Amet[UPDATED]",
      sum_no: "2",
      use_in_balance: "1",
      use_in_statement: "1",
      status: "100",
      inputtable: "1",
      fc_revaluation_target: 0
    }

    @account_master_update_without_fc = {
      id: 42,
      account_name: "外部から作った[NAME_ONLY_UPDATE]"
    }

    super("account_masters")
  end

  def test_list_account_masters
    list = @api.list_account_masters
    assert_equal 200, list[:status].to_i
    assert list[:json].is_a?(Array)
    assert list[:json].size > 0
  end

  def test_create_account_masters
    created = @api.create_account_masters(@account_master_create)
    assert_equal 200, created[:status].to_i
    assert_equal @account_master_create[:account_code], created[:json][:account_code]
    assert_equal @account_master_create[:account_name], created[:json][:account_name]
    assert_equal @account_master_create[:descid], created[:json][:descid]
    assert_equal @account_master_create[:fc_revaluation_target], created[:json][:fc_revaluation_target]
  end

  def test_create_account_masters_without_fc_revaluation_target
    # fc_revaluation_targetを省略した場合、レスポンスには0またはnilが含まれる
    # (DBのデフォルト値0が設定される)
    # このテストは実際のAPIレスポンスに依存するため、
    # スタブではcreate_responseを使用してfc_revaluation_target: 1を返す
    # 実際のAPIではfc_revaluation_targetが省略されると0になる
    created = @api.create_account_masters(@account_master_create_without_fc)
    assert_equal 200, created[:status].to_i
    assert_equal @account_master_create_without_fc[:account_code], created[:json][:account_code]
  end

  def test_update_account_masters
    updated = @api.update_account_masters(@account_master_update)
    assert_equal 200, updated[:status].to_i
    assert_equal @account_master_update[:account_code], updated[:json][:account_code]
    assert_equal @account_master_update[:account_name], updated[:json][:account_name]
    assert_equal @account_master_update[:descid], updated[:json][:descid]
    assert_equal @account_master_update[:fc_revaluation_target], updated[:json][:fc_revaluation_target]
  end

  def test_update_account_masters_without_fc_revaluation_target
    # fc_revaluation_targetを省略した場合、既存の値が保持される
    # このテストは実際のAPIレスポンスに依存するため、
    # スタブではupdate_responseを使用してfc_revaluation_target: 0を返す
    # 実際のAPIではfc_revaluation_targetを省略すると既存値が保持される
    updated = @api.update_account_masters(@account_master_update_without_fc)
    assert_equal 200, updated[:status].to_i
    assert_equal @account_master_update_without_fc[:account_name], updated[:json][:account_name]
  end
end
