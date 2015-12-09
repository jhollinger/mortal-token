require 'rake/testtask'
require 'benchmark'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

desc "Benchmark"
task :bm, [:n, :message] => :load do |t, args|
  n = args[:n].to_i
  puts Benchmark.measure {
    n.times do
      token = MortalToken.create 60*60, args[:message]
      token_str = token.to_s
      recovered_token, digest = MortalToken.recover token_str
      recovered_token == digest
    end
  }
end

task :load do
  $LOAD_PATH.unshift File.dirname(__FILE__) + '/lib/'
  require 'mortal-token'
  MortalToken.secret = SecureRandom.hex 8
end
