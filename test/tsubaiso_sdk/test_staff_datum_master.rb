require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class StaffDatumMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("staff_datum_masters")
  end

  def test_show_staff_datum_master
    staff_datum_masters_list = @api.list_staff_datum_masters
    first_staff_datum_master_id = staff_datum_masters_list[:json].first[:id]

    get_staff_datum_master = @api.show_staff_datum_master(first_staff_datum_master_id)
    assert_equal 200, get_staff_datum_master[:status].to_i, get_staff_datum_master.inspect
    assert_equal first_staff_datum_master_id, get_staff_datum_master[:json][:id]
  end

  def test_show_staff_datum_master_by_code
    staff_datum_masters_list = @api.list_staff_datum_masters
    first_staff_datum_master_code = staff_datum_masters_list[:json].first[:code]

    options = { code: first_staff_datum_master_code }

    # get data using code
    get_staff_data_2 = @api.show_staff_datum_master(options)
    assert_equal 200, get_staff_data_2[:status].to_i, get_staff_data_2.inspect
    assert_equal first_staff_datum_master_code, get_staff_data_2[:json][:code]
  end

  def test_list_staff_datum_masters
    staff_datum_masters_list = @api.list_staff_datum_masters
    assert_equal 200, staff_datum_masters_list[:status].to_i, staff_datum_masters_list.inspect
    assert !staff_datum_masters_list.empty?
  end
end
