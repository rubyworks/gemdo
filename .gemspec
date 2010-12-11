--- !ruby/object:Gem::Specification 
name: pom
version: !ruby/object:Gem::Version 
  hash: 23
  prerelease: false
  segments: 
  - 1
  - 0
  - 0
  version: 1.0.0
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2010-12-10 00:00:00 -05:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: facets
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 19
        segments: 
        - 2
        - 8
        version: "2.8"
  type: :runtime
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: syckle
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id002
- !ruby/object:Gem::Dependency 
  name: ko
  prerelease: false
  requirement: &id003 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id003
- !ruby/object:Gem::Dependency 
  name: qed
  prerelease: false
  requirement: &id004 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 7
        segments: 
        - 2
        - 2
        version: "2.2"
  type: :development
  version_requirements: *id004
description: POM provides a complete project layout standard and metadata system for Ruby developers.
email: transfire@gmail.com
executables: 
- pom
extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- qed/01_api/history.rdoc
- qed/01_api/metadata.rdoc
- qed/01_api/news.rdoc
- qed/01_api/project.rdoc
- qed/01_api/readme.rdoc
- qed/01_api/requires.rdoc
- qed/01_api/resources.rdoc
- qed/02_cli/bump.rdoc
- qed/02_cli/init.rdoc
- qed/applique/ae.rb
- qed/applique/fixtures.rb
- test/news.rb
- test/version.rb
- README.rdoc
has_rdoc: true
homepage: http://rubyworks.github.com/pom
licenses: 
- ""
post_install_message: 
rdoc_options: 
- --title
- POM API
- --main
- README.rdoc
require_paths: []

required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: pom
rubygems_version: 1.3.7
signing_key: 
specification_version: 3
summary: Ruby Project Object Model
test_files: []

