# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

describe 'solicitation_form', :js, type: :feature do
  subject { page }

  describe 'accessible solicitation form' do
    let(:pde_subject) { create :subject }
    let!(:landing) { create :landing, slug: 'accueil', title: 'Accueil' }
    let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
    let!(:landing_subject) do
      create :landing_subject, landing_theme: landing_theme, subject: pde_subject,
                                    title: "Super sujet", description: "Description LS", requires_siret: true
    end
    let!(:additional_question_1) { create :additional_subject_question, subject: pde_subject, key: 'recrutement_poste_cadre' }
    let!(:additional_question_2) { create :additional_subject_question, subject: pde_subject, key: 'recrutement_en_apprentissage' }
    let(:siret) { '41816609600069' }
    let(:solicitation) { Solicitation.last }
    let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
    let(:fixture_file) { 'api_insee_siret.json' }
    let(:query) { siret }

    before do
      authorize_insee_token
      stub_request(:get, api_url).to_return(
        body: file_fixture(fixture_file)
      )
    end

    it do
      # First step
      visit "/aide-entreprise/#{landing.slug}/demande/#{landing_subject.slug}"
      is_expected.to be_accessible
      fill_in 'Prénom et nom', with: 'Mariane'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Téléphone', with: '0123456789'
      click_on 'Suivant'
      # Second step
      ## Search company
      is_expected.to be_accessible
      fill_in 'Recherchez votre entreprise (SIRET, SIREN, nom...)', with: query
      click_on 'Suivant'
      # ## Search Facility
      is_expected.to be_accessible
      click_on "#{query} - Octo Technology"
      # Third step
      is_expected.to be_accessible
      fill_in I18n.t('solicitations.creation_form.description'), with: 'Ceci n\'est pas un test'
      choose 'Oui', name: 'solicitation[institution_filters_attributes][0][filter_value]', allow_label_click: true
      choose 'Oui', name: 'solicitation[institution_filters_attributes][1][filter_value]', allow_label_click: true
      click_on 'Envoyer ma demande'
      # Thank's step
      is_expected.to be_accessible
    end
  end
end
