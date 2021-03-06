# GemDo

(c) 2009 Rubyworks (BSD-2-Clause License)

[Homepage](http://rubyworks.github.com/gemdo) /
[Source Code](http://github.com/rubyworks/gemdo)


GemDo defines a standard Ruby Project Object Model (GemDo), encompassing a 
standard project layout, project files and thier formats. The standard is
specified via an implementation in Ruby, suited for use by Ruby projects
tools. GemDo supports the most common practices of the Ruby community at large.
But also defines some new practices to shore up weaker points or altogether
missing features.


## WHY?

Consider the state of Ruby project standards today. While a number of well
aheared practices have evolved over the years, largely due to specifications 
of the orginal _setup.rb_, still other common project needs remain chaotic and
confusing. The storage of the a project's current <i>version number</i> is a 
painfully obvious example. The data is required in a project's .gemspec, and
common practice dictates that is should also be in our library code as a
constant; if we use Rakegem[http://rakegem.github.org] that constanct should be
in lib/foo.rb, but if we are using Bundler[http://bundler.org] it is expected
in lib/foo/version.rb. If we use Bones[http://twp.github.com/bones] to help us
manage our project, the verison number is stored in a VERSION file as a string,
but if we use Jeweler[http://] the same file may be a YAML-formated hash. All
of this just for one piece of metadata and a small smatter of available tools!


## SYNOPSIS

Primarily GemDo defines a standard set of project layout and design patterns.
Most of these derive for setup.rb, the original Ruby project installer,
as well as common patterns widely used among the Ruby community.

The specification designates particular files and their uses, most fo which
are obvious, such as a `README` or a `MANIFEST`. Others are new introduced
by GemDo such as the `.ruby` and `Profile` files.

This entire specification is implemeted in Ruby code, known as the "GemDo"
(Project Object Model). Primary usage of this model relies on the
Project class, instantiated by passing the constructor the root directory
of the project.

    project = GemDo::Project.new(root_directory)

The project object then ties into all the available metadata, e.g.

    project.name
    project.version
    project.homepage

    etc...

GemDo also provides a command line tool with some useful project utilities.
For example, it can be used to easily bump a project's version number.

    $ gemdo bump --patch

See the Wiki[http://wiki.github.com/rubyworks/gemdo] and
API[http://rubyworks.github.com/gemdo/rdoc] documentation for further
details.


## DEVELOPMENT

### Source Code Management

GemDo uses git and hosts it's project repositories with GitHub at
http://github.com/rubyworks/gemdo.


### Mailing List

You can subscribe to the RubyWorks mailing list by sending a message to
this mailing address[mailto:rubyworks-mailinglist+subscribe@googlegroups.com],
or visit http://groups.google.com/group/rubyworks-mailinglist.


## HOW TO INSTALL

To install with RubyGems simply open a console and type:

  $ sudo gem install gemdo

Site installation requires Setup.rb (gem install setup),
then download the tarball package and type:

  $ tar -xvzf gemdo-1.0.0.tar.gz
  $ cd gemdo-1.0.0.tar.gz
  $ sudo setup.rb all

Windows users use 'ruby setup.rb all'.


## COPYRIGHT & LICENSE

GemDo Copyright (c) 2009 Thomas Sawyer

Made available according to the terms of the BSD 2-Clause License.

See COPYING.rdoc file for details.
