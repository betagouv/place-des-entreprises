# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

describe 'Landings', :js, :flaky do
  let(:pde_subject) { create :subject }
  let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
  let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, subject: pde_subject, title: "Super sujet", description: "Description LS", requires_siret: true }

  describe 'single_page_layout' do
    let!(:landing) { create :landing, integration: :intern, slug: 'intern', layout: 'single_page' }

    before do
      create_home_landing
      landing.landing_themes << landing_theme
    end

    context "root url" do
      it do
        visit "/aide-entreprise/#{landing.slug}"
        expect(page).to have_css('h2', text: landing_theme.title)
        expect(page).to have_link(landing_subject.title)
      end
    end

    context "theme url" do
      it do
        visit "/aide-entreprise/#{landing.slug}/theme/#{landing_theme.slug}"
        expect(page).to have_css('h2', text: landing_theme.title)
        expect(page).to have_link(landing_subject.title)
      end
    end
  end
end
