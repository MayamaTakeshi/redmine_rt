module RedmineRt
  # Patches Redmine's Journal model. 
  module JournalPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        after_create :handle_journal_after_create
        after_save :handle_journal_after_save
        after_destroy :handle_journal_after_destroy
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def handle_journal_after_create
      logger.debug "handle_journal_after_create"
      issue = Issue.find(self.journalized_id)
      if not issue then return end

      if self.notes then
        data = {command: "show_notification", data: {title: "issue #{issue.id} (#{issue.subject}) has a new comment", message: self.notes[0..48]}}
        [issue.author_id, issue.assigned_to_id].uniq.each {
          | user_id |
          if user_id and user_id != self.user_id then
            # only notify if target user is the same as the author of the note
            user = User.find(issue.author_id)
            Broadcaster.broadcast "user:#{user.login}", data
          end
        }
      end
    end

    def handle_journal_after_save
      logger.debug "handle_journal_after_save"
      if self.journalized_type != 'Issue' then return end
      Broadcaster.broadcast "issue:#{self.journalized_id}",
        { event: 'journal ' + self.id.to_s +  ' saved', type: 'journal_saved', journal_id: self.id }
    end
    def handle_journal_after_destroy
      logger.debug "handle_journal_after_destroy"
      if self.journalized_type != 'Issue' then return end
      Broadcaster.broadcast "issue:#{self.journalized_id}",
        { event: 'journal ' + self.id.to_s +  ' deleted', type: 'journal_deleted', journal_id: self.id }
    end
  end
end    
