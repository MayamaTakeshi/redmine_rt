Deface::Override.new(:virtual_path => 'issues/show',
                     :name => "add quick notes",
                     :insert_before => "erb[silent]:contains('if @journals.present?')") do
"""
<% if @issue.notes_addable? %>
<fieldset><legend><%= l(:field_notes) %></legend>
<textarea cols='60' rows='3' class='wiki-edit' name='quick_notes_ta' id='quick_notes_ta'></textarea>

<% if @issue.safe_attribute? 'private_notes' %>
<input type='checkbox' value='1' name='quick_notes_private_cbox' id='quick_notes_private_cbox' />
<label for='quick_private_notes'><%= l(:field_private_notes) %></label>
<% end %>

<button type='button' id='quick_notes_btn'><%= l(:button_submit) %></button>

</fieldset>
<% end %>
"""
end


Deface::Override.new(:virtual_path => 'issues/show',
                     :name => "force history always",
                     :replace => "erb[silent]:contains('if @journals.present?')",
                     :closing_selector => "erb[silent]:contains('end')") do
"""<div id='history' data-comment_sorting='<%= User.current.wants_comments_in_reverse_order? ? 'asc' : 'desc' %>'>
<h3><%=l(:label_history)%></h3>
<% if @journals.present? %>
<%= render :partial => 'history', :locals => { :issue => @issue, :journals => @journals } %>
<% end %>
</div>"""
end
