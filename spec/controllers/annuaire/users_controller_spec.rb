# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Annuaire::UsersController do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1 }
    let!(:user_1_same_antenne) { create :user, :invitation_accepted, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }
    let!(:user_2) { create :user, :invitation_accepted, antenne: antenne_2 }
    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    context 'with a user params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug, advisor: user_1, antenne_id: antenne_1.id } }

      it 'return all users for the user antenne' do
        request
        expect(assigns(:users)).to contain_exactly(user_1, user_1_same_antenne)
      end
    end

    context 'with an antenne params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug, antenne_id: antenne_1.id } }

      it 'return all users for the antenne' do
        request
        expect(assigns(:users)).to contain_exactly(user_1, user_1_same_antenne)
      end
    end

    context 'with an institution params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug } }

      it 'return all users for the institution' do
        request
        expect(assigns(:users)).to contain_exactly(user_1, user_1_same_antenne, user_2)
      end
    end

    context 'with region and institution params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug, region_id: region_ouest.id } }

      it 'return users for the selected region' do
        request
        expect(assigns(:users)).to contain_exactly(user_1, user_1_same_antenne)
      end
    end
  end

  describe '#POST send_invitations' do
    let(:institution) { create :institution }
    let!(:antenne) { create :antenne, institution: institution }
    let!(:user) { create :user, antenne: antenne, invitation_sent_at: nil }
    let(:one_day_ago) { 1.day.ago }
    let!(:old_user) { create :user, antenne: antenne, invitation_sent_at: one_day_ago }

    subject(:request) { post :send_invitations, params: { institution_slug: institution.slug, users_ids: "#{user.id} #{old_user.id}" } }

    before do
      stub_mjml_google_fonts
      request
    end

    it 'expect invitation sent to user' do
      expect(user.reload.invitation_sent_at).not_to be_nil
    end

    it 'don’t invite user which have already accept the invitation' do
      expect(old_user.reload.invitation_sent_at.beginning_of_hour).to eq one_day_ago.beginning_of_hour
    end
  end
end
