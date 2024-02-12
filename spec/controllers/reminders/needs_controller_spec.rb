# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Reminders::NeedsController do
  login_admin

  describe 'POST #send_abandoned_email' do
    let!(:need) { create :need }

    before { post :send_abandoned_email, params: { id: need.id } }

    it 'send email and set abandoned_email_sent' do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
      expect(enqueued_jobs.count).to eq 1
      expect(need.reload.is_abandoned?).to be false
    end
  end

  describe 'GET #abandon' do
    # - besoin avec 1 positionnement « refusé », et autres MER sans réponse           ko
    # - besoin avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ko
    # - besoin avec 1 cloture « injoignable », et autres MER sans réponse             ko
    # - besoin avec tous les positionnement « refusé »                                ok
    # - besoin archivé avec tous les positionnement « refusé »                        ko

    let!(:need1) { create :need_with_matches }
    let!(:need1_match) { create :match, need: need1, status: :not_for_me }
    let!(:need2) { create :need_with_matches }
    let!(:need2_match) { create :match, need: need2, status: :done_no_help }
    let!(:need3) { create :need_with_matches }
    let!(:need3_match) { create :match, need: need3, status: :done_not_reachable }
    let!(:need4) { create :need }
    let!(:need4_match1) { create :match, need: need4, status: :not_for_me }
    let!(:need4_match2) { create :match, need: need4, status: :not_for_me }

    before { get :abandon }

    it 'display only not_for_me needs' do
      expect(assigns(:needs)).to contain_exactly(need4)
    end
  end

  describe 'POST #send_last_chance_email' do
    let!(:need) { create :need }
    let!(:match1) { create :match, status: :quo, need: need }
    let!(:match2) { create :match, status: :done, need: need }
    let!(:match3) { create :match, status: :taking_care, need: need }
    let!(:match4) { create :match, status: :done_no_help, need: need }
    let!(:match5) { create :match, status: :done_not_reachable, need: need }
    let!(:match6) { create :match, status: :not_for_me, need: need }

    before do
      stub_mjml_google_fonts
      post :send_last_chance_email, params: { id: need.id }
    end

    it 'send email only for quo match and add a feedback' do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
      expect(enqueued_jobs.count).to eq 1
      expect(Feedback.where(feedbackable_id: match1.need.id).count).to eq 1
    end
  end

  describe 'POST #update_badges' do
    let!(:need) { create(:need) }
    let!(:badge) { create(:badge) }

    subject(:request) { post :update_badges, params: { id: need.id, need: { badge_ids: [badge.id] } }, format: :js }

    before { request }

    it { expect(need.badges).to contain_exactly(badge) }
  end
end
