web: bundle exec puma -C config/puma.rb
clock: bundle exec clockwork app/models/clockwork.rb
delayedjob: bundle exec sidekiq

postdeploy: bundle exec rake db:migrate
