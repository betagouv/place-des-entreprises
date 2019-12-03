# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe ExpertMailer do
  describe '#notify_company_needs' do
    subject(:mail) { described_class.notify_company_needs(expert, diagnosis).deliver_now }

    let(:expert) { create :expert }
    let(:user) { create :user }
    let(:subject1) { create :subject }
    let(:diagnosis) { create :diagnosis, advisor: user, visitee: create(:contact, :with_email) }
    let(:subjects_with_needs_description) { [{ subject: subject1, need_description: 'Help this company' }] }

    let(:params_hash) do
      {
        visit_date: diagnosis.happened_on,
        diagnosis_id: diagnosis.id,
        company_name: diagnosis.company.name,
        company_contact: diagnosis.visitee,
        subjects_with_needs_description: subjects_with_needs_description,
        advisor: user
      }
    end

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end

  describe '#remind_involvement' do
    subject(:mail) do
      described_class.remind_involvement(expert).deliver_now
    end

    let(:expert) { create :expert }

    before do
      create :match, expert: expert
    end

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end
end
