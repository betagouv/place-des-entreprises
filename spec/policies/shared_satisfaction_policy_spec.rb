require 'rails_helper'

RSpec.describe SharedSatisfactionPolicy, type: :policy do
  subject { described_class }

  permissions :show_navbar? do
    context "denies access if user is a manager" do
      let(:user) { create :user, :manager }

      it { is_expected.to permit(user) }
    end

    context "grants access if user is a standard user" do
      let(:user) { create :user }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end
  end
end
