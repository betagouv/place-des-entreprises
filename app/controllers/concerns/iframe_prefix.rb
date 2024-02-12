# frozen_string_literal: true

module IframePrefix
  extend ActiveSupport::Concern
  included do
    prepend_before_action :retrieve_main_objects
    skip_forgery_protection if: -> { in_iframe? }
    after_action :allow_in_iframe, if: -> { in_iframe? }
    helper_method :query_params
    skip_before_action :fetch_themes, if: -> { in_iframe? }
  end

  # Pour s'assurer que in_iframe? fonctionne en toutes circonstances
  # Besoin d'identifier @landing sur toutes les pages du process
  def retrieve_main_objects
    # Controller Landing & LandingTheme
    landing_slug = params[:landing_slug]
    if landing_slug.present?
      @landing = Landing.not_archived.find_by(slug: landing_slug)
      redirect_to root_path, status: :moved_permanently and return if @landing.nil?
    end
    landing_subject_slug = params[:landing_subject_slug]
    if landing_subject_slug.present?
      @landing_subject = LandingSubject.not_archived.find_by(slug: landing_subject_slug)
      redirect_to root_path, status: :moved_permanently and return if @landing_subject.nil?
    end
    # Controller Solicitation#other_methods
    solicitation_uuid = params[:uuid]
    if solicitation_uuid.present?
      @solicitation ||= Solicitation.find_by(uuid: solicitation_uuid)
      redirect_to root_path, status: :moved_permanently and return if @solicitation.nil?
      @landing = @solicitation.landing
      @landing_subject = @solicitation.landing_subject
    end
  end

  def query_params
    saved_params = session[:solicitation_form_info] || {}
    # pas de session dans les iframe, on recupere les params dans l'url
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS + [:siret] + AdditionalSubjectQuestion.pluck(:key))
    # on supprime les params matomo anciens si doublon
    saved_params.except!(*Solicitation::MATOMO_KEYS.map(&:to_s)) if double_matomo_params(saved_params, query_params)
    saved_params.with_indifferent_access.merge!(query_params)
  end

  def double_matomo_params(session_params, url_params)
    (session_params.include?('pk_campaign') && url_params.include?('mtm_campaign')) ||
      (session_params.include?('mtm_campaign') && url_params.include?('pk_campaign'))
  end

  def view_params
    params.permit(:landing_slug, :slug, :siret, *Solicitation::FORM_INFO_KEYS, AdditionalSubjectQuestion.pluck(:key))
  end

  def allow_in_iframe
    # Note: ActionDispatch sets "X-Frame-Options" => "SAMEORIGIN" by default,
    # which prevents a page to be displayed in an iframe.
    response.headers.except! 'X-Frame-Options'
  end

  # Implementation Note:
  # We want in_iframe? to be available both in template (as a helper method) and in controllers.
  # The InIframe module is included in SharedController…
  module InIframe
    extend ActiveSupport::Concern
    included { helper_method :in_iframe?, :show_breadcrumbs? } # … and this makes the in_iframe? method available in all views.

    def in_iframe?
      @landing&.iframe?
    end

    def show_breadcrumbs?
      !in_iframe? || show_iframe_breadcrumbs?
    end

    def show_iframe_breadcrumbs?
      return true unless in_iframe?
      return false unless defined?(@landing)
      # Iframe formulaire
      return false if @landing.form_iframe?
      # Iframe liste de sujet : breadcrumbs que sur pages formulaire pour pouvoir revenir à la liste des sujets
      return false if @landing.subjects_iframe? && !defined?(@landing_subject)
      true
    end
  end
end
