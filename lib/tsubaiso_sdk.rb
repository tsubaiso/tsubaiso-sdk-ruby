class TsubaisoSDK
  require "net/http"
  require "json"

  def initialize(options = {})
    @base_url = options[:base_url] || 'https://tsubaiso.net'
    @access_token = options[:access_token]
  end

  def list_sales(year, month)
    params = { "year" => year,
               "month" => month,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/list/")
    api_request(uri, "GET", params)
  end

  def list_purchases(year, month)
    params = { "year" => year,
               "month" => month,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ap_payments/list/")
    api_request(uri, "GET", params)
  end

  def list_customers
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/customer_masters/list/")
    api_request(uri, "GET", params)
  end

  def list_staff
    params = { "format" => "json"}
    uri = URI.parse(@base_url + "/staffs/list/")
    api_request(uri, "GET", params)
  end

  def list_staff_data(staff_id)
    params = {"format" => "json",
              "staff_id" => staff_id}
    uri = URI.parse(@base_url + "/staff_data/list/")
    api_request(uri, "GET", params)
  end

  def list_staff_datum_masters
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/staff_datum_masters/list/")
    api_request(uri, "GET", params)
  end

  def list_reimbursements(year, month)
    params = { "format" => "json",
               "year" => year,
               "month" => month
             }
    uri = URI.parse(@base_url + "/reimbursements/list/")
    api_request(uri, "GET", params)
  end
  
  def list_reimbursement_transactions(reimbursement_id)
    params = { "format" => "json",
               "id" => reimbursement_id.to_i
             }
    uri = URI.parse(@base_url + "/reimbursement_transactions/list/")
    api_request(uri, "GET", params)
  end

  def list_manual_journals(year = nil, month = nil)
    params = { "year" => year,
               "month" => month,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/manual_journals/list/")
    api_request(uri, "GET", params)
  end

  def list_journals(options)
    params = { "start_date" => options[:start_date],
               "finish_date" => options[:finish_date],
               "start_created_at" => options[:start_created_at],
               "finish_created_at" => options[:finish_created_at],
               "timestamp_order" => options[:timestamp_order],
               "account_code" => options[:account_code],
               "price" => options[:price],
               "memo" => options[:memo],
               "dept_code" => options[:dept_code],
               "tag_list" => options[:tag_list],
               "id" => options[:id],
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/journals/list/")
    api_request(uri, "GET", params)
  end

  def list_depts
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/depts/list/")
    api_request(uri, "GET", params)
  end

  def list_tags
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/tags/list/")
    api_request(uri, "GET", params)
  end

  def show_sale(voucher)
    sale_id = voucher.scan(/\d/).join("")
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/ar/show/#{sale_id}")
    api_request(uri, "GET", params)
  end

  def show_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join("")
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/ap_payments/show/#{purchase_id}")
    api_request(uri, "GET", params)
  end

  def show_customer(customer_id)
    customer_id = customer_id.to_i
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/customer_masters/show/#{customer_id}")
    api_request(uri, "GET", params)
  end

  def show_staff(staff_id)
    staff_id = staff_id.to_i
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/staffs/show/#{staff_id}")
    api_request(uri, "GET", params)
  end

  def show_staff_data(options)
    if options.is_a?(Hash)
      params = { "staff_id" => options[:staff_id],
                 "code" => options[:code],
                 "time" => options[:time],
                 "format" => "json"
               }
      id = options[:id]
    else
      params = { "format" => "json" }
      id = options
    end
    uri = URI.parse(@base_url + "/staff_data/show/#{id}")
    api_request(uri, "GET", params)
  end

  def show_staff_datum_master(options)
    if options.is_a?(Hash)
      params = { "code" => options[:code],
                 "format" => "json"
               }
      id = options[:id]
    else
      params = { "format" => "json" }
      id = options
    end
    uri = URI.parse(@base_url + "/staff_datum_masters/show/#{id}")
    api_request(uri, "GET", params)
  end

  def show_manual_journal(manual_journal_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/manual_journals/show/#{manual_journal_id}")
    api_request(uri, "GET", params)
  end

  def show_journal(journal_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/journals/show/#{journal_id}")
    api_request(uri, "GET", params)
  end

  def show_reimbursement(reimbursement_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/reimbursements/show/#{reimbursement_id}")
    api_request(uri, "GET", params)
  end

  def show_reimbursement_transaction(reimbursement_transaction_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/reimbursement_transactions/show/#{reimbursement_transaction_id}")
    api_request(uri, "GET", params)
  end

  def show_dept(dept_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/depts/show/#{dept_id}")
    api_request(uri, "GET", params)
  end

  def show_tag(tag_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/tags/show/#{tag_id}")
    api_request(uri, "GET", params)
  end

  def create_customer(options)
    params = { "name" => options[:name],
               "name_kana" => options[:name_kana],
               "code" => options[:code],
               "tax_type_for_remittance_charge" => options[:tax_type_for_remittance_charge],
               "used_in_ar" => options[:used_in_ar],
               "used_in_ap" => options[:used_in_ap],
               "ar_account_code" => options[:ar_account_code],
               "ap_account_code" => options[:ap_account_code],
               "is_valid" => options[:is_valid],
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/customer_masters/create')
    api_request(uri, "POST", params)
  end

  def create_sale(options)
    params = { "price_including_tax" => options[:price_including_tax],
               "realization_timestamp" => options[:realization_timestamp],
               "customer_master_code" => options[:customer_master_code],
               "dept_code" => options[:dept_code],
               "reason_master_code" => options[:reason_master_code],
               "dc" => options[:dc],
               "memo" => options[:memo],
               "tax_code" => options[:tax_code],
               "sales_tax" => options[:sales_tax],
               "scheduled_memo" => options[:scheduled_memo],
               "scheduled_receive_timestamp" => options[:scheduled_receive_timestamp],
               "tag_list" => options[:tag_list],
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/ar/create')
    api_request(uri, "POST", params)
  end

  def create_purchase(options)
    params = { "price_including_tax" => options[:price_including_tax],
               "accrual_timestamp" => options[:accrual_timestamp],
               "customer_master_code" => options[:customer_master_code],
               "dept_code" => options[:dept_code],
               "reason_master_code" => options[:reason_master_code],
               "dc" => options[:dc],
               "memo" => options[:memo],
               "tax_code" => options[:tax_code],
               "port_type" => options[:port_type],
               "tag_list" => options[:tag_list],
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/ap_payments/create')
    api_request(uri, "POST", params)
  end

  def create_staff_data(options)
    params = { "staff_id" => options[:staff_id],
               "code" => options[:code],
               "memo" => options[:memo],
               "value" => options[:value],
               "start_timestamp" => options[:start_timestamp],
               "format" => "json"
             }

    if options[:finish_timestamp]
      params[:finish_timestamp] = options[:finish_timestamp]
    elsif options[:no_finish_timestamp]
      params[:no_finish_timestamp] = options[:no_finish_timestamp]
    end

    uri = URI.parse(@base_url + '/staff_data/create')
    api_request(uri, "POST", params)
  end

  def create_manual_journal(options)
    params = { "journal_timestamp" => options[:journal_timestamp],
               "journal_dcs" => make_journal_dcs(options[:journal_dcs]),
               "format" => "json" }

    uri = URI.parse(@base_url + '/manual_journals/create')
    api_request(uri, "POST", params)
  end

  def create_reimbursement(options)
    params = { "format" => "json",
               "applicant" => options[:applicant],
               "application_term" => options[:application_term],
               "staff_code" => options[:staff_code],
               "dept_code" => options[:dept_code],
               "memo" => options[:memo]
             }
    uri = URI.parse(@base_url + "/reimbursements/create/")
    api_request(uri, "POST", params)
  end

  def create_reimbursement_transaction(options)
    params = { "format" => "json",
               "reimbursement_id" => options[:reimbursement_id].to_i,
               "transaction_timestamp" => options[:transaction_timestamp],
               "price_value" => options[:price_value],
               "reason_code" => options[:reason_code],
               "port_type" => options[:port_type],
               "dc" => options[:dc],
               "brief" => options[:brief],
               "memo" => options[:memo],
               "tag_list" => options[:tag_list],
               "tax_type" => options[:tax_type]
             }
    uri = URI.parse(@base_url + '/reimbursement_transactions/create/')
    api_request(uri, "POST", params)
  end

  def create_dept(options)
    params = { "format" => "json",
               "code" => options[:code],
               "name" => options[:name],
               "name_abbr" => options[:name_abbr],
               "color" => options[:color],
               "memo" => options[:memo],
               "start_date" => options[:start_date],
               "finish_date" => options[:finish_date]
             }
    uri = URI.parse(@base_url + '/depts/create/')
    api_request(uri, "POST", params)
  end

  def create_tag(options)
    params = { "format" => "json",
               "code" => options[:code],
               "name" => options[:name],
               "sort_no" => options[:sort_no],
               "tag_group_code" => options[:tag_group_code],
               "start_ymd" => options[:start_ymd],
               "finish_ymd" => options[:finish_ymd]
             }
    uri = URI.parse(@base_url + '/tags/create/')
    api_request(uri, "POST", params)
  end

  def update_sale(options)
    params = { "price_including_tax" => options[:price_including_tax],
               "realization_timestamp" => options[:realization_timestamp],
               "customer_master_code" => options[:customer_master_code],
               "dept_code" => options[:dept_code],
               "reason_master_code" => options[:reason_master_code],
               "dc" => options[:dc],
               "memo" => options[:memo],
               "tax_code" => options[:tax_code],
               "sales_tax" => options[:sales_tax],
               "scheduled_memo" => options[:scheduled_memo],
               "scheduled_receive_timestamp" => options[:scheduled_receive_timestamp],
               "tag_list" => options[:tag_list],
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/update/#{options[:id]}")
    api_request(uri, "POST", params)
  end

  def update_purchase(options)
    params = { "price_including_tax" => options[:price_including_tax],
               "accrual_timestamp" => options[:accrual_timestamp],
               "customer_master_code" => options[:customer_master_code],
               "dept_code" => options[:dept_code],
               "reason_master_code" => options[:reason_master_code],
               "dc" => options[:dc],
               "memo" => options[:memo],
               "tax_code" => options[:tax_code],
               "port_type" => options[:port_type],
               "tag_list" => options[:tag_list],
               "format" => "json"}

    uri = URI.parse(@base_url + "/ap_payments/update/#{options[:id]}")
    api_request(uri, "POST", params)
  end

  def update_customer(options)
    params = { "name" => options[:name],
               "name_kana" => options[:name_kana],
               "code" => options[:code],
               "tax_type_for_remittance_charge" => options[:tax_type_for_remittance_charge],
               "used_in_ar" => options[:used_in_ar],
               "used_in_ap" => options[:used_in_ap],
               "ar_account_code" => options[:ar_account_code],
               "ap_account_code" => options[:ap_account_code],
               "is_valid" => options[:is_valid],
               "format" => "json"
             }

    uri = URI.parse(@base_url + "/customer_masters/update/#{options[:id]}")
    api_request(uri, "POST", params)
  end

  def update_staff_data(options)
    params = { "memo" => options[:memo],
               "value" => options[:value],
               "start_timestamp" => options[:start_timestamp],
               "format" => "json"
             }

    if options[:finish_timestamp]
      params[:finish_timestamp] = options[:finish_timestamp]
    elsif options[:no_finish_timestamp]
      params[:no_finish_timestamp] = options[:no_finish_timestamp]
    end

    uri = URI.parse(@base_url + "/staff_data/update/#{options[:id]}")
    api_request(uri, "POST", params)
  end

  def update_manual_journal(options)
    params = { "journal_timestamp" => options[:journal_timestamp],
               "journal_dcs" => make_journal_dcs(options[:journal_dcs]),
               "format" => "json" }

    uri = URI.parse(@base_url + "/manual_journals/update/#{options[:id]}")
    api_request(uri, "POST", params)
  end

  def update_reimbursement(reimbursement_id, options)
    params = { "format" => "json",
               "applicant" => options[:applicant],
               "application_term" => options[:application_term],
               "staff_code" => options[:staff_code],
               "dept_code" => options[:dept_code],
               "memo" => options[:memo]
             }
    uri = URI.parse(@base_url + "/reimbursements/update/#{reimbursement_id}")
    api_request(uri, "POST", params)
  end

  def update_reimbursement_transaction(options)
    params = { "format" => "json",
               "port_type" => options[:port_type],
               "transaction_timestamp" => options[:transaction_timestamp],
               "price_value" => options[:price_value],
               "dc" => options[:dc],
               "reason_code" => options[:reason_code],
               "brief" => options[:brief],
               "memo"  => options[:memo],
               "tag_list" => options[:tag_list],
               "tax_type" => options[:tax_type]
             }
    uri = URI.parse(@base_url + "/reimbursement_transactions/update/#{options[:id]}")
    api_request(uri, "POST", params)
  end

  def update_dept(dept_id, options)
    params = { "format" => "json",
               "code" => options[:code],
               "name" => options[:name],
               "name_abbr" => options[:name_abbr],
               "color" => options[:color],
               "memo" => options[:memo],
               "start_date" => options[:start_date],
               "finish_date" => options[:finish_date]
             }
    uri = URI.parse(@base_url + "/depts/update/#{dept_id}")
    api_request(uri, "POST", params)
  end

  def update_tag(tag_id, options)
    params = { "format" => "json",
               "code" => options[:code],
               "name" => options[:name],
               "sort_no" => options[:sort_no],
               "tag_group_code" => options[:tag_group_code],
               "start_ymd" => options[:start_ymd],
               "finish_ymd" => options[:finish_ymd]
             }
    uri = URI.parse(@base_url + "/tags/update/#{tag_id}")
    api_request(uri, "POST", params)
  end

  def destroy_sale(voucher)
    sale_id = voucher.scan(/\d/).join("")
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/ar/destroy/#{sale_id}")
    api_request(uri, "POST", params)
  end

  def destroy_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join("")
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/ap/destroy/#{purchase_id}")
    api_request(uri, "POST", params)
  end

  def destroy_customer(customer_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/customer_masters/destroy/#{customer_id}")
    api_request(uri, "POST", params)
  end

  def destroy_staff_data(staff_data_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/staff_data/destroy/#{staff_data_id}")
    api_request(uri, "POST", params)
  end

  def destroy_manual_journal(manual_journal_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/manual_journals/destroy/#{manual_journal_id}")
    api_request(uri, "POST", params)
  end

  def destroy_reimbursement(reimbursement_id)
    params = { "id" => reimbursement_id,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/reimbursements/destroy/")
    api_request(uri, "POST", params)
  end

  def destroy_reimbursement_transaction(reimbursement_transaction_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/reimbursement_transactions/destroy/#{reimbursement_transaction_id}")
    api_request(uri, "POST", params)
  end

  def destroy_dept(dept_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/depts/destroy/#{dept_id}")
    api_request(uri, "POST", params)
  end

  def destroy_tag(tag_id)
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/tags/destroy/#{tag_id}")
    api_request(uri, "POST", params)
  end

  private

  def api_request(uri, http_verb, params)
    http = Net::HTTP.new(uri.host, uri.port)
    initheader = {'Content-Type' => 'application/json'}
    http.use_ssl = true if @base_url =~ /^https/
    if http_verb == "GET"
      request = Net::HTTP::Get.new(uri.path, initheader)
    else
      request = Net::HTTP::Post.new(uri.path, initheader)
    end
    request["Access-Token"] = @access_token
    request.body = params.to_json
    response = http.request(request)
    if response.body
      begin
        {:status => response.code, :json => recursive_symbolize_keys(JSON.load(response.body))}
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
          [ k.respond_to?(:to_sym) ? k.to_sym : k, recursive_symbolize_keys(v) ]
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
    journal_dcs.map {|journal_dc| make_journal_dc(journal_dc)}
  end

  def make_journal_dc(journal_dc)
    { "debit"  => make_journal_dc_oneside(journal_dc[:debit]),
      "credit" => make_journal_dc_oneside(journal_dc[:credit]),
      "dept_code" => journal_dc[:dept_code],
      "memo" => journal_dc[:memo] }
  end

  def make_journal_dc_oneside(side)
    return nil if side.nil?
    { "account_code" => side[:account_code].to_s,
      "price_including_tax" => side[:price_including_tax],
      "tax_type" => side[:tax_type],
      "sales_tax" => side[:sales_tax]
    }
  end
end



