Redmine::Plugin.register :redmine_sprint_reminder do
  name 'Redmine Sprint Reminder plugin'
  author 'William Sobel'
  description 'Used with RedmineUp Agile plugin to remined users when tasks are due by the end of the sprint'
  version '0.9.0'
  url 'https://github.com/mtconnect/redmine_sprint_reminder'
  author_url 'https://projects.wvsobel.llc'
end

require File.dirname(__FILE__) + '/lib/patches/sprint_mailer_patch'


