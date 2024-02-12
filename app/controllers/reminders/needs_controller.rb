module Reminders
  class NeedsController < BaseController
    before_action :persist_filter_params, :setup_territory_filters, :collections_counts
    before_action :find_need, only: %i[send_abandoned_email send_last_chance_email]

    def index
      redirect_to action: :poke
    end

    def poke
      render_collection(:poke)
    end

    def last_chance
      render_collection(:last_chance)
    end

    def abandon
      render_collection(:abandon)
    end

    def send_abandoned_email
      ActiveRecord::Base.transaction do
        @feedback = Feedback.create(user: current_user, category: :need_reminder, description: t('.email_sent'),
                                    feedbackable_type: 'Need', feedbackable_id: @need.id)
        CompanyMailer.abandoned_need(@need).deliver_later
      end
      respond_to do |format|
        format.js { render template: 'reminders/needs/add_feedback', layout: false }
        format.html { redirect_to abandon_reminders_needs_path, notice: t('mailers.email_sent') }
      end
    end

    def send_last_chance_email
      reminded_teams = []
      @need.matches.with_status_quo_active.each do |match|
        reminded_teams << "#{match.expert.full_name} (#{match.expert.institution.name})"
        ExpertMailer.with(expert: match.expert, support_user: current_user, need: @need).last_chance.deliver_later
      end
      @feedback = Feedback.create(user: current_user, category: :need_reminder, description: t('.email_send', teams: reminded_teams.to_sentence),
                                  feedbackable_type: 'Need', feedbackable_id: @need.id)
      respond_to do |format|
        format.js { render template: 'reminders/needs/add_feedback', layout: false }
        format.html { redirect_to last_chance_reminders_needs_path, notice: t('mailers.email_sent') }
      end
    end

    def update_badges
      @need = Need.find(params.permit(:id)[:id])
      badges_params = params.require(:need).permit(badge_ids: [])
      unless @need.update(badges_params)
        flash.alert = @need.errors.full_messages.to_sentence
        redirect_back(fallback_location: poke_reminders_needs_path)
      end
    end

    private

    def find_need
      @need = Need.find(params.permit(:id)[:id])
    end

    def render_collection(action)
      @action = action
      @needs = filtered_needs
        .reminders_to(action)
        .joins(:matches, :experts)
        .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
        .distinct
        .order(:created_at)
        .page(params[:page])

      render :index
    end

    def collections_counts
      @collections_by_reminders_actions_count = Rails.cache.fetch(['reminders_need', filtered_needs]) do
        collection_action_names.index_with { |name| filtered_needs.reminders_to(name).size }
      end
    end

    def filtered_needs
      @filtered_needs ||= Need.apply_filters(reminders_filter_params)
    end
  end
end
