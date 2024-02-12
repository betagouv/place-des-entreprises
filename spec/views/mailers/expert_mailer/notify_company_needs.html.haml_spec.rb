# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe 'mailers/expert_mailer/notify_company_needs' do
  context 'hash with several information' do
    let(:contact) { create :contact }
    let(:user) { create :user }
    let(:expert) { create :expert }
    let(:need) { create(:need, matches: [create(:match, expert: expert)]) }

    before do
      stub_mjml_google_fonts
      assign(:expert, expert)
      assign(:diagnosis, need.diagnosis)
      assign(:need, need)

      render
    end

    it 'displays the date, phone number and 1 items' do
      expect(rendered).to include "besoins/#{need.id}"
      expect(rendered).to have_text("Voir le besoin", count: 1)
    end
  end
end
