require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class BonusTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    @tag_1 = {
      code: 'test_code',
      name: 'テストタグ',
      sort_no: 10_000,
      tag_group_code: 'DEFAULT',
      start_ymd: '2016-01-01',
      finish_ymd: '2016-12-31'
    }
    super("bonuses")
  end

  def test_list_bonuses
    bonuses_list = @api.list_bonuses(1, 2016)
    assert_equal 200, bonuses_list[:status].to_i, bonuses_list.inspect
    assert bonuses_list[:json]
    assert !bonuses_list[:json].empty?
  end

  def test_show_bonus
    bonuses = @api.list_bonuses(1, 2016)
    bonus_id = bonuses[:json].first[:id]
    bonus = @api.show_bonus(bonus_id)

    assert_equal 200, bonus[:status].to_i, bonus.inspect
    assert_equal bonus[:json][:id], bonus_id
  end
end