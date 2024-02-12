class UserMailerPreview < ActionMailer::Preview
  def match_feedback
    feedback = Feedback.category_need.sample
    UserMailer.with(user: feedback.need.experts.sample, feedback: feedback).match_feedback
  end

  def quarterly_report
    UserMailer.with(user: User.active.managers.sample).quarterly_report
  end
end
