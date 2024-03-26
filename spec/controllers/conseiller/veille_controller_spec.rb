# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::VeilleController do
  login_admin

  describe 'index pages' do
    
    describe 'GET #index' do
      subject(:request) { get :index }
      
      it 'redirects properly' do
        expect(request).to redirect_to(quo_matches_conseiller_veille_index_path)
      end
    end
    
    describe 'GET #quo_matches' do
      let!(:done_need_with_quo_match) { create :need, status: :done }
      let!(:done_match_01) { create(:match, need: done_need_with_quo_match, status: :quo, sent_at: 30.days.ago) }
      let!(:done_match_02) { create(:match, need: done_need_with_quo_match, status: :done, sent_at: 30.days.ago) }
      let!(:taking_care_need_with_quo_match) { create :need, status: :taking_care }
      let!(:taking_care_match_01) { create(:match, need: taking_care_need_with_quo_match, status: :quo, sent_at: 30.days.ago) }
      let!(:taking_care_match_02) { create(:match, need: taking_care_need_with_quo_match, status: :taking_care, sent_at: 30.days.ago) }
      let!(:done_no_help_need_with_quo_match) { create :need, status: :done_no_help }
      let!(:done_no_help_match_01) { create(:match, need: done_no_help_need_with_quo_match, status: :quo, sent_at: 30.days.ago) }
      let!(:done_no_help_match_02) { create(:match, need: done_no_help_need_with_quo_match, status: :done_no_help, sent_at: 30.days.ago) }

      context 'without filters' do
        subject(:request) { get :quo_matches }

        before { request }
        
        it { expect(assigns(:needs)).to contain_exactly(done_need_with_quo_match, taking_care_need_with_quo_match, done_no_help_need_with_quo_match) }
      end

      context 'with filters' do
      #   TODO
      end

    end

    describe 'GET #starred_needs' do
      subject(:request) { get :starred_needs }

      before { request }

      xit { expect(assigns(:solicitations)).to contain_exactly(canceled) }
    end
  end
end
