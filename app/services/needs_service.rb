class NeedsService
  def self.archive_old_needs
    # Archive les vieux besoins non pris en charge pour ne pas saturer l’onglet "expirés" des conseillers
    Need.archived(false).for_reminders.where(created_at: ..Need::ARCHIVE_DELAY.ago).each do |need|
      need.update(archived_at: Time.now)
    end
  end

  def self.abandon_needs
    Need.archived(false).for_reminders.not_abandoned.where(created_at: ..Need::REMINDERS_DAYS[:last_chance].days.ago).each do |need|
      # Envoie de l'email d'abandon a l’entreprise si :
      # le besoin a aucun email envoyé et qu'il a plus de 45 jours
      # ou si le besoin a un email envoyé depuis plus de 10 jours et que le besoin a plus de 21 jours
      if (!need.has_action?('last_chance') && need.created_at <= Need::REMINDERS_DAYS[:abandon].days.ago) ||
        (need.has_action?('last_chance') && need.reminders_actions.find_by(category: 'last_chance').created_at <= 10.days.ago)
        ActiveRecord::Base.transaction do
          need.update(abandoned_email_sent: true)
          CompanyMailer.abandoned_need(need).deliver_later
        end
      end
    end
  end
end