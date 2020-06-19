# Redmine Sprint Reminder

Provides a simple rake task `rake redmine:sprint_reminders` to send out an email of all the tasks that are current open or active and have issues that are in flight to the person or people responsible.

Considers sprints where today is within the start and end date interval.

## Options:

* status: A regular expression matching the status names that are considered in-flight.
  * Default `'To Do|Doing'`
