# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'needs', type: :system do
  let(:user) { create :user }
  let!(:current_expert) { create :expert, users: [user] }
  let(:other_expert) { create :expert }
  let(:diagnosis) { create :diagnosis_completed }

  let!(:need_quo) do
    create(:need, matches: [create(:match, expert: current_expert, status: :quo)])
  end
  let!(:need_taking_care) do
    create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :taking_care)])
  end
  let!(:need_not_for_me) do
    create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :not_for_me)])
  end
  let!(:need_done) do
    create(:need, matches: [create(:match, expert: current_expert, status: :done)])
  end
  let!(:need_archived) do
    create(:need, matches: [create(:match, expert: current_expert, status: :quo)], archived_at: Time.zone.now)
  end
  let!(:need_other_done) do
    create(:need, diagnosis: diagnosis, matches: [
      create(:match, expert: current_expert, status: :quo),
      create(:match, expert: other_expert, status: :done)
    ])
  end
  let!(:need_abandoned) do
    create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, created_at: 46.days.ago)], created_at: 46.days.ago)
  end

  describe 'user needs' do
    before do
      create_home_landing
      login_as user, scope: :user
    end

    it 'displays all user received needs pages' do
      visit '/'
      click_link 'Accès conseillers'
      click_link 'Demandes reçues'
      expect(page).to have_current_path(quo_active_needs_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 2)

      expect(side_menu_link(quo_active_needs_path)).to have_text('2')
      expect(side_menu_link(taking_care_needs_path)).to have_text('1')
      expect(side_menu_link(done_needs_path)).to have_text('1')
      expect(side_menu_link(not_for_me_needs_path)).to have_text('1')
      expect(side_menu_link(quo_abandoned_needs_path)).to have_text('1')

      click_link 'Prises en charge'
      expect(page).to have_current_path(taking_care_needs_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      click_link 'Clôturées'
      expect(page).to have_current_path(done_needs_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      click_link 'Refusées'
      expect(page).to have_current_path(not_for_me_needs_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      click_link 'Expirées'
      expect(page).to have_current_path(quo_abandoned_needs_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      click_link 'Boite de réception'
      find("a[href='#{need_path(need_other_done)}']").click

      expect(page).to have_selector 'h1', text: "#{need_other_done.subject.label}"
      expect(page).to have_css('.row-match', count: 2)
    end
  end
end
