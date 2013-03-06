require 'fileutils'

FIXTURE_DIR = File.join(File.dirname(__FILE__), '..', 'fixtures')
PROJECT_DIR = 'example'

# Remove the example project if it exists.
Before :demo do
  FileUtils.rm_r(PROJECT_DIR) if File.exist?(PROJECT_DIR)
  FileUtils.cp_r(File.join(FIXTURE_DIR, 'empty'), PROJECT_DIR)
end

When 'iven a new project' do
  FileUtils.rm_r(PROJECT_DIR) if File.exist?(PROJECT_DIR)
  FileUtils.cp_r(File.join(FIXTURE_DIR, 'empty'), PROJECT_DIR)
  @_current = :empty
end

When 'iven a complete project example' do |name|
  if @_current != :complete
    FileUtils.rm_r(PROJECT_DIR) if File.exist?(PROJECT_DIR)
    FileUtils.cp_r(File.join(FIXTURE_DIR, 'complete'), PROJECT_DIR)
    @_current = :complete
  end
end

When 'iven a ((([\.\w]+))) project file' do |name, text|
  File.open(File.join(PROJECT_DIR, name), 'w') do |f|
    f << text
  end
end

When 'no ((([\.\w]+))) file in a project' do |name|
  FileUtils.rm(File.join(PROJECT_DIR, name))
end

