# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

# Tests AVEC js =========================================
# TODO
describe 'New Solicitation', :js, :flaky do
  let(:pde_subject) { create :subject }
  let!(:landing) { create :landing, slug: 'accueil', title: 'Accueil' }
  let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
  let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, subject: pde_subject, title: "Super sujet", description: "Description LS", requires_siret: true }
  let(:siret) { '41816609600069' }
  let(:siren) { siret[0..8] }
  let(:solicitation) { Solicitation.last }

  describe 'create' do
    before do
      landing.landing_themes << landing_theme
    end

    context "with API calls" do
      before do
        authorize_insee_token
        stub_request(:get, api_url).to_return(
          body: file_fixture(fixture_file)
        )
      end

      # Features tests sont coûteux, je tests deux éléments indépendants dans un test
      context "from siret, with additional_subject_questions in url" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret.json' }
        let(:query) { siret }
        let(:other_siret) { '89448692700011' }
        let!(:additional_question_1) { create :additional_subject_question, subject: pde_subject, key: 'recrutement_poste_cadre' }
        let!(:additional_question_2) { create :additional_subject_question, subject: pde_subject, key: 'recrutement_en_apprentissage' }

        before do
          stub_request(:get, "https://recherche-entreprises.api.gouv.fr/search?q=zzzzzz")
            .to_return(status: 200, body: '{"results": []}', headers: {})

          stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{other_siret}")
            .to_return(status: 400, body: file_fixture('api_insee_siret_400.json'))
          stub_request(:get, "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{other_siret}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013")
            .to_return(status: 200, body:
              { "data" =>
                { "siret" => "89448692700011",
                  "adresse" =>
                  { "status_diffusion" => "diffusible",
                    "code_postal" => "35000",
                    "libelle_commune" => "RENNES",
                    "libelle_commune_etranger" => nil,
                    "distribution_speciale" => nil,
                    "code_commune" => "35238",
                    "code_cedex" => nil,
                    "libelle_cedex" => nil,
                    "code_pays_etranger" => nil,
                    "libelle_pays_etranger" => nil
                    }
                },
                "links" => {}, "meta" => {}
              }.to_json)
        end

        it do
          visit '/?recrutement_poste_cadre=true&recrutement_en_apprentissage=false'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'

          # Etape contact
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
          expect(solicitation.persisted?).to be true
          expect(solicitation.pk_campaign).to be_nil
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.full_name).to eq 'Hubertine Auclerc'
          expect(solicitation.status_step_company?).to be true

          # Retour étape contact
          click_on 'Précédent'
          expect(solicitation.reload.status_step_company?).to be true
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc Superstar'
          click_on 'Suivant'
          expect(solicitation.reload.status_step_company?).to be true
          expect(solicitation.full_name).to eq 'Hubertine Auclerc Superstar'

          # Etape entreprise
          fill_in 'Recherchez votre entreprise', with: "zzzzzz"
          click_on 'Suivant'
          expect(page).to have_link('Je ne trouve pas mon entreprise')
          click_on 'Je ne trouve pas mon entreprise'
          fill_in 'Votre numéro SIRET', with: other_siret
          click_on 'Suivant'
          expect(solicitation.reload.siret).to eq other_siret
          expect(solicitation.reload.code_region).to eq 53
          expect(solicitation.status_step_description?).to be true

          # Retour étape entreprise
          click_on 'Précédent'
          expect(solicitation.status_step_description?).to be true
          fill_in 'Recherchez votre entreprise', with: query
          option = find(".autocomplete__option", match: :first)
          expect(option).to have_content('Octo Technology')
          page.execute_script("document.querySelector('.autocomplete__option').click()")
          click_on 'Suivant'

          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true

          # Etape description
          fill_in I18n.t('solicitations.creation_form.description'), with: 'Ceci n\'est pas un test'
          # radio button sur 'Oui' pour recrutement_poste_cadre
          expect(page).to have_field('solicitation_institution_filters_attributes_0_filter_value_true', checked: true, visible: :hidden)
          expect(page).to have_field('solicitation_institution_filters_attributes_0_filter_value_false', checked: false, visible: :hidden)
          # radio button sur 'Non' pour recrutement_en_apprentissage
          expect(page).to have_field("solicitation_institution_filters_attributes_1_filter_value_true", checked: false, visible: :hidden)
          expect(page).to have_field("solicitation_institution_filters_attributes_1_filter_value_false", checked: true, visible: :hidden)
          click_on 'Envoyer ma demande'

          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
          expect(solicitation.completed_at).not_to be_nil
        end
      end

      context "with siret in url and modification" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret.json' }
        let(:query) { '41816609600069' }
        let(:token) { '1234' }

        before do
          ENV['API_ENTREPRISE_TOKEN'] = token
          authorize_insee_token
          stub_request(:get, api_url).to_return(
            body: file_fixture(fixture_file)
          )
          stub_request(:get, "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{query}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013").to_return(
            body: file_fixture('api_entreprise_etablissement.json')
          )
        end

        it do
          visit "/?siret=#{query}"
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
          expect(solicitation.siret).to eq query
          expect(page).to have_field('query', with: query)

          click_on 'Suivant'
          expect(solicitation.reload.siret).to eq query
          expect(page).to have_field(I18n.t('solicitations.creation_form.description'))

          click_on 'Précédent'
          expect(solicitation.reload.siret).to eq query

          fill_in 'Recherchez votre entreprise', with: siret
          click_on 'Suivant'
          expect(page).to have_content("Sélectionnez votre entreprise :")

          click_on "#{siret} - Octo Technology"
          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
        end
      end

      context "from siren" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siren:#{query}" }
        let(:fixture_file) { 'api_insee_sirets_by_siren_many.json' }
        let(:siret_api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{siret}" }
        let(:siret_fixture_file) { 'api_insee_siret.json' }

        let(:query) { siren }

        before do
          # a la selection d'une option, la valeur de l'input est remplacée par le siret, une rech automatique est lancee
          stub_request(:get, siret_api_url).to_return(
            body: file_fixture(siret_fixture_file)
          )
        end

        it do
          visit '/'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
          expect(solicitation.persisted?).to be true
          expect(solicitation.pk_campaign).to be_nil
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.status_step_company?).to be true

          fill_in 'Recherchez votre entreprise', with: query
          option = find(".autocomplete__option", match: :first)
          expect(option).to have_content('Octo Technology')
          page.execute_script("document.querySelector('.autocomplete__option').click()")
          click_on 'Suivant'

          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true
          fill_in I18n.t('solicitations.creation_form.description'), with: 'Ceci n\'est pas un test'
          click_on 'Envoyer ma demande'

          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
          expect(solicitation.reload.completed_at).not_to be_nil
        end
      end

      context "from fulltext" do
        let(:api_url) { "https://recherche-entreprises.api.gouv.fr/search?q=#{query}" }
        let(:fixture_file) { 'api_recherche_entreprises_search.json' }
        let(:query) { 'octo technology' }

        before do
          # additional api call
          stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siren:#{siren}").to_return(
            body: file_fixture('api_insee_sirets_by_siren_many.json')
          )
          stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{siret}").to_return(
            body: file_fixture('api_insee_siret.json')
          )
        end

        it do
          visit '/'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
          expect(solicitation.persisted?).to be true
          expect(solicitation.pk_campaign).to be_nil
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.status_step_company?).to be true

          fill_in 'Recherchez votre entreprise', with: query
          option = find(".autocomplete__option", match: :first)
          expect(option).to have_content('Octo Technology')
          page.execute_script("document.querySelector('.autocomplete__option').click()")
          click_on 'Suivant'
          expect(solicitation.reload.siret).to be_nil
          expect(solicitation.status_step_description?).to be false

          expect(page).to have_content("Sélectionnez l'établissement concerné :")
          click_on("#{siret} - Octo Technology", match: :first)
          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true
          fill_in I18n.t('solicitations.creation_form.description'), with: 'Ceci n\'est pas un test'
          click_on 'Envoyer ma demande'

          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
        end
      end

      context "manual siret" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret.json' }
        let(:query) { '41816609600069' }
        let(:entreprise_api_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{query}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }

        before do
          stub_request(:get, "https://recherche-entreprises.api.gouv.fr/search?q=toto")
            .to_return(status: 200, body: '{"results": []}', headers: {})
          ENV['API_ENTREPRISE_TOKEN'] = '1234'
          stub_request(:get, entreprise_api_url).to_return(
            body: file_fixture('api_entreprise_etablissement.json')
          )
        end

        it do
          visit '/'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
          expect(solicitation.persisted?).to be true

          fill_in 'Recherchez votre entreprise', with: 'toto'
          click_on 'Suivant'
          expect(page).to have_content('Sélectionnez votre entreprise :')

          click_on "Je ne trouve pas mon entreprise"
          fill_in 'Votre numéro SIRET', with: "n'importe quoi"
          click_on 'Suivant'
          expect(page).to have_content('SIRET doit être un numéro à 14 chiffres')
          expect(solicitation.reload.siret).to be_nil

          fill_in 'Votre numéro SIRET', with: "418 166 096 00069"
          click_on 'Suivant'
          expect(solicitation.reload.siret).to eq "41816609600069"
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true
          fill_in I18n.t('solicitations.creation_form.description'), with: 'Ceci n\'est pas un test'
          click_on 'Envoyer ma demande'

          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
        end
      end

      context "with api error" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret_400.json' }
        let(:query) { 'tata yoyo' }

        it do
          visit '/'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
          expect(solicitation.persisted?).to be true

          fill_in 'Recherchez votre entreprise', with: '40440440440400'
          click_on 'Suivant'
          expect(page).to have_no_content('Sélectionnez votre entreprise :')

          expect(page).to have_content("L’identifiant (siret ou siren) est invalide")
        end
      end
    end
  end
end
