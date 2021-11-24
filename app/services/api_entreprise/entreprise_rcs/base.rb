# frozen_string_literal: true

module ApiEntreprise::EntrepriseRcs
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    # Retourne hash vide en cas d'erreur
    def handle_error(http_request)
      return { "rcs" => { "error" => http_request.error_message } }
    end
  end

  class Request < ApiEntreprise::Request
    def error_message
      @error&.message || @data['error'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def url_key
      @url_key ||= 'extraits_rcs_infogreffe/'
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      { "rcs" => @http_request.data }
    end
  end
end