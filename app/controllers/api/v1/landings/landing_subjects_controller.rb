class Api::V1::Landings::LandingSubjectsController < Api::V1::BaseController
  def index
    landing_subjects = base_scope
    render json: landing_subjects, each_serializer: serializer, meta: { total_results: landing_subjects.size }
  end

  def show
    landing_subject = base_scope.find(params[:id])
    render json: landing_subject, serializer: serializer, meta: {}
  end

  private

  def serializer
    Api::V1::LandingSubjectSerializer
  end

  def base_scope
    current_institution.landing_subjects.archived(false)
  end
end