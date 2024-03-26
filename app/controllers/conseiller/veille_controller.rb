class Conseiller::VeilleController < ApplicationController
  before_action :authenticate_admin!
  before_action :collections_counts

  layout 'side_menu'

  def index
    redirect_to action: :quo_matches
  end

  def quo_matches
    @needs = retrieve_quo_matches_needs
      .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
      .order(created_at: :asc)
      .page(params[:page])
    render :index
  end

  def starred_needs
    @needs = retrieve_starred_needs
      .page(params[:page])
    render :index
  end

  private

  def retrieve_quo_matches_needs
    @quo_matches_needs ||= Need.with_filtered_matches_quo
  end

  def retrieve_starred_needs
    @starred_needs ||= Need.order(:created_at).limit(3)
  end

  def collections_counts
    @collections_by_veille_count = Rails.cache.fetch(['veille', retrieve_quo_matches_needs.size, retrieve_starred_needs.size]) do
      {
        quo_matches: retrieve_quo_matches_needs.size,
        starred_needs: retrieve_starred_needs.size
      }
    end
  end
end
