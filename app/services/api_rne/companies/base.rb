# frozen_string_literal: true

module ApiRne::Companies
  class Base < ApiRne::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiRne::Request
    private

    def url_key
      @url_key ||= 'companies/'
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@siren_or_siret}"
    end
  end

  class Responder < ApiRne::Responder
    def format_data
      # pp @http_request.data
      content = @http_request.data.dig('formality','content')
      registres = content.dig('registreAnterieur')
      entite = content.dig('personneMorale') || content.dig('personnePhysique') || content.dig('exploitation')
      autresEtablissements = entite.dig("autresEtablissements") || []
      autresEtablissementsActivités = autresEtablissements.map do |etablissement|
        {
          "siret" => etablissement.dig('descriptionEtablissement', 'siret'),
          "activites" => etablissement.dig("activites")&.map do |activite|
            {
              "dateEffetFermeture" => etablissement.dig('descriptionEtablissement', 'dateEffetFermeture'),
              "categoryCode" => activite['categoryCode'],
              "formeExercice" => activite['formeExercice'],
            }
          end
        }
      end

      {
        "forme_exercice" => content.dig('formeExerciceActivitePrincipale'),
        "etablissementPrincipal" => {
          "siret" => entite.dig('etablissementPrincipal', 'descriptionEtablissement', 'siret'),
          "activites" => entite.dig('etablissementPrincipal', 'activites')&.map do |activite|
            {
              "categoryCode" => activite['categoryCode'],
              "formeExercice" => activite['formeExercice']
            }
          end
        },
        "autresEtablissements" => autresEtablissementsActivités,
        "rne_rcs" => registres.present? ? registres['rncs'] : nil,
        "rne_rnm" => registres.present? ? registres['rnm'] : nil,
      }
    end
  end
end
