# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedController do
  describe '#sanitize_params' do
    subject { described_class.new.send(:sanitize_params, params) }

    let(:params) { { "landing" => "1", "description" => "<a href=\"https://<IP_HACKER>/authentification.html\"><img src=\"https://undomaine.io/encarts/blanc-400.png\" alt=\"Conseillers-entreprises.service-public.fr ; TPE et PME : accédez gratuitement à tous les accompagnements publics. Déposez votre demande, le bon conseiller vous appelle.\" width=\"200\"></a>", "code_region" => "", "full_name" => "Quelqu’un", "phone_number" => "0606060606", "email" => "kingju@wanadoo.fr", "siret" => "21870030000013", "landing_subject" => "2" } }
    let(:expected_params) { { "landing" => "1", "description" => "<a><img alt=\"Conseillers-entreprises.service-public.fr ; TPE et PME : accédez gratuitement à tous les accompagnements publics. Déposez votre demande, le bon conseiller vous appelle.\"></a>", "code_region" => "", "full_name" => "Quelqu’un", "phone_number" => "0606060606", "email" => "kingju@wanadoo.fr", "siret" => "21870030000013", "landing_subject" => "2" } }

    it do
      is_expected.to eq expected_params
    end
  end
end
