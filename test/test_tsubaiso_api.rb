require 'minitest/autorun'
require 'time'
require './lib/tsubaiso_api'

class TsubaisoAPITest < Minitest::Test
  def setup
    @api = TsubaisoAPI.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })

    @customer_1000 = {
      name: 'テスト株式会社',
      name_kana: 'テストカブシキガイシャ',
      code: '10000',
      tax_type_for_remittance_charge: '3',
      used_in_ar: 1,
      used_in_ap: 1,
      is_valid: 1
    }

    @sale_201608 = {
      price_including_tax: 10_800,
      realization_timestamp: '2016-08-01',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: 'irfan test',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2016-09-25',
      data_partner: { link_url: 'www.example.com/1', id_code: '1' }
    }

    @sale_201702 = {
      price_including_tax: 10_800,
      realization_timestamp: '2017-02-28',
      customer_master_code: '105',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 18,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2017-03-25',
      data_partner: { link_url: 'www.example.com/8', id_code: '8' }
    }

    @reimbursement_1 = {
      applicant: 'Matsuno',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa'
    }

    @reimbursement_tx_1 = {
      transaction_timestamp: '2016-03-01',
      price_value: 10_000,
      dc: 'c',
      reason_code: 'SUPPLIES',
      brief: 'everyting going well',
      memo: 'easy',
      data_partner: { link_url: 'www.example.com/5', id_code: '5' }
    }
  end

  def test_list
    cm = @api.create('customer_masters', @customer_1000)
    assert_equal 200, cm[:status].to_i
    assert @customer_1000[:code], cm[:json]['code']

    list_customers = @api.list('customer_masters')
    assert_equal 200, list_customers[:status].to_i

    assert(list_customers[:json]&.any? { |x| x['code'] == @customer_1000[:code] })
  ensure
    @api.destroy('customer_masters', id: cm[:json]['id']) if cm[:json]['id']
  end

  def test_show
    ar = @api.create('ar_receipts', @sale_201608)
    assert 200, ar[:status].to_i
    assert @sale_201608[:customer_master_code], ar[:json]['customer_master_code']

    show_ar = @api.show('ar_receipts', id: ar[:json]['id'])
    assert successful?(show_ar[:status])
    assert_equal show_ar[:json], ar[:json]
  ensure
    @api.destroy('ar_receipts', id: ar[:json]['id']) if ar[:json]['id']
  end

  def test_create_and_destroy
    ar = @api.create('ar_receipts', @sale_201608)
    assert successful?(ar[:status])
    assert @sale_201608[:customer_master_code], ar[:json]['customer_master_code']

    cm = @api.create('customer_masters', @customer_1000)
    assert successful?(cm[:status])
    assert @customer_1000[:code], cm[:json]['code']

    reim = @api.create('reimbursements', @reimbursement_1)
    assert successful?(reim[:status])
    assert @reimbursement_1[:staff_code], reim[:json]['staff_code']

    reim_tx = @api.create('reimbursement_transactions', @reimbursement_tx_1)
    assert successful?(reim[:status])
    assert @reimbursement_tx_1[:reason_code], reim_tx[:json]['reason_code']
  ensure
    @api.destroy('ar_receipts', id: ar[:json]['id']) if ar[:json]['id']
    @api.destroy('customer_masters', id: cm[:json]['id']) if cm[:json]['id']
    @api.destroy('reimbursements', id: reim[:json]['id']) if reim[:json]['id']
    @api.destroy('reimbursement_transactions', id: reim_tx[:json]['id']) if reim_tx[:json]['id']
  end

  def test_get_and_post
    time = Time.mktime(@sale_201702[:realization_timestamp])
    balance_before = @api.get('ar_receipts/balance', { year: time.year, month: time.month })
    assert successful?(balance_before[:status])
    assert balance_before[:json].count > 0

    ar1 = @api.post('ar_receipts/create', @sale_201702)
    assert successful?(ar1[:status])
    assert_equal @sale_201702[:scheduled_memo], ar1[:json]['scheduled_memo']

    cm = @api.post('customer_masters/create', @customer_1000)
    assert successful?(cm[:status])
    assert_equal @customer_1000[:code], cm[:json]['code']

    balance_after = @api.get('ar_receipts/balance', { year: time.year, month: time.month })
    assert successful?(balance_after[:status])
    assert balance_after[:json].count > 0
  ensure
    @api.destroy('ar_receipts', id: ar1[:json]['id']) if ar1[:json]['id']
    @api.destroy('customer_masters', id: cm[:json]['id']) if cm[:json]['id']
  end

  def test_update
    cm = @api.create('customer_masters', @customer_1000)
    cm_updated = @api.update('customer_masters', { id: cm[:json]['id'], name: 'TEST_NEW_UPDATED' })
    assert successful?(cm_updated[:status])
    assert cm_updated[:json]['name'] == 'TEST_NEW_UPDATED'
    assert cm_updated[:json]['id'] == cm[:json]['id']
  ensure
    @api.destroy('customer_masters', id: cm[:json]['id']) if cm[:json]['id']
  end

  private

  def successful?(status)
    status.to_i == 200
  end
end
