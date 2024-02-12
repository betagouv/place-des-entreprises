# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API Conseillers-entreprises.service-public.fr V1',
        description: "## Bienvenue sur la documentation de l’API de Conseillers-entreprises.service-public.fr
        \nCette API permet à une organisation de proposer un formulaire de dépôt de besoin d'entreprise connecté à Conseillers-entreprises.service-public.fr sur son propre site internet.
        \nConcrètement, cette API permet de :
        \n- récupérer la liste des pages d'atterrisage, thèmes et sujets autorisés pour l'organisation concernée,
        \n- d'envoyer à Conseillers-entreprises.service-public.fr un besoin
        \n### Limite des requêtes
        \nLe serveur accepte un maximum de 300 appels  par 5 minutes.
        ",
        version: '1.0.0',
        contact: {
          name: 'Équipe technique',
          email: 'tech@conseillers-entreprises.service-public.fr'
        }
      },
      tags: [
        { name: 'Page d’atterrissage' },
        { name: 'Thèmes' },
        { name: 'Sujets' },
      ],
      paths: {},
      servers: [
        {
          url: 'https://conseillers-entreprises.service-public.fr',
        },
        {
          url: 'https://reso-staging.osc-fr1.scalingo.io',
        },
      ],
      components: {
        schemas: {
          landing: {
            type: :object,
            properties: {
              id: { type: :integer },
              iframe_category: { type: :string },
              title: { type: :string },
              slug: { type: :string },
              partner_url: { type: :string },
              landing_themes: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/landing_theme"
                }
              }
            },
            required: [ 'id', 'title', 'partner_url' ]
          },
          landing_theme: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              slug: { type: :string },
              description: { type: :string },
              landing_subjects: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/landing_subject"
                }
              }
            },
            required: [ 'id', 'title' ]
          },
          landing_subject: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              slug: { type: :string },
              description: { type: :string },
              description_explanation: { type: :string },
              requires_siret: { type: :boolean },
              requires_location: { type: :boolean },
              landing_subjects: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/landing_subject"
                }
              }
            },
            required: [ 'id', 'title', 'slug' ]
          },
          new_solicitation: {
            type: :object,
            properties: {
              solicitation: {
                type: :object,
                properties: {
                  landing_id: { type: :integer },
                  landing_subject_id: { type: :integer },
                  description: { type: :string },
                  full_name: { type: :string },
                  email: { type: :string },
                  phone_number: { type: :string },
                  siret: { type: :string },
                  location: { type: :string },
                  api_calling_url: { type: :string },
                  origin_url: { type: :string },
                  questions_additionnelles: {
                    type: :array,
                    items: {
                      '$ref': "#/components/schemas/question_additionnelle_short"
                    }
                  },
                },
                required: [ 'landing_id', 'landing_subject_id', 'description', 'full_name', 'email', 'api_calling_url' ]
              }
            },
            required: [ 'solicitation' ]
          },
          solicitation_created: {
            type: :object,
            properties: {
              uuid: { type: :string },
              landing_subject: { type: :string },
              full_name: { type: :string },
              email: { type: :string },
              phone_number: { type: :string },
              siret: { type: :string },
              location: { type: :string },
              description: { type: :string },
              code_region: { type: :integer },
              status: { type: :string },
              questions_additionnelles: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/question_additionnelle_long"
                }
              },
              api_calling_url: { type: :string },
              origin_url: { type: :string }
            },
            required: [ 'landing_id', 'landing_subject_id', 'description', 'full_name', 'email', 'api_calling_url' ]
          },
          question_additionnelle_short: {
            type: :object,
            properties: {
              question_id: { type: :integer },
              answer: { type: :boolean }
            }
          },
          question_additionnelle_long: {
            type: :object,
            properties: {
              question_id: { type: :integer },
              question_label: { type: :string },
              answer: { type: :boolean }
            }
          },
          error: {
            type: :object,
            properties: {
              source: { type: :string },
              message: { type: :string }
            }
          }
        },
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            description: "Le jeton vous est fourni après étude de votre demande par Conseillers-entreprises.service-public.fr.
            \nIl doit être placé dans le header '`Authorization: Bearer VOTRE_JETON`'.
            \nSa validité est de 18 mois, renouvelable sur demande."
          }
        }
      },
      security: [
        {
          bearer_auth: []
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
