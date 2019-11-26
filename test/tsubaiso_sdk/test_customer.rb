require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class CustomerTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    @customer_1000 = {
      name: 'テスト株式会社',
      name_kana: 'テストカブシキガイシャ',
      code: '10000',
      tax_type_for_remittance_charge: '3',
      used_in_ar: 1,
      used_in_ap: 1,
      is_valid: 1,
      pay_date_if_holiday: 1,
      receive_date_if_holiday: 1
    }
    super("customer_masters")
  end

  def test_create_customer
    customer = @api.create_customer(@customer_1000)

    assert_equal 200, customer[:status].to_i, customer.inspect
    assert_equal @customer_1000[:name], customer[:json][:name]
    assert_equal @customer_1000[:pay_date_if_holiday], customer[:json][:pay_date_if_holiday]
    assert_equal @customer_1000[:receive_date_if_holiday], customer[:json][:receive_date_if_holiday]
  end

  def test_update_customer
    customer = @api.create_customer(@customer_1000)
    options = {
      id: customer[:json][:id],
      name: 'New Customer Name',
      pay_date_if_holiday: 0,
      receive_date_if_holiday: 0
    }

    updated_customer = @api.update_customer(options)
    assert_equal 200, updated_customer[:status].to_i
    assert_equal customer[:json][:id], updated_customer[:json][:id]
    assert_equal options[:name], updated_customer[:json][:name]
    assert_equal options[:pay_date_if_holiday], updated_customer[:json][:pay_date_if_holiday]
    assert_equal options[:receive_date_if_holiday], updated_customer[:json][:receive_date_if_holiday]
  end

  def test_show_customer
    customer = @api.create_customer(@customer_1000)
    get_customer = @api.show_customer(customer[:json][:id])
    assert_equal 200, get_customer[:status].to_i, get_customer.inspect
    assert_equal customer[:json][:id], get_customer[:json][:id]
  end

  def test_show_customer_by_code
    customer = @api.create_customer(@customer_1000)

    get_customer = @api.show_customer_by_code(@customer_1000[:code])
    assert_equal 200, get_customer[:status].to_i, get_customer.inspect
    assert_equal customer[:json][:id], get_customer[:json][:id]
    assert_equal customer[:json][:code], get_customer[:json][:code]
  end

  def test_list_customers
    customer_1000 = @api.create_customer(@customer_1000)
    customer_1000_id = customer_1000[:json][:id]
    customer_list = @api.list_customers
    assert_equal 200, customer_list[:status].to_i, customer_list.inspect
    assert(customer_list[:json].any? { |x| x[:id] == customer_1000_id })
  end
end