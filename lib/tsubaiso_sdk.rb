class TsubaisoSDK
  require "net/http"
  require "json"
  
  def initialize(options = {})
    @base_url = 'http://tsubaiso.net'
    @login = options[:login]
    @password = options[:password]
    @ccode = options[:ccode]
    @role = options[:role]
    @authenticity_token = nil
    @cookies = {}
    authenticate(@login, @password, @ccode, @role)
  end
  
  def authenticate(login, password, ccode, role)
    uri = URI.parse(@base_url + '/auth/auth')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data({ id: login, pw: password, cd: ccode, dm: role })
    response = http.request(request)
    @authenticity_token = response.body.scan(/<authenticity_token>(.*)<\/authenticity_token>/).first.first
    response.get_fields('Set-Cookie').each do |str|
      k, v = str[0...str.index(';')].split('=')
      @cookies[k] = v
    end
  end
  
  def list_sales(year, month)
    params = { "year" => year,
               "month" => month,
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/list/?year=#{year}&month=#{month}")
    api_request(uri, "GET", params, @cookies)
  end
  
  def list_purchases(year, month)
    params = { "year" => year,
               "month" => month,
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ap_payments/list/?year=#{year}&month=#{month}")
    api_request(uri, "GET", params, @cookies)
  end
  
  def show_sale(voucher)
    sale_id = voucher.scan(/\d/).join("")
    params = { "id" => sale_id,
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/show/#{sale_id}")
    api_request(uri, "GET", params, @cookies)
  end
  
  def show_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join("")
    params = { "id" => purchase_id,
               "authenticity_token" => @authenticity_token,
               "format" => "json"
    }
    uri = URI.parse(@base_url + "/ap_payments/show/#{purchase_id}")
    api_request(uri, "GET", params, @cookies)
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
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/ar/create') 
    api_request(uri, "POST", params, @cookies)
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
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + '/ap_payments/create')
    api_request(uri, "POST", params, @cookies)
  end
  
  def destroy_sale(voucher)
    sale_id = voucher.scan(/\d/).join("")
    params = { "id" => sale_id,
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ar/destroy/#{sale_id}")
    api_request(uri, "POST", params, @cookies)
  end
  
  def destroy_purchase(voucher)
    purchase_id = voucher.scan(/\d/).join("")
    params = { "id" => purchase_id,
               "authenticity_token" => @authenticity_token,
               "format" => "json"
             }
    uri = URI.parse(@base_url + "/ap/destroy/#{purchase_id}")
    api_request(uri, "POST", params, @cookies)
  end
  
  private
  
  def api_request(uri, http_verb, params, cookies)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    if http_verb == "GET"
      request = Net::HTTP::Get.new(uri.path)
    else
      request = Net::HTTP::Post.new(uri.path)
    end
    request['Cookie'] = cookies.map { |k, v| "#{k}=#{v}"  }.join(';')
    request.set_form_data(params)
    response = http.request(request)
    return { :status => response.code, :json => JSON.load(response.body) }
  end
end
