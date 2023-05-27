module Issues::Show

Deface::Override.new(:virtual_path => 'issues/show',
                     :name => "force history always",
                     :replace => "#history") do
"""<div id='history' data-comment_sorting='<%= User.current.wants_comments_in_reverse_order? ? 'desc' : 'asc' %>'>
<%= render_tabs issue_history_tabs_for_redmine_rt, issue_history_default_tab %>
</div>

<%= stylesheet_link_tag 'my_styles', plugin: 'redmine_rt' %>

<div id='message-container' class='message-container'></div>

<%= javascript_tag do %> REDMINE_RT = {}; <% end %>

"""
end

Deface::Override.new(:virtual_path => 'issues/show',
                     :name => "add quick notes",
                     :insert_before => "#history") do
"""
<% if @issue.notes_addable? %>
<div id='quick_notes'>
<fieldset><legend><%= l(:field_notes) %></legend>
<textarea cols='60' rows='3' class='wiki-edit' name='quick_notes_ta' id='quick_notes_ta'></textarea>

<% if @issue.safe_attribute? 'private_notes' %>
<input type='checkbox' value='1' name='quick_notes_private_cbox' id='quick_notes_private_cbox' checked/>
<label for='quick_private_notes'><%= l(:field_private_notes) %></label>
<% end %>

<button type='button' id='quick_notes_btn'><%= l(:button_submit) %></button>

</fieldset>
</div>
<% end %>

<div id='operation_failed_message' title='<%= l(:operation_failed) %>' style='display:none'>
  <p>
    <%= l(:operation_failed_try_again_after_reloading) %>
  </p>
</div>

<div id='unauthorized_message' title='<%= l(:unauthorized) %>' style='display:none'>
  <p>
    <%= l(:unauthorized_logout_login) %>
  </p>
</div>

<% content_for :header_tags do %>
  <%= tag :meta, name: :page_specific_js, channel_name: 'issue:' + @issue.id.to_s %>

  <%= javascript_include_tag(:action_cable, :plugin => 'redmine_rt') %>
  <%= javascript_include_tag(:cable, :plugin => 'redmine_rt') %>

  <%= javascript_include_tag('channels/issue_channel.js', :plugin => 'redmine_rt') %>

<% end %>

"""
end

end
