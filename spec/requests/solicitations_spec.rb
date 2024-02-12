require "rails_helper"

RSpec.describe "Solicitations" do
  describe "with query params" do
    context "iframe landing" do
      let!(:landing) { create :landing, integration: :iframe, slug: 'iframe-01', partner_url: 'example.com' }
      let(:landing_theme) { create :landing_theme, slug: "recrutement-formation" }
      let(:landing_subject) { create :landing_subject, slug: "recruter" }

      before do
        landing.landing_themes << landing_theme
      end

      context "with origin query params" do
        it 'creates solicitation with origin data' do
          post "/aide-entreprise/iframe-01/demande/recruter?origin_title=Aide+aux+%C3%A9tudes+d%27am%C3%A9lioration+de+la+performance+%C3%A9nerg%C3%A9tique+ou+de+d%C3%A9carbonation+en+industrie&origin_url=toto.fr",
            params: { solicitation: {
              landing_subject_id: landing_subject.id,
              landing_id: landing.id,
              full_name: "Steve Mc Kouign",
              phone_number: 'xx',
              email: 'steve@mc-kouign.fr'
            } }
          solicitation = Solicitation.last
          expect(solicitation.form_info).to eq({ "origin_url" => "toto.fr", "origin_title" => "Aide aux études d'amélioration de la performance énergétique ou de décarbonation en industrie" })
        end
      end

      context "with fantasy query params" do
        it 'creates solicitation with no fantasy data' do
          post "/aide-entreprise/iframe-01/demande/recruter?fantasy_title=Aide+aux+%C3%A9tudes+de+licorne&fantasy_url=licorne.fr",
            params: { solicitation: {
              landing_subject_id: landing_subject.id,
              landing_id: landing.id,
              full_name: "Steve Mc Kouign",
              phone_number: 'xx',
              email: 'steve@mc-kouign.fr'
            } }
          solicitation = Solicitation.last
          expect(solicitation.form_info).to eq({})
        end
      end
    end

    context "classic landing" do
      let!(:landing) { create :landing, slug: 'classic-01' }
      let(:landing_theme) { create :landing_theme, slug: "recrutement-formation" }
      let(:landing_subject) { create :landing_subject, slug: "recruter" }

      before do
        create_home_landing
        landing.landing_themes << landing_theme
      end

      context "with origin query params" do
        it 'creates solicitation with origin data' do
          post "/aide-entreprise/classic-01/demande/recruter?origin_title=Aide+aux+%C3%A9tudes+d%27am%C3%A9lioration+de+la+performance+%C3%A9nerg%C3%A9tique+ou+de+d%C3%A9carbonation+en+industrie&origin_url=toto.fr",
            params: { solicitation: {
              landing_subject_id: landing_subject.id,
              landing_id: landing.id,
              full_name: "Steve Mc Kouign",
              phone_number: 'xx',
              email: 'steve@mc-kouign.fr'
            } }
          solicitation = Solicitation.last
          expect(solicitation.form_info).to eq({ "origin_url" => "toto.fr", "origin_title" => "Aide aux études d'amélioration de la performance énergétique ou de décarbonation en industrie" })
        end
      end
    end
  end
end
