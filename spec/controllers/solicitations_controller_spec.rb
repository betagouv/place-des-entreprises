require 'rails_helper'

RSpec.describe SolicitationsController do
  before { create_home_landing }

  describe 'GET #new' do
    let(:landing) { create(:landing) }
    let(:landing_subject) { create(:landing_subject) }

    context 'with existing landing and landing subject' do
      it do
        get :new, params: { landing_slug: landing.slug, landing_subject_slug: landing_subject.slug }
        expect(response).to be_successful
      end
    end

    context 'with existing landing but without landing subject' do
      let(:landing) { create(:landing) }

      it do
        get :new, params: { landing_slug: landing.slug, landing_subject_slug: 'unknown' }
        expect(response).to redirect_to root_path
        expect(response).to have_http_status(:moved_permanently)
      end
    end

    context 'with a good solicitation uuid' do
      let(:solicitation) { create(:solicitation, uuid: 'good-solicitation-uuid') }

      it do
        get :new, params: { uuid: solicitation.uuid, landing_slug: landing.slug, landing_subject_slug: landing_subject.slug }
        expect(response).to be_successful
      end
    end

    context 'with a bad solicitation uuid' do
      it do
        get :new, params: { uuid: 'bad-solicitation-uuid', landing_slug: landing.slug, landing_subject_slug: landing_subject.slug }
        expect(response).to redirect_to root_path
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end

  describe 'POST #create' do
    let(:landing) { create(:landing) }
    let(:landing_subject) { create(:landing_subject) }
    let(:request) do
    post :create,
         params: {
           landing_slug: landing.slug, landing_subject_slug: landing_subject.slug,
               solicitation: { full_name: full_name, email: email, phone_number: phone_number, landing_id: landing.id, landing_subject_id: landing_subject.id }
         }
  end

    context 'with good params' do
      let(:full_name) { 'Louise Michel' }
      let(:email) { 'louise@michel.org' }
      let(:phone_number) { '0606060606' }

      it 'creates a solicitation' do
        request
        solicitation = Solicitation.last
        expect(solicitation.full_name).to eq('Louise Michel')
        expect(solicitation.status).to eq('step_company')
      end
    end
  end

  describe 'PATCH #update_step_company' do
    let(:solicitation) { create(:solicitation, full_name: "L Michel", email: 'l@michel.org', phone_number: 'xx', status: 'step_company', siret: nil) }
    let(:request) { patch :update_step_company, params: { uuid: solicitation.uuid, solicitation: { siret: siret } } }

    context 'with blank siret' do
      let(:siret) { "       " }

      it "invalidates solicitation" do
        request
        expect(solicitation.siret).to be_nil
        expect(solicitation.reload.status).to eq('step_company')
      end
    end

    context 'with incorrect siret' do
      let(:siret) { "123 456 789 00011" }

      it "invalidates solicitation" do
        request
        expect(solicitation.siret).to be_nil
        expect(solicitation.reload.status).to eq('step_company')
      end
    end

    context 'with correct siret' do
      let(:siret) { "41816609600069" }

      it "updates solicitation" do
        request
        expect(solicitation.reload.siret).to eq("41816609600069")
        expect(solicitation.status).to eq('step_description')
      end
    end
  end

  describe 'prevent_completed_solicitation_modification' do
    let(:solicitation) { create :solicitation, status: 'in_progress' }

    context 'update_contact' do
      it 'redirects to homepage' do
        patch :update_step_contact, params: { uuid: solicitation.uuid, solicitation: { full_name: 'Modified !' } }
        expect(response).to redirect_to(root_path)
        expect(solicitation.reload.full_name).not_to eq('Modified !')
      end
    end

    context 'update_company' do
      it 'redirects to homepage' do
        patch :update_step_company, params: { uuid: solicitation.uuid, solicitation: { siret: '48475292800057' } }
        expect(response).to redirect_to(root_path)
        expect(solicitation.reload.siret).not_to eq('48475292800057')
      end
    end

    context 'update_description' do
      it 'redirects to homepage' do
        patch :update_step_company, params: { uuid: solicitation.uuid, solicitation: { description: 'Ah AH modifié!' } }
        expect(response).to redirect_to(root_path)
        expect(solicitation.reload.description).not_to eq('Ah AH modifié!')
      end
    end
  end

  describe 'GET #redirect_to_solicitation_step' do
    subject(:request) { get :redirect_to_solicitation_step, params: { uuid: solicitation.uuid, relaunch: 'relance-sollicitation' } }

    let!(:solicitation) { create :solicitation, full_name: "JJ Goldman", email: 'test@example.com', phone_number: 'xx', completed_at: nil, status: status, siret: siret }

    context 'step_company solicitation' do
      let(:status) { :step_company }
      let(:siret) { nil }

      it 'redirects properly' do
        expect(request).to redirect_to(step_company_search_solicitation_path(solicitation.uuid, anchor: 'section-breadcrumbs'))
      end

      it 'returns http success' do
        expect(response).to be_successful
      end
    end

    context 'step_description solicitation' do
      let(:status) { :step_description }
      let(:siret) { '41816609600069' }

      it 'redirects properly' do
        expect(request).to redirect_to(step_description_solicitation_path(solicitation.uuid, anchor: 'section-breadcrumbs'))
      end

      it 'returns http success' do
        expect(response).to be_successful
      end
    end

    context 'bad_quality solicitation' do
      let!(:solicitation) { create :solicitation, full_name: "JJ Goldman", email: 'test@example.com', phone_number: 'xx', status: 'canceled', siret: '41816609600069', description: 'Decription insuffisante' }

      it 'redirects properly' do
        expect(request).to redirect_to(step_description_solicitation_path(solicitation.uuid, anchor: 'section-breadcrumbs'))
      end

      it 'returns http success' do
        expect(response).to be_successful
      end
    end
  end
end
