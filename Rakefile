task :default => :test
task :test do
  Dir.glob('./test/*_test.rb').each { |f| require f }
end
