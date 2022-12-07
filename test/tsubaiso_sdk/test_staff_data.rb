require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class StaffDataTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @staff_data_1 = {
      staff_id: 300,
      code: 'QUALIFICATION',
      value: 'TOEIC',
      start_timestamp: '2016-01-01',
      no_finish_timestamp: '1',
      memo: 'First memo'
    }
    super("staff_data")
  end

  def test_create_staff_data
    # NOTE : So far Tsubaiso SDK does not support create new staff.
    # NOTE : This test assume that staff who has id: 300 is exist.
    staff_data = @api.create_staff_data(@staff_data_1)
    assert_equal 200, staff_data[:status].to_i, staff_data.inspect
    @staff_data_1.each_pair do |key, val|
      assert staff_data[:json][key] != nil, "#{key} not found."
      assert_equal val, staff_data[:json][key], "col :#{key},  #{val} was expected but #{staff_data[:json][key]} was found."
    end
  end

  def test_show_staff_data
    staff_data = @api.create_staff_data(@staff_data_1)

    # get data using id (of data)
    get_staff_data = @api.show_staff_data(staff_data[:json][:id].to_i)
    assert_equal 200, get_staff_data[:status].to_i, get_staff_data.inspect
    assert_equal staff_data[:json][:id], get_staff_data[:json][:id]

    options = {
      staff_id: staff_data[:json][:staff_id],
      code: staff_data[:json][:code],
      time: staff_data[:json][:start_timestamp]
    }

    # get data using staff id and code (packed in Hash)
    get_staff_data_2 = @api.show_staff_data(options)
    assert_equal 200, get_staff_data_2[:status].to_i, get_staff_data.inspect
    assert_equal staff_data[:json][:id], get_staff_data_2[:json][:id]
  end


  def test_list_staff_data
    staff_data = @api.list_staff_data(@staff_data_1[:staff_id])
    assert_equal 200, staff_data[:status].to_i, staff_data.inspect
    @staff_data_1.each_pair do |key, val|
      assert staff_data[:json][0][key] != nil, "#{key} not found."
      assert_equal val, staff_data[:json][0][key], "col :#{key},  #{val} was expected but #{staff_data[:json][0][key]} was found."
    end
  end

  def test_update_staff_data
    staff_id = 0
    options = {
      value: 'Programmer'
    }

    updated_staff_data = @api.update_staff_data(staff_id,options)
    assert_equal 200, updated_staff_data[:status].to_i, updated_staff_data.inspect
    assert_equal staff_id, updated_staff_data[:json][:id].to_i
    assert_equal 'Programmer', updated_staff_data[:json][:value]
  end
end
