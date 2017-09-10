module RedmineRt
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      [
        javascript_include_tag(:action_cable, :plugin => 'redmine_rt'),
        javascript_include_tag(:cable, :plugin => 'redmine_rt'),
        javascript_include_tag(:issue_channel, :plugin => 'redmine_rt')
      ]
    end
  end
end
