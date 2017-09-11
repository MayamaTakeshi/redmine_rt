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
