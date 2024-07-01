class CreateSharedSatisfactionJob < ApplicationJob
  queue_as :low_priority

  def perform(company_satisfaction_id)
    CompanySatisfaction.find(company_satisfaction_id).share
  end
end
