require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class JournalDistriibutionTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    @journal_distribution_1 = {
      title: 'title',
      start_date: '2012-07-01',
      finish_date: '2012-07-31',
      account_codes: ['135~999','604'],
      dept_code: 'SETSURITSU',
      memo: '',
      criteria: 'dept',
      target_timestamp: '2017-02-01',
      distribution_conditions: { 'SETSURITSU' => '1', 'COMMON' => '1' }
    }
    super('journal_distributions')
  end

  def test_create_journal_distribution
    journal_distribution = @api.create_journal_distribution(@journal_distribution_1)
    assert_equal 200, journal_distribution[:status].to_i, journal_distribution.inspect
    assert_equal Time.parse(@journal_distribution_1[:target_timestamp]), Time.parse(journal_distribution[:json][:target_ym])
    assert_equal @journal_distribution_1[:account_codes], journal_distribution[:json][:target_conditions_account_codes].split(',').map{|x| x.delete("'")}
  end

end
