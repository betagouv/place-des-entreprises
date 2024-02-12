require 'rails_helper'
RSpec.describe MatchFeedbackEmailJob do
  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end

  describe "perform" do
    let(:user) { create :user }

    before { stub_mjml_google_fonts }

    describe 'with feedback present' do
      let(:feedback) { create :feedback, :for_need, user: user }

      before { described_class.perform_now(feedback.id, user) }

      it { expect(ActionMailer::Base.deliveries.count).to eq 1 }
    end

    describe 'with feedback not present' do
      before { described_class.perform_now(0, user) }

      it { expect(ActionMailer::Base.deliveries.count).to eq 0 }
    end
  end
end
