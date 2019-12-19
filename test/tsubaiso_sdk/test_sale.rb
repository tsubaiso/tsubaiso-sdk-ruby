require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class SaleTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    @sale_201608 = {
      price_including_tax: 10_800,
      realization_timestamp: '2016-08-01',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2016-09-25',
      data_partner: { link_url: 'www.example.com/1', id_code: '1', partner_code: 'Example' }
    }

    @sale_201609 = {
      price_including_tax: 10_800,
      realization_timestamp: '2016-09-01',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2016-09-25',
      data_partner: { link_url: 'www.example.com/2', id_code: '2' }
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
    super("ar")
  end

  def test_create_sale
    sale = @api.create_sale(@sale_201608)

    assert_equal 200, sale[:status].to_i, sale.inspect
    assert_equal @sale_201608[:dept_code], sale[:json][:dept_code]
    assert_equal @sale_201608[:data_partner][:id_code], sale[:json][:data_partner][:id_code]
    assert_equal @sale_201608[:data_partner][:link_url], sale[:json][:data_partner][:link_url]
  end

  def test_list_sales
    august_sale_a = @api.create_sale(@sale_201608)
    feb_sale = @api.create_sale(@sale_201702)
    september_sale = @api.create_sale(@sale_201609)

    august_sale_a_id = august_sale_a[:json][:id]
    feb_sale_id = feb_sale[:json][:id]
    september_sale_id = september_sale[:json][:id]

    sales_list = @api.list_sales(2016, 8)
    assert_equal 200, sales_list[:status].to_i, sales_list.inspect
    assert sales_list[:json].size == 1

    assert(sales_list[:json].any? { |x| x[:id] == august_sale_a_id })
    assert(sales_list[:json].none? { |x| x[:id] == feb_sale_id })
    assert(sales_list[:json].none? { |x| x[:id] == september_sale_id })
  end

   def test_update_sale
     sale = @api.create_sale(@sale_201608)
     options = {
       id: sale[:json][:id].to_i,
       price_including_tax: 25_000,
       memo: 'Updated memo',
       data_partner: { id_code: "100" }
     }

    updated_sale = @api.update_sale(options)
    assert_equal 200, updated_sale[:status].to_i, updated_sale[:json]
    assert_equal options[:id], updated_sale[:json][:id]
    assert_equal options[:memo], updated_sale[:json][:memo]
    assert_equal options[:price_including_tax], updated_sale[:json][:price_including_tax]
    assert_equal options[:data_partner][:id_code], updated_sale[:json][:data_partner][:id_code]
  end

  def test_find_or_create_sale
    with_key = @sale_201608.merge!({:key => { "id_code" => "1", "partner_code" => "Example"}})
    sale1 = @api.find_or_create_sale(with_key)

    assert_equal 200, sale1[:status].to_i, sale1.inspect
    assert_equal @sale_201608[:dept_code], sale1[:json][:dept_code]
    assert_equal @sale_201608[:data_partner][:id_code], sale1[:json][:data_partner][:id_code]
    assert_equal @sale_201608[:data_partner][:partner_code], sale1[:json][:data_partner][:partner_code]

    key_options = { key: { id_code: sale1[:json][:data_partner][:id_code], partner_code: sale1[:json][:data_partner][:partner_code] } }
    sale2 = @api.find_or_create_sale(@sale_201608.merge(key_options))
    assert_equal sale2[:json][:id], sale1[:json][:id]
    assert_equal sale2[:json][:data_partner][:id_code], sale1[:json][:data_partner][:id_code]
  end

  def test_list_sales_and_account_balances
    # Without customer_master_code and ar_segment option parameters
    balance_lists = @api.list_sales_and_account_balances(2019, 12)
    assert_equal 200, balance_lists[:status].to_i, balance_lists.inspect
    assert_equal 3, balance_lists[:json].size

    # With customer_master_id option parameters
    balance_list_with_opts = @api.list_sales_and_account_balances(2019, 12,
                                                        :customer_master_id => 101)

    assert_equal 200, balance_list_with_opts[:status].to_i, balance_list_with_opts.inspect
    assert_equal 2, balance_list_with_opts[:json].size
    assert(balance_list_with_opts[:json].all? { |x| x[:customer_master_code] == "101"})
  end

end