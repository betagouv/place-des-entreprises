# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Reminders::ExpertsController do
  login_admin

  describe 'Currents baskets' do
    create_experts_for_reminders

    before { RemindersService.new.create_reminders_registers }

    describe '#GET many_pending_needs' do
      before { get :many_pending_needs }

      it { expect(assigns(:active_experts)).to contain_exactly(expert_with_many_old_quo_matches) }
    end

    describe '#GET medium_pending_needs' do
      before { get :medium_pending_needs }

      it { expect(assigns(:active_experts)).to contain_exactly(expert_with_medium_old_quo_matches, expert_with_only_old_quo_matches) }
    end

    describe '#GET one_pending_need' do
      before { get :one_pending_need }

      it { expect(assigns(:active_experts)).to contain_exactly(expert_with_one_quo_match_1, expert_with_one_old_quo_match) }
    end
  end

  describe 'input and output' do
    create_registers_for_reminders

    before do
      RemindersService.new.create_reminders_registers
      expert_input_processed.reminders_registers.last.update(processed: true)
    end

    describe '#GET inputs' do
      context 'without search params' do
        before { get :inputs }

        it { expect(assigns(:active_experts)).to contain_exactly(expert_input, expert_remainder_not_processed) }
      end

      context 'with search params' do
        before { get :inputs, params: { by_full_name: expert_input.full_name } }

        it { expect(assigns(:active_experts)).to contain_exactly(expert_input) }
      end
    end

    describe '#GET outputs' do
      before { get :outputs }

      it { expect(assigns(:active_experts)).to contain_exactly(expert_output_not_seen, old_expert_output_not_seen, expert_input_to_output) }
    end

    describe '#GET expired_needs' do
      before { get :expired_needs }

      it { expect(assigns(:active_experts)).to contain_exactly(expert_remainder_to_expired) }
    end
  end

  describe '#send_reminder_email' do
    let!(:need) { create :need }
    let!(:match1) { create :match, status: :quo, need: need }
    let!(:match2) { create :match, status: :done, need: need }
    let!(:match3) { create :match, status: :taking_care, need: need }
    let!(:match4) { create :match, status: :done_no_help, need: need }
    let!(:match5) { create :match, status: :done_not_reachable, need: need }
    let!(:match6) { create :match, status: :not_for_me, need: need }

    before do
      stub_mjml_google_fonts
      post :send_reminder_email, format: :turbo_stream, params: { id: match1.expert_id }
    end

    it 'send email only for quo match and add a feedback' do
      expect(enqueued_jobs.count).to eq 1
      expect(Feedback.where(feedbackable_id: match1.expert_id).count).to eq 1
    end
  end
end
