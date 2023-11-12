module RedmineRt
  module IssuePatch
    def self.included(base) # :nodoc:
      base.class_eval do
        after_save :handle_issue_after_save
        after_destroy :handle_issue_after_destroy
      end
    end

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
