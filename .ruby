--- 
name: pom
repositories: 
  public: git://github.com/rubyworks/pom.git
title: POM
contact: Thomas Sawyer <transfire@gmail.com>
resources: 
  forum: http://groups.google.com/group/rubyworks-mailinglist
  api: http://rubyworks.github.com/pom/rdoc
  mail: http://groups.google.com/group/rubyworks-mailinglist
  docs: http://wiki.github.com/rubyworks/pom
  wiki: http://wiki.github.com/rubyworks/pom
  home: http://rubyworks.github.com/pom
  work: http://github.com/rubyworks/pom
requires: 
- group: []

  name: facets
  version: 2.8+
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: ko
  version: 0+
- group: 
  - test
  name: qed
  version: 2.2+
manifest: 
- .rubyspec
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
- PACKAGE
- LICENSE
- README.rdoc
- NOTES.rdoc
version: 1.0.0
licenses: 
- Apache 2.0
copyright: Copyright (c) 2009 Thomas Sawyer
organization: RubyWorks
description: POM provides a complete project layout standard and metadata system for Ruby developers.
summary: Ruby Project Object Model
authors: 
- Thomas Sawyer
created: 2009-07-22
