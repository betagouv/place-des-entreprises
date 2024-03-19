require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.week, 'send_experts_reminders', at: 'Tuesday 9:00', tz: 'UTC') do
    SendExpertsRemindersJob.perform_later
  end
  every(1.week, 'anonymize_old_diagnoses', at: 'sunday 5:00', tz: 'UTC') do
    `rake anonymize_old_diagnoses`
  end
  every(1.day, 'revoke_api_keys', at: ('2:00'), if: -> (t) { t.day == 1 }, tz: 'UTC') do
    Api::ApiKeysRevokeJob.perform_later
  end
  every(1.day, 'archive_expired_matches', at: '02:11', tz: 'UTC') do
    ArchiveExpiredMatchesJob.perform_later
  end
  every(1.day, 'abandon_needs', at: '03:11', tz: 'UTC') do
    AbandonNeedsJob.perform_later
  end
  every(1.day, 'rattrapage_analyse', at: ('3:41'), tz: 'UTC') do
    `rake rattrapage_analyse`
  end
  every(1.day, 'purge_csv_exports', at: ('4:11'), tz: 'UTC') do
    Admin::PurgeCsvExportsJob.perform_later
  end
  every(1.day, 'send_retention_emails', at: ('4:41'), tz: 'UTC') do
    CompanyEmails::SendRetentionEmailsJob.perform_later
  end
  every(1.day, 'not_supported_solicitations', at: ('5:00'), tz: 'UTC') do
    CompanyEmails::NotYetTakenCareJob.perform_later
  end
  every(1.day, 'send_satisfaction_emails', at: ('5:41'), tz: 'UTC') do
    CompanyEmails::SendSatisfactionEmailsJob.perform_later
  end
  every(1.day, 'inteligent_retention', at: ('06:30'), tz: 'UTC') do
    CompanyEmails::SendIntelligentRetentionEmailsJob.perform_later
  end
  every(1.day, 'send_failed_jobs_email', at: '10:00', tz: 'UTC') do
    Admin::SendFailedJobsJob.perform_later
  end
  every(1.day, 'relaunch_solicitations', at: ('12:00'), tz: 'UTC') do
    CompanyEmails::SolicitationsRelaunchJob.perform_later
  end
  if Rails.env == 'production' && !ENV['FEATURE_HEAVY_CRON_DISABLED'].to_b
    every(1.day, 'generate_quarterly_reports', at: '01:00', if: -> (t) { t.day == 20 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }, tz: 'UTC') do
      QuarterlyReports::FindAntennesJob.perform_later
    end
    every(1.day, 'send_quarterly_reports_emails', at: '08:00', if: -> (t) { t.day == 23 && (t.month == 1 || t.month == 4 || t.month == 7 || t.month == 10) }, tz: 'UTC') do
      QuarterlyReports::NotifyManagersJob.perform_later
    end
    every(1.day, 'reminders_registers', :at => ['01:00', '13:00'], tz: 'UTC') do
      Admin::CreateRemindersRegistersJob.perform_later
    end
    every(1.day, 'backup_db', at: ('2:10')) do
      `rake backup_db`
    end
  end
end
