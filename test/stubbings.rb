require './lib/tsubaiso_sdk'
require 'webmock'

include WebMock::API
WebMock.enable!
WebMock.disable_net_connect!

class Stubbings

  def fixtures
  @bank_account_master_1 = {
    format: "json",
    id: 250,
    name: "ANZ Bank",
    account_type: "1",
    account_number: "66667777",
    nominee: "tsubaiso taro",
    account_code: "111",
    zengin_bank_code: "7777",
    zengin_branch_code: "777",
    dept_code: "COMMON",
    memo: "",
    regist_user_code: "yamakawa",
    update_user_code: nil,
    start_ymd: "2019/06/01",
    finish_ymd: nil,
    zengin_client_code_sogo: "9999999999",
    currency_code:"",
    currency_rate_master_id: nil,
    created_at:"2019/10/31 12:54:17 +0900",
    updated_at:"2019/10/31 12:54:17 +0900"
  }

  @bank_account_master_2 = {
    name: "NSW Bank",
    account_type: "1",
    account_number: "66665555",
    nominee: "tsubaiso jiro",
    memo: "",
    start_ymd: "2019-06-02",
    finish_ymd: nil,
    zengin_bank_code: "8888",
    zengin_branch_code: "777",
    zengin_client_code_sogo: "8888888888",
    currency_code: "",
    currency_rate_master_code: nil
  }

  @bank_account_master_3 = {
    name: "Bank of Melbourne",
    account_type: "1",
    account_number: "66664444",
    nominee: "tsubaiso saburo",
    memo: "",
    start_ymd: "2019-06-03",
    finish_ymd: nil,
    zengin_bank_code: "9999",
    zengin_branch_code: "999",
    zengin_client_code_sogo: "7777777777",
    currency_code: "",
    currency_rate_master_code: nil
  }

  @bank_account_master_4 = {
    format: "json",
    name: "ANZ Bank",
    account_type: "1",
    account_number: "66667777",
    nominee: "tsubaiso taro",
    memo: "",
    start_ymd: "2019-06-01",
    finish_ymd: nil,
    zengin_bank_code: "7777",
    zengin_branch_code: "777",
    zengin_client_code_sogo: "9999999999",
    zengin_client_code_kyoyo: nil,
    currency_code: "",
    currency_rate_master_id: nil
  }

  @common_request_headers = {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Access-Token'=>'6stryskt2i2fmm7j8qyv429zf-2sllzoej9ila018ryf2gllcl2',
    'Content-Type'=>'application/json',
    'User-Agent'=>'Ruby'
  }
end

  def initialize
    fixtures
    ["create"].each do |method|
      self.send("bank_account_master_#{method}".to_sym)
    end
  end

  def bank_account_master_create
    request_body_1 = {
      "format" => "json",
      "name" => "ANZ Bank",
      "account_type" => "1",
      "account_number" => "66667777",
      "nominee" => "tsubaiso taro",
      "memo" => "create memo",
      "start_ymd" => "2019-06-01",
      "finish_ymd" => nil,
      "zengin_bank_code" => "7777",
      "zengin_branch_code" => "777",
      "zengin_client_code_sogo" => "9999999999",
      "zengin_client_code_kyuyo" => nil,
      "currency_code" => nil,
      "currency_rate_master_id" => nil
    }

    request_body_2 = {
      "format" => "json",
      "name" => "NSW Bank",
      "account_type" => "1",
      "account_number" => "66665555",
      "nominee" => "tsubaiso jiro",
      "memo" => nil,
      "start_ymd" => "2019-06-02",
      "finish_ymd" => nil,
      "zengin_bank_code" => "7777",
      "zengin_branch_code" => "777",
      "zengin_client_code_sogo" => "9999999999",
      "zengin_client_code_kyuyo" => nil,
      "currency_code" => nil,
      "currency_rate_master_id" => nil
    }

    request_body_3 = {
      "format" => "json",
      "name" => "NSW Bank",
      "account_type" => "1",
      "account_number" => "66665555",
      "nominee" => "tsubaiso jiro",
      "memo" => nil,
      "start_ymd" => "2019-06-02",
      "finish_ymd" => nil,
      "zengin_bank_code" => "7777",
      "zengin_branch_code" => "777",
      "zengin_client_code_sogo" => "9999999999",
      "zengin_client_code_kyuyo" => nil,
      "currency_code" => nil,
      "currency_rate_master_id" => nil
    }


    stub_request(:post, "https://tsubaiso.net/bank_account_masters/create/").
    with(
      headers: @common_request_headers,
      body: request_body
    ).
    to_return(
      status: 200,
      body: request_body.merge(
        :id => "285",
        :created_at => "2019/11/05 18:51:21 +0900",
        :updated_at => "2019/11/05 18:51:21 +0900")
      },
      headers: {}
    )

    stub_request(:post, "https://tsubaiso.net/bank_account_masters/create/").
    with(
      headers: @common_request_headers,
      body: request_body.update()
    ).
    to_return(
      status: 200,
      body: request_body.merge(
        :id => "285",
        :created_at => "2019/11/05 18:51:21 +0900",
        :updated_at => "2019/11/05 18:51:21 +0900")
      },
      headers: {}
    )
  end

  def bank_account_master_update
    uri_template = Addressable::Template.new "https://tsubaiso.net/bank_account_master/update/{id}"

    bam_1_updated = @bank_account_master_1
    bam_1_updated[:name] = "Westpac"
    bam_1_updated[:account_type] = "3"
    bam_1_updated[:nominee] = "Hatagaya Taro"
    bam_1_updated[:memo] = "This is updatting test"

    stub_request(:put, uri_template)
    .with(body: @bank_account_master_1)
    .to_return(
    status: 200,
    body: bam_1_updated.to_json
    )
  end

  def bank_account_master_destroy
    uri_template = Addressable::Template.new "https://tsubaiso.net/bank_account_master/destroy/{id}"

    stub_request(:put, uri_template)
    .with(body: {'format' => 'json'})
    .to_return(
    status: 422
    )
  end

  def bank_account_master_show
    uri_template = Addressable::Template.new "https://tsubaiso.net/bank_account_master/show/{id}"

    stub_request(:get, uri_template)
    .with(body: {'format' => 'json'})
    .to_return(
    status: 200,
    body: @bank_account_master_1.to_json
    )
  end

  def bank_account_master_list
    uri_template = Addressable::Template.new "https://tsubaiso.net/bank_account_master/list"

    stub_request(:get, uri_template)
    .with(body: {'format' => 'json'})
    .to_return(
    status: 200,
    body: [
      @bank_account_master_1.to_json,
      @bank_account_master_2.to_json,
      @bank_account_master_3.to_json
    ]
    )
  end

end
