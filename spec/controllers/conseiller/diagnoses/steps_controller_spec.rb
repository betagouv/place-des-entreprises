# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Conseiller::Diagnoses::StepsController do
  login_admin

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #needs' do
    subject(:request) { get :needs, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'GET #contact' do
    subject(:request) { get :contact, params: { id: diagnosis.id } }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'POST #update_contact' do
    let(:diagnosis) { create :diagnosis, advisor: advisor, visitee: nil }
    let(:locality) { diagnosis.facility.readable_locality }

    describe 'with the original address' do
      let(:params) do
        {
          id: diagnosis.id,
          diagnosis: {
            happened_on: "27/01/2020",
            visitee_attributes: {
              full_name: "Edith Piaf", job: "directrice", email: "edith@piaf.fr", phone_number: "0606060606"
            }
          }
        }
      end

      it 'create a visitee for diagnosis' do
        post :update_contact, params: params
        diagnosis.reload
        expect(diagnosis.visitee.full_name).to eq("Edith Piaf")
        expect(diagnosis.facility.readable_locality).to eq(locality)
      end
    end
  end

  describe 'POST #update_needs' do
    let(:diagnosis) { create :diagnosis }
    let(:need) { create(:need, diagnosis: diagnosis) }
    let(:new_subject) { create(:subject) }

    context 'normal workflow' do
      let(:params) do
        {
          id: diagnosis.id,
          diagnosis: {
            needs_attributes: [
              {
                id: need.id,
                subject_id: new_subject.id,
                description: 'description'
              }
            ]
          }
        }
      end

      it 'updates subject and redirect to matches step' do
        post :update_needs, params: params
        diagnosis.reload
        expect(diagnosis.step).to eq 'matches'
        expect(diagnosis.needs.first.subject).to eq new_subject
        expect(response).to redirect_to matches_conseiller_diagnosis_path(diagnosis)
      end
    end

    context 'Changes subject from solicitation page' do
      let(:params) do
        {
          id: diagnosis.id,
          diagnosis: {
            submit: 'return_solicitation_page',
            needs_attributes: [
              {
                id: need.id,
                subject_id: new_subject.id,
                description: 'description'
              }
            ]
          }
        }
      end

      it 'updates the subject and redirect to solicitations page' do
        post :update_needs, params: params
        diagnosis.reload
        expect(diagnosis.step).to eq 'matches'
        expect(diagnosis.needs.first.subject).to eq new_subject
        expect(response).to redirect_to conseiller_solicitation_path(diagnosis.solicitation)
      end
    end
  end

  describe 'GET #matches' do
    subject(:request) { get :matches, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'POST #update_matches' do
    let(:expert_subject) { create(:expert_subject) }
    let(:need) { create(:need, diagnosis: diagnosis) }

    let(:params) do
      {
        id: diagnosis.id,
        diagnosis: {
          needs_attributes: [
            {
              id: need.id,
              matches_attributes: [
                {
                  _destroy: selected ? '0' : '1',
                  subject_id: expert_subject.subject.id,
                  expert_id: expert_subject.expert.id,
                }
              ]
            }
          ]
        }
      }
    end

    before { stub_mjml_google_fonts }

    describe 'statuses are correctly updated' do
      let(:selected) { true }

      it('updates matches, needs and diagnoses statuses') {
        post :update_matches, params: params

        diagnosis.reload
        need.reload
        expect(diagnosis.step).to eq 'completed'
        expect(need.status).to eq 'quo'
        expect(diagnosis.matches.pluck(:status)).to contain_exactly('quo')
      }
    end

    describe 'matches must be selected' do
      context 'one match selected' do
        let(:selected) { true }

        it('redirects to the besoins page') {
          post :update_matches, params: params

          diagnosis.reload
          expect(diagnosis.matches.count).to eq 1
          expect(response).to redirect_to conseiller_solicitations_path
        }
      end

      context 'no match selected' do
        let(:selected) { false }

        it('redirects back to the matches page') {
          post :update_matches, params: params

          diagnosis.reload
          expect(diagnosis.matches.count).to eq 0
          expect(response).to render_template("matches")
        }
      end
    end

    describe 'the current admin should become the advisor if needed' do
      let(:solicitation) { create :solicitation }
      let(:diagnosis) { create :diagnosis, advisor: advisor, solicitation: solicitation }
      let(:current_user) { create :user, :admin }
      let(:selected) { true }

      context 'advisor is previously nil' do
        let(:advisor) { nil }

        it 'assigns the diagnosis to the current user' do
          post :update_matches, params: params

          diagnosis.reload
          expect(diagnosis.advisor).to eq current_user
        end
      end

      context 'advisor is previously another user' do
        let(:advisor) { create :user }

        it 'keeps the existing advisor' do
          post :update_matches, params: params

          diagnosis.reload
          expect(diagnosis.advisor).to eq advisor
        end
      end
    end
  end
end
