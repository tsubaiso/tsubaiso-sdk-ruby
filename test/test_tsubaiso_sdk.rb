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
    @customer_1000 = { name: "テスト株式会社", name_kana: "テストカブシキガイシャ", code: "10000", tax_type_for_remittance_charge: "3", used_in_ar: 1, used_in_ap: 1, is_valid: 1 }
    @staff_id = 1
    @staff_data_1 = { staff_id: @staff_id, code: "NAME_SEI", value: "Tsubaiso", start_timestamp: "2015-01-01", no_finish_timestamp: "1", memo: "First memo" }
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

  def test_create_staff_data
    staff_data = @api.create_staff_data(@staff_data_1)
    
    assert_equal 200, staff_data[:status].to_i
    assert_equal @staff_data_1[:value], staff_data[:json][:value]
    
  ensure
    @api.destroy_staff_data(staff_data[:json][:id]) if staff_data[:json][:id]
  end
  
  def test_update_sale
    sale = @api.create_sale(@sale_201508)
    options = { id: sale[:json][:id],
                price: 25000,
                memo: "Updated memo" }

    updated_sale = @api.update_sale(options)
    assert_equal 200, updated_sale[:status].to_i
    assert_equal sale[:json][:id], updated_sale[:json][:id]
    assert_equal "Updated memo", updated_sale[:json][:memo]
    assert_equal 25000, updated_sale[:json][:sales_price] + updated_sale[:json][:sales_tax]

  ensure
    @api.destroy_sale("AP#{sale[:json][:id]}") if sale[:json][:id]
  end
  
  def test_update_purchase
    purchase = @api.create_purchase(@purchase_201508)
    options = { id: purchase[:json][:id],
                price: 50000,
                memo: "Updated memo"}

    updated_purchase = @api.update_purchase(options)
    assert_equal 200, updated_purchase[:status].to_i
    assert_equal purchase[:json][:id], updated_purchase[:json][:id]
    assert_equal "Updated memo", updated_purchase[:json][:memo]
    assert_equal 50000, updated_purchase[:json][:buying_price] + updated_purchase[:json][:buying_tax]

  ensure
    @api.destroy_purchase("AP#{purchase[:json][:id]}") if purchase[:json][:id]
  end

  def test_update_customer
    customer = @api.create_customer(@customer_1000)
    options = { id: customer[:json][:id],
                name: "New Customer Name"}

    updated_customer = @api.update_customer(options)
    assert_equal 200, updated_customer[:status].to_i
    assert_equal customer[:json][:id], updated_customer[:json][:id]
    assert_equal "New Customer Name", updated_customer[:json][:name]

  ensure
    @api.destroy_customer(customer[:json][:id]) if customer[:json][:id]
  end

  def test_update_staff_data
    staff_data = @api.create_staff_data(@staff_data_1)
    options = { id: staff_data[:json][:id],
                value: "Programmer"
              }
    
    updated_staff_data = @api.update_staff_data(options)
    assert_equal 200, updated_staff_data[:status].to_i
    assert_equal staff_data[:json][:id], updated_staff_data[:json][:id]
    assert_equal "Programmer", updated_staff_data[:json][:value]
    
  ensure
    @api.destroy_staff_data(staff_data[:json][:id]) if staff_data[:json][:id]
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

    get_customer = @api.show_customer(customer[:json][:id])
    assert_equal 200, get_customer[:status].to_i
    assert_equal customer[:json][:id], get_customer[:json][:id]

  ensure
    @api.destroy_customer(customer[:json][:id]) if customer[:json][:id]
  end

  def test_show_staff
    get_staff_member = @api.show_staff(@staff_id)
    assert_equal 200, get_staff_member[:status].to_i
    assert_equal @staff_id, get_staff_member[:json][:id]
  end

  def test_show_staff_data
    staff_data = @api.create_staff_data(@staff_data_1)

    #get data using id
    get_staff_data = @api.show_staff_data(staff_data[:json][:id])
    assert_equal 200, get_staff_data[:status].to_i
    assert_equal staff_data[:json][:id], get_staff_data[:json][:id]

    options = { staff_id: staff_data[:json][:staff_id],
                code: staff_data[:json][:code],
                time: staff_data[:json][:start_timestamp]
              }
    
    #get data using staff id and code
    get_staff_data_2 = @api.show_staff_data(options)
    assert_equal 200, get_staff_data_2[:status].to_i
    assert_equal staff_data[:json][:id], get_staff_data_2[:json][:id]

  ensure
    @api.destroy_staff_data(staff_data[:json][:id]) if staff_data[:json][:id]    
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

  def test_list_staff_data
    staff_data_list = @api.list_staff_data(@staff_id)
    assert_equal 200, staff_data_list[:status].to_i
    assert staff_data_list[:json].all?{ |x| x[:staff_id] == @staff_id }
  end
end
