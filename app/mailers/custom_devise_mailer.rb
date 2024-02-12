class CustomDeviseMailer < Devise::Mailer
  layout 'expert_mailers'

  def headers_for(action, opts)
    if action == :invitation_instructions
      super.merge!({
        subject: I18n.t('devise.mailer.invitation_instructions.subject', institution: resource.institution.name),
          from: email_address_with_name(ApplicationMailer::SENDER, resource.antenne.support_user_name),
          reply_to: resource.antenne.support_user_email_with_name
      })
    else
      super.merge!({
        from: ApplicationMailer::SENDER,
        reply_to: ApplicationMailer::REPLY_TO
      })
    end
  end

  def invitation_instructions(record, token, opts = {})
    @institution_logo_name = record.institution.logo&.filename
    super
  end

  def reset_password_instructions(record, token, opts = {})
    @institution_logo_name = record.institution.logo&.filename
    super
  end
end
