require 'webmock'
require 'stubbing.rb'

class BankAccountMaster < Stubbing
  def initialize
    super("bank_account_masters/")
  end

  def create
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
      "zengin_bank_code" => "8888",
      "zengin_branch_code" => "777",
      "zengin_client_code_sogo" => "8888888888",
      "zengin_client_code_kyuyo" => nil,
      "currency_code" => nil,
      "currency_rate_master_id" => nil
    }

    request_body_3 = {
      "format" => "json",
      "name" => "Bank of Melbourne",
      "account_type" => "1",
      "account_number" => "66664444",
      "nominee" => "tsubaiso saburo",
      "memo" => "",
      "start_ymd" => "2019-06-03",
      "finish_ymd" => nil,
      "zengin_bank_code" => "9999",
      "zengin_branch_code" => "999",
      "zengin_client_code_sogo" => "7777777777",
      "zengin_client_code_kyuyo" => nil,
      "currency_code" => "",
      "currency_rate_master_id" => nil
    }

    [request_body_1,request_body_2, request_body_3].each_with_index do |request_body, index|
      stub_request(:post, @root_url + "create/").
      with(
        headers: @common_request_headers,
        body: request_body
      ).
      to_return(
        status: 200,
        body: request_body.add_date_and_id(index).to_json,
        headers: {}
      )
      @created_records << request_body.add_date_and_id(index)
    end
  end

  def update
    bam_1_update = {
      :name => "Westpac",
      :account_type => "3",
      :nominee => "Hatagaya Taro",
      :memo => "This is updatting test"
    }

    stub_request(:post, @root_url + "update/#{@created_records[0][:id]}")
    .with(
      headers: @common_request_headers,
      body: bam_1_update.merge({"format" => "json"})
    )
    .to_return(
      status: 200,
      body: @created_records[0].merge(bam_1_update).to_json
    )
  end
end
