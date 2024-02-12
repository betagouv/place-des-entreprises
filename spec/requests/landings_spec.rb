require "rails_helper"

RSpec.describe "Landings" do
  describe "redirections" do
    context "locales landings" do
      context "home landing" do
        let!(:home_landing) { create :landing, slug: 'accueil' }
        let(:landing_theme) { create :landing_theme, slug: "recrutement-formation" }

        before do
          home_landing.landing_themes << landing_theme
        end

        context "with pk params" do
          it 'redirects with pk params' do
            get "/aide-entreprises/recrutement-formation/?pk_campaign=FOO&pk_kwd=BAR"
            expect(response).to redirect_to("/aide-entreprise/accueil/theme/recrutement-formation?pk_campaign=FOO&pk_kwd=BAR")
          end
        end

        context "with mtm params" do
          it 'redirects with pk params' do
            get "/aide-entreprises/recrutement-formation/?mtm_campaign=FOO&mtm_kwd=BAR"
            expect(response).to redirect_to("/aide-entreprise/accueil/theme/recrutement-formation?mtm_campaign=FOO&mtm_kwd=BAR")
          end
        end

        context "with subject page" do
          let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, slug: "bilan-rse" }

          it 'redirects with pk params' do
            get "/aide-entreprises/recrutement-formation/demande/bilan_RSE"
            expect(response).to redirect_to("/aide-entreprise/accueil/demande/bilan-rse")
          end
        end
      end

      context "other landing" do
        let!(:landing) { create :landing, slug: 'relance' }
        let(:landing_theme) { create :landing_theme, slug: "les-mesures-de-soutien-economique" }
        let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, slug: "demarche-ecologie" }

        before do
          landing.landing_themes << landing_theme
        end

        it 'redirects correctly' do
          get "/aide-entreprises/relance/demande/demarche_ecologie"
          expect(response).to redirect_to("/aide-entreprise/relance/demande/demarche-ecologie")
        end
      end
    end

    context "iframes" do
      context "360 iframes" do
        context "without pk" do
          let!(:landing) { create :landing, slug: 'zetwal' }

          it 'redirects correctly' do
            get "/e?institution=collectivite_de_martinique"
            expect(response).to redirect_to("/aide-entreprise/zetwal?institution=collectivite_de_martinique")
          end
        end

        context "with pk" do
          let!(:landing) { create :landing, slug: 'entreprises-haut-de-france' }

          it 'redirects correctly' do
            get "/e?institution=conseil_regional_hauts_de_france&pk_campaign=FOO&pk_kwd=BAR"
            expect(response).to redirect_to("/aide-entreprise/entreprises-haut-de-france?institution=conseil_regional_hauts_de_france&pk_campaign=FOO&pk_kwd=BAR")
          end
        end

        context "with mtm" do
          let!(:landing) { create :landing, slug: 'entreprises-haut-de-france' }

          it 'redirects correctly' do
            get "/e?institution=conseil_regional_hauts_de_france&mtm_campaign=FOO&mtm_kwd=BAR"
            expect(response).to redirect_to("/aide-entreprise/entreprises-haut-de-france?institution=conseil_regional_hauts_de_france&mtm_campaign=FOO&mtm_kwd=BAR")
          end
        end
      end

      context "other iframes" do
        context "with groupnames" do
          let!(:landing) { create :landing, slug: 'relance-hautsdefrance' }

          it 'redirects correctly' do
            get "/e/aide-entreprises/relance-hautsdefrance"
            expect(response).to redirect_to("/aide-entreprise/relance-hautsdefrance")
          end
        end

        context "to specific theme" do
          let!(:landing) { create :landing, slug: 'france-transition-ecologique' }

          it 'redirects correctly' do
            get "/e/aide-entreprises/france-transition-ecologique"
            expect(response).to redirect_to("/aide-entreprise/france-transition-ecologique")
          end
        end
      end
    end

    context "bascule" do
      let!(:home_landing) { create :landing, slug: 'accueil' }
      let(:landing_theme) { create :landing_theme, slug: "recrutement-formation" }

      before do
        home_landing.landing_themes << landing_theme
      end

      context 'root_url' do
        xit 'redirects to new url' do
          get "https://place-des-entreprises.beta.gouv.fr"
          expect(response).to redirect_to("https://conseillers-entreprises.service-public.fr")
        end
      end

      context "with pk params" do
        xit 'redirects with pk params' do
          get "/aide-entreprise/accueil/theme/recrutement-formation"
          expect(response).to redirect_to("https://conseillers-entreprises.service-public.fr/aide-entreprise/accueil/theme/recrutement-formation?pk_campaign=FOO&pk_kwd=BAR")
        end
      end

      context 'landing_url' do
        xit 'redirects to new url' do
          get "https://place-des-entreprises.beta.gouv.fr/aide-entreprise/accueil/theme/recrutement-formation"
          expect(response).to redirect_to("https://conseillers-entreprises.service-public.fr/aide-entreprise/accueil/theme/recrutement-formation")
        end
      end
    end
  end
end
