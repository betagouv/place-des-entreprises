# frozen_string_literal: true

module ApiEntreprise::Entreprise
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiEntreprise::Request
    private

    # /v3/insee/sirene/unites_legales/diffusibles/{siren}
    def url_key
      @url_key ||= 'insee/sirene/unites_legales/diffusibles/'
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      data = @http_request.data['data']
      # utilisation de strings pour fournir un json correctement formaté
      formatted_data = {
        'entreprise' => data["entreprise"],
        'etablissement_siege' => data["etablissement_siege"],
        'errors' => data["errors"]
      }
      raise ApiEntreprise::ApiEntrepriseError, I18n.t('api_requests.default_error_message.etablissement') if missing_mandatory_data?(formatted_data)
      return formatted_data
    end

    # Impossible d'afficher la page sans ces données
    def missing_mandatory_data?(data)
      data['entreprise'].blank? || data['etablissement_siege'].blank?
    end
  end
end
