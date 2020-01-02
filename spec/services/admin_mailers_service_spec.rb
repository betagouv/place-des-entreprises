# frozen_string_literal: true

require 'rails_helper'

describe AdminMailersService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_statistics_email' do
    subject(:send_statistics_email) { described_class.send_statistics_email }

    let!(:not_admin_user) { create :user, is_admin: false }

    before do
      mail_instance = instance_double(ActionMailer::MessageDelivery, deliver_later: nil)

      allow(AdminMailer).to receive(:weekly_statistics).and_return(mail_instance)
    end

    describe 'email method parameters' do
      context 'no data' do
        let(:expected_information_hash) do
          {
            signed_up_users: { count: 1, items: [not_admin_user] },
            created_diagnoses: { count: 0, items: [] },
            updated_diagnoses: { count: 0, items: [] },
            completed_diagnoses: { count: 0, items: [] },
            abandoned_quo_not_taken: 0,
            abandoned_taken_not_done: 0,
            rejected: 0,
            matches_count: 0
          }
        end

        it do
          send_statistics_email

          expect(AdminMailer).to have_received(:weekly_statistics).with(expected_information_hash)
        end
      end

      context 'some data' do
        # Create experts with an already existing user
        let(:another_user) { create :user }
        let(:expert1) { create :expert, users: [another_user] }
        let(:expert2) { create :expert, users: [another_user] }
        let(:expert3) { create :expert, users: [another_user] }
        let(:expert4) { create :expert, users: [another_user] }
        let(:created_diagnoses) { create_list :diagnosis, 1, step: 1, advisor: not_admin_user }
        let(:completed_diagnoses) { create_list :diagnosis, 2, step: 5, advisor: not_admin_user, needs: [build(:need, matches: [build(:match, expert: expert1)])] }
        let(:need) { create :need, diagnosis: completed_diagnoses.first }
        let(:updated_diagnoses) do
          create_list :diagnosis, 1, step: 4, advisor: not_admin_user, created_at: 2.weeks.ago, updated_at: 1.hour.ago
        end

        let!(:expected_information_hash) do
          {
            signed_up_users: { count: 2, items: [not_admin_user, another_user] },
            created_diagnoses: { count: 1, items: created_diagnoses },
            updated_diagnoses: { count: 1, items: updated_diagnoses },
            completed_diagnoses: { count: 2, items: completed_diagnoses.reverse },
            abandoned_quo_not_taken: 0,
            abandoned_taken_not_done: 0,
            rejected: 0,
            matches_count: 4
          }
        end

        before do
          create :diagnosis, step: 1, advisor: not_admin_user, created_at: 2.weeks.ago, updated_at: 2.weeks.ago
          create :match, need: need, expert: expert1
          create :match, need: need, expert: expert2
          create :match, need: need, expert: expert3
        end

        it do
          send_statistics_email

          expect(AdminMailer).to have_received(:weekly_statistics).with(expected_information_hash)
        end
      end
    end
  end
end
