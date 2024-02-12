class MatchFeedbackEmailJob < ApplicationJob
  def perform(feedback_id, person)
    feedback = Feedback.find_by(id: feedback_id)
    if feedback.present?
      UserMailer.with(user: person, feedback: feedback).match_feedback.deliver_now
    end
  end
end
