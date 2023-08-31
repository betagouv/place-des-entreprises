require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.week, 'send_app_administrators_statistics_email', at: 'Monday 07:30', tz: 'UTC') do
    AdminMailersService.delay(queue: :low_priority).send_statistics_email
  end
  every(1.week, 'send_experts_reminders', at: 'Tuesday 9:00', tz: 'UTC') do
    ExpertReminderService.delay(queue: :low_priority).send_reminders
  end
  every(1.week, 'anonymize_old_diagnoses', at: 'sunday 5:00', tz: 'UTC') do
    `rake anonymize_old_diagnoses`
  end
  every(1.day, 'revoke_api_keys', at: ('2:00'), if: -> (t) { t.day == 1 }, tz: 'UTC') do
    ApiKeysManagement.delay.batch_revoke
  end
  every(1.day, 'archive_expired_matches', at: '02:11', tz: 'UTC') do
    NeedsService.delay.archive_expired_matches
  end
  every(1.day, 'abandon_needs', at: '03:11', tz: 'UTC') do
    NeedsService.delay.abandon_needs
  end
  every(1.day, 'rattrapage_analyse', at: ('3:41'), tz: 'UTC') do
    `rake rattrapage_analyse`
  end
  every(1.day, 'purge_csv_exports', at: ('4:11'), tz: 'UTC') do
    CsvExport.delay.purge_later
  end
  every(1.day, 'send_retention_emails', at: ('4:41'), tz: 'UTC') do
    CompanyMailerService.delay.send_retention_emails
  end
  every(1.day, 'not_supported_solicitations', at: ('5:00'), tz: 'UTC') do
    NotYetTakenCareEmailService.new.delay.call
  end
  every(1.day, 'send_satisfaction_emails', at: ('5:41'), tz: 'UTC') do
    CompanyMailerService.delay.send_satisfaction_emails
  end
  every(1.day, 'inteligent_retention', at: ('06:30'), tz: 'UTC') do
    RetentionService.delay(queue: :low_priority).send_emails
  end
  every(1.day, 'send_failed_jobs_email', at: '10:00', tz: 'UTC') do
    AdminMailersService.delay(queue: :low_priority).send_failed_jobs
  end
  every(1.day, 'relaunch_solicitations', at: ('12:00'), tz: 'UTC') do
    SolicitationsRelaunchService.delay(queue: :low_priority).perform
  end
  if Rails.env == 'production'
    every(1.day, 'generate_quarterly_reports', at: '01:00', if: -> (t) { t.day == 20 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }, tz: 'UTC') do
      Antenne.find_each do |antenne|
        QuarterlyReports::GenerateReports.new(antenne).delay(queue: :low_priority).call
      end
    end
    every(1.day, 'send_quarterly_reports_emails', at: '08:00', if: -> (t) { t.day == 21 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }, tz: 'UTC') do
      QuarterlyReports::NotifyManagers.new.delay(queue: :low_priority).call
    end
    every(1.day, 'reminders_registers', :at => ['01:00', '13:00'], tz: 'UTC') { RemindersService.delay(queue: :low_priority).create_reminders_registers }
  end
end
