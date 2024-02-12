# frozen_string_literal: true

class NeedsController < ApplicationController
  include Inbox
  before_action :retrieve_user, except: %i[index]
  before_action :retrieve_need, only: %i[show]
  before_action :persist_search_params, only: [:index, :quo_active, :taking_care, :done, :not_for_me, :expired]

  layout 'side_menu', except: :show

  ## Collection actions
  # (aka “index pages”)
  # TODO: The collections rely on InvolvementConcern being used on User and Antenne.
  # We could simply have one route and get the name of the collection as a parameter, like this;
  # /besoins(/antenne)/:collection_name
  # However, Needs#show is already used to display the _completed diagnoses_, like this:
  # /besoins/:diagnosis_id
  # This is… sub-optimal. We might want to use Diagnoses#show for this; it is already used for in-progress diagnoses.
  # Note: We would still need to handle redirections, because the diagnoses paths are the ones sent by email to experts.
  # TODO: Another issue is that the collections in /besoins/ are actually collections of diagnoses.
  # All of this is #1278.
  def index
    redirect_to action: :quo_active
  end

  def quo_active
    retrieve_needs(current_user, :quo_active, order: :asc)
  end

  def taking_care
    retrieve_needs(current_user, :taking_care)
  end

  def done
    retrieve_needs(current_user, :done)
  end

  def not_for_me
    retrieve_needs(current_user, :not_for_me)
  end

  def expired
    retrieve_needs(current_user, :expired)
  end

  ## Instance actions
  #

  def show
    authorize @need
    if @need.status_diagnosis_not_complete?
      flash[:alert] = t('.diagnosis_not_completed')
      redirect_to quo_active_needs_path
    else
      @origin = params[:origin]
      @matches = @need.matches.sent.order(:created_at)
      @facility = @need.facility
      @facility_needs = Need.for_facility(@facility).where.not(id: @need.id)
      @contact_needs = NeedPolicy::Scope.new(current_user, Need.for_emails_and_sirets([@need.diagnosis.visitee.email])).resolve - [@facility_needs, @need]
    end
  end

  def additional_experts
    @need = Need.find(params.require(:need))
    @query = params.require('query')&.strip

    @experts = Expert.omnisearch(@query)
      .active
      .with_subjects
      .where.not(id: @need.experts)
      .limit(20)
      .includes(:antenne, experts_subjects: :institution_subject)
  end

  def add_match
    @need = retrieve_need
    expert = Expert.find(params.require(:expert))
    @match = Match.create(need: @need, expert: expert, subject: @need.subject, sent_at: Time.zone.now)
    if @match.valid?
      ExpertMailer.with(expert: expert, need: @need).notify_company_needs.deliver_later
      expert.first_notification_help_email
    else
      flash.alert = @match.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def authorize_index_solicitation
    authorize Need, :index?
  end

  def retrieve_diagnosis
    Diagnosis.find(params.require(:id))
  end

  def retrieve_need
    @need = Need.find(params.require(:id))
  end

  def retrieve_user
    @user = current_user
  end

  def recipient_for_search
    @user
  end
end
