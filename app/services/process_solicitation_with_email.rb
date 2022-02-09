class ProcessSolicitationWithEmail
  attr_reader :base_faq

  def initialize(solicitation, email_type)
    @solicitation = solicitation
    @email_type = email_type
  end

  def valid?
    @email_type.present? && @solicitation.present? && Solicitation::GENERIC_EMAILS_TYPES.include?(@email_type.to_sym)
  end

  def process
    @solicitation.update(badge_ids: @solicitation.badge_ids + [email_type_to_badge_id])
    @solicitation.update(status: 'processed')
    SolicitationMailer.send(@email_type, @solicitation).deliver_later
  end

  private

  def email_type_to_badge_id
    translated_email_type = I18n.t(@email_type, scope: 'solicitations.solicitation_actions.emails')
    badge = Badge.find_by('lower(title) = ?', translated_email_type.squish.downcase)
    badge = Badge.create(title: translated_email_type, color: "#000000") if badge.nil?
    badge.id
  end
end