module RedmineRt
  # Patches Redmine's Issue Helper
  module IssuesHelperPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def issue_history_tabs_for_redmine_rt
      tabs = []
      #if @journals.present?
        journals_without_notes = @journals.select{|value| value.notes.blank?}
        journals_with_notes = @journals.reject{|value| value.notes.blank?}
        tabs <<
          {
            :name => 'history',
            :label => :label_history,
            :onclick => 'showIssueHistory("history", this.href)',
            :partial => 'issues/tabs/history',
            :locals => {:issue => @issue, :journals => @journals}
          }
        #if journals_with_notes.any?
          tabs <<
            {
              :name => 'notes',
              :label => :label_issue_history_notes,
              :onclick => 'showIssueHistory("notes", this.href)'
            }
        #end
        #if journals_without_notes.any?
          tabs <<
            {
              :name => 'properties',
              :label => :label_issue_history_properties,
              :onclick => 'showIssueHistory("properties", this.href)'
            }
        #end
      #end

      if User.current.allowed_to?(:view_time_entries, @project) && @issue.spent_hours > 0
        tabs <<
          {
            :name => 'time_entries',
            :label => :label_time_entry_plural,
            :remote => true,
            :onclick =>
              "getRemoteTab('time_entries', " \
              "'#{tab_issue_path(@issue, :name => 'time_entries')}', " \
              "'#{issue_path(@issue, :tab => 'time_entries')}')"
          }
      end
      if @has_changesets
        tabs <<
          {
            :name => 'changesets',
            :label => :label_associated_revisions,
            :remote => true,
            :onclick =>
              "getRemoteTab('changesets', " \
              "'#{tab_issue_path(@issue, :name => 'changesets')}', " \
              "'#{issue_path(@issue, :tab => 'changesets')}')"
          }
      end
      tabs
    end
  end

end 
