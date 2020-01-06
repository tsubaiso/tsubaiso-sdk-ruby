require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class DeptsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @dept_1 = {
      sort_no: 12_345_678,
      code: 'test_code',
      name: 'テスト部門',
      name_abbr: 'テストブモン',
      color: '#ffffff',
      memo: 'テストメモ',
      start_date: '2016-01-01',
      finish_date: '2016-01-02'
    }
    super("depts")
  end

  def test_create_dept
    dept = @api.create_dept(@dept_1)
    assert_equal 200, dept[:status].to_i, dept.inspect
    assert_equal @dept_1[:code], dept[:json][:code]
  end

  def test_update_dept
    dept = @api.create_dept(@dept_1)
    options = {
      id: dept[:json][:id],
      sort_no: 98_765,
      memo: 'updated at test',
      name: '更新部門',
      name_abbr: '更新部門'
    }

    updated_dept = @api.update_dept(dept[:json][:id], options)
    assert_equal 200, updated_dept[:status].to_i, updated_dept.inspect
    assert_equal options[:memo], updated_dept[:json][:memo]
    assert_equal options[:name], updated_dept[:json][:name]
    assert_equal options[:name_abbr], updated_dept[:json][:name_abbr]
  ensure
    @api.destroy_dept(updated_dept[:json][:id] || dept[:json][:id]) if updated_dept[:json][:id] || dept[:json][:id]
  end

  def test_show_dept
    dept = @api.create_dept(@dept_1)
    dept = @api.show_dept(dept[:json][:id])

    assert_equal 200, dept[:status].to_i, dept.inspect
    assert_equal @dept_1[:memo], dept[:json][:memo]
    @api.destroy_dept(dept[:json][:id])
  end

  def test_list_depts
    dept = @api.create_dept(@dept_1)
    assert_equal 200, dept[:status].to_i, dept.inspect

    depts = @api.list_depts
    assert_equal 200, depts[:status].to_i, depts.inspect
    assert(depts[:json].any? { |x| x[:id] == dept[:json][:id] })
  ensure
    @api.destroy_dept(dept[:json][:id]) if dept[:json][:id]
  end

end
