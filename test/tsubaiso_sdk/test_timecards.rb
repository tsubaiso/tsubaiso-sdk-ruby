require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class TimecardsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @timecards_1 = {
      staff_id: 2010,
      target_ymd: '2020/01/15',
      punch_time_0: '09:00',
      punch_time_1: '12:30',
      punch_time_2: '13:45',
      punch_time_3: '17:20',
      additional_memo: 'タイムカード１',
    }

    @timecards_2 = {
      staff_id: 2010,
      target_ymd: '2020/01/16',
      punch_time_0: '09:05',
      punch_time_3: '17:25',
      additional_memo: 'タイムカード2',
    }

    super("timecards")
  end

  def test_create_timecard
    created_timecard = @api.create_timecard(@timecards_1)

    assert_equal 200, created_timecard[:status].to_i, created_timecard.inspect
    assert_equal @timecards_1[:staff_id], created_timecard[:json][:staff_id]
    assert_equal @timecards_1[:target_ymd], created_timecard[:json][:target_ymd]
    assert_equal @timecards_1[:punch_time_0], created_timecard[:json][:punch_time_0]
    assert_equal @timecards_1[:punch_time_1], created_timecard[:json][:punch_time_1]
    assert_equal @timecards_1[:punch_time_2], created_timecard[:json][:punch_time_2]
    assert_equal @timecards_1[:punch_time_3], created_timecard[:json][:punch_time_3]
    assert_equal 'タイムカード１[22-01-21 13:30:46 (山川 太郎)', created_timecard[:json][:memo]
  end

  def test_list_timecards
    tc1 = @api.create_timecard(@timecards_1)
    tc2 = @api.create_timecard(@timecards_2)

    listed_timecards = @api.list_timecards(2020, 1)
    assert_equal 200, listed_timecards[:status].to_i, listed_timecards.inspect
    target_timecard = listed_timecards[:json].find{ |tc| tc[:id] == tc1[:json][:id]}
    assert_equal @timecards_1[:punch_time_0], target_timecard[:punch_time_0]
  end

  def test_update_timecard
    created_timecard = @api.create_timecard(@timecards_1)
    assert_equal 200, created_timecard[:status].to_i
    assert_equal "0", created_timecard[:json][:id]

    updating_options = {
      id: created_timecard[:json][:id],
      punch_time_0: "09:01",
      punch_time_1: "12:31",
      punch_time_2: "13:46",
      punch_time_3: "17:21",
      additional_memo: "修正しました。",
    }

    updated_timecard = @api.update_timecard(updating_options)
    assert_equal 200, updated_timecard[:status].to_i
  end
end
