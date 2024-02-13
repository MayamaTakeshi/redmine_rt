module RedmineRt
  module IssueRelationPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        after_save :handle_issue_relation_after_save
        after_destroy :handle_issue_relation_after_destroy
      end
    end

    def handle_issue_relation_after_save
      Broadcaster.broadcast "issue:#{self.issue_from_id}", 
        { event: 'issue ' + self.issue_from_id.to_s +  ' relation_saved', type: 'issue_relation_saved', other_issue_id: self.issue_to_id }

      Broadcaster.broadcast "issue:#{self.issue_to_id}", 
        { event: 'issue ' + self.issue_to_id.to_s +  ' relation_saved', type: 'issue_relation_saved', other_issue_id: self.issue_from_id }
    end

    def handle_issue_relation_after_destroy
      Broadcaster.broadcast "issue:#{self.issue_from_id}",
        { event: 'issue ' + self.issue_from_id.to_s +  ' relation_deleted', type: 'issue_relation_deleted', other_issue_id: self.issue_to_id }

      Broadcaster.broadcast "issue:#{self.issue_to_id}",
        { event: 'issue ' + self.issue_to_id.to_s +  ' relation_deleted', type: 'issue_relation_deleted', other_issue_id: self.issue_from_id }
    end
  end
end 
