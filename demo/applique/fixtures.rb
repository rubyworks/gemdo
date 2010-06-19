FIXTURE_DIR = 'tmp/example/'

When 'iven a ((([\.\w]+))) project file' do |name, text|
  FileUtils.mkdir_p(FIXTURE_DIR)
  File.open(FIXTURE_DIR + name, 'w') do |f|
    f << text
  end
end

# Remove the example project if it exists.
Before :document do
  FileUtils.rm_r(FIXTURE_DIR) if File.exist?(FIXTURE_DIR)
end

