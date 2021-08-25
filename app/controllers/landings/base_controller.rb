class Landings::BaseController < PagesController
  include IframePrefix

  before_action :retrieve_landing, except: [:home]

  private

  def retrieve_landing
    landing_slug = params.permit(:landing_slug)[:landing_slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{landing_slug}", expires_in: 1.minute) do
      Landing.find_by(slug: landing_slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing.nil?
  end

  def save_query_params
    saved_params = session[:solicitation_form_info] || {}
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS)
    saved_params.merge!(query_params)
    session[:solicitation_form_info] = saved_params if saved_params.present?
  end

  def view_params
    params.permit(:slug, *Solicitation::FORM_INFO_KEYS)
  end
end
