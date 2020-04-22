# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solicitation, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :diagnoses }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :landing_slug }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :phone_number }
    it { is_expected.to validate_presence_of :email }
  end

  describe '#landing_options' do
    let(:solicitation) { create :solicitation, landing_options_slugs: slugs }
    let!(:option1) { create :landing_option, slug: 'option1' }
    let!(:option2) { create :landing_option, slug: 'option2' }

    subject { solicitation.landing_options }

    context 'slugs are known' do
      let(:slugs) { %w[option1 option2] }

      it { is_expected.to match_array [option1, option2] }
    end

    context 'slugs are unknown' do
      let(:slugs) { %w[option3 option4] }

      it { is_expected.to be_empty }
    end
  end
end
