# frozen_string_literal: true

require 'rails_helper'

describe 'about', :js, type: :feature do
  before { create_home_landing }

  subject { page }

  describe '/cgu' do
    before { visit '/cgu' }

    it { is_expected.to be_accessible }
  end

  describe '/mentions_d_information' do
    before { visit '/mentions_d_information' }

    it { is_expected.to be_accessible }
  end

  describe '/comment_ca_marche' do
    before do
      create_list :institution, 2, show_on_list: true
      visit '/comment_ca_marche'
    end

    it { is_expected.to be_accessible }
  end

  describe '/mentions_legales' do
    before { visit '/mentions_legales' }

    it { is_expected.to be_accessible }
  end

  describe '/accessibilite' do
    before { visit '/accessibilite' }

    it { is_expected.to be_accessible }
  end

  describe '/equipe' do
    before { visit '/equipe' }

    it { is_expected.to be_accessible }
  end
end
