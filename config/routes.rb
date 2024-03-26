Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Rswag::Ui::Engine => '/documentation-api'
  mount Rswag::Api::Engine => '/documentation-api'
  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end
  # ActiveAdmin
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad

  # Impersonate
  mount UserImpersonate::Engine, at: '/impersonate', as: 'impersonate_engine'

  # LetterOpener
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # Split A/B Testing
  match "/split" => Split::Dashboard, anchor: false, via: [:get, :post, :delete], constraints: -> (request) do
    request.env['warden'].authenticated? # are we authenticated?
    request.env['warden'].authenticate! # authenticate if not already
    request.env['warden'].user.is_admin?
  end

  # API ==================================================

  namespace :api do
    namespace :v1 do
      resources :landings, controller: "landings/landings", only: [:index, :show] do
        get :search, on: :collection
        resources :landing_themes, controller: "landings/landing_themes", only: [:index, :show]
        resources :landing_subjects, controller: "landings/landing_subjects", only: [:index, :show] do
          get :search, on: :collection
        end
      end
      resources :solicitations, only: [:create]
    end
  end

  # Partie conseiller ================================================

  # Devise
  devise_for :users,
             path: 'mon_compte',
             controllers: {
               registrations: 'users/registrations',
               invitations: 'users/invitations'
             },
             skip: [:registrations]

  devise_scope :user do
    resource :user, only: %i[show update], path: 'mon_compte', controller: 'users/registrations' do
      get :edit, path: 'informations'
      get :password, path: 'mot_de_passe'
      put :update_password
      get :antenne
    end
  end

  scope 'mon_compte', as: '' do
    resources :experts, only: %i[index edit update], path: 'referents' do
      member do
        get :subjects, path: 'domaines'
      end
    end
  end

  namespace 'conseiller' do
    resources :solicitations, only: %i[index show], path: 'sollicitations' do
      member do
        post :update_status
        post :update_badges
        post :prepare_diagnosis
      end
      collection do
        get :processed, path: 'mises-en-relation'
        get :canceled, path: 'abandonnees'
      end
      collection do # Nice pagination paths instead of the ?page= parameter (for kaminari)
        get 'page/:page', action: :index
        get 'mises-en-relation/page/:page', action: :processed
        get 'abandonnees/page/:page', action: :canceled
      end
    end
    resources :csv_exports, path: 'exports-csv', only: [:index] do
      member do
        get :download
      end
    end
    controller :sitemap do
      get :sitemap
    end
    resources :experts, only: %i[index]
    resources :diagnoses, only: %i[new show create], path: 'analyses' do
      member do
        controller 'diagnoses/steps' do
          get :needs, path: 'besoins'
          patch :update_needs
          get :contact, path: 'contact'
          patch :update_contact
          get :matches, path: 'selection'
          patch :update_matches
          post :add_match
        end
      end
    end
    resources :veille, only: %i[index], path: 'veille' do
      collection do
        get :quo_matches, path: 'mer-en-attente'
        get :starred_needs, path: 'besoins-suivis'
      end
    end
  end

  namespace 'manager' do
    controller :stats do
      get :index, path: 'stats', as: :stats
      get :load_data, as: :load_data
      get :load_filter_options
    end
    resources :needs, only: :index, path: 'besoins-des-antennes' do
      collection do
        get :quo_active, path: 'boite-de-reception'
        get :taking_care, path: 'prises-en-charge'
        get :done, path: 'cloturees'
        get :not_for_me, path: 'refusees'
        get :expired, path: 'expirees'
      end
    end
  end

  resources :reports, path: 'export-des-donnees', only: :index do
    member do
      get :download
    end
  end

  resources :companies, only: %i[show], path: 'entreprises' do
    member do
      get :needs, path: 'besoins'
    end
    collection do
      get :search, path: 'search'
      get :show_with_siret, path: 'siret/:siret'
    end
  end

  resources :contacts, only: [] do
    member do
      get :needs_historic, path: 'historique-des-besoins'
    end
  end

  resources :needs, only: %i[index show], path: 'besoins' do
    collection do
      get :quo_active, path: 'boite_de_reception'
      get :taking_care, path: 'prises_en_charge'
      get :done, path: 'cloturees'
      get :not_for_me, path: 'refusees'
      get :expired, path: 'expirees'
    end
    member do
      post :add_match
    end
  end

  resources :matches, only: %i[update]
  resources :feedbacks, only: %i[create destroy]
  resources :reminders_actions, only: %i[create]

  namespace :reminders, path: 'relances' do
    get '/', to: redirect('/relances/besoins')

    resources :experts, only: %i[index show], path: 'experts' do
      collection do
        get :inputs, path: 'arrivees'
        get :outputs, path: 'departs'
        get :expired_needs, path: 'expires'
        get :many_pending_needs, path: 'superieur-a-cinq-besoins'
        get :medium_pending_needs, path: 'entre-deux-et-cinq-besoins'
        get :one_pending_need, path: 'un-besoin-recent'
      end
      member do
        get :quo_active, path: 'boite_de_reception'
        get :taking_care, path: 'prises_en_charge'
        get :done, path: 'cloturees'
        get :not_for_me, path: 'refusees'
        get :expired, path: 'expirees'
        post :send_reminder_email
        post :send_re_engagement_email
      end
    end
    resources :needs, path: 'besoins', only: %i[index] do
      member do
        post :update_badges
        post :send_failure_email
        post :send_last_chance_email
      end
      collection do
        get :poke, path: 'sans-reponse'
        get :last_chance, path: 'risque-abandon'
        get :refused, path: 'refuses'
        get :expert, path: 'risque-abandon-expert'
      end
    end
    resources :reminders_registers, only: :update
  end

  scope :annuaire, module: :annuaire do
    get '/', to: redirect('/annuaire/institutions')

    concern :importable do
      get :import, on: :collection
      post :import, action: :import_create, on: :collection
    end

    controller :search do
      post :search, as: 'annuaire_search'
      get :autocomplete, as: 'annuaire_autocomplete'
    end

    resources :institutions, param: :slug, only: %i[index show] do
      resources :subjects, path: 'domaines', only: :index
      resources :users, path: 'conseillers', only: :index, concerns: [:importable] do
        collection do
          post :send_invitations
        end
      end
      resources :antennes, only: :index, concerns: [:importable] do
        resources :users, path: 'conseillers', only: :index
      end
    end
  end

  resources :badges, except: :show, path: 'tags' do
    collection do
      get :solicitations, path: 'sollicitations'
      get :needs, path: 'besoins'
    end
  end

  namespace :emails do
    controller :solicitations do
      post :send_generic_email, as: :solicitation_generic
    end
  end

  # Partie publique ===================================================

  root controller: "landings/landings", action: :home
  resources :landings, param: :landing_slug, controller: "landings/landings", only: [:show], path: 'aide-entreprise' do
    # Utilisation de member pour que ce soit :landing_slug qui soit utilisé sur toutes les routes
    member do
      resources :landing_themes, param: :slug, controller: "landings/landing_themes", path: 'theme', only: %i[show]
    end
  end

  resources :solicitations, only: %i[], param: :uuid, path: 'votre-demande', path_names: { new: 'nouvelle-demande' } do
    member do
      get :step_contact, path: 'contact'
      patch :update_step_contact
      get :search_company, path: 'recherche-entreprise'
      get :search_facility, path: 'recherche-etablissement'
      get :step_company, path: 'etablissement'
      get :step_company_search, path: 'rechercher-mon-etablissement'
      patch :update_step_company
      get :step_description, path: 'description'
      patch :update_step_description
      get :form_complete, path: 'merci'
      get :redirect_to_solicitation_step, path: 'reprendre'
    end
  end
  # New et create custom pour concerver des url avec les landings et faciliter gestion des iframes
  get 'aide-entreprise/:landing_slug/demande/:landing_subject_slug', to: 'solicitations#new', as: :new_solicitation
  post 'aide-entreprise/:landing_slug/demande/:landing_subject_slug', to: 'solicitations#create', as: :solicitations

  resource :newsletters, only: %i[] do
    post :create
    get :new, path: 'abonnement', as: :new
    get :index, to: redirect('/newsletters/abonnement')
    get :unsubscribe, path: 'desinscription'
  end

  controller :about do
    get :comment_ca_marche
    get :cgu
    get :equipe
    get :mentions_d_information
    get :mentions_legales
    get :accessibilite
  end

  scope :stats, module: :stats do
    resources :public, only: :index, path: '/' do
      collection do
        get :load_data
      end
    end
    resources :team, only: :index, path: 'equipe' do
      collection do
        get :public, path: 'public'
        get :needs, path: 'besoins'
        get :matches, path: 'mises-en-relation'
        get :load_data
        get :load_filter_options
      end
    end
  end

  controller :user_pages do
    get :tutoriels
  end

  controller :sitemap do
    get :sitemap
  end

  resource :company_satisfactions, only: %i[new create], path: 'satisfaction' do
    collection do
      get :thank_you, path: 'merci'
    end
  end

  # Redirections =====================================

  get 'profile' => 'users#show'

  ## Redirection for compatibility
  ### Landings - Accueil
  ["recrutement-formation", "financement-projets", "entreprise-en-difficulte", "droit-du-travail", "developpement-commercial", "internet-web", "environnement-transition-ecologique", "sante-securite-travail", "cession-reprise"].each do |theme|
    get "/aide-entreprises/#{theme}", to: redirect(path: "aide-entreprise/accueil/theme/#{theme}")
    get "/aide-entreprises/#{theme}/demande/:option_slug", to: redirect { |path_params, req| "/aide-entreprise/accueil/demande/#{path_params[:option_slug].dasherize.parameterize}" }
  end
  ### Landings - autres locales
  ["contactez-nous", "relance"].each do |landing|
    get "/aide-entreprises/#{landing}", to: redirect(path: "aide-entreprise/#{landing}")
    get "/aide-entreprises/#{landing}/demande/:option_slug", to: redirect { |path_params, req| "/aide-entreprise/#{landing}/demande/#{path_params[:option_slug].dasherize.parameterize}" }
  end
  ### Landings - Iframe
  ["relance-hautsdefrance", "brexit", "france-transition-ecologique"].each do |landing|
    get "/e/aide-entreprises/#{landing}", to: redirect(path: "aide-entreprise/#{landing}")
  end
  get '/e', to: redirect { |path_params, req|
    query_params = Rack::Utils.parse_query(req.query_string)
    hash = {
      'conseil_regional_hauts_de_france' => 'entreprises-haut-de-france',
      'collectivite_de_martinique' => 'zetwal'
    }
    landing_slug = hash[query_params['institution']]
    ["/aide-entreprise/#{landing_slug}", req.query_string.presence].compact.join('?')
  }

  ## Handle 404 properly
  get '*unmatched_route', :to => 'shared#not_found'
end
