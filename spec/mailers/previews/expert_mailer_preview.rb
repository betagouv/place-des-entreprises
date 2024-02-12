class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs_from_pde
    expert = active_expert
    need = expert.received_needs.sample
    need.solicitation = Solicitation.joins(:landing).where(landing: { partner_url: [nil, ''] }).sample
    ExpertMailer.with(expert: expert, need: need).notify_company_needs
  end

  def notify_company_needs_from_partner
    expert = active_expert
    need = expert.received_needs.sample
    solicitation = Solicitation.all.sample
    need.solicitation = solicitation
    solicitation.landing = Landing.all.sample
    solicitation.landing.update(partner_url: 'https://test.com/formulaire')
    ExpertMailer.with(expert: expert, need: need).notify_company_needs
  end

  def first_notification_help
    expert = active_expert
    ExpertMailer.with(expert: expert).first_notification_help
  end

  def remind_involvement
    expert = Match.sent.status_quo.where(created_at: ..4.days.ago, archived_at: nil).joins(:expert).where(experts: { deleted_at: nil }).sample.expert
    ExpertMailer.with(expert: expert).remind_involvement
  end

  def positioning_rate_reminders
    expert = Expert.not_deleted.many_pending_needs.sample
    ExpertMailer.with(expert: expert, support_user: User.support_users.sample).positioning_rate_reminders
  end

  def last_chance
    expert = active_expert
    need = expert.received_needs.sample
    ExpertMailer.with(expert: expert, support_user: User.support_users.sample, need: need).last_chance
  end

  def re_engagement
    expert = active_expert
    need = expert.received_needs.sample
    ExpertMailer.with(expert: expert, support_user: User.support_users.sample, need: need).re_engagement
  end

  private

  def active_expert
    Expert.not_deleted.with_active_matches.sample
  end
end
