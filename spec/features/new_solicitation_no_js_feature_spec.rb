# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

# Tests SANS js =========================================

describe 'New Solicitation' do
  let(:pde_subject) { create :subject }
  let!(:landing) { create :landing, slug: 'accueil', title: 'Accueil' }
  let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
  let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, subject: pde_subject, title: "Super sujet", description: "Description LS", requires_siret: true }
  let(:siret) { '41816609600069' }
  let(:siren) { siret[0..8] }
  let(:solicitation) { Solicitation.last }

  describe 'create' do
    before do
      landing.landing_themes << landing_theme
    end

    context "no API calls" do
      context "with PK params in url" do
        before do
          visit '/?pk_campaign=FOO&pk_kwd=BAR'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
        end

        it do
          expect(solicitation.persisted?).to be true
          expect(solicitation.pk_campaign).to eq 'FOO'
          expect(solicitation.pk_kwd).to eq 'BAR'
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.status_step_company?).to be true
        end
      end

      context "with MTM params in url" do
        before do
          visit '/?mtm_campaign=FOO&mtm_kwd=BAR'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Téléphone', with: '0123456789'
          fill_in 'Email', with: 'user@exemple.com'
          click_on 'Suivant'
        end

        it do
          expect(solicitation.persisted?).to be true
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject.subject).to eq pde_subject
          expect(solicitation.mtm_campaign).to eq 'FOO'
          expect(solicitation.mtm_kwd).to eq 'BAR'
        end
      end

      context "with siret in url" do
        let(:siret) { "41816609600069" }

        before do
          visit "/?siret=#{siret}"
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
        end

        it do
          expect(solicitation.persisted?).to be true
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.siret).to eq siret
          expect(solicitation.pk_campaign).to be_nil
          expect(solicitation.mtm_campaign).to be_nil
          expect(solicitation.status_step_company?).to be true
        end
      end
    end
  end
end
