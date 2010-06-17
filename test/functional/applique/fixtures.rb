FIXTURE_DIR = 'tmp/example/'

When 'iven a ((([\.\w]+))) project file' do |name, text|
  FileUtils.mkdir_p(FIXTURE_DIR)
  File.open(FIXTURE_DIR + name, 'w') do |f|
    f << text
  end
end

# TODO: remove the whole directory
#After :document do
#  Dir[FIXTURE_DIR + '**/*'].each do |file|
#    FileUtils.rm_r(file) if File.exist?(file)
#  end
#end

