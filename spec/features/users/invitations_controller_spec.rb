# frozen_string_literal: true

require 'rails_helper'

describe 'invitations', type: :feature do
  describe 'new invitations' do
    login_user

    let!(:antenne) { create :antenne, name: 'Agence tous risques' }

    before do
      visit new_user_invitation_path

      fill_in id: 'user_email', with: 'marie.dupont@exemple.fr'
      fill_in id: 'user_full_name', with: 'Marie Dupont'
      fill_in id: 'user_phone_number', with: '0123456789'
      fill_in id: 'user_role', with: 'Conseillère'
      select 'Agence tous risques', from: 'user_antenne_id'

      click_button 'Envoyer l’invitation'
    end

    it 'creates a new invited user' do
      last_user = User.last
      expect(last_user).to be_created_by_invite
      expect(last_user.email).to eq 'marie.dupont@exemple.fr'
      expect(last_user.full_name).to eq 'Marie Dupont'
      expect(last_user.phone_number).to eq '0123456789'
      expect(last_user.role).to eq 'Conseillère'
      expect(last_user.antenne).to eq antenne
    end
  end

  describe 'accept invitation' do
    let!(:user) { create :user, full_name: "John Doe" }

    before do
      user.invite!
      visit accept_user_invitation_url(invitation_token: user.raw_invitation_token)
      fill_in id: 'user_full_name', with: 'Jane Doe'

      fill_in id: 'user_password', with: 'fakepassword'
      fill_in id: 'user_password_confirmation', with: 'fakepassword'

      click_button 'Enregistrer'
    end

    it 'marks the invitation as accepted, and takes modifications into account' do
      user.reload
      expect(user).to be_invitation_accepted
      expect(user.full_name).to eq 'Jane Doe'
    end
  end
end
