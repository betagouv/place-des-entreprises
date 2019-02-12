# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailers/admin_mailer/weekly_statistics.html.haml', type: :view do
  context 'hash with several information' do
    let(:user) { create :user }
    let(:diagnoses) { create_list :diagnosis, 2 }

    before do
      information_hash = {
        signed_up_users: { count: 1, items: [user] },
        created_diagnoses: { count: 2, items: diagnoses },
        updated_diagnoses: { count: 2, items: diagnoses },
        completed_diagnoses: { count: 2, items: diagnoses },
        matches_count: 3,
        rejected_needs_count: 2,
        needs_with_no_one_in_charge_count: 2
      }

      assign(:information_hash, information_hash)
      render
    end

    it 'displays a title and 4 list elements' do
      expect(rendered).to include 'Bonjour, chers administrateurs !'
      assert_select 'li', count: 9
    end
  end

  context 'hash with few information' do
    before do
      information_hash = {
        signed_up_users: { count: 0, items: [] },
        created_diagnoses: { count: 0, items: [] },
        updated_diagnoses: { count: 0, items: [] },
        completed_diagnoses: { count: 0, items: [] },
        matches_count: 0,
        rejected_needs_count: 0,
        needs_with_no_one_in_charge_count: 0
      }

      assign(:information_hash, information_hash)
      render
    end

    it 'displays a title and no list element' do
      expect(rendered).to include 'Bonjour, chers administrateurs !'
      assert_select 'li', count: 0
    end
  end
end
