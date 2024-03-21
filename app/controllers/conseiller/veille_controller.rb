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

  def followed_needs
    @needs = retrieve_followed_needs
      .page(params[:page])
    render :index
  end

  private

  def retrieve_quo_matches_needs
    range = Range.new(45.days.ago, 20.days.ago)
    # On ne veut pas les "besoins en PQ" (relance Expert ou besoin)
    relance_experts = Expert.in_reminders_registers
    quo_matches ||= Match.sent
      .status_quo
      .where(sent_at: range)
      .where.not(expert: relance_experts)
    @quo_matches_needs ||= Need.diagnosis_completed.joins(:matches)
      .where(matches: quo_matches)
      .where.not(status: :quo) # besoins dans panier relance
      .without_action(:quo_match)
      .distinct
  end

  def retrieve_followed_needs
    @followed_needs ||= Need.order(:created_at).limit(3)
  end

  def collections_counts
    @collections_by_veille_count = Rails.cache.fetch(['veille', retrieve_quo_matches_needs.size, retrieve_followed_needs.size]) do
      {
        quo_matches: retrieve_quo_matches_needs.size,
        followed_needs: retrieve_followed_needs.size
      }
    end
  end
end
