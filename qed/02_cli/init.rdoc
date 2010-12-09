= Generate POM Metadata with +init+ Command

== Extracted from a README file

Given a README project file containing ...

    = MyApp

    * http://some.org

    == DESCRIPTION

    This is a description of the
    fake project.

    = INSTALL

    To install use RubyGems

      $ gem install myapp

    = LICENSE

    (GPL)

    Copyright 2009 Thomas Sawyer

We can generate metadata from the README using the +init+ command.

    `cd tmp/example; pom init README`

Now lets verify the metadata was extracted as expected.

    require 'pom/project'

    project = POM::Project.new('tmp/example')

The values should have been picked up from PACKAGE and PROFILE files.

    project.metadata.title.assert       == "MyApp"
    project.metadata.description.assert == "This is a description of the\nfake project."
    project.metadata.license.assert     == "GPL"

== Extracted from a Gemspec

Given an empty project directory and given a myapp.gemspec
project file containing ...

    Gem::Specification.new do |s|
      s.name = %q{myapp}
      s.version = "1.0.0"
      s.authors = ["Tom Sawyer"]
      s.date = %q{2010-10-10}
      s.description = %q{This is a description of a fake project.}
      s.email = %q{transfire@gmail.com}
    end

We can generate metadata from the gem specification using the pom command.

    `cd tmp/example; pom init myapp.gemspec`

Now lets verify the metadata was extracted as expected.

    require 'pom/project'

    project = POM::Project.new('tmp/example')

The values should have been picked up from PACKAGE and PROFILE files.

    project.metadata.title.assert        == "Myapp"
    project.metadata.version.to_s.assert == "1.0.0"
    project.metadata.description.assert  == "This is a description of a fake project."

