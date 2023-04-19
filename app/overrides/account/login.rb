module Account::Login
Deface::Override.new(:virtual_path => 'account/login',
                     :name => "force autologin checkbox to checked=true",
                     :insert_after => "erb[loud]:contains('call_hook :view_account_login_bottom')") do
"""
<%= javascript_tag \"$('#autologin').prop('checked', true);\" %>
"""
end
end
