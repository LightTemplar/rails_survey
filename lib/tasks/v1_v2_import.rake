desc 'Import from CSV file'
task :v1_v2_import, [:filename] => :environment do |_t, args|
  CSV.foreach(args[:filename], headers: true) do |row|

  end
end
