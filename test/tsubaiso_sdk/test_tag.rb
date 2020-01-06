require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class TagsTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @tag_1 = {
      code: 'test_code',
      name: 'テストタグ',
      sort_no: 10_000,
      tag_group_code: 'DEFAULT',
      start_ymd: '2016-01-01',
      finish_ymd: '2016-12-31'
    }
    super("tags")
  end

  def test_create_tag
    tag = @api.create_tag(@tag_1)
    assert_equal 200, tag[:status].to_i, tag.inspect
    assert_equal @tag_1[:code], tag[:json][:code]
  end

  def test_update_tag
    tag = @api.create_tag(@tag_1)
    assert tag[:json][:id], tag
    options = {
      name: '更新タグ'
    }

    updated_tag = @api.update_tag(tag[:json][:id], options)
    assert_equal 200, updated_tag[:status].to_i, updated_tag.inspect
    assert_equal options[:name], updated_tag[:json][:name]
  end

  def test_list_tags
    tag = @api.create_tag(@tag_1)

    tags = @api.list_tags
    assert_equal 200, tags[:status].to_i, tags.inspect
    assert(tags[:json][@tag_1[:tag_group_code].to_sym].any? { |x| x[:id] == tag[:json][:id] })
  end

  def test_show_tag
    tag = @api.create_tag(@tag_1)
    tag = @api.show_tag(tag[:json][:id])

    assert_equal 200, tag[:status].to_i, tag.inspect
    assert_equal @tag_1[:name], tag[:json][:name]
  end

end
