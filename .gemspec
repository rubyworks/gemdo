--- !ruby/object:Gem::Specification 
name: ""
version: !ruby/object:Gem::Version 
  hash: 23
  prerelease: 
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

date: 2011-04-23 00:00:00 Z
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
- bin/pom
- lib/pom/command.rb
- lib/pom/commands/about.rb
- lib/pom/commands/bump.rb
- lib/pom/commands/gemspec.rb
- lib/pom/commands/init.rb
- lib/pom/commands/news.rb
- lib/pom/commands/resolve.rb
- lib/pom/commands/show.rb
- lib/pom/commands/spec.rb
- lib/pom/core_ext/pathname.rb
- lib/pom/core_ext/to_list.rb
- lib/pom/core_ext/try_dup.rb
- lib/pom/core_ext.rb
- lib/pom/errors.rb
- lib/pom/gemspec.rb
- lib/pom/history.rb
- lib/pom/manifest.rb
- lib/pom/news.rb
- lib/pom/profile/inference.rb
- lib/pom/profile/properties.rb
- lib/pom/profile/template.erb
- lib/pom/profile.rb
- lib/pom/project/files.rb
- lib/pom/project/paths.rb
- lib/pom/project/utils.rb
- lib/pom/project.rb
- lib/pom/property.rb
- lib/pom/readme.rb
- lib/pom/requires.rb
- lib/pom/resolver/gemcutter.rb
- lib/pom/resolver/rubygems.rb
- lib/pom/resolver/source.rb
- lib/pom/resolver.rb
- lib/pom/resources.rb
- lib/pom/version.rb
- lib/pom.rb
- lib/pom.yml
- qed/01_api/applique/pom.rb
- qed/01_api/history.rdoc
- qed/01_api/news.rdoc
- qed/01_api/profile.rdoc
- qed/01_api/project.rdoc
- qed/01_api/readme.rdoc
- qed/01_api/resources.rdoc
- qed/02_cli/bump.rdoc
- qed/02_cli/init.rdoc
- qed/applique/ae.rb
- qed/applique/fixtures.rb
- qed/profile.rdoc
- test/news.rb
- test/version.rb
- Rakefile
- README.rdoc
- Notes.rdoc
- History.rdoc
- License.txt
homepage: http://rubyworks.github.com/pom
licenses: []

post_install_message: 
rdoc_options: 
- --title
- POM API
- --main
- README.rdoc
require_paths: 
- lib
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

rubyforge_project: ""
rubygems_version: 1.7.2
signing_key: 
specification_version: 3
summary: Ruby Project Object Model
test_files: []

