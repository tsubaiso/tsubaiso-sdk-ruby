# -*- coding: utf-8 -*-
$LOAD_PATH << 'lib/'
require 'tsubaiso_sdk'

class Sample
  def initialize(sample)
    @sample = sample
    api = TsubaisoSDK.new({ login: ENV["SDK_LOGIN"], password: ENV["SDK_PASSWORD"], ccode: ENV["SDK_CCODE"], role: ENV["SDK_ROLE"] } )
    @sample.each do | line |
      if line[:action] == "List"
        if line[:module] == "Sales"
          res = api.list_sales(line[:year], line[:month])
          puts res[:json]
        end
        if line[:module] == "Purchases"
          res = api.list_purchases(line[:year], line[:month])
          puts res[:json]
        end
      end
      if line[:action] == "Show"
        if line[:module] == "Sales"
          res = api.show_sale(line[:voucher])
          puts res[:json]
        end
        if line[:module] == "Purchases"
          res = api.show_purchase(line[:voucher])
          puts res[:json]
        end
      end
      if line[:action] == "Create"
        if line[:module] == "Sales"
          res = api.create_sale(line)
          if res[:status].to_i == 422
            puts "error:" + res[:json]
            exit
          end
        end
        if line[:module] == "Purchases"
          res = api.create_purchase(line)
          if res[:status].to_i == 422
            puts "error:" + res[:json]
            exit
          end
        end
      end
      if line[:action] == "Destroy"
        if line[:module] == "Sales"
          res = api.destroy_sale(line[:voucher])
        end
        if line[:module] == "Purchases"
          res = api.destroy_purchase(line[:voucher])
        end
      end
    end
  end
end

Sample.new([
                   { action: "Create", module: "Sales", price: 10000, year: 2015, month: 8, realization_timestamp: "2015-08-01", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "SALES", dc: 'd', memo: "", tax_code: 1007, scheduled_memo: "This is a scheduled memo.", scheduled_receive_timestamp: "2015-09-25" },
                   { action: "Create", module: "Purchases", price: 5000, year: 2015, month: 8, accrual_timestamp: "2015-08-01", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "BUYING_IN", dc: 'c', memo: "", tax_code: 1007, port_type: 1 },
                   { action: "Create", module: "Sales", price: 95000, year: 2015, month: 9, realization_timestamp: "2015-09-25", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "OTHERS_INCREASE", dc: 'd', memo: "決算会社/マーチャントの相殺", tax_code: 0 },
                   { action: "Create", module: "Sales", price: 10000, year: 2015, month: 9, realization_timestamp: "2015-09-25", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "OTHERS_DECREASE", dc: 'c', memo: "決算会社/マーチャントの相殺", tax_code: 0 },
                   { action: "Create", module: "Sales", price: 5000, year: 2015, month: 9, realization_timestamp: "2015-09-25", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "OFFSET_CREDITS_AGAINST_DEBTS", dc: 'c', memo: "決算会社/決済会社の相殺", tax_code: 0 },
                   { action: "Create", module: "Purchases", price: 5000, year: 2015, month: 9, accrual_timestamp: "2015-09-25", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "OFFSET_DEBTS_AGAINST_CREDITS", dc: 'd', memo: "決算会社/決済会社の相殺", tax_code: 0, port_type: 1 },
                   { action: "Create", module: "Purchases", price: 90000, year: 2015, month: 9, accrual_timestamp: "2015-09-30", customer_master_code: "101", dept_code: "SETSURITSU", reason_master_code: "OTHERS_INCREASE", dc: 'c', memo: "売掛金/未払金振替", tax_code: 0, port_type: 1 },
                   { action: "Create", module: "Sales", price: 90000, year: 2015, month: 9, realization_timestamp: "2015-09-30", customer_master_code: "102", dept_code: "SETSURITSU", reason_master_code: "OTHERS_INCREASE", dc: 'd', memo: "売掛金/未払い金振替", tax_code: 0 },
                   { action: "Show", module: "Sales", voucher: "AR834"},
                   { action: "Show", module: "Purchases", voucher: "AP622"},
                   { action: "Destroy", module: "Sales", voucher: "AR839"},
                   { action: "Destroy", module: "Purchases", voucher: "AP625"},
                   { action: "List", module: "Sales", year: 2015, month: 9},
                   { action: "List", module: "Purchases", year: 2015, month: 9}
                 ])


