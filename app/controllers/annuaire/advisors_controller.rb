module  Annuaire
  class AdvisorsController < BaseController
    def index
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil

      @advisors = (@antenne || @institution).advisors
        .not_deleted
        .relevant_for_skills
        .joins(:antenne)
        .order('antennes.name', 'team_name', 'users.full_name')
        .preload(:antenne, relevant_expert: [:users, :antenne, :experts_subjects])

      institutions_subjects = @institution.institutions_subjects
        .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)

      @grouped_subjects = institutions_subjects
        .group_by(&:theme).transform_values{ |is| is.group_by(&:subject) }

      respond_to do |format|
        format.html
        format.csv do
          result = @advisors.export_csv(include_expert_team: true, institutions_subjects: institutions_subjects)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
      end
    end

    def import; end

    def import_create
      @result = User.import_csv(params.require(:file), institution: @institution)
      if @result.success?
        flash[:table_highlighted_ids] = @result.objects.map(&:id)
        redirect_to action: :index
      else
        render :import
      end
    end
  end
end
