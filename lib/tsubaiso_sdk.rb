class TsubaisoSDK
  require 'net/http'
  require 'json'
  require_relative './debug_patch.rb'
  prepend ApiDebug

  module UrlBuilder
    def url(root, resource, method, year = nil, month = nil)
      require_yms = %w(ar ap_payments manual_journals reimbursement_transactions bank_accounts)
      if require_yms.include?(resource) && method == "list"
        return root + "/" + resource + "/list/" + year.to_s + "/" + month.to_s
      else
        return root + "/" + resource + "/" + method
      end
    end
  end

  def initialize(options = {})
    @base_url = options[:base_url] || 'https://tsubaiso.net'
    @access_token = options[:access_token] || "Fake_Token"
  end

  def list_bank_account_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/bank_account_masters/list')
    api_request(uri, 'GET', params)
  end

  def update_bank_account_master(options)
    params = {}
    candidate_keys = [
      :name,
      :account_type,
      :account_number,
      :nominee,
      :memo,
      :start_ymd,
      :finish_ymd,
      :zengin_bank_code,
      :zengin_branch_code,
      :zengin_client_code_sogo,
      :currency_code,
      :currency_rate_master_code
    ]

    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + '/bank_account_masters/update/' + options[:id].to_s)
    api_request(uri, 'POST', params)
  end

  def list_bank_account_transactions(bank_account_id)
    params = {
      'format' => 'json',
      'bank_account_id' => bank_account_id.to_i
    }
    uri = URI.parse(@base_url + "/bank_account_transactions/list")
    api_request(uri, 'GET', params)
  end

  def show_bank_account_transaction(id)
    params = {
      'format' => 'json',
    }
    uri = URI.parse(@base_url + "/bank_account_transactions/show/#{id}")
    api_request(uri, 'GET', params)
  end

  def create_bank_account_transaction(options)
    params = {
      'bank_account_id' => options[:bank_account_id],
      'journal_timestamp' => options[:journal_timestamp],
      'price_value' => options[:price_value],
      'price_value_fc' => options[:price_value_fc],
      'exchange_rate' => options[:exchange_rate],
      'reason_code' => options[:reason_code],
      'dc' => options[:dc],
      'brief' => options[:brief],
      'memo' => options[:memo],
      'tag_list' => options[:tag_list],
      'dept_code' => options[:dept_code],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/bank_account_transactions/create')
    api_request(uri, 'POST', params)
  end

  def destroy_bank_account_transaction(id)
    params = {
      'format' => 'json'
    }
    uri = URI.parse(@base_url + "/bank_account_transactions/destroy/#{id}")
    api_request(uri, 'POST', params)
  end

  def update_bank_account_transaction(options)
    params = {}
    candidate_keys = [
      :bank_account_id,
      :journal_timestamp,
      :price_value,
      :price_value_fc,
      :exchange_rate,
      :reason_code,
      :dc,
      :brief,
      :memo,
      :tag_list,
      :dept_code,
    ]

    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/bank_account_transactions/update/#{options[:id]}")
    api_request(uri, "POST",params)
  end

  def list_bank_account(options)
    params = {
      'format' => 'json',
    }
    uri = URI.parse(@base_url + "/bank_accounts/list/#{options[:year]}/#{options[:month]}")
    api_request(uri,'GET',params)
  end

  def create_bank_account(options)
    params = {
      'bank_account_master_id' => options[:bank_account_master_id],
      'start_timestamp' => options[:start_timestamp],
      'finish_timestamp' => options[:finish_timestamp],
      'format' => 'json'
    }

    uri = URI.parse(@base_url + '/bank_accounts/create')
    api_request(uri, 'POST', params)
  end

  def show_bank_account_master(master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/bank_account_masters/show/' + master_id.to_s)
    api_request(uri, 'GET', params)
  end

  def destroy_bank_account_master(destroy_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/bank_account_masters/destroy/' + destroy_id.to_s)
    api_request(uri, 'POST', params)
  end

  def create_bank_account_master(options)
    params = {
      'format' => 'json',
      'name' => options[:name],
      'account_type' => options[:account_type],
      'account_number' => options[:account_number],
      'nominee' => options[:nominee],
      'memo' => options[:memo],
      'start_ymd' => options[:start_ymd],
      'finish_ymd' => options[:finish_ymd],
      'zengin_bank_code' => options[:zengin_bank_code],
      'zengin_branch_code' => options[:zengin_branch_code],
      'zengin_client_code_sogo' => options[:zengin_client_code_sogo],
      'currency_code' => options[:currency_code],
      'currency_rate_master_code' => options[:currency_rate_master_code]
    }

    uri = URI.parse(@base_url + '/bank_account_masters/create')
    api_request(uri, 'POST', params)
  end

  def index_api_history
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/api_histories/index')
    api_request(uri, 'GET', params)
  end

  def list_sales(year, month)
    params = {
      'format' => 'json'
    }
    uri = URI.parse(@base_url + "/ar/list/#{year.to_i}/#{month.to_i}")
    api_request(uri, 'GET', params)
  end

  def list_sales_and_account_balances(year, month, options = {})
    params = {
      'year' => year,
      'month' => month,
      'customer_master_id' => options[:customer_master_id],
      'ar_segment' => options[:ar_segment],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/ar_receipts/balance')
    api_request(uri, 'GET', params)
  end

  def list_purchases(year, month)
    params = {
      'format' => 'json'
    }
    uri = URI.parse(@base_url + "/ap_payments/list/#{year.to_i}/#{month.to_i}")
    api_request(uri, 'GET', params)
  end

  def list_purchases_and_account_balances(year, month, options = {})
    params = {
      'year' => year,
      'month' => month,
      'customer_master_id' => options[:customer_master_id],
      'ap_segment' => options[:ap_segment],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/ap_payments/balance')
    api_request(uri, 'GET', params)
  end

  def list_customers
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/customer_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_payrolls(year, month)
    params = {
      'format' => 'json',
      'year' => year,
      'month' => month
    }
    uri = URI.parse(@base_url + '/payrolls/list')
    api_request(uri, 'GET', params)
  end

  def list_staff
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/staffs/list')
    api_request(uri, 'GET', params)
  end

  def list_staff_data(staff_id)
    params = {
      'format' => 'json',
      'staff_id' => staff_id
    }
    uri = URI.parse(@base_url + '/staff_data/list')
    api_request(uri, 'GET', params)
  end

  def list_staff_datum_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/staff_datum_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_reimbursements(year, month)
    params = {
      'format' => 'json',
      'year' => year,
      'month' => month
    }
    uri = URI.parse(@base_url + '/reimbursements/list')
    api_request(uri, 'GET', params)
  end

  def list_reimbursement_transactions(reimbursement_id)
    params = {
      'format' => 'json',
      'id' => reimbursement_id.to_i
    }
    uri = URI.parse(@base_url + '/reimbursement_transactions/list')
    api_request(uri, 'GET', params)
  end

  def list_reimbursement_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/reimbursement_reason_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_manual_journals(year, month)
    params = {
      'year' => year,
      'month' => month,
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/manual_journals/list')
    api_request(uri, 'GET', params)
  end

  def list_journals(options)
    params = {
      'start_date' => options[:start_date],
      'finish_date' => options[:finish_date],
      'start_created_at' => options[:start_created_at],
      'finish_created_at' => options[:finish_created_at],
      'timestamp_order' => options[:timestamp_order],
      'account_codes' => options[:account_codes],
      'price' => options[:price],
      'memo' => options[:memo],
      'dept_code' => options[:dept_code],
      'tag_list' => options[:tag_list],
      'id' => options[:id],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/journals/list/')
    api_request(uri, 'GET', params)
  end

  def list_depts
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/depts/list/')
    api_request(uri, 'GET', params)
  end

  def list_tax_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/tax_masters/list/')
    api_request(uri, 'GET', params)
  end

  def list_tags
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/tags/list/')
    api_request(uri, 'GET', params)
  end

  def list_bonuses(bonus_no, target_year)
    params = {
      'format' => 'json',
      'bonus_no' => bonus_no,
      'target_year' => target_year
    }
    uri = URI.parse(@base_url + '/bonuses/list/')
    api_request(uri, 'GET', params)
  end

  def list_ap_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/ap_reason_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_ar_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/ar_reason_masters/list/')
    api_request(uri, 'GET', params)
  end

  def list_physical_inventory_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/physical_inventory_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_bank_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/bank_reason_masters/list')
    api_request(uri, 'GET', params)
  end

  # Alpha version now.
  def list_fixed_assets
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/fixed_assets/list/')
    api_request(uri, 'GET', params)
  end

  def list_petty_cash_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/petty_cash_reason_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_api_history(options)
    params = {
      'format' => 'json',
      'month' => options[:month],
      'year' => options[:year]
    }
    uri = URI.parse(@base_url + '/api_histories/list/')
    api_request(uri, 'GET', params)
  end

  def show_sale(voucher)
    sale_id = voucher.scan(/\d/).join('')
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ar/show/#{sale_id}")
    api_request(uri, 'GET', params)
  end

  def show_tax_master(tax_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/tax_masters/show/#{tax_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join('')
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ap_payments/show/#{purchase_id}")
    api_request(uri, 'GET', params)
  end

  def show_customer(customer_id)
    customer_id = customer_id.to_i
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/customer_masters/show/#{customer_id}")
    api_request(uri, 'GET', params)
  end

  def show_customer_by_code(code)
    params = {
      'code' => code,
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/customer_masters/show')
    api_request(uri, 'GET', params)
  end

  def show_staff(staff_id)
    staff_id = staff_id.to_i
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/staffs/show/#{staff_id}")
    api_request(uri, 'GET', params)
  end

  def show_staff_data(options)
    if options.is_a?(Hash)
      params = {
        'staff_id' => options[:staff_id],
        'code' => options[:code],
        'time' => options[:time],
        'format' => 'json'
      }
      # id = options[:id]
    else
      params = { 'format' => 'json' }
      id = "/" + options.to_s
    end
    uri = URI.parse(@base_url + "/staff_data/show#{id}")
    api_request(uri, 'GET', params)
  end

  def show_staff_datum_master(options)
    if options.is_a?(Hash)
      params = {
        'code' => options[:code],
        'format' => 'json'
      }
      id = options[:id]
    else
      params = { 'format' => 'json' }
      id = options
    end
    uri = URI.parse(@base_url + "/staff_datum_masters/show/#{id}")
    api_request(uri, 'GET', params)
  end

  def show_manual_journal(manual_journal_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/manual_journals/show/#{manual_journal_id}")
    api_request(uri, 'GET', params)
  end

  def show_journal(journal_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/journals/show/#{journal_id}")
    api_request(uri, 'GET', params)
  end

  def show_reimbursement(reimbursement_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/reimbursements/show/#{reimbursement_id}")
    api_request(uri, 'GET', params)
  end

  def show_reimbursement_transaction(reimbursement_transaction_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/reimbursement_transactions/show/#{reimbursement_transaction_id}")
    api_request(uri, 'GET', params)
  end

  def show_reimbursement_reason_master(reimbursement_reason_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/reimbursement_reason_masters/show/#{reimbursement_reason_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_dept(dept_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/depts/show/#{dept_id}")
    api_request(uri, 'GET', params)
  end

  def show_tag(tag_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/tags/show/#{tag_id}")
    api_request(uri, 'GET', params)
  end

  def show_bonus(bonus_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/bonuses/show/#{bonus_id}")
    api_request(uri, 'GET', params)
  end

  def show_payroll(payroll_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/payrolls/show/#{payroll_id}")
    api_request(uri, 'GET', params)
  end

  def show_ar_reason_master(ar_reason_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ar_reason_masters/show/#{ar_reason_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_ap_reason_master(ap_reason_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ap_reason_masters/show/#{ap_reason_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_physical_inventory_master(physical_inventory_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/physical_inventory_masters/show/#{physical_inventory_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_bank_reason_master(bank_reason_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/bank_reason_masters/show/#{bank_reason_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_petty_cash_reason_master(petty_cash_reason_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/petty_cash_reason_masters/show/#{petty_cash_reason_master_id}")
    api_request(uri, 'GET', params)
  end

  def show_corporate_master(corporate_master_id, options = {})
    params = {
      'ccode' => options[:ccode],
      'format' => 'json'
    }

    uri = URI.parse(@base_url + "/corporate_masters/show/#{corporate_master_id}")
    api_request(uri, 'GET', params)
  end

  def create_customer(options)
    available_keys = [
      'accountant_email',
      'address',
      'administrator_name',
      'ap_account_code',
      'ap_reason_selections',
      'ar_account_code',
      'ar_reason_selections',
      'bank_account_number',
      'bank_branch_code',
      'bank_branch_name',
      'bank_code',
      'bank_course',
      'bank_name',
      'bank_nominee',
      'bill_detail_round_rule',
      'code',
      'dept_code',
      'email',
      'fax',
      'finish_timestamp',
      'foreign_currency',
      'is_valid',
      'locale',
      'name',
      'name_kana',
      'need_tax_deductions',
      'pay_closing_schedule',
      'pay_interface_id',
      'pay_sight',
      'receive_closing_schedule',
      'receive_interface_id',
      'receive_sight',
      'sender_name',
      'sort_no',
      'start_timestamp',
      'tax_type_for_remittance_charge',
      'tel',
      'memo',
      'used_in_ap',
      'used_in_ar',
      'withholding_tax_base',
      'withholding_tax_segment',
      'zip',
      'pay_date_if_holiday',
      'receive_date_if_holiday',
      'data_partner'
    ]
    params = {}
    available_keys.each do |key|
      params[key.to_s] = options[key.to_sym]  if options.has_key?(key.to_sym)
    end
    params['format'] = 'json'

    uri = URI.parse(@base_url + '/customer_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_bank_reason_masters(options)
    params = {
      'sort_number' => options[:sort_number],
      'reason_code' => options[:reason_code],
      'reason_name' => options[:reason_name],
      'dc' => options[:dc],
      'is_valid' => options[:is_valid],
      'memo' => options[:memo],
      'account_code' => options[:account_code],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/bank_reason_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_sale(options)
    params = {
      'price_including_tax' => options[:price_including_tax],
      'realization_timestamp' => options[:realization_timestamp],
      'customer_master_code' => options[:customer_master_code],
      'dept_code' => options[:dept_code],
      'reason_master_code' => options[:reason_master_code],
      'dc' => options[:dc],
      'memo' => options[:memo],
      'tax_code' => options[:tax_code],
      'sales_tax' => options[:sales_tax],
      'scheduled_memo' => options[:scheduled_memo],
      'scheduled_receive_timestamp' => options[:scheduled_receive_timestamp],
      'tag_list' => options[:tag_list],
      'data_partner' => options[:data_partner],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/ar/create')
    api_request(uri, 'POST', params)
  end

  def find_or_create_sale(options)
    params = {}
    available_keys = [
      'price_including_tax',
      'realization_timestamp',
      'customer_master_code',
      'dept_code',
      'reason_master_code',
      'dc',
      'memo',
      'tax_code',
      'sales_tax',
      'scheduled_memo',
      'scheduled_receive_timestamp',
      'tag_list',
      'data_partner',
      'key'
    ]
    available_keys.each do |key|
      params[key.to_s] = options[key.to_sym] if options.has_key?(key.to_sym)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + '/ar/find_or_create')
    api_request(uri, 'POST', params)
  end

  def create_purchase(options)
    params = {
      'price_including_tax' => options[:price_including_tax],
      'accrual_timestamp' => options[:accrual_timestamp],
      'customer_master_code' => options[:customer_master_code],
      'dept_code' => options[:dept_code],
      'reason_master_code' => options[:reason_master_code],
      'dc' => options[:dc],
      'memo' => options[:memo],
      'tax_code' => options[:tax_code],
      'port_type' => options[:port_type],
      'tag_list' => options[:tag_list],
      'data_partner' => options[:data_partner],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/ap_payments/create')
    api_request(uri, 'POST', params)
  end

  def find_or_create_purchase(options)
    params = {
      'price_including_tax' => options[:price_including_tax],
      'accrual_timestamp' => options[:accrual_timestamp],
      'customer_master_code' => options[:customer_master_code],
      'dept_code' => options[:dept_code],
      'reason_master_code' => options[:reason_master_code],
      'dc' => options[:dc],
      'memo' => options[:memo],
      'tax_code' => options[:tax_code],
      'port_type' => options[:port_type],
      'tag_list' => options[:tag_list],
      'data_partner' => options[:data_partner],
      'key' => options[:key],
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/ap_payments/find_or_create')
    api_request(uri, 'POST', params)
  end

  def create_staff_data(options)
    params = {
      'staff_id' => options[:staff_id],
      'code' => options[:code],
      'memo' => options[:memo],
      'value' => options[:value],
      'start_timestamp' => options[:start_timestamp],
      'format' => 'json'
    }

    if options[:finish_timestamp]
      params[:finish_timestamp] = options[:finish_timestamp]
    elsif options[:no_finish_timestamp]
      params[:no_finish_timestamp] = options[:no_finish_timestamp]
    end

    uri = URI.parse(@base_url + '/staff_data/create')
    api_request(uri, 'POST', params)
  end

  def create_manual_journal(options)
    params = {
      'journal_timestamp' => options[:journal_timestamp],
      'journal_dcs' => make_journal_dcs(options[:journal_dcs]),
      'data_partner' => options[:data_partner],
      'format' => 'json'
    }

    uri = URI.parse(@base_url + '/manual_journals/create')
    api_request(uri, 'POST', params)
  end

  def create_reimbursement(options)
    params = {
      'format' => 'json',
      'applicant' => options[:applicant],
      'application_term' => options[:application_term],
      'staff_code' => options[:staff_code],
      'dept_code' => options[:dept_code],
      'memo' => options[:memo]
    }
    uri = URI.parse(@base_url + '/reimbursements/create')
    api_request(uri, 'POST', params)
  end

  def create_reimbursement_transaction(options)
    params = {
      'format' => 'json',
      'reimbursement_id' => options[:reimbursement_id].to_i,
      'transaction_timestamp' => options[:transaction_timestamp],
      'price_value' => options[:price_value],
      'reason_code' => options[:reason_code],
      'port_type' => options[:port_type],
      'dc' => options[:dc],
      'brief' => options[:brief],
      'memo' => options[:memo],
      'tag_list' => options[:tag_list],
      'tax_type' => options[:tax_type],
      'data_partner' => options[:data_partner]
    }
    uri = URI.parse(@base_url + '/reimbursement_transactions/create')
    api_request(uri, 'POST', params)
  end

  def create_dept(options)
    params = {
      'format' => 'json',
      'sort_no' => options[:sort_no],
      'code' => options[:code],
      'name' => options[:name],
      'name_abbr' => options[:name_abbr],
      'color' => options[:color],
      'memo' => options[:memo],
      'start_date' => options[:start_date],
      'finish_date' => options[:finish_date]
    }
    uri = URI.parse(@base_url + '/depts/create')
    api_request(uri, 'POST', params)
  end

  def create_tag(options)
    params = {
      'format' => 'json',
      'code' => options[:code],
      'name' => options[:name],
      'sort_no' => options[:sort_no],
      'tag_group_code' => options[:tag_group_code],
      'start_ymd' => options[:start_ymd],
      'finish_ymd' => options[:finish_ymd]
    }
    uri = URI.parse(@base_url + '/tags/create')
    api_request(uri, 'POST', params)
  end

  def create_journal_distribution(options)
    params = {
      'format' => 'json',
      'search_conditions' => {
        'start_date' => options[:start_date],
        'finish_date' => options[:finish_date],
        'account_codes' => options[:account_codes],
        'dept_code' => options[:dept_code],
        'tag_list' => options[:tag_list]
      },
      'title' => options[:title],
      'target_timestamp' => options[:target_timestamp],
      'memo' => options[:memo],
      'criteria' => options[:criteria],
      'distribution_conditions' => options[:distribution_conditions]
    }
    uri = URI.parse(@base_url + '/journal_distributions/create')
    api_request(uri, 'POST', params)
  end

  def create_petty_cash_reason_master(options)
    params = {
      'format' => 'json',
      'reason_code' => options[:reason_code],
      'reason_name' => options[:reason_name],
      'dc' => options[:dc],
      'account_code' => options[:account_code],
      'is_valid' => options[:is_valid],
      'memo' => options[:memo],
      'port_type' => options[:port_type],
      'sort_number' => options[:sort_number]
    }
    uri = URI.parse(@base_url + '/petty_cash_reason_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_physical_inventory_masters(options)
    params = {}
    candidate_keys = [:name, :start_ymd, :finish_ymd, :memo, :tag_list, :dept_code]
    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'

    uri = URI.parse(@base_url + '/physical_inventory_masters/create')
    api_request(uri, 'POST', params)
  end

  def update_sale(options)
    available_keys = [
      'id',
      'price_including_tax',
      'realization_timestamp',
      'customer_master_code',
      'dept_code',
      'reason_master_code',
      'dc',
      'memo',
      'tax_code',
      'sales_tax',
      'scheduled_memo',
      'scheduled_receive_timestamp',
      'tag_list',
      'data_partner'
    ]
    params = {}
    available_keys.each do |key|
      params[key.to_s] = options[key.to_sym] if options.has_key?(key.to_sym)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/ar/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def update_purchase(options)
    params = options.merge({ 'format' => 'json' })

    uri = URI.parse(@base_url + "/ap_payments/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def update_customer(options)
    available_keys = [
      'accountant_email',
      'address',
      'administrator_name',
      'ap_account_code',
      'ap_reason_selections',
      'ar_account_code',
      'ar_reason_selections',
      'bank_account_number',
      'bank_branch_code',
      'bank_branch_name',
      'bank_code',
      'bank_course',
      'bank_name',
      'bank_nominee',
      'bill_detail_round_rule',
      'code',
      'dept_code',
      'email',
      'fax',
      'finish_timestamp',
      'foreign_currency',
      'is_valid',
      'locale',
      'name',
      'name_kana',
      'need_tax_deductions',
      'pay_closing_schedule',
      'pay_interface_id',
      'pay_sight',
      'receive_closing_schedule',
      'receive_interface_id',
      'receive_sight',
      'sender_name',
      'sort_no',
      'start_timestamp',
      'tax_type_for_remittance_charge',
      'tel',
      'memo',
      'used_in_ap',
      'used_in_ar',
      'withholding_tax_base',
      'withholding_tax_segment',
      'zip',
      'pay_date_if_holiday',
      'receive_date_if_holiday',
      'data_partner'
    ]
    params = {}
    available_keys.each do |key|
      params[key.to_s] = options[key.to_sym] if options.has_key?(key.to_sym)
    end
    params['format'] = 'json'

    uri = URI.parse(@base_url + "/customer_masters/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def update_bank_reason_masters(options)
    params = {}
    candidate_keys = [
      :sort_number,
      :reason_code,
      :reason_name,
      :dc,
      :is_valid,
      :memo,
      :account_code
    ]

    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + '/bank_reason_masters/update/' + options[:id].to_s)
    api_request(uri, "POST",params)
  end

  def update_staff_data(options)
    params = {
      'memo' => options[:memo],
      'value' => options[:value],
      'start_timestamp' => options[:start_timestamp],
      'format' => 'json'
    }

    if options[:finish_timestamp]
      params[:finish_timestamp] = options[:finish_timestamp]
    elsif options[:no_finish_timestamp]
      params[:no_finish_timestamp] = options[:no_finish_timestamp]
    end

    uri = URI.parse(@base_url + "/staff_data/update/#{options[:staff_id]}")
    api_request(uri, 'POST', params)
  end

  def update_manual_journal(options)
    params = {
      'journal_timestamp' => options[:journal_timestamp],
      'journal_dcs' => make_journal_dcs(options[:journal_dcs]),
      'data_partner' => options[:data_partner],
      'format' => 'json'
    }

    uri = URI.parse(@base_url + "/manual_journals/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def update_reimbursement(reimbursement_id, options)
    params = {}
    candidate_keys = [
      :applicant,
      :application_term,
      :staff_code,
      :dept_code,
      :memo,
    ]
    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/reimbursements/update/#{reimbursement_id}")
    api_request(uri, 'POST', params)
  end

  def update_reimbursement_transaction(options)
    params = {
      'format' => 'json',
      'port_type' => options[:port_type],
      'transaction_timestamp' => options[:transaction_timestamp],
      'price_value' => options[:price_value],
      'dc' => options[:dc],
      'reason_code' => options[:reason_code],
      'brief' => options[:brief],
      'memo'  => options[:memo],
      'tag_list' => options[:tag_list],
      'tax_type' => options[:tax_type],
      'data_partner' => options[:data_partner]
    }
    uri = URI.parse(@base_url + "/reimbursement_transactions/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def update_dept(dept_id, options)
    params = {
      'format' => 'json',
      'sort_no' => options[:sort_no],
      'code' => options[:code],
      'name' => options[:name],
      'name_abbr' => options[:name_abbr],
      'color' => options[:color],
      'memo' => options[:memo],
      'start_date' => options[:start_date],
      'finish_date' => options[:finish_date]
    }
    uri = URI.parse(@base_url + "/depts/update/#{dept_id}")
    api_request(uri, 'POST', params)
  end

  def update_tag(tag_id, options)
    params = {
      'format' => 'json',
      'code' => options[:code],
      'name' => options[:name],
      'sort_no' => options[:sort_no],
      'tag_group_code' => options[:tag_group_code],
      'start_ymd' => options[:start_ymd],
      'finish_ymd' => options[:finish_ymd]
    }
    uri = URI.parse(@base_url + "/tags/update/#{tag_id}")
    api_request(uri, 'POST', params)
  end

  def update_petty_cash_reason_master(petty_cash_reason_master_id, options)
    params = {}
    candidate_keys = [
      :reason_code,
      :reason_name,
      :dc,
      :account_code,
      :is_valid,
      :memo,
      :port_type,
      :sort_number
    ]
    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/petty_cash_reason_masters/update/#{petty_cash_reason_master_id}")
    api_request(uri, 'POST', params)
  end

  def update_physical_inventory_masters(options)
    params = {}
    candidate_keys = [:name, :start_ymd, :finish_ymd, :memo]
    candidate_keys.each do |key|
      params[key.to_s] = options[key] if options.has_key?(key)
    end
    params['format'] = 'json'

    uri = URI.parse(@base_url + "/physical_inventory_masters/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def destroy_sale(voucher)
    sale_id = voucher.scan(/\d/).join('')
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ar/destroy/#{sale_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_bank_reason_masters(destroy_id)
    params = {'format' => 'json'}
    uri = URI.parse(@base_url + '/bank_reason_masters/destroy/' + destroy_id.to_s)
    api_request(uri,"POST",params)
  end

  def destroy_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join('')
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ap/destroy/#{purchase_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_customer(customer_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/customer_masters/destroy/#{customer_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_staff_data(staff_data_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/staff_data/destroy/#{staff_data_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_manual_journal(manual_journal_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/manual_journals/destroy/#{manual_journal_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_reimbursement(reimbursement_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/reimbursements/destroy/#{reimbursement_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_reimbursement_transaction(reimbursement_transaction_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/reimbursement_transactions/destroy/#{reimbursement_transaction_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_dept(dept_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/depts/destroy/#{dept_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_tag(tag_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/tags/destroy/#{tag_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_journal_distribution(journal_distribution_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/journal_distributions/destroy/#{journal_distribution_id}")
    api_request(uri, 'POST', params)
  end

  # Alpha version now.
  def destroy_fixed_asset(fixed_asset_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/fixed_assets/destroy/#{fixed_asset_id}")
    api_request(uri, 'POST', params)
  end

  def scheduled_date(target_date, sight, closing_day, shift = 'before')
    params = { 'format' => 'json', target_date: target_date, sight: sight, closing_day: closing_day, shift: shift }
    uri = URI.parse(@base_url + '/scheduled_dates/calc')
    api_request(uri, 'GET', params)
  end

  def destroy_petty_cash_reason_master(petty_cash_reason_master_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/petty_cash_reason_masters/destroy/#{petty_cash_reason_master_id}")
    api_request(uri, 'POST', params)
  end

  def destroy_physical_inventory_masters(physical_inventory_masters_id)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/physical_inventory_masters/destroy/#{physical_inventory_masters_id}")
    api_request(uri, 'POST', params)
  end

  def next_customer_code
    params = {
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/customer_masters/next_code')
    api_request(uri, 'GET', params)
  end

  private

  def api_request(uri, http_verb, params)
    http = Net::HTTP.new(uri.host, uri.port)
    initheader = { 'Content-Type' => 'application/json' }
    http.use_ssl = true if @base_url =~ /^https/
    if http_verb == 'GET'
      request = Net::HTTP::Get.new(uri.path, initheader)
    else
      request = Net::HTTP::Post.new(uri.path, initheader)
    end
    request['Access-Token'] = @access_token
    request.body = params.to_json
    response = http.request(request)
    if response.body
      begin
        { :status => response.code, :json => recursive_symbolize_keys(JSON.parse(response.body)) }
      rescue
        response.body
      end
    else
      response.code
    end
  end

  def recursive_symbolize_keys(data)
    case data
    when Hash
      Hash[
        data.map do |k, v|
          [k.respond_to?(:to_sym) ? k.to_sym : k, recursive_symbolize_keys(v)]
        end
      ]
    when Enumerable
      data.map { |v| recursive_symbolize_keys(v) }
    else
      data
    end
  end

  def make_journal_dcs(journal_dcs)
    return nil if journal_dcs.nil?

    journal_dcs.map { |journal_dc| make_journal_dc(journal_dc) }
  end

  def make_journal_dc(journal_dc)
    {
      'debit' => make_journal_dc_oneside(journal_dc[:debit]),
      'credit' => make_journal_dc_oneside(journal_dc[:credit]),
      'dept_code' => journal_dc[:dept_code],
      'memo' => journal_dc[:memo],
      'tag_list' => journal_dc[:tag_list]
    }
  end

  def make_journal_dc_oneside(side)
    return nil if side.nil?

    {
      'account_code' => side[:account_code].to_s,
      'price_including_tax' => side[:price_including_tax],
      'tax_type' => side[:tax_type],
      'sales_tax' => side[:sales_tax]
    }
  end
end
