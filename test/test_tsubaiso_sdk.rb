require 'minitest/autorun'
require 'time'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < Minitest::Test
  def setup

    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })

    # data

    @staff_data_1 = {
      code: 'QUALIFICATION',
      value: 'TOEIC',
      start_timestamp: '2016-01-01',
      no_finish_timestamp: '1',
      memo: 'First memo'
    }

    @reimbursement_1 = {
      applicant: 'Irfan',
      application_term: '2016-03-01',
      staff_code: 'EP2000',
      memo: 'aaaaaaaa'
    }

    @reimbursement_2 = {
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

    @reimbursement_tx_2 = {
      transaction_timestamp: '2016-03-01',
      price_value: 20_000,
      dc: 'c',
      reason_code: 'SUPPLIES',
      brief: 'not well',
      memo: 'hard',
      data_partner: { link_url: 'www.example.com/6', id_code: '6' }
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
          },
          tag_list: 'KIWI',
          dept_code: 'SYSTEM'
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
          memo: 'Created From API',
          dept_code: 'R_AND_D'
        }
      ],
      data_partner: { link_url: 'www.example.com/7', id_code: '7' }
    }

    @dept_1 = {
      sort_no: 12_345_678,
      code: 'test_code',
      name: 'テスト部門',
      name_abbr: 'テストブモン',
      color: '#ffffff',
      memo: 'テストメモ',
      start_date: '2016-01-01',
      finish_date: '2016-01-02'
    }

    @tag_1 = {
      code: 'test_code',
      name: 'テストタグ',
      sort_no: 10_000,
      tag_group_code: 'DEFAULT',
      start_ymd: '2016-01-01',
      finish_ymd: '2016-12-31'
    }

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

  end

  def test_failed_request
    @api_fail = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: 'fake token' })
    sale = @api_fail.create_sale(@sale_201608)

    assert_equal 401, sale[:status].to_i, sale.inspect
    assert_equal 'Bad credentials', sale[:json][:error]
  end

  def test_index_api_history
    index = @api.index_api_history
    assert_equal 200, index[:status].to_i, index.inspect
    assert !index[:json].empty?

    initial_api_count = if index[:json].first[:ym] == "#{Time.now.year}#{format('%02d', Time.new.month)}"
                          index[:json].first[:cnt]
                        else
                          0
                        end

    index = @api.index_api_history
    assert_equal 200, index[:status].to_i, index.inspect
    new_api_count = index[:json].first[:cnt]
    assert_equal initial_api_count + 1, new_api_count
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
      assert_equal @manual_journal_1[:journal_dcs][0][:debit][:price_including_tax], manual_journal[:json].first[:journal_dcs][0][:debit][:price_including_tax]
      assert_equal @manual_journal_1[:data_partner][:id_code], manual_journal[:json].first[:data_partner][:id_code]
    ensure
      @api.destroy_manual_journal(manual_journal[:json].first[:id]) if successful?(manual_journal[:status])
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
    assert_equal @reimbursement_tx_1[:data_partner][:id_code], reimbursement_transaction[:json][:data_partner][:id_code]
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

  def test_update_reimbursement
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = {
      applicant: 'test',
      dept_code: 'COMMON'
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
    updates = { :id => reimbursement_transaction[:json][:id], :price_value => 9999, :reason_code => 'SUPPLIES', :data_partner => { :id_code => '500' } }

    updated_reimbursement_transaction = @api.update_reimbursement_transaction(updates)
    assert_equal 200, updated_reimbursement_transaction[:status].to_i, updated_reimbursement_transaction.inspect
    assert_equal updates[:id].to_i, updated_reimbursement_transaction[:json][:id].to_i
    assert_equal updates[:price_value].to_i, updated_reimbursement_transaction[:json][:price_value].to_i
    assert_equal updates[:reason_code], updated_reimbursement_transaction[:json][:reason_code]
    assert_equal updates[:data_partner][:id_code], updated_reimbursement_transaction[:json][:data_partner][:id_code]
  ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction[:json][:id]) if reimbursement_transaction[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_update_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    options = {
      id: manual_journal[:json].first[:id],
      journal_dcs: manual_journal[:json].first[:journal_dcs],
      data_partner: { :id_code => '700' }
    }
    options[:journal_dcs][0][:debit][:price_including_tax]  = 2000
    options[:journal_dcs][0][:credit][:price_including_tax] = 2000
    options[:journal_dcs][0][:memo] = 'Updated from API'
    options[:journal_dcs][1][:dept_code] = 'SETSURITSU'
    options[:journal_dcs][1][:tag_list] = 'GLOZE'

    updated_manual_journal = @api.update_manual_journal(options)
    assert_equal 200, updated_manual_journal[:status].to_i, updated_manual_journal.inspect
    assert_equal options[:journal_dcs][0][:debit][:price_including_tax], updated_manual_journal[:json].first[:journal_dcs][0][:debit][:price_including_tax]
    assert_equal options[:journal_dcs][0][:memo], updated_manual_journal[:json].first[:journal_dcs][0][:memo]
    assert_equal options[:journal_dcs][1][:dept_code], updated_manual_journal[:json].first[:journal_dcs][1][:dept_code]
    assert_equal [options[:journal_dcs][1][:tag_list]], updated_manual_journal[:json].first[:journal_dcs][1][:tag_list]
    assert_equal options[:data_partner][:id_code], updated_manual_journal[:json].first[:data_partner][:id_code]
  ensure
    @api.destroy_manual_journal(manual_journal[:json].first[:id]) if successful?(manual_journal[:status])
  end

  def test_update_dept
    dept = @api.create_dept(@dept_1)
    options = {
      id: dept[:json][:id],
      sort_no: 98_765,
      memo: 'updated at test',
      name: '更新部門',
      name_abbr: '更新部門'
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
    assert tag[:json][:id], tag
    options = {
      name: '更新タグ',
      code: 'updated_tag'
    }

    updated_tag = @api.update_tag(tag[:json][:id], options)
    assert_equal 200, updated_tag[:status].to_i, updated_tag.inspect
    assert_equal options[:name], updated_tag[:json][:name]
    assert_equal options[:code], updated_tag[:json][:code]
  ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_show_staff
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    get_staff_member = @api.show_staff(first_staff_id)
    assert_equal 200, get_staff_member[:status].to_i, get_staff_member.inspect
    assert_equal first_staff_id, get_staff_member[:json][:id]
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

    # get data using code
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

  def test_show_reimbursement_reason_master
    reim_reason_msts = @api.list_reimbursement_reason_masters
    reim_reason_mst_id = reim_reason_msts[:json].first[:id]
    reim_reason_mst = @api.show_reimbursement_reason_master(reim_reason_mst_id)

    assert_equal 200, reim_reason_mst[:status].to_i, reim_reason_mst.inspect
    assert_equal reim_reason_mst[:json][:id], reim_reason_mst_id
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
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    manual_journals_list = @api.list_manual_journals(2016, 4)
    last_manual_journal_id = manual_journals_list[:json].last[:id]

    manual_journal = @api.show_manual_journal(last_manual_journal_id)
    assert_equal 200, manual_journal[:status].to_i, manual_journal.inspect
    assert_equal last_manual_journal_id, manual_journal[:json].first[:id]
  ensure
    @api.destroy_manual_journal(manual_journal[:json].first[:id]) if successful?(manual_journal[:status])
  end

  def test_show_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    journals_list = @api.list_journals({ start_date: '2016-04-01', finish_date: '2016-04-30' })
    first_journal_id = journals_list[:json][:records].first[:id]

    journal = @api.show_journal(first_journal_id)
    assert_equal 200, journal[:status].to_i, journal.inspect
    assert_equal first_journal_id, journal[:json][:records][:id]
  ensure
    @api.destroy_manual_journal(manual_journal[:json].first[:id]) if successful?(manual_journal[:status])
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

  def test_show_bonus
    bonuses = @api.list_bonuses(1, 2016)
    bonus_id = bonuses[:json].first[:id]
    bonus = @api.show_bonus(bonus_id)

    assert_equal 200, bonus[:status].to_i, bonus.inspect
    assert_equal bonus[:json][:id], bonus_id
  end

  def test_show_payroll
    payrolls_list = @api.list_payrolls(2017, 2)
    first_payroll_id = payrolls_list[:json].first[:id]

    payroll = @api.show_payroll(first_payroll_id)
    assert_equal 200, payroll[:status].to_i, payroll.inspect
    assert_equal first_payroll_id, payroll[:json][:id]
  end

  def test_show_ap_reason_master
    ap_reason_masters = @api.list_ap_reason_masters
    first_ap_reason_master = ap_reason_masters[:json].first
    ap_reason_master = @api.show_ap_reason_master(first_ap_reason_master[:id])

    assert_equal 200, ap_reason_master[:status].to_i, ap_reason_master.inspect
    assert_equal first_ap_reason_master[:reason_code], ap_reason_master[:json][:reason_code]
  end

  def test_show_ar_reason_master
    ar_reason_masters = @api.list_ar_reason_masters
    ar_reason_master_id = ar_reason_masters[:json].first[:id]
    ar_reason_master = @api.show_ar_reason_master(ar_reason_master_id)

    assert_equal 200, ar_reason_master[:status].to_i, ar_reason_master.inspect
    assert_equal ar_reason_master[:json][:id], ar_reason_master_id
  end

  def test_show_tax_master
    tax_masters = @api.list_tax_masters
    first_tax_master = tax_masters[:json].first
    tax_master = @api.show_tax_master(first_tax_master[:id])

    assert_equal 200, tax_master[:status].to_i, tax_master.inspect
    assert_equal first_tax_master[:name], tax_master[:json][:name]
  end

  def test_show_corporate_master
    # With HatagayaTest CorporateMaster ID Only
    shown_corporate_master = @api.show_corporate_master(2099)
    assert_equal 90020, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷システム株式会社（開発テスト）', shown_corporate_master[:json][:name]

    # With HatagayaTest Corporate Code Only
    shown_corporate_master = @api.show_corporate_master(nil, { ccode: 90020 })
    assert_equal 90020, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷システム株式会社（開発テスト）', shown_corporate_master[:json][:name]

    # With HatagayaTest Both CorporateMaster ID and Corporate Code
    shown_corporate_master = @api.show_corporate_master(2099, { ccode: 90020 })
    assert_equal 90020, shown_corporate_master[:json][:corporate_code]
    assert_equal '幡ヶ谷システム株式会社（開発テスト）', shown_corporate_master[:json][:name]
  end

  def test_list_sales_and_account_balances
    realization_timestamp = Time.parse(@sale_201702[:realization_timestamp])

    # Without customer_master_code and ar_segment option parameters
    balance_list_before = @api.list_sales_and_account_balances(realization_timestamp.year, realization_timestamp.month)
    assert_equal 200, balance_list_before[:status].to_i, balance_list_before.inspect

    new_sale = @api.create_sale(@sale_201702)
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


  def test_list_staff
    staff_list = @api.list_staff
    assert_equal 200, staff_list[:status].to_i, staff_list.inspect
    assert !staff_list.empty?
  end

  def test_list_staff_data
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    staff_data_list = @api.list_staff_data(first_staff_id)
    assert_equal 200, staff_data_list[:status].to_i, staff_data_list.inspect
    assert(staff_data_list[:json].all? { |x| x[:staff_id] == first_staff_id })
  end

  def test_list_staff_datum_masters
    staff_datum_masters_list = @api.list_staff_datum_masters
    assert_equal 200, staff_datum_masters_list[:status].to_i, staff_datum_masters_list.inspect
    assert !staff_datum_masters_list.empty?
  end

  def test_list_manual_journals
    manual_journals_list = @api.list_manual_journals(2016, 4)
    assert_equal 200, manual_journals_list[:status].to_i, manual_journals_list.inspect
    assert !manual_journals_list.empty?
  end

  def test_list_journals
    august_sale = @api.create_sale(@sale_201608)
    september_sale = @api.create_sale(@sale_201609)
    august_purchase = @api.create_purchase(@purchase_201608)
    september_purchase = @api.create_purchase(@purchase_201609)
    assert_equal 200, august_sale[:status].to_i
    assert_equal 200, september_sale[:status].to_i
    assert_equal 200, august_purchase[:status].to_i
    assert_equal 200, september_purchase[:status].to_i

    options = { start_date: '2016-08-01', finish_date: '2016-08-31' }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_timestamps = records.map { |x| Time.parse(x[:journal_timestamp]) }
    assert_includes record_timestamps, Time.parse(august_sale[:json][:realization_timestamp])
    assert_includes record_timestamps, Time.parse(august_purchase[:json][:accrual_timestamp])

    options = { price: 10_800 }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    record_prices = records.map { |x| x[:journal_dcs].map { |y| y[:debit][:price_including_tax] } }.flatten(1)
    assert_includes record_prices, august_sale[:json][:price_including_tax]
    assert_includes record_prices, september_sale[:json][:price_including_tax]

    options = { dept_code: 'SETSURITSU' }
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
    assert(reimbursements_list[:json].any? { |x| x[:id] == reimbursement_a_id })
    assert(reimbursements_list[:json].any? { |x| x[:id] == reimbursement_b_id })
  ensure
    @api.destroy_reimbursement(reimbursement_a_id) if reimbursement_a_id
    @api.destroy_reimbursement(reimbursement_b_id) if reimbursement_b_id
  end

  def test_list_reimbursement_reason_masters
    reimbursement_reason_masters_list = @api.list_reimbursement_reason_masters
    assert_equal 200, reimbursement_reason_masters_list[:status].to_i, reimbursement_reason_masters_list.inspect
    assert reimbursement_reason_masters_list[:json]
    assert !reimbursement_reason_masters_list[:json].empty?
  end

  def test_list_reimbursement_transactions
    reimbursement = @api.create_reimbursement(@reimbursement_1)
    options = { :reimbursement_id => reimbursement[:json][:id].to_i }
    reimbursement_transaction_1 = @api.create_reimbursement_transaction(@reimbursement_tx_1.merge(options))
    reimbursement_transaction_2 = @api.create_reimbursement_transaction(@reimbursement_tx_2.merge(options))

    reimbursement_transactions = @api.list_reimbursement_transactions(reimbursement[:json][:id])
    assert_equal 200, reimbursement_transactions[:status].to_i, reimbursement_transactions.inspect
    assert(reimbursement_transactions[:json].any? { |x| x[:id] == reimbursement_transaction_1[:json][:id] })
    assert(reimbursement_transactions[:json].any? { |x| x[:id] == reimbursement_transaction_2[:json][:id] })
  ensure
    @api.destroy_reimbursement_transaction(reimbursement_transaction_1[:json][:id]) if reimbursement_transaction_1[:json][:id]
    @api.destroy_reimbursement_transaction(reimbursement_transaction_2[:json][:id]) if reimbursement_transaction_2[:json][:id]
    @api.destroy_reimbursement(reimbursement[:json][:id]) if reimbursement[:json][:id]
  end

  def test_list_depts
    dept = @api.create_dept(@dept_1)
    assert_equal 200, dept[:status].to_i, dept.inspect

    depts = @api.list_depts
    assert_equal 200, depts[:status].to_i, depts.inspect
    assert(depts[:json].any? { |x| x[:id] == dept[:json][:id] })
  ensure
    @api.destroy_dept(dept[:json][:id]) if dept[:json][:id]
  end

  def test_list_tax_masters
    tax_masters = @api.list_tax_masters
    assert_equal 200, tax_masters[:status].to_i, tax_masters.inspect
    assert !tax_masters[:json].empty?
  end

  def test_list_tags
    tag = @api.create_tag(@tag_1)

    tags = @api.list_tags
    assert_equal 200, tags[:status].to_i, tags.inspect
    assert(tags[:json][@tag_1[:tag_group_code].to_sym].any? { |x| x[:id] == tag[:json][:id] })
  ensure
    @api.destroy_tag(tag[:json][:id]) if tag[:json][:id]
  end

  def test_list_bonuses
    bonuses_list = @api.list_bonuses(1, 2016)
    assert_equal 200, bonuses_list[:status].to_i, bonuses_list.inspect
    assert bonuses_list[:json]
    assert !bonuses_list[:json].empty?
  end

  def test_list_payrolls
    payrolls_list = @api.list_payrolls(2016, 2)

    assert_equal 200, payrolls_list[:status].to_i, payrolls_list.inspect
    assert !payrolls_list.empty?
  end

  def test_list_ar_reason_masters
    ar_reason_masters_list = @api.list_ar_reason_masters
    assert_equal 200, ar_reason_masters_list[:status].to_i, ar_reason_masters_list.inspect
    assert ar_reason_masters_list[:json]
    assert !ar_reason_masters_list[:json].empty?
  end

  def test_list_ap_reason_masters
    ap_reason_masters_list = @api.list_ap_reason_masters
    assert_equal 200, ap_reason_masters_list[:status].to_i, ap_reason_masters_list.inspect
    assert ap_reason_masters_list[:json]
    assert !ap_reason_masters_list[:json].empty?
  end

  def test_list_fixed_assets
    list = @api.list_fixed_assets
    assert_equal 200, list[:status].to_i, list.inspect
    assert list[:json]
    assert !list[:json].empty?
  end

  def test_list_api_history
    options = {
      month: Date.today.month,
      year: Date.today.year
    }
    list = @api.list_api_history(options)
    assert_equal 200, list[:status].to_i, list.inspect
    list_count = list[:json].count

    list_again = @api.list_api_history(options)
    assert_equal 200, list[:status].to_i, list.inspect
    assert_equal list_again[:json].first[:controller], 'api_histories'
    assert_equal list_again[:json].first[:method], 'list'
    assert_equal list_count, list_again[:json].count - 1
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
