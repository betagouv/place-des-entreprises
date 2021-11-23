require 'rails_helper'

RSpec.describe Effectif, type: :model do
  describe 'intitule_effectif' do
    subject { described_class::intitule_effectif code }

    context 'valid code' do
      let(:code) { '31' }

      it{ is_expected.to eq '200 à 249 salariés' }
    end

    context 'nil code' do
      let(:code) { nil }

      it{ is_expected.to eq 'Autre' }
    end

    context 'invalid code' do
      let(:code) { 'Invalid' }

      it{ is_expected.to eq 'Autre' }
    end
  end
end
