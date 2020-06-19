desc <<-EOT
Check for tasks in To Do or Doing state for the current sprint.

Options:
  days=5,2

Will send reminders when issues are due 5 or 2 days in advance.
EOT

namespace :redmine do
  task :sprint_reminders => :environment do
    Mailer.with_synched_deliveries do
      options = {}
      options[:states] = ENV['states'].presence.to_s
      puts "Calling mailer with #{options.inspect}"
      Mailer.sprint_reminders(options)
    end
  end
end
