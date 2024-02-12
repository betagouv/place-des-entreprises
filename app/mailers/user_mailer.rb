# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions
  helper :status

  layout 'expert_mailers'

  def match_feedback
    with_user_init do
      @feedback = params[:feedback]
      return if @feedback.nil?

      @author = @feedback.user
      @match = @user.received_matches.find_by(need: @feedback.need.id)

      mail(to: @user.email_with_display_name,
          subject: t('mailers.user_mailer.match_feedback.subject', company_name: @feedback.need.company))
    end
  end

  def quarterly_report
    with_user_init do
      mail(
        to: @user.email_with_display_name,
        subject: t('mailers.user_mailer.quarterly_report.subject')
      )
    end
  end

  private

  def with_user_init
    @user = params[:user]
    return false if @user.deleted?
    @institution_logo_name = @user.institution.logo&.filename
    yield
  end
end
