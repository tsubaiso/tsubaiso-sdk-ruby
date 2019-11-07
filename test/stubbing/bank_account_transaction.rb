require_relative "./bank_account_master.rb"
require_relative './stubbing.rb'

class BankAccountTransaction < Stubbing
    def initialize
      BankAccountMaster.new  # All BankAccounts belong to BankAccountMaster.
      super("bank_accounts/")
    end

    def add_columns(hash)
      hash.merge!({
        :bank_account_master_id => "990",
        :start_timestamp => "2019/06/30 00:00:00 +0900",
        :finish_timestamp => "2019/07/30 00:00:00 +0900",
        :start_balance_fixed => nil,
        :start_balance => nil,
        :finish_balance => nil,
        :start_balance_cache => 1230,
        :finish_balance_cache => 1330,
        :is_balanced => false,
        :bank_account_transactions_count => 1,
        :regist_user_code => nil,
        :update_user_code => nil,
        :start_balance_cache_fc => nil,
        :finish_balance_cache_fc => nil,
        :start_balance_fixed_fc => nil,
        :finish_balance_fc => nil,
        :exchange_gl_journal_id => nil,
      })
      hash
    end

    def create
      request_body_1 = {
        "format" => "json",
        "bank_account_master_id" => "990",
        "start_timestamp" => "2019-06-30",
        "finish_timestamp" => "2019-07-30"
      }

      response_hash = add_columns(request_body_1.add_date_and_id)
      stub_request(:post, @root_url + "create/").
      with(
        headers: @common_request_headers,
        body: request_body_1
      ).
      to_return(
        status: 200,
        body: response_hash.to_json,
        headers: {}
      )
      @created_records << response_hash
    end

    def update
      # NOTE: Bank Account Master API doesn't have update method.
      # NOTE: Still, parental class calls all CRUD methods to create stubs.
    end
  end