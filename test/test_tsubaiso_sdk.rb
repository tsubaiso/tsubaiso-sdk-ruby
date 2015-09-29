require 'minitest/autorun'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < MiniTest::Unit::TestCase
  
  def setup
    @api = TsubaisoSDK.new(login: ENV["SDK_LOGIN"], password: ENV["SDK_PASSWORD"], ccode: ENV["SDK_CCODE"], role: ENV["SDK_ROLE"])
  end

  def test_create_sale
    sale = @api.create_sale({ price: 10800, year: 2015, month: 8, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" })

    assert_equal 200, sale[:status].to_i
    assert_equal "SETSURITSU", sale[:json][:dept_code]

    deleted_sale = @api.destroy_sale("AR#{sale[:json][:id]}")
    assert_equal 204, deleted_sale.to_i
  end

  def test_create_purchase
    purchase = @api.create_purchase({ price: 5400, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1})

    assert_equal 200, purchase[:status].to_i
    assert_equal "SETSURITSU", purchase[:json][:dept_code]

    deleted_purchase = @api.destroy_purchase("AP#{purchase[:json][:id]}")
    assert_equal 204, deleted_purchase.to_i
  end

  def test_show_sale
    sale = @api.create_sale({ price: 10800, year: 2015, month: 8, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" })

    get_sale = @api.show_sale("AR#{sale[:json][:id]}")
    assert_equal 200, get_sale[:status].to_i
    assert_equal get_sale[:json][:sales_price], sale[:json][:sales_price]

    deleted_sale = @api.destroy_sale("AR#{sale[:json][:id]}")
    assert_equal 204, deleted_sale.to_i
  end

  def test_show_purchase
    purchase = @api.create_purchase({ price: 5400, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1})

    get_purchase = @api.show_purchase("AP#{purchase[:json][:id]}")
    assert_equal 200, get_purchase[:status].to_i
    assert_equal get_purchase[:json][:id], purchase[:json][:id]

    deleted_purchase = @api.destroy_purchase("AP#{purchase[:json][:id]}")
    assert_equal 204, deleted_purchase.to_i
  end

  def test_list_sales
    august_sale_a = @api.create_sale({ price: 10800, year: 2015, month: 8, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" })
    august_sale_b = @api.create_sale({ price: 10800, year: 2015, month: 8, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" })
    september_sale = @api.create_sale({ price: 10800, year: 2015, month: 9, realization_timestamp: "2015-09-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" })

    sales_list = @api.list_sales(2015, 8)
    assert_equal 200, sales_list[:status].to_i
    assert_equal 2, sales_list[:json].count

    deleted_sale_a = @api.destroy_sale("AR#{august_sale_a[:json][:id]}")
    assert_equal 204, deleted_sale_a.to_i

    deleted_sale_b = @api.destroy_sale("AR#{august_sale_b[:json][:id]}")
    assert_equal 204, deleted_sale_b.to_i

    deleted_sale_c = @api.destroy_sale("AR#{september_sale[:json][:id]}")
    assert_equal 204, deleted_sale_c.to_i
  end

  def test_list_purchases
    august_purchase_a = @api.create_purchase({ price: 5400, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1})
    august_purchase_b = @api.create_purchase({ price: 5400, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1})
    september_purchase = @api.create_purchase({ price: 5400, year: 2015, month: 9, accrual_timestamp: "2015-09-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1})

    purchase_list = @api.list_purchases(2015, 8)
    assert_equal 200, purchase_list[:status].to_i
    assert_equal 2, purchase_list[:json].count

    deleted_purchase_a = @api.destroy_purchase("AP#{august_purchase_a[:json][:id]}")
    assert_equal 204, deleted_purchase_a.to_i

    deleted_purchase_b = @api.destroy_purchase("AP#{august_purchase_b[:json][:id]}")
    assert_equal 204, deleted_purchase_b.to_i

    deleted_purchase_c = @api.destroy_purchase("AP#{september_purchase[:json][:id]}")
    assert_equal 204, deleted_purchase_c.to_i
  end
end
