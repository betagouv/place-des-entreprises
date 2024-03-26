module Annuaire
  class BaseController < ApplicationController
    before_action :set_session_params
    before_action :retrieve_form_params, except: :search
    layout 'annuaire'

    def retrieve_institution
      @institution = Institution.find_by(slug: params[:institution_slug].presence || params[:institution])
      authorize @institution
    end

    def form_params
      %i[institution antenne name region theme]
        .reduce({}) { |h,key| h[key] = params[key]; h }
    end

    def retrieve_form_params
      params.merge(form_params)
    end

    def set_session_params
      form_params.each_key do |key|
        session["annuaire_#{key}"] = params[key] if params[key].present?
      end
      if params[:reset_query].present?
        form_params.each_key do |key|
          session.delete("annuaire_#{key}")
        end
      end
    end
  end
end
