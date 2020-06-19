module RedmineSprintReminder
  module MailerPatch
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        
        def self.sprint_reminders(options)
          days = options[:days] || [5]          
          issues_by_assignee = Hash.new { |h, k| h[k] = [] unless h.include?(k) }

          AgileSprint.available.select do |s|
            (s.status == AgileSprint::ACTIVE || s.status == AgileSprint::OPEN) and days.include?(s.remaining)
          end.each do |sprint|
            sprint.issues.select do |i|
              i.status.name =~ /To Do|Doing/
            end.each do |i|
              assignee = i.assigned_to
              if assignee.is_a?(Group)
                assignee.users.each do |user|
                  issues_by_assignee[user] << [i, sprint] if assignee.active?
                end
              elsif assignee.is_a?(User) and assignee.active?
                issues_by_assignee[assignee] << [i, sprint]
              end
            end
          end

          issues_by_assignee.each do |assignee, issues|
            sprint_reminder(assignee, issues).deliver_later
          end
        end
      end
    end

    module InstanceMethods
      # Builds a reminder mail to user about issues that are due in the next days.
      def sprint_reminder(user, issues)
        @issues = issues
        @issues_url = url_for(:controller => 'issues', :action => 'index',
                              :set_filter => 1, :assigned_to_id => 'me',
                              :sort => 'due_date:asc')
        @days = @issues.map { |i, s| s.remaining }.min
        
        mail(:to => user,
             :subject => "You have #{issues.size} issue(s) due soon")
      end
    end
  end
end

unless Mailer.included_modules.include?(RedmineSprintReminder::MailerPatch)
  Mailer.include(RedmineSprintReminder::MailerPatch)
end
