require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class TexMasterTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("tax_masters")
  end

  def test_list_tax_masters
    tax_masters = @api.list_tax_masters
    assert_equal 200, tax_masters[:status].to_i, tax_masters.inspect
    assert !tax_masters[:json].empty?
  end

  def test_show_tax_master
    tax_masters = @api.list_tax_masters
    first_tax_master = tax_masters[:json].first
    tax_master = @api.show_tax_master(first_tax_master[:id])

    assert_equal 200, tax_master[:status].to_i, tax_master.inspect
    assert_equal first_tax_master[:name], tax_master[:json][:name]
  end
end
