FIXTURE_DIR = 'qed/fixtures/'

When 'iven a (((\w+))) project file' do |name, text|
  File.open(FIXTURE_DIR + name, 'w') do |f|
    f << text
  end
end

After :document do
  Dir[FIXTURE_DIR + '**/*'].each do |file|
    FileUtils.rm_r(file) if File.exist?(file)
  end
end

