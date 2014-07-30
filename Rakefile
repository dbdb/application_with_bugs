require "rubygems"
require "dm-migrations"
require_relative "model"

namespace :db do
	desc "Create the database"
	task :migrate do
		DataMapper.auto_migrate!
		
		["Participant", "Guest-Speaker", "Admin Staff"].each {|t| Type.create(:name => t)}
		
	end
end