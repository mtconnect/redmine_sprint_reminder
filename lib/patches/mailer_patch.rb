module RedmineSprintReminder
  module MailerPatch
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        
        def self.sprint_reminders(options)
          only_admins = options[:admins] || false
          states = options[:states] || /To Do|Doing/
          state_pattern = Regexp.new(states)
          issues_by_assignee = Hash.new { |h, k| h[k] = [] unless h.include?(k) }
          today = Date.today

          AgileSprint.available.
            where(":today BETWEEN #{AgileSprint.table_name}.start_date AND #{AgileSprint.table_name}.end_date", today: today).
            eager_load(issues: [:status, :assigned_to]).
            each do |sprint|
            sprint.issues.select do |i|
              i.status.name =~ state_pattern
            end.each do |i|
              assignee = i.assigned_to
              if assignee.is_a?(Group)
                assignee.users.each do |user|
                  issues_by_assignee[user] << [i, sprint] if user.active?
                end
              elsif assignee.is_a?(User) and assignee.active?
                issues_by_assignee[assignee] << [i, sprint]
              end
            end
          end

          issues_by_assignee.each do |assignee, issues|
            sprint_reminder(assignee, issues).deliver_later if !only_admins or assignee.admin?
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
        @issues.sort_by { |i, s| s.remaining }
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
