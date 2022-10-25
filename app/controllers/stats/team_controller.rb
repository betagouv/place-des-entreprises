module Stats
  class TeamController < BaseController
    before_action :authorize_team

    def index
      redirect_to action: :public, params: stats_params
    end

    def public
      @stats = Stats::Public::All.new(stats_params)
      @charts_names = [
        :solicitations, :solicitations_in_deployed_regions, :solicitations_diagnoses,
        :exchange_with_expert, :taking_care, :themes, :companies_by_employees, :companies_by_naf_code
      ]
      render :index
    end

    def quality
      @stats = Stats::Quality::All.new(stats_params)
      @charts_names = [:needs_done, :needs_done_no_help, :needs_done_not_reachable, :needs_not_for_me, :needs_abandoned]
      render :index
    end

    def matches
      @stats = Stats::Matches::All.new(stats_params)
      @charts_names = [
        :transmitted_less_than_72h_stats, :positioning_rate, :taking_care_rate_stats, :done_rate_stats,
        :done_no_help_rate_stats, :done_not_reachable_rate_stats, :not_for_me_rate_stats, :not_positioning_rate
      ]
      render :index
    end

    def search_antennes
      institution = Institution.find(params.permit(:institution_id)[:institution_id])
      render json: institution.antennes.not_deleted.order(:name).as_json()
    end

    private

    def authorize_team
      authorize Stats::All, :team?
    end
  end
end
