class TsubaisoSDK
  require 'net/http'
  require 'json'

  module UrlBuilder
    def url(root, resource, method, year = nil, month = nil)
      if year && month && method == "list"
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

    params = create_parameters(candidate_keys,options)
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

    params = create_parameters(candidate_keys,options)
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
      'currency_rate_master_id' => options[:currency_rate_master_id]
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
    uri = URI.parse(@base_url + '/ar/balance')
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
      'format' => 'json'
    }
    uri = URI.parse(@base_url + "/payrolls/list/#{year.to_s}/#{month.to_s}")
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
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/manual_journals/list/#{year.to_i}/#{month.to_i}")
    api_request(uri, 'GET', params)
  end

  def list_journals(options)
    params = {}
    candidate_keys = [
      :start_date,
      :finish_date,
      :start_created_at,
      :finish_created_at,
      :account_codes,
      :price_min,
      :price_max,
      :memo,
      :dept_code,
      :id,
      :tag_list,
    ]
    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'
    uri = URI.parse(@base_url + '/journals/list')
    api_request(uri, 'GET', params)
  end

  def list_depts
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/depts/list')
    api_request(uri, 'GET', params)
  end

  def list_tax_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/tax_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_tags
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/tags/list')
    api_request(uri, 'GET', params)
  end

  def list_bonuses(bonus_no, target_year)
    params = {
      'format' => 'json',
      'bonus_no' => bonus_no,
      'target_year' => target_year
    }
    uri = URI.parse(@base_url + '/bonuses/list')
    api_request(uri, 'GET', params)
  end

  def list_ap_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/ap_reason_masters/list')
    api_request(uri, 'GET', params)
  end

  def list_ar_reason_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/ar_reason_masters/list')
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
    uri = URI.parse(@base_url + '/fixed_assets/list')
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
    uri = URI.parse(@base_url + '/api_histories/list')
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
    else
      params = { 'format' => 'json' }
      id = '/' + options.to_s
    end
    uri = URI.parse(@base_url + "/staff_datum_masters/show#{id}")
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
    corporate_master_id = '/' + corporate_master_id.to_s if corporate_master_id

    uri = URI.parse(@base_url + "/corporate_masters/show#{corporate_master_id}")
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
      'data_partner',
      'corporate_mynumber',
      'pay_method',
    ]
    params = {}
    params = create_parameters(available_keys.map{|x| x.to_sym},options)
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
    params = create_parameters(available_keys.map{|x| x.to_sym},options)
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

  def create_corp(options)
    params = {
      'format' => 'json',
      'stage' => options[:stage],
      'corporate_master_type' => options[:corporate_master_type],
      'email_to' => options[:email_to],
      'name' => options[:name],
      'freeze_login' => options[:freeze_login]
    }
    uri = URI.parse(@base_url + '/corporate_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_user(options)
    params = {
      'format' => 'json'
    }
    uri = URI.parse(@base_url + '/users/create')
    api_request(uri, 'POST', params)
  end

  def update_user(options)
    params = {
      'format' => 'json',
      'id' => options[:id],
      'email' => options[:email],
      'firstname' => options[:firstname],
      'lastname' => options[:lastname],
      'permitted_address' => options[:permitted_address],
      'dept_codes' => options[:dept_codes],
      'lang' => options[:lang],
      'inuse' => options[:inuse],
    }
    uri = URI.parse(@base_url + '/users/update')
    api_request(uri, 'POST', params)
  end

  def add_domains(options)
    params = {
      'format' => 'json',
      'id' => options[:id],
      'domains' => options[:domains]
    }
    uri = URI.parse(@base_url + '/users/add_domains')
    api_request(uri, 'POST', params)
  end

  def create_fiscal_master(options)
    params = {
      'format' => 'json',
      'term' => options[:term],
      'start_timestamp' => options[:start_timestamp],
      'finish_timestamp' => options[:finish_timestamp],
      'launch_timestamp' => options[:launch_timestamp],
      'status' => options[:status],
      'sales_tax_system' => options[:sales_tax_system]
    }
    uri = URI.parse(@base_url + '/fiscal_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_reimbursement(options)
    params = {
      'format' => 'json',
      'applicant' => options[:applicant],
      'application_term' => options[:application_term],
      'staff_code' => options[:staff_code],
      'dept_code' => options[:dept_code],
      'memo' => options[:memo],
      'applicant_staff_code' => options[:applicant_staff_code],
      'transactions' => options[:transactions],
      'pay_date' => options[:pay_date]
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
    params = create_parameters(candidate_keys,options)
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
    params = create_parameters(available_keys.map{|x| x.to_sym},options)
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
    params = create_parameters(available_keys.map{|x| x.to_sym},options)
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

    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'
    uri = URI.parse(@base_url + '/bank_reason_masters/update/' + options[:id].to_s)
    api_request(uri, "POST",params)
  end

  def update_staff_data(staff_data_id, options)
    params = {
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

    uri = URI.parse(@base_url + "/staff_data/update/#{staff_data_id}")
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
    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/reimbursements/update/#{reimbursement_id}")
    api_request(uri, 'POST', params)
  end

  def update_reimbursement_transaction(options)
    params = {}
    candidate_keys = [
      :port_type,
      :transaction_timestamp,
      :price_value,
      :bc,
      :reason_code,
      :brief,
      :memo,
      :tag_list,
      :tax_type,
      :data_partner
    ]
    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'

    uri = URI.parse(@base_url + "/reimbursement_transactions/update/#{options[:id]}")
    api_request(uri, 'POST', params)
  end

  def update_dept(dept_id, options)
    params = {}
    candidate_keys = [
      :sort_no,
      :code,
      :name,
      :memo,
      :name_abbr,
      :color,
      :start_date,
      :finish_date
    ]
    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/depts/update/#{dept_id}")
    api_request(uri, 'POST', params)
  end

  def update_tag(tag_id, options)
    params = {}
    candidate_keys = [
      :code,
      :name,
      :sort_no,
      :tagg_group_code,
      :start_ymd,
      :finish_ymd
    ]
    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'
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
    params = create_parameters(candidate_keys,options)
    params['format'] = 'json'
    uri = URI.parse(@base_url + "/petty_cash_reason_masters/update/#{petty_cash_reason_master_id}")
    api_request(uri, 'POST', params)
  end

  def update_physical_inventory_masters(options)
    params = {}
    candidate_keys = [:name, :start_ymd, :finish_ymd, :memo]
    params = create_parameters(candidate_keys,options)
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

  def create_account_masters(options)
    candidate_keys = [
      :account_code,
      :account_name,
      :descid,
      :account_kana,
      :dc,
      :bspl,
      :sum_no,
      :brief,
      :inputtable,
      :use_in_balance,
      :status,
    ]
    params = create_parameters(candidate_keys,options)
    uri = URI.parse(@base_url + '/account_masters/create')
    api_request(uri, 'POST', params)
  end

  def update_account_masters(options)
    candidate_keys = [
      :id,
      :account_code,
      :account_name,
      :account_kana,
      :descid,
      :brief,
      :sum_no,
      :dc,
      :bspl,
      :inputtable,
      :use_in_balance,
      :status,
    ]
    params = create_parameters(candidate_keys,options)
    uri = URI.parse(@base_url + '/account_masters/update')
    api_request(uri, 'POST', params)
  end

  def list_account_masters
    params = {
      'format' => 'json',
    }
    uri = URI.parse(@base_url + "/account_masters/list")
    api_request(uri, 'GET', params)
  end

  def create_corporate_data(options)
    params = {
      'format' => 'json',
      'code' => options[:code],
      'start_timestamp' => options[:start_timestamp],
      'finish_timestamp' => options[:finish_timestamp],
      'value' => options[:value],
      'memo' => options[:memo]
    }
    uri = URI.parse(@base_url + '/corporate_data/create')
    api_request(uri, 'POST', params)
  end

  def create_petty_cash_masters(options)
    params = {
      'format' => 'json',
      'name' => options[:name],
      'start_ymd' => options[:start_ymd],
      'finish_ymd' => options[:finish_ymd],
      'memo' => options[:memo],
    }
    uri = URI.parse(@base_url + '/petty_cash_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_ar_reason_masters(options)
    params = {
      'format' => 'json',
      'reason_code' => options[:reason_code],
      'reason_name' => options[:reason_name],
      'dc' => options[:dc],
      'account_code' => options[:account_code],
      'sort_number' => options[:sort_number],
      'is_valid' => options[:is_valid],
      'memo' => options[:memo],
      'ar_reason_taxes' => options[:ar_reason_taxes],
    }
    uri = URI.parse(@base_url + '/ar_reason_masters/create')
    api_request(uri, 'POST', params)
  end

  def update_ar_reason_masters(id, options)
    params = {
      'format' => 'json',
      'reason_code' => options[:reason_code],
      'reason_name' => options[:reason_name],
      'dc' => options[:dc],
      'sort_number' => options[:sort_number],
      'is_valid' => options[:is_valid],
      'memo' => options[:memo],
      'ar_reason_taxes' => options[:ar_reason_taxes],
    }
    uri = URI.parse(@base_url + "/ar_reason_masters/update/#{id}")
    api_request(uri, 'POST', params)
  end

  def create_ap_reason_masters(options)
    params = {
      'format' => 'json',
      'reason_code' => options[:reason_code],
      'reason_name' => options[:reason_name],
      'dc' => options[:dc],
      'account_code' => options[:account_code],
      'sort_number' => options[:sort_number],
      'is_valid' => options[:is_valid],
      'memo' => options[:memo],
      'port_type' => options[:port_type],
      'ap_reason_taxes' => options[:ap_reason_taxes],
    }
    uri = URI.parse(@base_url + '/ap_reason_masters/create')
    api_request(uri, 'POST', params)
  end

  def update_ap_reason_masters(id, options)
    params = {
      'format' => 'json',
      'reason_code' => options[:reason_code],
      'reason_name' => options[:reason_name],
      'dc' => options[:dc],
      'port_type' => options[:port_type],
      'sort_number' => options[:sort_number],
      'is_valid' => options[:is_valid],
      'memo' => options[:memo],
    }
    uri = URI.parse(@base_url + "/ap_reason_masters/update/#{id}")
    api_request(uri, 'POST', params)
  end

  def list_users
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/users/list')
    api_request(uri, 'GET', params)
  end

  def list_depts
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/depts/list/')
    api_request(uri, 'GET', params)
  end

  def update_system_managements(options)
    params = {
      'format' => 'json',
      'code' => options[:code],
      'enable' => options[:enable],
    }
    uri = URI.parse(@base_url + '/system_managements/update')
    api_request(uri, 'POST', params)
  end

  def create_tags(options)
    params = {
      'format' => 'json',
      'code' => options[:code],
      'name' => options[:name],
      'sort_no' => options[:sort_no],
      'tag_group_code' => options[:tag_group_code],
      'start_ymd' => options[:start_ymd],
      'finish_ymd' => options[:finish_ymd],
    }
    uri = URI.parse(@base_url + '/tags/create')
    api_request(uri, 'POST', params)
  end

  def create_ar_segment_masters(options)
    params = {
      'format' => 'json',
      'account_descid' => options[:account_descid],
      'priority_order' => options[:priority_order],
      'enable' => options[:enable],
      'name' => options[:name],
      'description' => options[:description],
    }
    uri = URI.parse(@base_url + '/ar_segment_masters/create')
    api_request(uri, 'POST', params)
  end

  def create_ap_segment_masters(options)
    params = {
      'format' => 'json',
      'account_descid' => options[:account_descid],
      'priority_order' => options[:priority_order],
      'enable' => options[:enable],
      'name' => options[:name],
      'description' => options[:description],
    }
    uri = URI.parse(@base_url + '/ap_segment_masters/create')
    api_request(uri, 'POST', params)
  end

  def list_fiscal_masters
    params = {
      'format' => 'json',
    }
    uri = URI.parse(@base_url + "/fiscal_masters/list")
    api_request(uri, 'GET', params)
  end

  def list_balance_plan_masters
    params = {
      'format' => 'json',
    }
    uri = URI.parse(@base_url + "/balance_plan_masters/list")
    api_request(uri, 'GET', params)
  end

  def create_balance_plan_masters(options)
    params = {
      'format' => 'json',
      'code' => options[:code],
      'name' => options[:name],
      'memo' => options[:memo],
      'start_ymd' => options[:start_ymd],
      'finish_ymd' => options[:finish_ymd],
      'in_use' => options[:in_use],
      'is_default' => options[:is_default],
    }
    uri = URI.parse(@base_url + '/balance_plan_masters/create')
    api_request(uri, 'POST', params)
  end

  def update_staffs(id, options)
    candidate_keys = [
      :code,
      :status,
      :dept_codes,
    ]
    params = create_parameters(candidate_keys,options)
    uri = URI.parse(@base_url + "/staffs/update/#{id}")
    api_request(uri, 'POST', params)
  end

  def create_personalized_asset_type_masters(options)
    candidate_keys = [
      :code,
      :name,
      :asset_account_code,
      :contra_account_code,
      :contra_mc_account_code,
      :impairment_account_code,
      :impairment_mc_account_code,
      :accumulated_depreciation_account_code,
      :local_tax_segment_code,
      :corporate_tax_segment_name,
      :sort_no
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + '/personalized_asset_type_masters/create')
    api_request(uri, 'POST', params)
  end

  def bulk_create_or_update_balance_plans(options)
    candidate_keys = [
      :balance_plans
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + '/balance_plans/bulk_create_or_update')
    api_request(uri, 'POST', params)
  end

  def list_petty_cash_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/petty_cash_masters/list')
    api_request(uri, 'GET', params)
  end

  def create_petty_cashes(options)
    candidate_keys = [
      :petty_cash_master_id,
      :start_ymd,
      :finish_ymd,
      :start_balance_fixed,
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + '/petty_cashes/create')
    api_request(uri, 'POST', params)
  end

  def create_petty_cash_transactions(options)
    candidate_keys = [
      :petty_cash_id,
      :journal_timestamp,
      :price_value,
      :reason_code,
      :dc,
      :tax_type,
      :brief,
      :memo,
      :tag_list,
      :dept_code,
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + '/petty_cash_transactions/create')
    api_request(uri, 'POST', params)
  end

  def list_ar_reconciliations(year, month)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ar_reconciliations/list/#{year}/#{month}")
    api_request(uri, 'GET', params)
  end

  def reconcile_ar_reconciliations(options)
    candidate_keys = [
      :reconciliation_id,   # (BankAccount Transaction / PettyCash Transaction / Reimbursement Transaction) JournalDc ID.
      :reconcile_transactions
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/ar_reconciliations/reconcile")
    api_request(uri, 'POST', params)
  end

  def reconcile_ap_reconciliations(options)
    candidate_keys = [
      :reconciliation_id,   # (BankAccount Transaction / PettyCash Transaction / Reimbursement Transaction) JournalDc ID.
      :reconcile_transactions
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/ap_reconciliations/reconcile")
    api_request(uri, 'POST', params)
  end

  # @param [String] arap 'ar' または 'ap'
  def search_customer_masters_by_reconcile_keyword(keyword, arap)
    params = {
      'format' => 'json',
      'keyword' => keyword,
      'arap' => arap,
    }
    uri = URI.parse(@base_url + "/customer_masters/search_by_reconcile_keyword")
    api_request(uri, 'GET', params)
  end

  def list_ar_cashflow_schedule(year, month)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ar_reports/list_cashflow_schedule/#{year}/#{month}")
    api_request(uri, 'GET', params)
  end

  def list_ap_cashflow_schedule(year, month)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ap_reports/list_cashflow_schedule/#{year}/#{month}")
    api_request(uri, 'GET', params)
  end

  def standardize_payroll_column_masters(year, month)
    params = {
      'format' => 'json',
      'year' => year,
      'month' => month,
    }
    uri = URI.parse(@base_url + "/payroll_column_masters/standardize")
    api_request(uri, 'POST', params)
  end

  def show_payroll_column_masters(year, month)
    params = {
      'format' => 'json',
      'year' => year,
      'month' => month,
    }
    uri = URI.parse(@base_url + "/payroll_column_masters/show")
    api_request(uri, 'GET', params)
  end

  def update_payrolls(options)
    candidate_keys = [
      :year,
      :month,
      :only_save,
      :update_journal,
      :staffs
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/payrolls/update")
    api_request(uri, 'POST', params)
  end

  def list_ap_reconciliations(year, month)
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + "/ap_reconciliations/list/#{year}/#{month}")
    api_request(uri, 'GET', params)
  end

  def update_boy_adjusts(options)
    candidate_keys = [
      :term,
      :dept_code,
      :fixed_balances
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/adjusts/update_boy")
    api_request(uri, 'POST', params)
  end

  def brought_forward_adjusts(options)
    candidate_keys = [
      :term,
      :dept_code,
      :calc_common
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/adjusts/brought_forward")
    api_request(uri, 'POST', params)
  end

  def update_bank_adjusts(options)
    candidate_keys = [
      :bank_term_balances
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/adjusts/update_bank")
    api_request(uri, 'POST', params)
  end

  def create_fixed_assets(options)
    candidate_keys = [
      :acquire_method,
      :acquire_source_journal_dc_id,
      :acquire_ymd,
      :asset_type_master_id,
      :brief,
      :code,
      :depreciation_entry_method,
      :depreciation_method,
      :dept_code,
      :durable_years,
      :ignore_immediate_depreciation_limit,
      :initial_depreciated_amount,
      :installed_place,
      :is_product_cost,
      :name,
      :quantity,
      :start_ymd,
      :tag_list,
      :target_ym,
      :amount_inclusive,
      :tax_code
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/fixed_assets/create")
    api_request(uri, 'POST', params)
  end

  def list_personalized_asset_type_masters
    params = { 'format' => 'json' }
    uri = URI.parse(@base_url + '/personalized_asset_type_masters/list')
    api_request(uri, 'GET', params)
  end

  def update_journals_payrolls(options)
    candidate_keys = [
      :year,
      :month
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/payrolls/update_journals")
    api_request(uri, 'POST', params)
  end

  def calc_balances_queues(options)
    candidate_keys = [
      :dept_code,
      :account_code,
      :ym_from,
      :ym_until
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/balances/calc_queues")
    api_request(uri, 'POST', params)
  end

  def default_fixed_assets_revaluations(id)
    uri = URI.parse(@base_url + "/fixed_assets/default_revaluations/#{id}")
    api_request(uri, 'GET', params)
  end

  def create_fixed_assets_revaluations(options)
    candidate_keys = [
      :id,
      :asset_revaluations
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/fixed_assets/create_revaluations")
    api_request(uri, 'POST', params)
  end

  def create_fixed_assets_journal(options)
    candidate_keys = [
      :id,
      :year,
      :month
    ]
    params = create_parameters(candidate_keys, options)
    uri = URI.parse(@base_url + "/fixed_assets/create_journal")
    api_request(uri, 'POST', params)
  end

  private


  def create_parameters(keys,options)
    # Add new keys and value if options has keys, even if value in options is nil.
    # This code avoid updateing attributes witch is not specified by the users.
    (keys & options.keys).inject({ 'format' => 'json' }) do |params, key|
      params.merge(key.to_s => options[key]) # Hash#slice can be replace this code if your ruby is =< 2.5.0
    end
  end

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
    if response.body && !response.body.empty?
      begin
        { :status => response.code, :json => recursive_symbolize_keys(JSON.parse(response.body)) }
      rescue
        puts "rescue"
        puts "response.code:#{response.code}"
        puts "response.body:#{response.body}"
        response.body
      end
    else
      { :status => response.code }
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
