# frozen_string_literal: true

require 'rails_helper'

describe 'devise', :js, type: :feature do
  before { create_home_landing }

  subject { page }

  describe '/mon_compte/sign_in' do
    before { visit '/mon_compte/sign_in' }

    it do
      is_expected.to be_accessible
    end
  end

  describe '/mon_compte' do
    login_user
    let!(:expert) { create :expert_with_users, users: [current_user], antenne: current_user.antenne }
    let!(:expert2) { create :expert_with_users, users: [current_user], antenne: current_user.antenne }
    let!(:expert_subject) { create :expert_subject, expert: expert }
    let!(:institution_subject) { create :institution_subject, institution: expert.antenne.institution }

    context '/mon_compte/informations' do
      before { visit '/mon_compte/informations' }

      it { is_expected.to be_accessible }
    end

    context '/mon_compte/mot_de_passe' do
      before { visit '/mon_compte/mot_de_passe' }

      it { is_expected.to be_accessible }
    end

    context '/mon_compte/antenne' do
      before { visit '/mon_compte/antenne' }

      it { is_expected.to be_accessible }
    end

    context '/mon_compte/referents/:expert_id/domaines' do
      before { visit "/mon_compte/referents/#{expert.id}/domaines" }

      it { is_expected.to be_accessible }
    end
  end
end
