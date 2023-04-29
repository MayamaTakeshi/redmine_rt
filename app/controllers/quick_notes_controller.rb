class QuickNotesController < ApplicationController
  unloadable

  before_action :find_issue_by_id
  #before_action :authorize
  helper :issues

  def add
    unless User.current.allowed_to?(:add_issues, @issue.project, :global => true)
      raise ::Unauthorized
    end

    return unless update_issue_from_params
    save_issue_with_child_records
    render json: "{}"
  end

  def find_issue_by_id
    @issue = Issue.find(params[:id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # copied verbatim from issues_controller
  def update_issue_from_params
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    if params[:time_entry]
      @time_entry.safe_attributes = params[:time_entry]
    end
    @issue.init_journal(User.current)
    issue_attributes = params[:issue]
    if issue_attributes && issue_attributes[:assigned_to_id] == 'me'
      issue_attributes[:assigned_to_id] = User.current.id
    end
    if issue_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
      when 'overwrite'
        issue_attributes = issue_attributes.dup
        issue_attributes.delete(:lock_version)
      when 'add_notes'
        issue_attributes = issue_attributes.slice(:notes, :private_notes)
      when 'cancel'
        redirect_to issue_path(@issue)
        return false
      end
    end
    issue_attributes = replace_none_values_with_blank(issue_attributes)
    @issue.safe_attributes = issue_attributes
    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    true
  end

  # copied verbatim from issues_controller
  def save_issue_with_child_records
    Issue.transaction do
      if params[:time_entry] &&
           (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) &&
           User.current.allowed_to?(:log_time, @issue.project)
        time_entry = @time_entry || TimeEntry.new
        time_entry.project = @issue.project
        time_entry.issue = @issue
        time_entry.author = User.current
        time_entry.user = User.current
        time_entry.spent_on = User.current.today
        time_entry.safe_attributes = params[:time_entry]
        @issue.time_entries << time_entry
      end
      call_hook(
        :controller_issues_edit_before_save,
        {:params => params, :issue => @issue,
         :time_entry => time_entry,
         :journal => @issue.current_journal}
      )
      if @issue.save
        call_hook(
          :controller_issues_edit_after_save,
          {:params => params, :issue => @issue,
           :time_entry => time_entry,
           :journal => @issue.current_journal}
        )
      else
        raise ActiveRecord::Rollback
      end
    end
  end
end
