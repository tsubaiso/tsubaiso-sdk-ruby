require 'minitest/autorun'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < MiniTest::Unit::TestCase
  
  def setup
    @api = TsubaisoSDK.new({ base_url: ENV["SDK_BASE_URL"], access_token: ENV["SDK_ACCESS_TOKEN"] })

    # data
    @sale_201508 = { price: 10800, year: 2015, month: 8, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" }
    @sale_201509 = { price: 10800, year: 2015, month: 9, realization_timestamp: "2015-09-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" }
    @purchase_201508 = { price: 5400, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1 }
    @purchase_201509 = { price: 5400, year: 2015, month: 9, accrual_timestamp: "2015-09-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1}
    @customer_1000 = { name: "テスト株式会社", name_kana: "テストカブシキガイシャ", code: "1000", tax_type_for_remittance_charge: "3", used_in_ar: 1, used_in_ap: 1, is_valid: 1 }
  end

  def test_failed_request
    @api_fail = TsubaisoSDK.new({ base_url: ENV["SDK_BASE_URL"], access_token: "fake token" })
    sale = @api_fail.create_sale(@sale_201508)

    assert_equal 401, sale[:status].to_i
    assert_equal "Bad credentials", sale[:json][:error]
  end

  def test_create_customer
    customer = @api.create_customer(@customer_1000)

    assert_equal 200, customer[:status].to_i
    assert_equal @customer_1000[:name], customer[:json][:name]

  ensure
    @api.destroy_customer(customer[:json][:id]) if customer[:json][:id]
  end
  
  def test_create_sale
    sale = @api.create_sale(@sale_201508)

    assert_equal 200, sale[:status].to_i
    assert_equal @sale_201508[:dept_code], sale[:json][:dept_code]

  ensure
    @api.destroy_sale("AR#{sale[:json][:id]}") if sale[:json][:id]
  end

  def test_create_purchase
    purchase = @api.create_purchase(@purchase_201508)

    assert_equal 200, purchase[:status].to_i
    assert_equal @purchase_201508[:dept_code], purchase[:json][:dept_code]

  ensure
    @api.destroy_purchase("AP#{purchase[:json][:id]}") if purchase[:json][:id]
  end

  def test_show_sale
    sale = @api.create_sale(@sale_201508)

    get_sale = @api.show_sale("AR#{sale[:json][:id]}")
    assert_equal 200, get_sale[:status].to_i
    assert_equal sale[:json][:sales_price], get_sale[:json][:sales_price]

  ensure
    @api.destroy_sale("AR#{sale[:json][:id]}") if sale[:json][:id]
  end

  def test_show_purchase
    purchase = @api.create_purchase(@purchase_201508)

    get_purchase = @api.show_purchase("AP#{purchase[:json][:id]}")
    assert_equal 200, get_purchase[:status].to_i
    assert_equal purchase[:json][:id], get_purchase[:json][:id]

  ensure
    @api.destroy_purchase("AP#{purchase[:json][:id]}") if purchase[:json][:id]
  end

  def test_show_customer
    customer = @api.create_customer(@customer_1000)

    get_customer = @api.show_customer("#{customer[:json][:id]}")
    assert_equal 200, get_customer[:status].to_i
    assert_equal customer[:json][:id], get_customer[:json][:id]

  ensure
    @api.destroy_customer(customer[:json][:id]) if customer[:json][:id]
  end

  def test_show_staff_member
    get_staff_member = @api.show_staff_member(1)
    assert_equal 200, get_staff_member[:status].to_i
    assert_equal 1, get_staff_member[:json][:id]
  end

  def test_list_sales
    august_sale_a = @api.create_sale(@sale_201508)
    august_sale_b = @api.create_sale(@sale_201508)
    september_sale = @api.create_sale(@sale_201509)

    august_sale_a_id = august_sale_a[:json][:id]
    august_sale_b_id = august_sale_b[:json][:id]
    september_sale_id = september_sale[:json][:id]
    
    sales_list = @api.list_sales(2015, 8)
    assert_equal 200, sales_list[:status].to_i
    assert sales_list[:json].any?{ |x| x[:id] == august_sale_a_id }
    assert sales_list[:json].any?{ |x| x[:id] == august_sale_b_id }
    assert !sales_list[:json].any?{ |x| x[:id] == september_sale_id }

  ensure
    @api.destroy_sale("AR#{august_sale_a[:json][:id]}") if august_sale_a[:json][:id]
    @api.destroy_sale("AR#{august_sale_b[:json][:id]}") if august_sale_b[:json][:id]
    @api.destroy_sale("AR#{september_sale[:json][:id]}") if september_sale[:json][:id]
  end

  def test_list_purchases
    august_purchase_a = @api.create_purchase(@purchase_201508)
    august_purchase_b = @api.create_purchase(@purchase_201508)
    september_purchase = @api.create_purchase(@purchase_201509)
    
    august_purchase_a_id = august_purchase_a[:json][:id]
    august_purchase_b_id = august_purchase_b[:json][:id]
    september_purchase_id = september_purchase[:json][:id]

    purchase_list = @api.list_purchases(2015, 8)
    assert_equal 200, purchase_list[:status].to_i
    assert purchase_list[:json].any?{ |x| x[:id] == august_purchase_a_id }
    assert purchase_list[:json].any?{ |x| x[:id] == august_purchase_b_id }
    assert !purchase_list[:json].any?{ |x| x[:id] == september_purchase_id }
    
  ensure
    @api.destroy_purchase("AP#{august_purchase_a[:json][:id]}") if august_purchase_a[:json][:id]
    @api.destroy_purchase("AP#{august_purchase_b[:json][:id]}") if august_purchase_b[:json][:id]
    @api.destroy_purchase("AP#{september_purchase[:json][:id]}") if september_purchase[:json][:id]
  end

  def test_list_customers
    customer_1000 = @api.create_customer(@customer_1000)

    customer_1000_id = customer_1000[:json][:id]

    customer_list = @api.list_customers
    assert_equal 200, customer_list[:status].to_i
    assert customer_list[:json].any?{ |x| x[:id] == customer_1000_id }
    
  ensure
    @api.destroy_customer(customer_1000[:json][:id]) if customer_1000[:json][:id]
  end

  def test_list_staff
    staff_list = @api.list_staff
    assert_equal 200, staff_list[:status].to_i
    assert(staff_list.size > 0)
  end
end
