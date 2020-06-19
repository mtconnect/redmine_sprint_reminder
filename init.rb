Redmine::Plugin.register :redmine_sprint_reminder do
  name 'Redmine Sprint Reminder plugin'
  author 'William Sobel'
  description 'Used with RedmineUp Agile plugin to remined users when tasks are due by the end of the sprint'
  version '0.9.0'
  url 'https://projects.wvsobel.llc'
  author_url 'https://projects.wvsobel.llc'

  require_dependency 'patches/mailer_patch'
end

