module RedmineRt
  # Patches Redmine's Journal model. 
  module JournalPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        after_save :handle_journal_after_save
        after_destroy :handle_journal_after_destroy
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def handle_journal_after_save
      if self.journalized_type != 'Issue' then return end
      Broadcaster.broadcast "issue:#{self.journalized_id}",
        { event: 'journal ' + self.id.to_s +  ' saved', type: 'journal_saved', journal_id: self.id }
    end
    def handle_journal_after_destroy
      if self.journalized_type != 'Issue' then return end
      Broadcaster.broadcast "issue:#{self.journalized_id}",
        { event: 'journal ' + self.id.to_s +  ' deleted', type: 'journal_deleted', journal_id: self.id }
    end
  end
end    
