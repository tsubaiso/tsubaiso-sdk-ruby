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
    uri = URI.parse(@base_url + "/ar/list/?year=#{year}&month=#{month}")
    api_request(uri, "GET", params)
  end
  
  def list_purchases(year, month)
    params = { "year" => year,
               "month" => month,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ap_payments/list/?year=#{year}&month=#{month}")
    api_request(uri, "GET", params)
  end

  def list_customers
    params = { "format" => "json" }
    uri = URI.parse(@base_url + "/customer_masters/list/")
    api_request(uri, "GET", params)
  end

  def show_sale(voucher)
    sale_id = voucher.scan(/\d/).join("")
    params = { "id" => sale_id,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/show/#{sale_id}")
    api_request(uri, "GET", params)
  end
  
  def show_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join("")
    params = { "id" => purchase_id,
               "format" => "json"
    }
    uri = URI.parse(@base_url + "/ap_payments/show/#{purchase_id}")
    api_request(uri, "GET", params)
  end
  
  def show_customer(customer_id)
    customer_id = customer_id.to_i
    params = { "id" => customer_id,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/customer_masters/show/#{customer_id}")
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
    params = { "price" => options[:price],
               "year" => options[:year],
               "month" => options[:month],
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
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/ar/create') 
    api_request(uri, "POST", params)
  end
  
  def create_purchase(options)
    params = { "price" => options[:price],
               "year" => options[:year],
               "month" => options[:month],
               "accrual_timestamp" => options[:accrual_timestamp],
               "customer_master_code" => options[:customer_master_code],
               "dept_code" => options[:dept_code],
               "reason_master_code" => options[:reason_master_code],
               "dc" => options[:dc],
               "memo" => options[:memo],
               "tax_code" => options[:tax_code],
               "port_type" => options[:port_type],
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/ap_payments/create')
    api_request(uri, "POST", params)
  end
  
  def destroy_sale(voucher)
    sale_id = voucher.scan(/\d/).join("")
    params = { "id" => sale_id,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/destroy/#{sale_id}")
    api_request(uri, "POST", params)
  end
  
  def destroy_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join("")
    params = { "id" => purchase_id,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ap/destroy/#{purchase_id}")
    api_request(uri, "POST", params)
  end

  def destroy_customer(customer_id)
    params = { "id" => customer_id,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/customer_masters/destroy/#{customer_id}")
    api_request(uri, "POST", params)
  end
  
  private
  
  def api_request(uri, http_verb, params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if @base_url =~ /^https/
    if http_verb == "GET"
      request = Net::HTTP::Get.new(uri.path)
    else
      request = Net::HTTP::Post.new(uri.path)
    end
    request["Access-Token"] = @access_token
    request.set_form_data(params)
    response = http.request(request)
    if response.body
      begin
        {:status => response.code, :json => symbolize_keys(JSON.load(response.body))}
      rescue
        response.body
      end
    else                    
      response.code
    end
  end

  def symbolize_keys(data)
    if data.class == Array
      data.each_with_index do |hash, index|
        data[index] = hash.each_with_object({}) do |(k,v), memo|
          memo[k.to_sym] = v
        end
      end
    else
      data.each_with_object({}) do |(k,v), memo|
        memo[k.to_sym] = v
      end
    end
  end
end
