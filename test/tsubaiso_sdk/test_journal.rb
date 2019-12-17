require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class JournalsTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    @sale_201608 = {
      price_including_tax: 10_800,
      realization_timestamp: '2016-08-01',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2016-09-25',
      data_partner: { link_url: 'www.example.com/1', id_code: '1', partner_code: 'Example' }
    }
    @sale_201609 = {
      price_including_tax: 10_800,
      realization_timestamp: '2016-09-01',
      customer_master_code: '101',
      dept_code: 'SETSURITSU',
      reason_master_code: 'SALES',
      dc: 'd',
      memo: '',
      tax_code: 1007,
      scheduled_memo: 'This is a scheduled memo.',
      scheduled_receive_timestamp: '2016-09-25',
      data_partner: { link_url: 'www.example.com/2', id_code: '2' }
    }
    @purchase_201608 = {
      price_including_tax: 5400,
      year: 2016,
      month: 8,
      accrual_timestamp: '2016-08-01',
      customer_master_code: '102',
      dept_code: 'SETSURITSU',
      reason_master_code: 'BUYING_IN',
      dc: 'c',
      memo: '',
      tax_code: 1007,
      port_type: 1,
      data_partner: { link_url: 'www.example.com/3', id_code: '3', partner_code: 'Example' }
    }
    super('journals')
  end

  def test_list_journals
    options = { start_date: '2019-12-01', finish_date: '2019-12-31' }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    assert_equal records.size, 3

    options = { price_min: 10_800, price_max: 10_800 }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    assert_equal records.size, 3
    record_prices = records.map { |x| x[:journal_dcs].map { |y| y[:debit][:price_excluding_tax] } }.flatten(1)
    record_prices.each do |price|
      assert_equal price, 10_800
    end

    options = { dept_code: 'SETSURITSU' }
    journals_list = @api.list_journals(options)
    records = journals_list[:json][:records]
    assert_equal 200, journals_list[:status].to_i, journals_list.inspect
    assert_equal records.size, 3
    record_depts = records.map { |x| x[:journal_dcs].map { |y| y[:dept_code] } }.flatten(1)
    record_depts.each do |dept|
      assert_equal dept, "SETSURITSU"
    end

  end

  def test_show_journal
    journal0 = @api.show_journal(0)
    journal1 = @api.show_journal(1)
    journal2 = @api.show_journal(2)

    assert_equal 200, journal0[:status].to_i, journal0.inspect
    assert_equal 200, journal0[:status].to_i, journal1.inspect
    assert_equal 200, journal0[:status].to_i, journal2.inspect

    assert_equal 0.to_s, journal0[:json][:record][:id]
    assert_equal 1.to_s, journal1[:json][:record][:id]
    assert_equal 2.to_s, journal2[:json][:record][:id]
  end
end