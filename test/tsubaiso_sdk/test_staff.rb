require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class StaffTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("staffs")
  end

  def test_show_staff
    staff_list = @api.list_staff
    first_staff_id = staff_list[:json].first[:id]

    get_staff_member = @api.show_staff(first_staff_id)
    assert_equal 200, get_staff_member[:status].to_i, get_staff_member.inspect
    assert_equal first_staff_id, get_staff_member[:json][:id]
  end

  def test_list_staff
    staff_list = @api.list_staff
    assert_equal 200, staff_list[:status].to_i, staff_list.inspect
    assert !staff_list.empty?
  end

end
