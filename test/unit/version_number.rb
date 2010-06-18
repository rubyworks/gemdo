Covers 'pom/version_number'

TestCase POM::VersionNumber do

  Concern "Version Bumping"

  Unit :bump => 'major' do
    v = POM::VersionNumber[1,0,0]
    v.bump(:major).to_s.assert == '2.0.0'
  end

  Unit :bump => 'minor' do
    v = POM::VersionNumber[1,0,0]
    v.bump(:minor).to_s.assert == '1.1.0'
  end

  Unit :bump => 'patch' do
    v = POM::VersionNumber[1,0,0]
    v.bump(:patch).to_s.assert == '1.0.1'
  end

  Unit :bump => 'build' do
    v = POM::VersionNumber[1,0,0,0]
    v.bump(:build).to_s.assert == '1.0.0.1'
    v = POM::VersionNumber[1,0,0,'pre',1]
    v.bump(:build).to_s.assert == '1.0.0.pre.2'
  end

  Unit :bump => 'state' do
    v = POM::VersionNumber[1,0,0,'pre',2]
    v.bump(:state).to_s.assert == '1.0.0.rc.1'
  end

  Unit :restate do
    v = POM::VersionNumber[1,0,0,'pre',2]
    v.restate(:beta).to_s.assert == '1.0.0.beta.1' 
  end

end

