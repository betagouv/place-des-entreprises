class AdminMailerPreview < ActionMailer::Preview
  def failed_jobs
    jobs_count = Sidekiq::Failures.count
    AdminMailer.failed_jobs(jobs_count)
  end
end
