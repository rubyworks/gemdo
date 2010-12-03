--- !ruby/object:Gem::Specification 
name: gemdo
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

date: 2010-12-03 00:00:00 -05:00
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
description: Gemdo provides a complete project layout standard and metadata system for Ruby developers.
email: transfire@gmail.com
executables: 
- gemdo
extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- bin/gemdo
- lib/gemdo/command.rb
- lib/gemdo/commands/about.rb
- lib/gemdo/commands/bump.rb
- lib/gemdo/commands/dump.rb
- lib/gemdo/commands/gemspec.rb
- lib/gemdo/commands/news.rb
- lib/gemdo/commands/rubyspec.rb
- lib/gemdo/commands/show.rb
- lib/gemdo/commands/verify.rb
- lib/gemdo/core_ext/pathname.rb
- lib/gemdo/core_ext/to_list.rb
- lib/gemdo/core_ext/try_dup.rb
- lib/gemdo/core_ext.rb
- lib/gemdo/deprecate/metadir.rb
- lib/gemdo/deprecate/metastore.rb
- lib/gemdo/dotruby.rb
- lib/gemdo/errors.rb
- lib/gemdo/gemspec.rb
- lib/gemdo/history.rb
- lib/gemdo/manifest.rb
- lib/gemdo/metadata.rb
- lib/gemdo/metafile.rb
- lib/gemdo/news.rb
- lib/gemdo/package.rb
- lib/gemdo/profile.rb
- lib/gemdo/project.rb
- lib/gemdo/readme.rb
- lib/gemdo/requires.rb
- lib/gemdo/resolver.rb
- lib/gemdo/resources.rb
- lib/gemdo/root.rb
- lib/gemdo/rubyfile.rb
- lib/gemdo/rubyspec.rb
- lib/gemdo/version.rb
- lib/gemdo.rb
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
- HISTORY.rdoc
- PROFILE
- Rubyfile
- PACKAGE
- LICENSE
- README.rdoc
- NOTES.rdoc
has_rdoc: true
homepage: http://proutils.github.com/gemdo
licenses: 
- Apache 2.0
post_install_message: 
rdoc_options: 
- --title
- Gemdo API
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

rubyforge_project: gemdo
rubygems_version: 1.3.7
signing_key: 
specification_version: 3
summary: Ruby Project Object Model
test_files: []

