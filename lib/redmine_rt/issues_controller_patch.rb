module RedmineRt
  # Patches Redmine's IssuesController. 
  module IssuesControllerPatch

    def sample_helper_method
      return "some_result"
    end

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        before_action :find_issue, :only => [:show, :edit, :update, :add_quick_notes]
        before_action :authorize, :except => [:index, :new, :create, :add_quick_notes]

	helper_method :sample_helper_method # this method can be called from an issues view.
      end

    end

    module ClassMethods
    end

    module InstanceMethods
      def add_quick_notes
        unless User.current.allowed_to?(:add_issues, @issue.project, :global => true)
         raise ::Unauthorized
        end

        return unless update_issue_from_params
        save_issue_with_child_records
        render json: "{}"
      end

    end

  end
end
