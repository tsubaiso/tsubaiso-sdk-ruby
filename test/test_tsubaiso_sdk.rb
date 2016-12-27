# encoding: utf-8
require 'minitest/autorun'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < MiniTest::Unit::TestCase

  def setup
    @api = TsubaisoSDK.new({ base_url: ENV["SDK_BASE_URL"], access_token: ENV["SDK_ACCESS_TOKEN"] })

    # data
    @sale_201608 = { price_including_tax: 10800, realization_timestamp: "2016-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2016-09-25" }
    @sale_201609 = { price_including_tax: 10800, realization_timestamp: "2016-09-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2016-09-25" }
    @purchase_201608 = { price_including_tax: 5400, year: 2016, month: 8, accrual_timestamp: "2016-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1}
    @purchase_201609 = { price_including_tax: 5400, year: 2016, month: 9, accrual_timestamp: "2016-09-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1}
    @customer_1000 = { name: "テスト株式会社", name_kana: "テストカブシキガイシャ", code: "10000", tax_type_for_remittance_charge: "3", used_in_ar: 1, used_in_ap: 1, is_valid: 1 }
    @staff_data_1 = { code: "QUALIFICATION", value: "TOEIC", start_timestamp: "2016-01-01", no_finish_timestamp: "1", memo: "First memo" }
    @reimbursement_1 = { applicant: "Irfan", application_term: "2016-03-01", staff_code: "EP2000", memo: "aaaaaaaa" }
    @reimbursement_2 = { applicant: "Matsuno", application_term: "2016-03-01", staff_code: "EP2000", memo: "aaaaaaaa" }
    @reimbursement_tx_1 = { transaction_timestamp: "2016-03-01", price_value: 10000, dc:"c", reason_code:"SUPPLIES", brief:"everyting going well", memo:"easy" }
    @reimbursement_tx_2 = { transaction_timestamp: "2016-03-01", price_value: 20000, dc:"c", reason_code:"SUPPLIES", brief:"not well", memo:"hard" }
    @manual_journal_1 = {journal_timestamp: "2016-04-01", journal_dcs: [
                         debit:  {account_code: 100, price_including_tax: 1000, tax_type: 1, sales_tax: 100},
                         credit: {account_code: 135, price_including_tax: 1000, tax_type: 1, sales_tax: 100} ] }
    @dept_1= {sort_no: 12345678, code: 'test_code', name: 'テスト部門', name_abbr: 'テストブモン', color: '#ffffff', memo: 'テストメモ', start_date: '2016-01-01', finish_date: '2016-01-02'}
    @tag_1 = {code: 'test_code', name: 'テストタグ', sort_no: 10000, tag_group_code: "DEFAULT", start_ymd: '2016-01-01', finish_ymd: '2016-12-31'}
  end

  def test_failed_request
    @api_fail = TsubaisoSDK.new({ base_url: ENV["SDK_BASE_URL"], access_token: "fake token" })
    sale = @api_fail.create_sale(@sale_201608)

    assert_equal 401, sale[:status].to_i, sale.inspect
    assert_equal "Bad credentials", sale[:json][:error]
  end

  def test_create_customer
    customer = @api.create_customer(@customer_1000)

    assert_equal 200, customer[:status].to_i, customer.inspect
    assert_equal @customer_1000[:name], customer[:json][:name]

  ensure
    @api.destroy_customer(customer[:json][:id]) if customer[:json][:id]
  end

  def test_create_sale
    sale = @api.create_sale(@sale_201608)

    assert_equal 200, sale[:status].to_i, sale.inspect
    assert_equal @sale_201608[:dept_code], sale[:json][:dept_code]

  ensure
    @api.destroy_sale("AR#{sale[:json][:id]}") if sale[:json][:id]
  end

  def test_create_purchase
    purchase = @api.create_purchase(@purchase_201608)

    assert_equal 200, purchase[:status].to_i, purchase.inspect
    assert_equal @purchase_201608[:dept_code], purchase[:json][:dept_code]

  ensure
    @api.destroy_purchase("AP#{purchase[:json][:id]}") if purchase[:json][:id]
  end

  def test_create_staff_data
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]
    @staff_data_1[:staff_id] = first_staff_id

    staff_data = @api.create_staff_data(@staff_data_1)

    assert_equal 200, staff_data[:status].to_i, staff_data.inspect
    assert_equal @staff_data_1[:value], staff_data[:json][:value]

  ensure
    @api.destroy_staff_data(staff_data[:json][:id]) if staff_data[:json][:id]
  end

  def test_create_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)

    begin
      assert_equal 200, manual_journal[:status].to_i, manual_journal.inspect
      assert_equal @manual_journal_1[:journal_dcs][0][:price_including_tax], manual_journal[:json][:journal_dcs][0]["price_including_tax"]

    ensure
      @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
    end
  end

  def test_create_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    assert_equal 200, reimbursement[:status].to_i, reimbursement.inspect
    assert_equal @reimbursement_1[:applicant], reimbursement[:json][:applicant]

    ensure
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_create_reimbursement_transaction
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = @reimbursement_tx_1.merge({ :reimbursement_id => reimbursement[:json][:id] })
    reimbursement_transaction = @api.create_reimbursement_transaction(options)
    assert_equal 200, reimbursement_transaction[:status].to_i, reimbursement_transaction.inspect
    assert_equal @reimbursement_tx_1[:price_value], reimbursement_transaction[:json][:price_value]

    ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction[:json][:id]) if reimbursement_transaction[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_create_dept
    dept = @api.create_dept(@dept_1)
    assert_equal 200, dept[:status].to_i, dept.inspect
    assert_equal @dept_1[:code], dept[:json][:code]

    ensure
    @api.destroy_dept(dept[:json][:id]) if dept[:json][:id]
  end

  def test_create_tag
    tag = @api.create_tag(@tag_1)
    assert_equal 200, tag[:status].to_i, tag.inspect
    assert_equal @tag_1[:code], tag[:json][:code]

    ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_update_sale
    sale = @api.create_sale(@sale_201608)
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
    purchase = @api.create_purchase(@purchase_201608)
    options = { id: purchase[:json][:id],
                price_including_tax: 50000,
                memo: "Updated memo"}

    updated_purchase = @api.update_purchase(options)
    assert_equal 200, updated_purchase[:status].to_i, updated_purchase.inspect
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
    assert_equal 200, updated_staff_data[:status].to_i, updated_staff_data.inspect
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
    assert_equal 200, updated_reimbursement[:status].to_i, updated_reimbursement.inspect
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
    assert_equal 200, updated_reimbursement_transaction[:status].to_i, updated_reimbursement_transaction.inspect
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
    assert_equal 200, updated_manual_journal[:status].to_i, updated_manual_journal.inspect
    assert_equal @manual_journal_1[:journal_dcs][0][:price_including_tax], updated_manual_journal[:json][:journal_dcs][0]["price_including_tax"]

  ensure
    @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
  end

  def test_update_dept
    dept = @api.create_dept(@dept_1)
    options = { id: dept[:json][:id],
                sort_no: 98765,
                memo: "updated at test",
                name: "更新部門",
                name_abbr: "更新部門",
              }

    updated_dept = @api.update_dept(dept[:json][:id], options)
    assert_equal 200, updated_dept[:status].to_i, updated_dept.inspect
    assert_equal options[:memo], updated_dept[:json][:memo]
    assert_equal options[:name], updated_dept[:json][:name]
    assert_equal options[:name_abbr], updated_dept[:json][:name_abbr]

  ensure
    @api.destroy_dept(updated_dept[:json][:id] || dept[:json][:id]) if updated_dept[:json][:id] || dept[:json][:id]
  end

  def test_update_tag
    tag = @api.create_tag(@tag_1)
    options = { name: "更新タグ",
                code: "updated_tag"
              }

    updated_tag = @api.update_tag(tag[:json][:id], options)
    assert_equal 200, updated_tag[:status].to_i, updated_tag.inspect
    assert_equal options[:name], updated_tag[:json][:name]
    assert_equal options[:code], updated_tag[:json][:code]

  ensure
    @api.destroy_tag(updated_tag[:json][:id] || tag[:json][:id]) if updated_tag[:json][:id] || tag[:json][:id]
  end

  def test_show_sale
    sale = @api.create_sale(@sale_201608)

    get_sale = @api.show_sale("AR#{sale[:json][:id]}")
    assert_equal 200, get_sale[:status].to_i, get_sale.inspect
    assert_equal sale[:json][:price_including_tax], get_sale[:json][:price_including_tax]

  ensure
    @api.destroy_sale("AR#{sale[:json][:id]}") if sale[:json][:id]
  end

  def test_show_purchase
    purchase = @api.create_purchase(@purchase_201608)

    get_purchase = @api.show_purchase("AP#{purchase[:json][:id]}")
    assert_equal 200, get_purchase[:status].to_i, get_purchase.inspect
    assert_equal purchase[:json][:id], get_purchase[:json][:id]

  ensure
    @api.destroy_purchase("AP#{purchase[:json][:id]}") if purchase[:json][:id]
  end

  def test_show_customer
    customer = @api.create_customer(@customer_1000)

    get_customer = @api.show_customer(customer[:json][:id])
    assert_equal 200, get_customer[:status].to_i, get_customer.inspect
    assert_equal customer[:json][:id], get_customer[:json][:id]

  ensure
    @api.destroy_customer(customer[:json][:id]) if customer[:json][:id]
  end

  def test_show_staff
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    get_staff_member = @api.show_staff(first_staff_id)
    assert_equal 200, get_staff_member[:status].to_i, get_staff_member.inspect
    assert_equal first_staff_id, get_staff_member[:json][:id]
  end

  def test_show_staff_data
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]
    @staff_data_1[:staff_id] = first_staff_id

    staff_data = @api.create_staff_data(@staff_data_1)

    #get data using id
    get_staff_data = @api.show_staff_data(staff_data[:json][:id])
    assert_equal 200, get_staff_data[:status].to_i, get_staff_data.inspect
    assert_equal staff_data[:json][:id], get_staff_data[:json][:id]

    options = { staff_id: staff_data[:json][:staff_id],
                code: staff_data[:json][:code],
                time: staff_data[:json][:start_timestamp]
              }

    #get data using staff id and code
    get_staff_data_2 = @api.show_staff_data(options)
    assert_equal 200, get_staff_data_2[:status].to_i, get_staff_data.inspect
    assert_equal staff_data[:json][:id], get_staff_data_2[:json][:id]

  ensure
    @api.destroy_staff_data(staff_data[:json][:id]) if staff_data[:json][:id]
  end

  def test_show_staff_datum_master
    staff_datum_masters_list = @api.list_staff_datum_masters
    first_staff_datum_master_id = staff_datum_masters_list[:json].first[:id]

    get_staff_datum_master = @api.show_staff_datum_master(first_staff_datum_master_id)
    assert_equal 200, get_staff_datum_master[:status].to_i, get_staff_datum_master.inspect
    assert_equal first_staff_datum_master_id, get_staff_datum_master[:json][:id]
  end

  def test_show_staff_datum_master_by_code
    staff_datum_masters_list = @api.list_staff_datum_masters
    first_staff_datum_master_code = staff_datum_masters_list[:json].first[:code]

    options = { code: first_staff_datum_master_code }

    #get data using code
    get_staff_data_2 = @api.show_staff_datum_master(options)
    assert_equal 200, get_staff_data_2[:status].to_i, get_staff_data_2.inspect
    assert_equal first_staff_datum_master_code, get_staff_data_2[:json][:code]
  end

  def test_show_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    reimbursement = @api.show_reimbursement(reimbursement[:json][:id])

    assert_equal 200, reimbursement[:status].to_i, reimbursement.inspect
    assert_equal @reimbursement_1[:applicant], reimbursement[:json][:applicant]
  ensure
    @api.destroy_reimbursement(reimbursement[:json][:id])
  end

  def test_show_reimbursement_transaction
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = { :reimbursement_id => reimbursement[:json][:id].to_i }
    reimbursement_transaction = @api.create_reimbursement_transaction(@reimbursement_tx_1.merge(options))
    reimbursement_transaction = @api.show_reimbursement_transaction(reimbursement_transaction[:json][:id])

    assert_equal 200, reimbursement_transaction[:status].to_i, reimbursement_transaction.inspect
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
    assert_equal 200, manual_journal[:status].to_i, manual_journal.inspect
    assert_equal first_manual_journal_id, manual_journal[:json][:id]

  ensure
    @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
  end

  def test_show_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    journals_list = @api.list_journals({ start_date: "2016-04-01", finish_date: "2016-04-30" })
    first_journal_id = journals_list[:json][:records].first[:id]

    journal = @api.show_journal(first_journal_id)
    assert_equal 200, journal[:status].to_i, journal.inspect
    assert_equal first_journal_id, journal[:json][:records][:id]

  ensure
    @api.destroy_manual_journal(manual_journal[:json][:id]) if successful?(manual_journal[:status])
  end

  def test_show_dept
    dept = @api.create_dept(@dept_1)
    dept = @api.show_dept(dept[:json][:id])

    assert_equal 200, dept[:status].to_i, dept.inspect
    assert_equal @dept_1[:memo], dept[:json][:memo]
  ensure
    @api.destroy_dept(dept[:json][:id])
  end

  def test_show_tag
    tag = @api.create_tag(@tag_1)
    tag = @api.show_tag(tag[:json][:id])

    assert_equal 200, tag[:status].to_i, tag.inspect
    assert_equal @tag_1[:name], tag[:json][:name]
  ensure
    @api.destroy_tag(tag[:json][:id])
  end

  def test_show_payroll
    payrolls_list = @api.list_payrolls(2016, 2)
    first_payroll_id = payrolls_list[:json].first[:id]

    payroll = @api.show_payroll(first_payroll_id)
    assert_equal 200, payroll[:status].to_i, payroll.inspect
    assert_equal first_payroll_id, payroll[:json][:id]
  end

  def test_list_sales
    august_sale_a = @api.create_sale(@sale_201608)
    august_sale_b = @api.create_sale(@sale_201608)
    september_sale = @api.create_sale(@sale_201609)

    august_sale_a_id = august_sale_a[:json][:id]
    august_sale_b_id = august_sale_b[:json][:id]
    september_sale_id = september_sale[:json][:id]

    sales_list = @api.list_sales(2016, 8)
    assert_equal 200, sales_list[:status].to_i, sales_list.inspect
    assert sales_list[:json].any?{ |x| x[:id] == august_sale_a_id }
    assert sales_list[:json].any?{ |x| x[:id] == august_sale_b_id }
    assert !sales_list[:json].any?{ |x| x[:id] == september_sale_id }

  ensure
    @api.destroy_sale("AR#{august_sale_a[:json][:id]}") if august_sale_a[:json][:id]
    @api.destroy_sale("AR#{august_sale_b[:json][:id]}") if august_sale_b[:json][:id]
    @api.destroy_sale("AR#{september_sale[:json][:id]}") if september_sale[:json][:id]
  end

  def test_list_purchases
    august_purchase_a = @api.create_purchase(@purchase_201608)
    august_purchase_b = @api.create_purchase(@purchase_201608)
    september_purchase = @api.create_purchase(@purchase_201609)

    august_purchase_a_id = august_purchase_a[:json][:id]
    august_purchase_b_id = august_purchase_b[:json][:id]
    september_purchase_id = september_purchase[:json][:id]

    purchase_list = @api.list_purchases(2016, 8)
    assert_equal 200, purchase_list[:status].to_i, purchase_list.inspect
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
    assert_equal 200, customer_list[:status].to_i, customer_list.inspect
    assert customer_list[:json].any?{ |x| x[:id] == customer_1000_id }

  ensure
    @api.destroy_customer(customer_1000[:json][:id]) if customer_1000[:json][:id]
  end

  def test_list_staff
    staff_list = @api.list_staff
    assert_equal 200, staff_list[:status].to_i, staff_list.inspect
    assert(staff_list.size > 0)
  end

  def test_list_staff_data
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    staff_data_list = @api.list_staff_data(first_staff_id)
    assert_equal 200, staff_data_list[:status].to_i, staff_data_list.inspect
    assert staff_data_list[:json].all?{ |x| x[:staff_id] == first_staff_id }
  end

  def test_list_staff_datum_masters
    staff_datum_masters_list = @api.list_staff_datum_masters
    assert_equal 200, staff_datum_masters_list[:status].to_i, staff_datum_masters_list.inspect
    assert(staff_datum_masters_list.size > 0)
  end

  def test_list_manual_journals
    manual_journals_list = @api.list_manual_journals(2016, 4)
    assert_equal 200, manual_journals_list[:status].to_i, manual_journals_list.inspect
    assert(manual_journals_list.size > 0)
  end

  def test_list_journals
    august_sale = @api.create_sale(@sale_201608)
    september_sale = @api.create_sale(@sale_201609)
    august_purchase = @api.create_purchase(@purchase_201608)
    september_purchase = @api.create_purchase(@purchase_201609)

    options = { start_date: "2016-08-01", finish_date: "2016-08-31" }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_timestamps = records.map { |x| x[:journal_timestamp].split(" ")[0] }
    assert_includes record_timestamps, august_sale[:json][:realization_timestamp]
    assert_includes record_timestamps, august_purchase[:json][:accrual_timestamp]

    options = { price: 10800 }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_prices = records.map { |x| x[:journal_dcs].map { |y| y[:debit][:price_including_tax] } }.flatten(1)
    assert_includes record_prices, august_sale[:json][:price_including_tax]
    assert_includes record_prices, september_sale[:json][:price_including_tax]

    options = { dept_code: "SETSURITSU" }
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

  def test_list_reimbursements
    reimbursement_a = @api.create_reimbursement(@reimbursement_1)
    reimbursement_b = @api.create_reimbursement(@reimbursement_2)

    reimbursement_a_id = reimbursement_a[:json][:id]
    reimbursement_b_id = reimbursement_b[:json][:id]

    reimbursements_list = @api.list_reimbursements(2016, 3)
    assert_equal 200, reimbursements_list[:status].to_i, reimbursements_list.inspect
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
    assert_equal 200, reimbursement_transactions[:status].to_i, reimbursement_transactions.inspect
    assert reimbursement_transactions[:json].any?{ |x| x[:id] == reimbursement_transaction_1[:json][:id] }
    assert reimbursement_transactions[:json].any?{ |x| x[:id] == reimbursement_transaction_2[:json][:id] }

  ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction_1[:json][:id]) if reimbursement_transaction_1[:json][:id]
    @api.destroy_reimbursement_transaction(reimbursement_transaction_1[:json][:id]) if reimbursement_transaction_1[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_list_depts
    dept = @api.create_dept(@dept_1)

    depts = @api.list_depts
    assert_equal 200, depts[:status].to_i, depts.inspect
    assert depts[:json].any?{ |x| x[:id] == dept[:json][:id] }

  ensure
    @api.destroy_dept(dept[:json][:id]) if dept[:json][:id]
  end

  def test_list_tags
    tag = @api.create_tag(@tag_1)

    tags = @api.list_tags
    assert_equal 200, tags[:status].to_i, tags.inspect
    assert tags[:json][@tag_1[:tag_group_code].to_sym].any?{ |x| x[:id] == tag[:json][:id] }

  ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_list_payrolls
    payrolls_list = @api.list_payrolls(2016, 2)

    assert_equal 200, payrolls_list[:status].to_i, payrolls_list.inspect
    assert(payrolls_list.size > 0)
  end

  private
  def successful?(status)
    status.to_i == 200
  end
end
