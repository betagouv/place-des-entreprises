module Stats
  class TeamController < BaseController
    before_action :authorize_team
    before_action :init_filters, except: %i[search_antennes]
    before_action :set_stats_params, only: %i[public needs matches]

    def index
      redirect_to action: :public
    end

    def public
      @charts_names = %w[
        solicitations_completed solicitations_diagnoses needs_quo needs_exchange_with_expert
        needs_done solicitations_taking_care_time needs_themes companies_by_employees companies_by_naf_code
      ]
      render :index
    end

    def needs
      @charts_names = %w[
        solicitations_transmitted_less_than_72h needs_quo needs_done needs_done_no_help
        needs_done_not_reachable needs_not_for_me needs_abandoned
      ]
      render :index
    end

    def matches
      @charts_names = %w[
        needs_transmitted matches_positioning matches_taking_care matches_done
        matches_done_no_help matches_done_not_reachable matches_not_for_me matches_not_positioning
      ]
      render :index
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      data = Rails.cache.fetch(['team-public-stats', name, session[:team_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:team_stats_params])
      end
      render_partial(data, name)
    end

    def institution_filters
      institution = Institution.find(params.permit(:institution_id)[:institution_id])
      response = {
        antennes: institution.antennes.not_deleted.order(:name),
        subjects: institution.subjects.not_archived.order(:label)
      }
      render json: response.as_json
    end

    private

    def authorize_team
      authorize Stats::All, :team?
    end

    def init_filters
      @iframes = Landing.iframe.not_archived.order(:slug)
      @institution_antennes = params[:institution].present? ?
                                Institution.find(params[:institution]).antennes.not_deleted : []
    end

    def render_partial(data, name)
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    def set_stats_params
      @stats_params = stats_params
      session[:team_stats_params] = @stats_params
    end
  end
end
