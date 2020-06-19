desc <<-EOT
Check for tasks in To Do or Doing state for the current sprint.

Options:

Specify the regexp for matching state name
  states='To Do|Doing'

Only send emails to admins, used for testing.
  admins='yes'

Will send reminders when issues in an active sprint.
EOT

namespace :redmine do
  task :sprint_reminders => :environment do
    Mailer.with_synched_deliveries do
      options = {}
      options[:states] = ENV['states'].presence.to_s
      options[:admins] = ENV['admins'].presence.to_s == 'yes'
      puts "Calling mailer with #{options.inspect}"
      Mailer.sprint_reminders(options)
    end
  end
end
