# frozen_string_literal: true

require 'rails_helper'

describe 'landings', :js, type: :feature do
  let!(:landing) { create :landing, title: 'Accueil', slug: 'accueil' }
  let(:landing_theme) { create :landing_theme, title: 'Theme', slug: 'theme' }

  subject { page }

  describe '/' do
    before { visit '/' }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprise/:landing_slug' do
    before do
      visit "/aide-entreprise/#{Landing.last.slug}"
    end

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprise/:landing_slug/theme/:slug' do
    before { visit "/aide-entreprise/#{landing.slug}/theme/#{landing_theme.slug}" }

    it { is_expected.to be_accessible }
  end
end
