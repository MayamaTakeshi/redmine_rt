module RedmineRt
  # Patches Redmine's Issue model. 
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        after_save :handle_issue_after_save
        after_destroy :handle_issue_after_destroy
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def handle_issue_after_save
      Broadcaster.broadcast "issue:#{self.id}", 
        { event: 'issue ' + self.id.to_s +  ' saved', type: 'issue_saved', issue_id: self.id }
    end

    def handle_issue_after_destroy
      Broadcaster.broadcast "issue:#{self.id}",
        { event: 'issue ' + self.id.to_s +  ' deleted', type: 'issue_deleted', issue_id: self.id }
    end
  end
end 
