require 'benchmark'

def load_yaml
  YAML.load(File.new("example.yaml"))
end

def load_files
  data = {}
  data['name']     = File.read('example/name')
  data['version']  = File.read('example/version')
  data['loadpath'] = File.read('example/loadpath').strip.split(/\n/)
  data
end

count = 10000

puts
puts "YAML:"

Benchmark.bm(25) do |x|
  x.report("  Require YAML:          "){ require 'yaml' }
end

Benchmark.bm(25) do |x|
  x.report("  YAML:          "){ count.times{ load_yaml } }
end

puts
puts "Files:"

Benchmark.bm(25) do |x|
  x.report("  Files:          "){ count.times{ load_files } }
end

