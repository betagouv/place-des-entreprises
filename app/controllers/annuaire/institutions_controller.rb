module  Annuaire
  class InstitutionsController < BaseController
    before_action :retrieve_institutions, only: :index

    def index
      authorize Institution, :index?
      get_antennes_count
      get_users_count
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    private

    def retrieve_institutions
      @institutions = Institution.includes(:logo, :themes).not_deleted.order(:slug)
      @institutions = @institutions.in_region(params[:region_id]) if params[:region_id].present?
    end

    def get_antennes_count
      antennes_count = if params[:region_id].present?
        Antenne.select('COUNT(DISTINCT antennes.id) AS antennes_count, antennes.institution_id AS institution_id')
          .not_deleted
          .left_joins(:regions, :experts)
          .where(territories: { id: params[:region_id] })
          .or(Antenne.where(deleted_at: nil, experts: { is_global_zone: true }))
          .group('antennes.institution_id')
      else
        Antenne.select('COUNT(DISTINCT antennes.id) AS antennes_count, antennes.institution_id AS institution_id')
          .not_deleted
          .group('antennes.institution_id')
      end

      @antennes_count = antennes_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.antennes_count
      end
    end

    def get_users_count
      users_count = if params[:region_id].present?
        User.select('COUNT(DISTINCT users.id) AS users_count, antennes.institution_id AS institution_id')
          .not_deleted
          .left_joins(:antenne_regions, :experts)
          .where(antennes: { territories: { id: params[:region_id] } })
          .or(Antenne.where(users: { deleted_at: nil }, experts: { is_global_zone: true }))
          .group('antennes.institution_id')
      else
        User.select('COUNT(DISTINCT users.id) AS users_count, antennes.institution_id AS institution_id')
          .joins(:antenne)
          .not_deleted
          .where(antennes: { deleted_at: nil })
          .group('antennes.institution_id')
      end

      @users_count = users_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.users_count
      end
    end
  end
end
