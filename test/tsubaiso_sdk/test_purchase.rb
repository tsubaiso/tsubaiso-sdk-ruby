require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class PurchaseTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    @purchase_201608 = {
      price_including_tax: 5400,
      year: 2016,
      month: 8,
      accrual_timestamp: '2016-08-01',
      customer_master_code: '102',
      dept_code: 'SETSURITSU',
      reason_master_code: 'BUYING_IN',
      dc: 'c',
      memo: '',
      tax_code: 1007,
      port_type: 1,
      data_partner: { link_url: 'www.example.com/3', id_code: '3', partner_code: 'Example' }
    }

    @purchase_201609 = {
      price_including_tax: 5400,
      year: 2016,
      month: 9,
      accrual_timestamp: '2016-09-01',
      customer_master_code: '102',
      dept_code: 'SETSURITSU',
      reason_master_code: 'BUYING_IN',
      dc: 'c',
      memo: '',
      tax_code: 1007,
      port_type: 1,
      data_partner: { link_url: 'www.example.com/4', id_code: '4' }
    }

    @purchase_201702 = {
      price_including_tax: 5400,
      year: 2017,
      month: 2,
      accrual_timestamp: '2017-02-28',
      customer_master_code: '105',
      reason_master_code: 'BUYING_IN',
      dc: 'c',
      memo: '',
      tax_code: 18,
      port_type: 1,
      data_partner: { link_url: 'www.example.com/9', id_code: '9' }
    }
    super("ap_payments")
  end

  def test_create_purchase
    purchase = @api.create_purchase(@purchase_201608)
    assert_equal 200, purchase[:status].to_i, purchase.inspect
    assert_equal @purchase_201608[:dept_code], purchase[:json][:dept_code]
    assert_equal @purchase_201608[:data_partner][:id_code], purchase[:json][:data_partner][:id_code]
    assert_equal @purchase_201608[:data_partner][:partner_code], purchase[:json][:data_partner][:partner_code]
  end

  def test_find_or_create_purchase
    key_options = { key:
                      { id_code: @purchase_201608[:data_partner][:id_code],
                        partner_code: @purchase_201608[:data_partner][:partner_code] } }
    purchase1 = @api.find_or_create_purchase(@purchase_201608.merge(key_options))

    assert_equal 200, purchase1[:status].to_i, purchase1.inspect
    assert_equal @purchase_201608[:dept_code], purchase1[:json][:dept_code]
    assert_equal @purchase_201608[:data_partner][:id_code], purchase1[:json][:data_partner][:id_code]
    assert_equal @purchase_201608[:data_partner][:partner_code], purchase1[:json][:data_partner][:partner_code]

    purchase2 = @api.find_or_create_purchase(@purchase_201608.merge(key_options))
    assert_equal 200, purchase2[:status].to_i, purchase2.inspect
    assert_equal purchase2[:json][:id], purchase1[:json][:id]
    assert_equal purchase2[:json][:data_partner][:id_code], purchase1[:json][:data_partner][:id_code]
  end

  def test_update_purchase
    purchase = @api.create_purchase(@purchase_201702)
    assert purchase[:json][:id], purchase
    options = {
      id: purchase[:json][:id].to_i,
      price_including_tax: 50_000,
      memo: 'Updated memo',
      data_partner: { id_code: '300' }
    }

    updated_purchase = @api.update_purchase(options)
    assert_equal 200, updated_purchase[:status].to_i, updated_purchase.inspect
    assert_equal options[:id], updated_purchase[:json][:id]
    assert_equal options[:memo], updated_purchase[:json][:memo]
    assert_equal options[:price_including_tax], updated_purchase[:json][:price_including_tax]
    assert_equal options[:data_partner][:id_code], updated_purchase[:json][:data_partner][:id_code]
  end

  def test_show_purchase
    purchase = @api.create_purchase(@purchase_201608)

    get_purchase = @api.show_purchase("AP#{purchase[:json][:id]}")
    assert_equal 200, get_purchase[:status].to_i, get_purchase.inspect
    assert_equal purchase[:json][:id], get_purchase[:json][:id]
  end

  def test_list_purchases
    feb_purchase = @api.create_purchase(@purchase_201702)
    august_purchase = @api.create_purchase(@purchase_201608)
    september_purchase = @api.create_purchase(@purchase_201609)

    feb_purchase_id = feb_purchase[:json][:id]
    august_purchase_id = august_purchase[:json][:id]
    september_purchase_id = september_purchase[:json][:id]

    purchase_list = @api.list_purchases(2016, 8)
    assert_equal 200, purchase_list[:status].to_i, purchase_list.inspect
    assert(purchase_list[:json].none? { |x| x[:id] == feb_purchase_id })
    assert(purchase_list[:json].any? { |x| x[:id] == august_purchase_id })
    assert(purchase_list[:json].none? { |x| x[:id] == september_purchase_id })
  end

end