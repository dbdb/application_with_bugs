require "rubygems"
require "sinatra"
require "prawn"
require 'data_mapper'
require_relative "model"

use Rack::Session::Cookie, :secret => "83%"

helpers do
	def show_flash
		return unless (message = session[:flash])
		session[:flash] = false
		"<p>#{message}</p>"
	end
end

get "/home/?" do
	@types = Type.all
	erb :home
end

post "/generate" do
	pdfgen = Generator.new
	u = User.create(:full_name => params[:full_name], :nick => params[:nick], :type => params[:type])
	conf = Conference.new params[:conf_name], params[:conf_location]
	
	filename = pdfgen.generate(u, conf)
	session[:flash] = "Generated doc <a href='#{filename}'>#{filename}</a>"
	u.update(:pdf_doc => filename)
	
	redirect "/home"
end

get "/log/?" do
	@users = User.all
	erb :log
end

get "/clear/?" do
	User.destroy
	session[:flash] = "Log was cleared"
	redirect "/home"
end

get "/new_type/?" do
	@types = Type.all
	erb :new_type
end

post "/types/?" do
	Type.create(:name => params[:name])
	session[:flash] = params[:name] + " was added to types"
	redirect "/home"
end

__END__

@@ home
<p><a href="/log">View log</a></p>

<form action="/generate" name="user" method="post">
<table>
	<tr><td>Conf Name: </td><td><input type="text" name="conf_name" value="Free Food Conf 2014" /></td></tr>
	<tr><td>Location: </td><td><input type="text" name="conf_location" value="USA, New York" /></td></tr>
	
	<tr><td>Full Name*: </td><td><input type="text" name="full_name" value="Dr. Cucumber Green" /></td></tr>
	<tr><td>Nickname: </td><td><input type="text" name="nick" /></td></tr>
	<tr>
		<td>Type: </td>
		<td>
			<select name="type">
				<% @types.each do |t| %>
					<%= "<option>#{t.name}</option>" %>
				<% end %>
			</select>
			<a href="/new_type">add type</a>
		</td>
	</tr>
	<tr>
		<td><input type="submit" /></td>
		<td><input type="reset" /></td>
	</tr>
</table>
</form>

<script>
	function verify(e){
		if(e.target.full_name.value.length == 0){
			alert("Full name should not be blank!");
			e.preventDefault();
		}
	}

	document.user.addEventListener("submit", verify, false);
</script>

<%=  show_flash %>

@@ log
<a href="/home">Back</a> <br />

<% @users.each do |user| %>
	<%= [user.full_name, user.nick, user.type].join(', ') %> <%=  "<a href=\"#{user.pdf_doc}\">#{user.pdf_doc}</a>" %> <br />
<% end %>

<a href="/clear">Clear log</a>

@@ new_type
<a href="/home">Back</a> <br />

<form action="/types" method="post">
	<input type="text" name="name" /><input type="submit" />
</form>

<% @types.each do |t| %>
	<%= t.name + "<br />" %>
<% end %>

