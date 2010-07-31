#covers 'rock/version'
require 'rock/version'

feature "Version Bumping" do

  #unit Rock::VersionNumber, :bump

  scenario "bump major number" do
    v = Rock::VersionNumber[1,0,0]
    v.bump(:major).to_s.assert == '2.0.0'
  end

  scenario "bump minor number" do
    v = Rock::VersionNumber[1,0,0]
    v.bump(:minor).to_s.assert == '1.1.0'
  end

  scenario "bump patch number" do
    v = Rock::VersionNumber[1,0,0]
    v.bump(:patch).to_s.assert == '1.0.1'
  end

  scenario "bump build number" do
    v = Rock::VersionNumber[1,0,0,0]
    v.bump(:build).to_s.assert == '1.0.0.1'
    v = Rock::VersionNumber[1,0,0,'pre',1]
    v.bump(:build).to_s.assert == '1.0.0.pre.2'
  end

  scenario "bump state segment" do
    v = Rock::VersionNumber[1,0,0,'pre',2]
    v.bump(:state).to_s.assert == '1.0.0.rc.1'
  end

  #unit Rock::VersionNumber, :restate

  scenario "reset state" do
    v = Rock::VersionNumber[1,0,0,'pre',2]
    v.restate(:beta).to_s.assert == '1.0.0.beta.1' 
  end

end

