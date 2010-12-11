require 'pom/version'  #covers 'pom/version'

KO.case "POM::VersionNumber" do

  #unit Rock::VersionNumber, :bump

  test "bump major number" do
    v = POM::VersionNumber[1,0,0]
    v.bump(:major).to_s == '2.0.0'
  end

  test "bump minor number" do
    v = POM::VersionNumber[1,0,0]
    v.bump(:minor).to_s == '1.1.0'
  end

  test "bump patch number" do
    v = POM::VersionNumber[1,0,0]
    v.bump(:patch).to_s == '1.0.1'
  end

  test "bump build number" do
    v = POM::VersionNumber[1,0,0,0]
    v.bump(:build).to_s == '1.0.0.1'
  end

  test "bump build number with state" do
    v = POM::VersionNumber[1,0,0,'pre',1]
    v.bump(:build).to_s == '1.0.0.pre.2'
  end

  test "bump state segment" do
    v = POM::VersionNumber[1,0,0,'pre',2]
    v.bump(:state).to_s == '1.0.0.rc.1'
  end

  #unit Rock::VersionNumber, :restate

  test "reset state" do
    v = POM::VersionNumber[1,0,0,'pre',2]
    v.restate(:beta).to_s == '1.0.0.beta.1' 
  end

end

