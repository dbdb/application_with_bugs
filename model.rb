DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/data.db")

class User
	include DataMapper::Resource
	
	property  :id, Serial
	property  :full_name, String
	property  :nick, String
	property  :type, String
	property  :pdf_doc, String
end

class Type
	include DataMapper::Resource
	property  :id, Serial
	property  :name, String
end

DataMapper.finalize

class Conference
	attr_accessor :name, :place
	
	def initialize name, place
		@name, @place = name, place
	end
end

class Generator
	def initialize(page_layout = :landscape, page_size = 'A8', margin = 10, big_font = 14, small_font = 10, step_down = 18, docs_dir='public' )
		@page_layout = page_layout
		@page_size = page_size
		@margin = margin
		@big_font = big_font
		@small_font = small_font
		@step_down = step_down
		@docs_dir = docs_dir
	end
	
	def file_name user
		# not uniq names, special chars, cyrillic
		user.full_name.gsub(' ', '_').downcase + '.pdf'
	end
	
	def generate user, conf
		doc_name = file_name(user)
		
		Prawn::Document.generate(@docs_dir + "/" + doc_name, :page_layout => @page_layout, :page_size => @page_size, :margin => @margin) do |doc|
			doc.text conf.name, :size => @small_font, :align => :center
			doc.text conf.place, :size => @small_font, :align => :center
			doc.move_down @step_down
			
			doc.text user.full_name, :size => @big_font, :align => :center
			doc.text user.nick, :size => @big_font, :align => :center
			doc.move_down @step_down
			
			doc.text user.type, :size => @small_font, :align => :center
		end
		doc_name
	end
end
