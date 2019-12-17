require 'minitest/autorun'
require 'time'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < Minitest::Test
  def setup

    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })

    # data
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

    @manual_journal_1 = {
      journal_timestamp: '2016-04-01',
      journal_dcs: [
        {
          debit: {
            account_code: '110',
            price_including_tax: 200_000,
            tax_type: 0
          },
          credit: {
            account_code: '100',
            price_including_tax: 200_000,
            tax_type: 0
          }#,
          # tag_list: 'KIWI',
          # dept_code: 'SYSTEM'
        },
        {
          debit: {
            account_code: '1',
            price_including_tax: 54_321,
            tax_type: 0
          },
          credit: {
            account_code: '110',
            price_including_tax: 54_321,
            tax_type: 0
          },
          memo: 'Created From API'#,
         # dept_code: 'R_AND_D'
        }
      ],
      data_partner: { link_url: 'www.example.com/7', id_code: '7' }
    }

    @sale_201912 = {
      price_including_tax: 10_800,
      realization_timestamp: '2019-12-17',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2019-12-18',
      data_partner: { link_url: 'www.example.com/1', id_code: '1', partner_code: 'Example' }
    }

    @sale_201911 = {
      price_including_tax: 10_800,
      realization_timestamp: '2019-12-17',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2016-11-25',
      data_partner: { link_url: 'www.example.com/2', id_code: '2' }
    }

    @purchase_201912 = {
      price_including_tax: 5400,
      year: 2019,
      month: 12,
      accrual_timestamp: '2019-12-04',
      customer_master_code: '102',
      dept_code: 'SETSURITSU',
      reason_master_code: 'BUYING_IN',
      dc: 'c',
      memo: '',
      tax_code: 1007,
      port_type: 1,
      data_partner: { link_url: 'www.example.com/3', id_code: '3', partner_code: 'Example' }
    }

    @purchase_201911 = {
      price_including_tax: 5400,
      year: 2019,
      month: 11,
      accrual_timestamp: '2019-11-01',
      customer_master_code: '102',
      dept_code: 'HEAD',
      reason_master_code: 'BUYING_IN',
      dc: 'c',
      memo: '',
      tax_code: 1007,
      port_type: 1,
      data_partner: { link_url: 'www.example.com/4', id_code: '4' }
    }


  end

  def test_failed_request
    @api_fail = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: 'fake token' })
    sale = @api_fail.create_sale(@sale_201608)

    assert_equal 401, sale[:status].to_i, sale.inspect
    assert_equal 'Bad credentials', sale[:json][:error]
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

  def test_list_sales_and_account_balances
    realization_timestamp = Time.parse(@sale_201912[:realization_timestamp])

    # Without customer_master_code and ar_segment option parameters
    balance_list_before = @api.list_sales_and_account_balances(realization_timestamp.year, realization_timestamp.month)
    assert_equal 200, balance_list_before[:status].to_i, balance_list_before.inspect

    new_sale = @api.create_sale(@sale_201912)
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
