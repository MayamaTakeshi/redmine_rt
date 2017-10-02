module RedmineRt
  # Patches Redmine's JournalsController. 
  module JournalsControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
      end

    end

    module ClassMethods
    end

    module InstanceMethods
      def show
        # TODO must check if user is allowed to see this journal

        @journal = Journal.includes([:details]).includes([:user => :email_address]).find(params[:id])
        @issue = Issue.find(@journal.journalized_id)

        @journal.indice = params[:indice]

        if @journal.private_notes
          if @journal.user != User.current and !User.current.allowed_to?(:view_private_notes, @issue.project) 
            render plain: "you don't have permission", status: 401
            return
          end
        end

        @reply_links = @issue.notes_addable? 

        respond_to do |format|
          format.html {
            headers["X-issue-lock-version"] = @issue.lock_version
            render :action => 'show', :layout => false, locals: { journal: @journal, issue: @issue, reply_links: @reply_links}
          }
          format.api { render plain: {journal: @journal, details: @journal.details}.to_json }
        end
     end
    end
  end
end
