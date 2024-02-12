# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

describe QuarterlyReports::NotifyManagers do
  describe 'call' do
    let(:antenne) { create :antenne }
    let!(:quarterly_report) { create :quarterly_report, antenne: antenne, start_date: 3.months.ago.beginning_of_month }
    let!(:manager) { create :user, :manager, managed_antennes: [antenne] }
    let!(:normal_user) { create :user }

    before { stub_mjml_google_fonts }

    subject { described_class.new.call }

    it 'send a mail to managers' do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
        subject
      end
      expect(enqueued_jobs.count).to eq 1
    end
  end
end
