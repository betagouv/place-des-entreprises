# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :antenne
      is_expected.to have_many(:experts_subjects)
      is_expected.to have_many :received_matches
      is_expected.to have_and_belong_to_many :users
      is_expected.to have_and_belong_to_many :communes
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:antenne)
        is_expected.to validate_presence_of(:email)
        is_expected.to validate_presence_of(:phone_number)
      end
    end
  end

  describe 'scopes' do
    describe 'commune zone scopes' do
      let(:expert_with_custom_communes) { create :expert, antenne: antenne, communes: [commune1] }
      let(:expert_without_custom_communes) { create :expert, antenne: antenne }
      let(:commune1) { create :commune }
      let(:commune2) { create :commune }
      let!(:antenne) { create :antenne, communes: [commune1, commune2] }

      describe 'with_custom_communes' do
        subject { described_class.with_custom_communes }

        it { is_expected.to match_array [expert_with_custom_communes] }
      end

      describe 'without_custom_communes' do
        subject { described_class.without_custom_communes }

        it { is_expected.to match_array [expert_without_custom_communes] }
      end
    end
  end

  describe 'to_s' do
    let(:expert) { build :expert, full_name: 'Ivan Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end

  describe 'generate_access_token' do
    let(:expert) { create :expert }

    context 'it is a new expert' do
      context 'there is no expert with this access_token' do
        before { allow(SecureRandom).to receive(:hex).once.and_return('access_token') }

        it { expect(expert.access_token).to eq 'access_token' }
      end

      context 'there is already a expert with this access_token' do
        let!(:expert_with_same_access_token) { create :expert }

        before do
          expert_with_same_access_token.update access_token: 'access_token'
          allow(SecureRandom).to receive(:hex).at_least(:once).and_return('access_token', 'other_access_token')
        end

        it { expect(expert.access_token).to eq 'other_access_token' }
      end
    end

    context 'expert is already created' do
      before do
        allow(SecureRandom).to receive(:hex).once.and_return('access_token')
        expert.save
      end

      it { expect(expert.access_token).to eq 'access_token' }
    end
  end
end
