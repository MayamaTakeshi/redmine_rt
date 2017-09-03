module RedmineRt
  class RedmineRtHooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      %{
         <script src="/javascripts/action_cable.js"></script>
         <script src="/plugin_assets/redmine_rt/javascripts/channels/redmine_rt.js?body=1"></script>}
    end
  end
end
