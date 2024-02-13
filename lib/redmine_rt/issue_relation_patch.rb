module RedmineRt
  module IssueRelationPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        after_save :handle_issue_relation_after_save
        after_destroy :handle_issue_relation_after_destroy
      end
    end

    def handle_issue_relation_after_save
      evt = { event: 'issue_relation ' + self.id.to_s +  ' saved', type: 'issue_relation_saved', id: self.id, issue_from_id: self.issue_from_id, issue_to_id: self.issue_to_id }
      Broadcaster.broadcast "issue:#{self.issue_from_id}", evt
      Broadcaster.broadcast "issue:#{self.issue_to_id}",  evt
    end

    def handle_issue_relation_after_destroy
      evt = { event: 'issue_relation ' + self.id.to_s +  ' deleted', type: 'issue_relation_deleted', id: self.id, issue_from_id: self.issue_from_id, issue_to_id: self.issue_to_id }
      Broadcaster.broadcast "issue:#{self.issue_from_id}", evt
      Broadcaster.broadcast "issue:#{self.issue_to_id}", evt
    end
  end
end 
