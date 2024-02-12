# frozen_string_literal: true

require 'rails_helper'

describe 'pages', :js, type: :feature do
  before { create_home_landing }

  login_user

  subject { page }

  describe '/tutoriels' do
    before { visit '/tutoriels' }

    it { is_expected.to be_accessible }
  end

  describe '/conseiller/sitemap' do
    before { visit '/conseiller/sitemap' }

    it { is_expected.to be_accessible }
  end

  describe '/mon_compte/informations' do
    before { visit '/mon_compte/informations' }

    it { is_expected.to be_accessible }
  end

  describe '/mon_compte/mot_de_passe' do
    before { visit '/mon_compte/mot_de_passe' }

    it { is_expected.to be_accessible }
  end

  describe '/mon_compte/antenne' do
    before { visit '/mon_compte/antenne' }

    it { is_expected.to be_accessible }
  end
end
