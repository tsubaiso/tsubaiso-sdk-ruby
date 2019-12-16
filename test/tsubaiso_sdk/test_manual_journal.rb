require 'minitest/autorun'
require_relative './common_setup_teardown.rb'

class ManualJournalTest < Minitest::Test
  include CommonSetupTeardown

  def setup
    @manual_journal_1 = {
      journal_timestamp: '2016-04-01',
      journal_dcs: [
        {
          debit: {
            account_code: '110',
            price_including_tax: 200_000,
            tax_type: 0
          },
          credit: {
            account_code: '100',
            price_including_tax: 200_000,
            tax_type: 0
          }
        },
        {
          debit: {
            account_code: '1',
            price_including_tax: 54_321,
            tax_type: 0
          },
          credit: {
            account_code: '110',
            price_including_tax: 54_321,
            tax_type: 0
          },
          memo: 'Created From API'
        }
      ],
      data_partner: { link_url: 'www.example.com/7', id_code: '7' }
    }
    super('manual_journals')
  end

  def test_list_manual_journals
    manual_journals_list = @api.list_manual_journals(2016, 4)
    assert_equal 200, manual_journals_list[:status].to_i, manual_journals_list.inspect
    assert !manual_journals_list[:json].empty?
  end

  def test_show_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    manual_journals_list = @api.list_manual_journals(2016, 4)
    last_manual_journal_id = manual_journals_list[:json].last[:id]

    manual_journal = @api.show_manual_journal(last_manual_journal_id)
    assert_equal 200, manual_journal[:status].to_i, manual_journal.inspect
    assert_equal last_manual_journal_id, manual_journal[:json][:id]
  end

  def test_create_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    assert_equal 200, manual_journal[:status].to_i, manual_journal.inspect
    assert_equal @manual_journal_1[:journal_dcs][0][:debit][:price_including_tax], manual_journal[:json][:journal_dcs][0][:debit][:price_including_tax]
    assert_equal @manual_journal_1[:data_partner][:id_code], manual_journal[:json][:data_partner][:id_code]
  end

  def test_update_manual_journal
    manual_journal = @api.create_manual_journal(@manual_journal_1)
    options = {
      id: manual_journal[:json][:id],
      journal_dcs: manual_journal[:json][:journal_dcs],
      data_partner: { :id_code => '700' },
    }
    options[:journal_dcs][0][:debit][:price_including_tax]  = 2000
    options[:journal_dcs][0][:credit][:price_including_tax] = 2000
    options[:journal_dcs][0][:memo] = 'Updated from API'
    options[:journal_dcs][1][:dept_code] = 'SETSURITSU'

    updated_manual_journal = @api.update_manual_journal(options)
    assert_equal 200, updated_manual_journal[:status].to_i, updated_manual_journal.inspect
    assert_equal options[:journal_dcs][0][:debit][:price_including_tax], updated_manual_journal[:json][:journal_dcs][0][:debit][:price_including_tax]
    assert_equal options[:journal_dcs][0][:memo], updated_manual_journal[:json][:journal_dcs][0][:memo]
    assert_equal options[:journal_dcs][1][:dept_code], updated_manual_journal[:json][:journal_dcs][1][:dept_code]
    assert_equal options[:data_partner][:id_code], updated_manual_journal[:json][:data_partner][:id_code]
  end
end