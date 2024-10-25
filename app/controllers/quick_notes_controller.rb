class QuickNotesController < ApplicationController
  before_action :require_login

  def add_quick_notes
    issue = Issue.find(params[:id])
    unless User.current.allowed_to?(:add_issues, issue.project, :global => true)
      raise ::Unauthorized
    end

    project = issue.project
    raise NotAllowedInProject, "not possible to add notes to project [#{project.name}]" unless project.allows_to?(:add_issue_notes)

    unless issue.notes_addable?
      raise InsufficientPermissions, "not allowed to add notes on issues to project [#{issue.project.name}]"
    end

	user = User.current

    journal = issue.init_journal(user)

    journal.notes = params[:issue][:notes]
	journal.private_notes = params[:issue][:private_notes]

    issue.save!

    render json: "{}"
  end

end
