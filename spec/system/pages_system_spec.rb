# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'Pages' do
  before do
    create_home_landing
    # todo : tester empahsis + page contactez-nous ?
    create_base_dummy_data
  end

  it 'navigates public pages' do
    visit '/'

    find("a[href='#{comment_ca_marche_path}']", match: :first).click
    expect(page).to have_content "Questions fréquentes"
    expect(page).to have_css '.faq', count: 4
    advisors_count = User.not_deleted.invitation_accepted.distinct.count
    needs_count = Need.diagnosis_completed.count
    companies_count = Company.includes(:needs).references(:needs).where(facilities: { diagnoses: { step: :completed } }).distinct.count
    expect(page).to have_content(advisors_count)
    expect(page).to have_content(needs_count)
    expect(page).to have_content(companies_count)

    click_on 'Accès conseillers'
    click_on 'Accueil'

    click_on 'Conditions d’utilisation'
    click_on 'Mentions d\'information'
    click_on 'Mentions légales'
    click_on 'Accessibilité : partiellement conforme'
    click_on 'Statistiques'
    expect(page).to have_select 'territory'
    expect(page).to have_no_select 'institution'
    find_by_id('start_date').set "2021-03-01"
    click_on 'Filtrer'
    expect(page).to have_select 'territory'
    click_on 'Plan du site'
    expect(page).to have_content(Landing.first.landing_themes.first.title)
  end
end
