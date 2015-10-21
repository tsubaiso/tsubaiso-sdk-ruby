# Tsubaiso SDK (Ruby)

The Tsubaiso SDK is a library of methods that directly uses Tsubaiso API web endpoints.

## API Endpoint Documentation

[English](https://github.com/tsubaiso/tsubaiso-api-documentation)

[Japanese](https://github.com/tsubaiso/tsubaiso-api-documentation/blob/master/README-j.md)

## Installation

Add this line to your application's Gemfile:

    gem 'tsubaiso-sdk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tsubaiso-sdk

## Usage

```sh
> require 'tsubaiso_sdk'
> sdk = TsubaisoSDK.new(access_token: 'XXXXX')
> sdk.create_sale({ price: 10000, year: 2015, month: 10, realization_timestamp: "2015-10-01", customer_master_code: "101", dept_code: "Dept A", reason_master_code: "SALES", dc: 'd', memo: "500 widgets", tax_code: 1007})
=> {:status=>"200", :json=>{:ar_reason_master_id=>4403, :ar_receipt_attachments_count=>nil, :code=>nil, :created_at=>"2015/10/21 11:17:39 +0900", :customer_master_id=>31304, :dc=>"d", :dept_code=>"Dept A", :id=>280959, :memo=>"500 widgets", :realization_timestamp=>"2015/10/01", :regist_user_code=>"XXXXX", :sales_journal_dc_id=>1813416, :scheduled_memo=>nil, :scheduled_receive_timestamp=>nil, :update_user_code=>nil, :updated_at=>"2015/10/21 11:17:39 +0900", :account_code=>"500", :sales_price=>9260, :sales_tax=>740, :sales_tax_type=>1007}}
```

## Testing

```sh
$ cd /~tsubaiso-sdk-1.0.0
$ export SDK_BASE_URL="https://tsubaiso.net"
$ export SDK_ACCESS_TOKEN="XXXXX"
$ rake
```
