require 'rawr'
task :default => :test
task :test do
  Dir.glob('./test/*_test.rb').each { |f| require f }
end

task :console do
  require_relative 'pigeon'
  require 'pry'; binding.pry
end
