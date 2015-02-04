

namespace :training_data do
  desc "Loads training data from command line"
  task :load, [:file_to_load] => :environment do |t, args|
    if File.readable?(args[:file_to_load])
      DataImporter.new(args[:file_to_load]).import! 
    else
      puts "Cannot Open File '#{args[:file_to_load]}'"
    end
  end
end
