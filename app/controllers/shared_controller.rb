# frozen_string_literal: true

class SharedController < ActionController::Base
  include Pundit::Authorization
  NOT_FOUND_ERROR_CLASSES = [
    ActionController::RoutingError,
    ActionController::UrlGenerationError,
    ActionController::UnknownFormat,
    ActiveRecord::RecordNotFound,
    ActionView::MissingTemplate,
    Pundit::NotAuthorizedError
  ].freeze

  protect_from_forgery with: :exception
  rescue_from Exception, with: :render_error

  before_action :set_sentry_context, :http_authentication

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  include IframePrefix::InIframe # Note: This could be included in PagesController, there's currently no need for in the ApplicationController.

  private

  def sanitize_params(params)
    params.each do |key, value|
      next if value.class != String
      params[key] = ActionController::Base.helpers.sanitize(value, tags: %w[a p img], attributes: %w[alt])
    end
    params
  end

  def render_error(exception)
    raise exception if (Rails.env.development? || Rails.env.test?) && !ENV['TEST_ERROR_RENDERING'].to_b
    if NOT_FOUND_ERROR_CLASSES.include? exception.class
      @user = current_user
      respond_with_status(404)
    else
      Sentry.capture_exception(exception)
      respond_with_status(500)
    end
  end

  def set_sentry_context
    Sentry.configure_scope do |scope|
      scope.set_user(id: current_user&.id)
      scope.set_extras(
        params: params.to_unsafe_h,
        url: request.url
      )
    end
  end

  def respond_with_status(status)
    render "shared/errors/#{status}", status: status, layout: 'pages'
  end

  def http_authentication
    if Rails.env.production? && ENV['SP_AUTHENTICATION_ACTIVATED'].to_b
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['SP_LOGIN'] && password == ENV['SP_PASSWORD']
      end
    end
  end

  def fetch_themes
    @footer_landing = Landing.accueil
    @footer_landing_themes = Rails.cache.fetch('footer_landing_themes', expires_in: 1.hour) do
      @footer_landing.landing_themes.not_archived.order(:position)
    end
  end
end
