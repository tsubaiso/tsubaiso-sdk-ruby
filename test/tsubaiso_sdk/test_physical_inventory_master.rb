require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class PhysicalInventoryMaster < Minitest::Test
  include CommonSetupTeardown

  def setup
    @pim_201901 = {
      name: 'sendai',
      memo: 'this inventory is registered from SDK test',
      start_ymd: '2019/01/01',
      finish_ymd: nil,
      tag_list: 'GROUP2_1,GROUP3_2',
      dept_code: 'NEVER_ENDING'
    }

    @pim_201902 = {
      name: 'osaka',
      memo: 'this inventory is registered from SDK test #2',
      start_ymd: '2019/02/01',
      finish_ymd: '2020/12/02'
    }

    @pim_201903 = {
      name: 'nagoya',
      memo: 'this inventory is registered from SDK test #3',
      start_ymd: '2019/03/01',
      finish_ymd: '2020/12/03'
    }
    super("physical_inventory_masters")
  end

  def test_create_physical_inventory_masters
    physical_inventory_master = @api.create_physical_inventory_masters(@pim_201901)
    assert physical_inventory_master[:json] != nil

    assert_equal 200, physical_inventory_master[:status].to_i, physical_inventory_master.inspect
    assert_equal @pim_201901[:name], physical_inventory_master[:json][:name]
    assert_equal @pim_201901[:memo], physical_inventory_master[:json][:memo]
    assert_equal @pim_201901[:start_ymd], physical_inventory_master[:json][:start_ymd]
    assert_equal @pim_201901[:finish_ymd], physical_inventory_master[:json][:finish_ymd]
    assert_equal @pim_201901[:tag_list], physical_inventory_master[:json][:tag_list].join(",")
  end

  def test_list_physical_inventory_masters
    pim_201901 = @api.create_physical_inventory_masters(@pim_201901)
    pim_201902 = @api.create_physical_inventory_masters(@pim_201902)
    pim_201903 = @api.create_physical_inventory_masters(@pim_201903)

    pim_201901_id = pim_201901[:json][:id]
    pim_201902_id = pim_201902[:json][:id]
    pim_201903_id = pim_201903[:json][:id]

    list_physical_inventory_masters = @api.list_physical_inventory_masters
    assert_equal 200, list_physical_inventory_masters[:status].to_i, list_physical_inventory_masters.inspect

    assert(list_physical_inventory_masters[:json].any? { |x| x[:id] == pim_201901_id })
    assert(list_physical_inventory_masters[:json].any? { |x| x[:id] == pim_201902_id })
    assert(list_physical_inventory_masters[:json].any? { |x| x[:id] == pim_201903_id })
  end

  def test_update_physical_inventory_masters
    physical_inventory_master = @api.create_physical_inventory_masters(@pim_201901)
    assert physical_inventory_master[:json][:id], physical_inventory_master
    options = {
      id: physical_inventory_master[:json][:id],
      memo: 'Updated memo',
      name: 'kanazawa',
      start_ymd: '2019/11/21',
    }
    # NOTE: updating dept and tag_list is not permitted in physical_inventory_master.
    updated_physical_inventory_master = @api.update_physical_inventory_masters(options)
    assert physical_inventory_master[:json] != nil

    assert_equal 200, updated_physical_inventory_master[:status].to_i, updated_physical_inventory_master.inspect
    assert_equal options[:id], updated_physical_inventory_master[:json][:id]
    assert_equal options[:memo], updated_physical_inventory_master[:json][:memo]
    assert_equal options[:name], updated_physical_inventory_master[:json][:name]
    assert_equal options[:start_ymd], updated_physical_inventory_master[:json][:start_ymd]
    assert_equal physical_inventory_master[:json][:finish_ymd], updated_physical_inventory_master[:json][:finish_ymd]
  end

end

