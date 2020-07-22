# frozen_string_literal: true

class CompanyMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/company_mailer'

  def confirmation_solicitation(solicitation)
    @solicitation = solicitation
    mail(
      to: @solicitation.email,
      subject: t('mailers.company_mailer.confirmation_solicitation.subject')
    )
  end

  def notify_matches_made(diagnosis)
    @diagnosis = diagnosis

    subject = @diagnosis.from_solicitation? ?
      t('mailers.company_mailer.notify_matches_made.subject_from_solicitation') :
      t('mailers.company_mailer.notify_matches_made.subject_from_visit')
    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: subject
    )
  end

  def notify_taking_care(match)
    @match = match
    @diagnosis = match.diagnosis
    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.notify_taking_care.subject')
    )
  end

  def satisfaction(diagnosis)
    @diagnosis = diagnosis

    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.satisfaction.subject')
    )
  end

  def newsletter_subscription(diagnosis)
    @diagnosis = diagnosis

    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.newsletter_subscription.subject')
    )
  end
end
