require 'minitest/autorun'
require 'time'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < Minitest::Test
  def setup

    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })

    # data
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

    @staff_data_1 = {
      code: 'QUALIFICATION',
      value: 'TOEIC',
      start_timestamp: '2016-01-01',
      no_finish_timestamp: '1',
      memo: 'First memo'
    }

    @tag_1 = {
      code: 'test_code',
      name: 'テストタグ',
      sort_no: 10_000,
      tag_group_code: 'DEFAULT',
      start_ymd: '2016-01-01',
      finish_ymd: '2016-12-31'
    }

    @journal_distribution_1 = {
      title: 'title',
      start_date: '2012-07-01',
      finish_date: '2012-07-31',
      account_codes: ['135~999','604'],
      dept_code: 'SETSURITSU',
      memo: '',
      criteria: 'dept',
      target_timestamp: '2017-02-01',
      distribution_conditions: { 'SETSURITSU' => '1', 'COMMON' => '1' }
    }

  end

  def test_failed_request
    @api_fail = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: 'fake token' })
    sale = @api_fail.create_sale(@sale_201608)

    assert_equal 401, sale[:status].to_i, sale.inspect
    assert_equal 'Bad credentials', sale[:json][:error]
  end

  def test_create_tag
    tag = @api.create_tag(@tag_1)
    assert_equal 200, tag[:status].to_i, tag.inspect
    assert_equal @tag_1[:code], tag[:json][:code]
  ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_create_journal_distribution
    options = { start_date: @journal_distribution_1[:target_timestamp], finish_date: @journal_distribution_1[:target_timestamp] }

    journals_list_before = @api.list_journals(options)
    records_before_count = journals_list_before[:json][:records].count
    assert_equal 200, journals_list_before[:status].to_i, journals_list_before.inspect

    journal_distribution = @api.create_journal_distribution(@journal_distribution_1)
    assert_equal 200, journal_distribution[:status].to_i, journal_distribution.inspect
    assert_equal Time.parse(@journal_distribution_1[:target_timestamp]), Time.parse(journal_distribution[:json][:target_ym])

    journals_list_after = @api.list_journals(options)
    records_after_count = journals_list_after[:json][:records].count
    assert_equal 200, journals_list_after[:status].to_i, journals_list_after.inspect
    assert(records_before_count != records_after_count)
  ensure
    @api.destroy_journal_distribution(journal_distribution[:json][:id]) if journal_distribution[:json][:id]
  end

  def test_update_tag
    tag = @api.create_tag(@tag_1)
    assert tag[:json][:id], tag
    options = {
      name: '更新タグ'
    }

    updated_tag = @api.update_tag(tag[:json][:id], options)
    assert_equal 200, updated_tag[:status].to_i, updated_tag.inspect
    assert_equal options[:name], updated_tag[:json][:name]
  ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_show_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    journals_list = @api.list_journals({ start_date: '2016-04-01', finish_date: '2016-04-30' })
    first_journal_id = journals_list[:json][:records].first[:id]

    journal = @api.show_journal(first_journal_id)
    assert_equal 200, journal[:status].to_i, journal.inspect
    assert_equal first_journal_id, journal[:json][:records][:id]
  ensure
    @api.destroy_manual_journal(manual_journal[:json].first[:id]) if successful?(manual_journal[:status])
  end


  def test_show_tag
    tag = @api.create_tag(@tag_1)
    tag = @api.show_tag(tag[:json][:id])

    assert_equal 200, tag[:status].to_i, tag.inspect
    assert_equal @tag_1[:name], tag[:json][:name]
  ensure
    @api.destroy_tag(tag[:json][:id])
  end

  def test_show_bonus
    bonuses = @api.list_bonuses(1, 2016)
    bonus_id = bonuses[:json].first[:id]
    bonus = @api.show_bonus(bonus_id)

    assert_equal 200, bonus[:status].to_i, bonus.inspect
    assert_equal bonus[:json][:id], bonus_id
  end

  def test_show_payroll
    payrolls_list = @api.list_payrolls(2017, 2)
    first_payroll_id = payrolls_list[:json].first[:id]

    payroll = @api.show_payroll(first_payroll_id)
    assert_equal 200, payroll[:status].to_i, payroll.inspect
    assert_equal first_payroll_id, payroll[:json][:id]
  end

  def test_show_tax_master
    tax_masters = @api.list_tax_masters
    first_tax_master = tax_masters[:json].first
    tax_master = @api.show_tax_master(first_tax_master[:id])

    assert_equal 200, tax_master[:status].to_i, tax_master.inspect
    assert_equal first_tax_master[:name], tax_master[:json][:name]
  end

  def test_show_corporate_master
    # With HatagayaTest CorporateMaster ID Only
    shown_corporate_master = @api.show_corporate_master(2099)
    assert_equal 90020, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷システム株式会社（開発テスト）', shown_corporate_master[:json][:name]

    # With HatagayaTest Corporate Code Only
    shown_corporate_master = @api.show_corporate_master(nil, { ccode: 90020 })
    assert_equal 90020, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷システム株式会社（開発テスト）', shown_corporate_master[:json][:name]

    # With HatagayaTest Both CorporateMaster ID and Corporate Code
    shown_corporate_master = @api.show_corporate_master(2099, { ccode: 90020 })
    assert_equal 90020, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷システム株式会社（開発テスト）', shown_corporate_master[:json][:name]
  end

  def test_list_sales_and_account_balances
    realization_timestamp = Time.parse(@sale_201702[:realization_timestamp])

    # Without customer_master_code and ar_segment option parameters
    balance_list_before = @api.list_sales_and_account_balances(realization_timestamp.year, realization_timestamp.month)
    assert_equal 200, balance_list_before[:status].to_i, balance_list_before.inspect

    new_sale = @api.create_sale(@sale_201702)
    assert_equal 200, new_sale[:status].to_i, new_sale.inspect
    assert(new_sale[:json].count > 0)

    balance_list_after = @api.list_sales_and_account_balances(realization_timestamp.year, realization_timestamp.month)
    assert_equal 200, balance_list_after[:status].to_i, balance_list_after.inspect
    assert(balance_list_after[:json].count > 0)
    assert(balance_list_after[:json] != balance_list_before[:json])

    customer_masters_list = @api.list_customers
    assert_equal 200, customer_masters_list[:status].to_i, customer_masters_list.inspect
    assert(customer_masters_list[:json].any? { |x| x[:code] == new_sale[:json][:customer_master_code] })
    filtered_cm = customer_masters_list[:json].select { |x| x[:code] == new_sale[:json][:customer_master_code] }.first

    # With customer_master_id and ar_segment option parameters
    balance_list = @api.list_sales_and_account_balances(realization_timestamp.year,
                                                        realization_timestamp.month,
                                                        :customer_master_id => filtered_cm[:id],
                                                        :ar_segment => filtered_cm[:used_in_ar])

    assert_equal 200, balance_list[:status].to_i, balance_list.inspect
    assert(balance_list[:json].count > 0)
    assert(balance_list[:json].all? { |x| x[:customer_master_code] == filtered_cm[:code] && x[:ar_segment] == filtered_cm[:used_in_ar] })
  ensure
    @api.destroy_sale("AR#{new_sale[:json][:id]}") if new_sale[:json][:id]
  end

  def test_list_purchases_and_account_balances
    accrual_timestamp = Time.parse(@purchase_201702[:accrual_timestamp])

    # Without customer_master_id and ap_segment option parameters
    balance_list_before = @api.list_purchases_and_account_balances(accrual_timestamp.year, accrual_timestamp.month)
    assert_equal 200, balance_list_before[:status].to_i, balance_list_before.inspect

    new_purchase = @api.create_purchase(@purchase_201702)
    assert_equal 200, new_purchase[:status].to_i, new_purchase.inspect
    assert(new_purchase[:json].count > 0)

    balance_list_after = @api.list_purchases_and_account_balances(accrual_timestamp.year, accrual_timestamp.month)
    assert_equal 200, balance_list_after[:status].to_i, balance_list_after.inspect
    assert(balance_list_after[:json].count > 0)
    assert(balance_list_after[:json] != balance_list_before[:json])

    customer_masters_list = @api.list_customers
    assert_equal 200, customer_masters_list[:status].to_i, customer_masters_list.inspect
    assert(customer_masters_list[:json].any? { |x| x[:code] == new_purchase[:json][:customer_master_code] })
    filtered_customer_master = customer_masters_list[:json].select { |x| x[:code] == new_purchase[:json][:customer_master_code] }.first
    customer_master_id = filtered_customer_master[:id]
    ap_segment = filtered_customer_master[:used_in_ap]

    # With customer_master_id and ap_segment option parameters
    balance_list = @api.list_purchases_and_account_balances(accrual_timestamp.year,
                                                            accrual_timestamp.month,
                                                            :customer_master_id => customer_master_id,
                                                            :ap_segment => ap_segment)

    assert_equal 200, balance_list[:status].to_i, balance_list.inspect
    assert(balance_list[:json].count > 0)
    assert(balance_list[:json].all? { |x| x[:customer_master_id] == customer_master_id && x[:ap_segment] == ap_segment })
  ensure
    @api.destroy_purchase("AP#{new_purchase[:json][:id]}") if new_purchase[:json][:id]
  end

  def test_list_journals
    august_sale = @api.create_sale(@sale_201608)
    september_sale = @api.create_sale(@sale_201609)
    august_purchase = @api.create_purchase(@purchase_201608)
    september_purchase = @api.create_purchase(@purchase_201609)
    assert_equal 200, august_sale[:status].to_i
    assert_equal 200, september_sale[:status].to_i
    assert_equal 200, august_purchase[:status].to_i
    assert_equal 200, september_purchase[:status].to_i

    options = { start_date: '2016-08-01', finish_date: '2016-08-31' }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_timestamps = records.map { |x| Time.parse(x[:journal_timestamp]) }
    assert_includes record_timestamps, Time.parse(august_sale[:json][:realization_timestamp])
    assert_includes record_timestamps, Time.parse(august_purchase[:json][:accrual_timestamp])

    options = { price: 10_800 }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_prices = records.map { |x| x[:journal_dcs].map { |y| y[:debit][:price_including_tax] } }.flatten(1)
    assert_includes record_prices, august_sale[:json][:price_including_tax]
    assert_includes record_prices, september_sale[:json][:price_including_tax]

    options = { dept_code: 'SETSURITSU' }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_depts = records.map { |x| x[:journal_dcs].map { |y| y[:dept_code] } }.flatten(1)
    assert_includes record_depts, august_sale[:json][:dept_code]
    assert_includes record_depts, september_sale[:json][:dept_code]
    assert_includes record_depts, august_purchase[:json][:dept_code]
    assert_includes record_depts, september_purchase[:json][:dept_code]
  ensure
    @api.destroy_sale("AR#{august_sale[:json][:id]}") if august_sale[:json][:id]
    @api.destroy_sale("AR#{september_sale[:json][:id]}") if september_sale[:json][:id]
    @api.destroy_purchase("AP#{august_purchase[:json][:id]}") if august_purchase[:json][:id]
    @api.destroy_purchase("AP#{september_purchase[:json][:id]}") if september_purchase[:json][:id]
  end


  def test_list_tax_masters
    tax_masters = @api.list_tax_masters
    assert_equal 200, tax_masters[:status].to_i, tax_masters.inspect
    assert !tax_masters[:json].empty?
  end

  def test_list_tags
    tag = @api.create_tag(@tag_1)

    tags = @api.list_tags
    assert_equal 200, tags[:status].to_i, tags.inspect
    assert(tags[:json][@tag_1[:tag_group_code].to_sym].any? { |x| x[:id] == tag[:json][:id] })
  ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_list_bonuses
    bonuses_list = @api.list_bonuses(1, 2016)
    assert_equal 200, bonuses_list[:status].to_i, bonuses_list.inspect
    assert bonuses_list[:json]
    assert !bonuses_list[:json].empty?
  end

  def test_list_payrolls
    payrolls_list = @api.list_payrolls(2016, 2)

    assert_equal 200, payrolls_list[:status].to_i, payrolls_list.inspect
    assert !payrolls_list.empty?
  end

  def test_list_fixed_assets
    list = @api.list_fixed_assets
    assert_equal 200, list[:status].to_i, list.inspect
    assert list[:json]
    assert !list[:json].empty?
  end

  def test_calc_scheduled_dates
    response = @api.scheduled_date('2019-01-02', '1m10', '5', 'before')
    assert_equal '200', response[:status]
    assert_equal '2019-01-10', response[:json][:scheduled_date]
  end

  private

  def successful?(status)
    status.to_i == 200
  end
end
