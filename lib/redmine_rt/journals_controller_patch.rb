module RedmineRt
  # Patches Redmine's JournalsController. 
  module JournalsControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        accept_api_auth :destroy
      end

    end

    module ClassMethods
    end

    module InstanceMethods
      def show

        @journal = Journal.includes([:details]).includes([:user => :email_address]).find(params[:id])
        @issue = Issue.find(@journal.journalized_id)

        user = User.current
        if @journal.private_notes? && @journal.user != user then
          if not user.allowed_to?(:view_private_notes, @issue.project)
             raise ::Unauthorized
          end
        end

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
            headers["X-issue-lock-version"] = @issue.lock_version.to_s
      
            if Rails::VERSION::MAJOR >= 5
              render :action => 'show', :layout => false, locals: { journal: @journal, issue: @issue, reply_links: @reply_links}
            else
              render :action => 'show_old', :layout => false, locals: { journal: @journal, issue: @issue, reply_links: @reply_links}
            end
          }
          format.api { render plain: {journal: @journal, details: @journal.details}.to_json }
        end
      end

      def destroy
        @journal = Journal.find(params[:id])
        unless @journal.editable_by?(User.current)
          raise ::Unauthorized
        end
        @journal.destroy
        respond_to do |format|
           format.api { render :nothing => true, :status => 204 }
        end
      end
    end
  end
end
