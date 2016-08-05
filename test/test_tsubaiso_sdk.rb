# encoding: utf-8
require 'minitest/autorun'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < MiniTest::Unit::TestCase

  def setup
    @api = TsubaisoSDK.new({ base_url: ENV["SDK_BASE_URL"], access_token: ENV["SDK_ACCESS_TOKEN"] })

    # data
    @sale_201508 = { price_including_tax: 10800, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25", tag_list: "Banana" }
    @sale_201509 = { price_including_tax: 10800, realization_timestamp: "2015-09-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25", tag_list: "Banana" }
    @purchase_201508 = { price_including_tax: 5400, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1, tag_list: "Canada,Banana" }
    @purchase_201509 = { price_including_tax: 5400, year: 2015, month: 9, accrual_timestamp: "2015-09-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1, tag_list: "Banana"}
    @customer_1000 = { name: "テスト株式会社", name_kana: "テストカブシキガイシャ", code: "10000", tax_type_for_remittance_charge: "3", used_in_ar: 1, used_in_ap: 1, is_valid: 1 }
    @staff_data_1 = { code: "QUALIFICATION", value: "TOEIC", start_timestamp: "2015-01-01", no_finish_timestamp: "1", memo: "First memo" }
    @reimbursement_1 = { applicant: "Irfan", application_term: "2016-03-01", staff_code: "EP2000", memo: "aaaaaaaa", dept_code: "SETSURITSU" }
    @reimbursement_2 = { applicant: "Matsuno", application_term: "2016-03-01", staff_code: "EP2000", memo: "aaaaaaaa", dept_code: "SETSURITSU" }
    @reimbursement_tx_1 = { transaction_timestamp: "2016-03-01", price_value: 10000, dc:"c", reason_code:"MEETING", brief:"everyting going well", memo:"easy", tag_list:"Canada,Banana" }
    @reimbursement_tx_2 = { transaction_timestamp: "2016-03-01", price_value: 20000, dc:"c", reason_code:"SUPPLIES", brief:"not well", memo:"hard", tag_list:"Canada" }
    @manual_journal_1 = {journal_timestamp: "2016-04-01", journal_dcs: [
                         debit:  {account_code: 100, price_including_tax: 1000, tax_type: 1, sales_tax: 100},
                         credit: {account_code: 135, price_including_tax: 1000, tax_type: 1, sales_tax: 100} ] }
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
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]
    @staff_data_1[:staff_id] = first_staff_id

    staff_data = @api.create_staff_data(@staff_data_1)

    assert_equal 200, staff_data[:status].to_i
    assert_equal @staff_data_1[:value], staff_data[:json][:value]

  ensure
    @api.destroy_staff_data(staff_data[:json][:id]) if staff_data[:json][:id]
  end

  def test_create_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)

    begin
      assert_equal 200, manual_journal[:status].to_i, manual_journal[:json]
      assert_equal @manual_journal_1[:journal_dcs][0][:price_including_tax], manual_journal[:json][:journal_dcs][0]["price_including_tax"]

    ensure
      @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
    end
  end

  def test_create_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    assert_equal 200, reimbursement[:status].to_i
    assert_equal @reimbursement_1[:applicant], reimbursement[:json][:applicant]

    ensure
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end
  
  def test_create_reimbursement_transaction
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = @reimbursement_tx_1.merge({ :reimbursement_id => reimbursement[:json][:id] })
    reimbursement_transaction = @api.create_reimbursement_transaction(options)
    assert_equal 200, reimbursement_transaction[:status].to_i
    assert_equal @reimbursement_tx_1[:price_value], reimbursement_transaction[:json][:price_value]
    
    ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction[:json][:id]) if reimbursement_transaction[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_update_sale
    sale = @api.create_sale(@sale_201508)
    options = { id: sale[:json][:id],
                price_including_tax: 25000,
                memo: "Updated memo" }

    updated_sale = @api.update_sale(options)
    assert_equal 200, updated_sale[:status].to_i
    assert_equal sale[:json][:id], updated_sale[:json][:id]
    assert_equal "Updated memo", updated_sale[:json][:memo]
    assert_equal 25000, updated_sale[:json][:price_including_tax]

  ensure
    @api.destroy_sale("AP#{sale[:json][:id]}") if sale[:json][:id]
  end

  def test_update_purchase
    purchase = @api.create_purchase(@purchase_201508)
    options = { id: purchase[:json][:id],
                price_including_tax: 50000,
                memo: "Updated memo"}

    updated_purchase = @api.update_purchase(options)
    assert_equal 200, updated_purchase[:status].to_i
    assert_equal purchase[:json][:id], updated_purchase[:json][:id]
    assert_equal "Updated memo", updated_purchase[:json][:memo]
    assert_equal 50000, updated_purchase[:json][:price_including_tax]

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
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]
    @staff_data_1[:staff_id] = first_staff_id

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

  def test_update_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = {
      applicant: "test",
      dept_code: "COMMON"
    }
    updated_reimbursement = @api.update_reimbursement(reimbursement[:json][:id], options)
    assert_equal 200, updated_reimbursement[:status].to_i
    assert_equal options[:applicant], updated_reimbursement[:json][:applicant]
    assert_equal options[:dept_code], updated_reimbursement[:json][:dept_code]

  ensure
    @api.destroy_reimbursement(updated_reimbursement[:json][:id] || reimbursement[:json][:id]) if updated_reimbursement[:json][:id] || reimbursement[:json][:id]
  end

  def test_update_reimbursement_transaction
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = @reimbursement_tx_1.merge({ :reimbursement_id => reimbursement[:json][:id].to_i })
    reimbursement_transaction = @api.create_reimbursement_transaction(options)
    updates = { :id => reimbursement_transaction[:json][:id], :price_value => 9999, :reason_code => "SUPPLIES" }
    
    updated_reimbursement_transaction = @api.update_reimbursement_transaction(updates)
    assert_equal 200, updated_reimbursement_transaction[:status].to_i
    assert_equal updates[:id].to_i, updated_reimbursement_transaction[:json][:id].to_i
    assert_equal updates[:price_value].to_i, updated_reimbursement_transaction[:json][:price_value].to_i
    assert_equal updates[:reason_code], updated_reimbursement_transaction[:json][:reason_code]
    
  ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction[:json][:id]) if reimbursement_transaction[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_update_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    options = { id: manual_journal[:json][:id],
                journal_dcs: manual_journal[:json][:journal_dcs]
              }
    options[:journal_dcs][0][:debit][:price_including_tax]  = 2000
    options[:journal_dcs][0][:credit][:price_including_tax] = 2000

    updated_manual_journal = @api.update_manual_journal(options)
    assert_equal 200, updated_manual_journal[:status].to_i, updated_manual_journal[:json]
    assert_equal @manual_journal_1[:journal_dcs][0][:price_including_tax], updated_manual_journal[:json][:journal_dcs][0]["price_including_tax"]

  ensure
    @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
  end

  def test_show_sale
    sale = @api.create_sale(@sale_201508)

    get_sale = @api.show_sale("AR#{sale[:json][:id]}")
    assert_equal 200, get_sale[:status].to_i
    assert_equal sale[:json][:price_including_tax], get_sale[:json][:price_including_tax]

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
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    get_staff_member = @api.show_staff(first_staff_id)
    assert_equal 200, get_staff_member[:status].to_i
    assert_equal first_staff_id, get_staff_member[:json][:id]
  end

  def test_show_staff_data
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]
    @staff_data_1[:staff_id] = first_staff_id

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

  def test_show_staff_datum_master
    staff_datum_masters_list = @api.list_staff_datum_masters
    first_staff_datum_master_id = staff_datum_masters_list[:json].first[:id]

    get_staff_datum_master = @api.show_staff_datum_master(first_staff_datum_master_id)
    assert_equal 200, get_staff_datum_master[:status].to_i
    assert_equal first_staff_datum_master_id, get_staff_datum_master[:json][:id]
  end

  def test_show_staff_datum_master_by_code
    staff_datum_masters_list = @api.list_staff_datum_masters
    first_staff_datum_master_code = staff_datum_masters_list[:json].first[:code]

    options = { code: first_staff_datum_master_code }

    #get data using code
    get_staff_data_2 = @api.show_staff_datum_master(options)
    assert_equal 200, get_staff_data_2[:status].to_i
    assert_equal first_staff_datum_master_code, get_staff_data_2[:json][:code]
  end

  def test_show_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    reimbursement = @api.show_reimbursement(reimbursement[:json][:id])

    assert_equal 200, reimbursement[:status].to_i
    assert_equal @reimbursement_1[:applicant], reimbursement[:json][:applicant]
  ensure
    @api.destroy_reimbursement(reimbursement[:json][:id])
  end

  def test_show_reimbursement_transaction
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = { :reimbursement_id => reimbursement[:json][:id].to_i }
    reimbursement_transaction = @api.create_reimbursement_transaction(@reimbursement_tx_1.merge(options))
    reimbursement_transaction = @api.show_reimbursement_transaction(reimbursement_transaction[:json][:id])
    
    assert_equal 200, reimbursement_transaction[:status].to_i
    assert_equal options[:reimbursement_id], reimbursement_transaction[:json][:reimbursement_id]
    
  ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction[:json][:id]) if reimbursement_transaction[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_show_manual_journal
    @api.create_manual_journal(@manual_journal_1)
    manual_journals_list = @api.list_manual_journals(2016, 4)
    first_manual_journal_id = manual_journals_list[:json].first[:id]

    manual_journal = @api.show_manual_journal(first_manual_journal_id)
    assert_equal 200, manual_journal[:status].to_i
    assert_equal first_manual_journal_id, manual_journal[:json][:id]
    
  ensure
    @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
  end

  def test_show_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    journals_list = @api.list_journals({ start_date: "2016-04-01", finish_date: "2016-04-30" })
    first_journal_id = journals_list[:json][:records].first[:id]

    journal = @api.show_journal(first_journal_id)
    assert_equal 200, journal[:status].to_i
    assert_equal first_journal_id, journal[:json][:records][:id]

  ensure
    @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
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
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    staff_data_list = @api.list_staff_data(first_staff_id)
    assert_equal 200, staff_data_list[:status].to_i
    assert staff_data_list[:json].all?{ |x| x[:staff_id] == first_staff_id }
  end

  def test_list_staff_datum_masters
    staff_datum_masters_list = @api.list_staff_datum_masters
    assert_equal 200, staff_datum_masters_list[:status].to_i
    assert(staff_datum_masters_list.size > 0)
  end

  def test_list_manual_journals
    manual_journals_list = @api.list_manual_journals(2016, 4)
    assert_equal 200, manual_journals_list[:status].to_i
    assert(manual_journals_list.size > 0)
  end

  def test_list_journals
    august_sale = @api.create_sale(@sale_201508) 
    september_sale = @api.create_sale(@sale_201509)
    august_purchase = @api.create_purchase(@purchase_201508)
    september_purchase = @api.create_purchase(@purchase_201509)
    
    options = { start_date: "2015-08-01", finish_date: "2015-08-31" }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i
    record_timestamps = records.map { |x| x[:journal_timestamp].split(" ")[0] }
    assert_includes record_timestamps, august_sale[:json][:realization_timestamp]
    assert_includes record_timestamps, august_purchase[:json][:accrual_timestamp]

    options = { price: 10800 }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i
    record_prices = records.map { |x| x[:journal_dcs].map { |y| y[:debit][:price_including_tax] } }.flatten(1)
    assert_includes record_prices, august_sale[:json][:price_including_tax]
    assert_includes record_prices, september_sale[:json][:price_including_tax]

    options = { dept: "SETSURITSU" }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i
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

  def test_list_reimbursements
    reimbursement_a = @api.create_reimbursement(@reimbursement_1)
    reimbursement_b = @api.create_reimbursement(@reimbursement_2)

    reimbursement_a_id = reimbursement_a[:json][:id]
    reimbursement_b_id = reimbursement_b[:json][:id]

    reimbursements_list = @api.list_reimbursements(2016, 3)
    assert_equal 200, reimbursements_list[:status].to_i
    assert reimbursements_list[:json].any?{ |x| x[:id] == reimbursement_a_id }
    assert reimbursements_list[:json].any?{ |x| x[:id] == reimbursement_b_id }

  ensure
    @api.destroy_reimbursement(reimbursement_a_id) if reimbursement_a_id
    @api.destroy_reimbursement(reimbursement_b_id) if reimbursement_b_id
  end

  def test_list_reimbursement_transactions
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = { :reimbursement_id => reimbursement[:json][:id].to_i }
    reimbursement_transaction_1 = @api.create_reimbursement_transaction(@reimbursement_tx_1.merge(options))
    reimbursement_transaction_2 = @api.create_reimbursement_transaction(@reimbursement_tx_2.merge(options))
    
    reimbursement_transactions = @api.list_reimbursement_transactions(reimbursement[:json][:id])
    assert_equal 200, reimbursement_transactions[:status].to_i
    assert reimbursement_transactions[:json].any?{ |x| x[:id] == reimbursement_transaction_1[:json][:id] }
    assert reimbursement_transactions[:json].any?{ |x| x[:id] == reimbursement_transaction_2[:json][:id] }

  ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction_1[:json][:id]) if reimbursement_transaction_1[:json][:id]
    @api.destroy_reimbursement_transaction(reimbursement_transaction_1[:json][:id]) if reimbursement_transaction_1[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  private
  def successful?(status)
    status.to_i == 200
  end
end
