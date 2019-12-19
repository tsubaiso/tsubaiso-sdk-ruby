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
