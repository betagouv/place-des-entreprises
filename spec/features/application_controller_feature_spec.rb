# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationController specific features' do
  before { create_home_landing }

  describe 'authenticate_admin!' do
    login_user

    context 'user is not admin' do

      it do
        expect do
          visit '/admin'
        end.to raise_error ActionController::RoutingError
      end
    end

    context 'user is admin' do
      it do
        current_user.user_rights.create(category: 'admin')
        visit '/admin'
        expect(page.html).to include 'Sollicitations'
      end
    end
  end

  describe 'general navigation' do
    login_user

    context 'user is simple user' do
      it 'shows no errors' do
        visit '/besoins'
        visit '/mon_compte'
        click_on 'Mot de passe'
        click_on 'Antenne'
        click_on 'Domaines d’intervention'
        click_on 'Tutoriel'
        visit 'entreprises/search'
        expect(page.html).to include 'Demandes reçues'
        expect(page.html).not_to include 'Administration'
        expect(page.html).not_to include 'Annuaire'
        expect(page.html).not_to include 'Tags'
        expect(page.html).not_to include 'Exports csv'
        expect(page.html).not_to include 'Inviter des utilisateurs'
      end
    end

    context 'user is manager' do
      before { current_user.user_rights.create(category: 'manager') }

      it 'shows no errors' do
        visit '/besoins'
        visit '/manager/besoins-des-antennes'
        visit '/export-des-donnees'
        expect(page.html).to include 'Demandes reçues'
      end
    end

    context 'user is admin' do
      before { current_user.user_rights.create(category: 'admin') }

      it 'shows no errors' do
        visit '/mon_compte'
        expect(page.html).to include 'Annuaire'
        click_on 'Annuaire'
        click_on 'Tags'
        click_on 'Exports csv'
        click_on 'Inviter des utilisateurs'
      end
    end
  end

  describe 'after_sign_in_path_for' do
    let(:password) { 'yX*4Ubo_xPW!u' }

    before do
      visit new_user_session_path
      within '.new_user' do
        fill_in I18n.t('attributes.email'), with: user.email
        fill_in I18n.t('activerecord.attributes.user.password'), with: password
        click_on I18n.t('sign_in'), class: 'fr-btn'
      end
    end

    context 'first connexion' do
      let(:user) { create :user, password: password, password_confirmation: password, sign_in_count: 0 }

      it('redirects to tutorial page') { expect(current_url).to eq tutoriels_url }
    end

    context 'already connected' do
      let(:user) { create :user, password: password, password_confirmation: password, sign_in_count: 1 }

      it('redirects to needs quo page') { expect(current_url).to eq quo_active_needs_url }
    end

    context 'antenne manager connection' do
      let(:user) { create :user, :manager, password: password, password_confirmation: password, sign_in_count: 1 }

      it('redirects to reports page') { expect(current_url).to eq reports_url }
    end

    context 'admin manager connection' do
      let(:user) { create :user, :admin, password: password, password_confirmation: password, sign_in_count: 1 }

      it('redirects to conseiller solicitations page') { expect(current_url).to eq conseiller_solicitations_url }
    end
  end
end
