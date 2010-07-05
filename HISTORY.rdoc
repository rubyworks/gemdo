= RELEASE HISTORY

== 2.1.2 / 2010-01-20

Add new 'pom news' command to show current release
notes --useful for tagging! (NOTE: I thought this was
in the last release but it never made it into the MANIFEST.)

Changes:

* Add pom news command to show current release notes.


== 2.1.1 / 2010-10-19

Bump command can now take state or slot as an argument.
In other words, 'pom bump major' will work exactly like
using 'pom bump --major'. Als added new 'pom news' command
to show current release notes (usefule for tagging!). And
last but not least History and News class are now much
more robust.

Changes:

* More robust History and News classes.
* Bump command is more versitile.


== 2.1.0 / 2010-10-18

The significant change with v2.1 is the use of a PACKAGE
file to provide essential information needed by package and
library managers and other tools, including name, version
and loadpath. The file can still be called VERSION if prefered.
PACKAGE was chosen as a default to prevent potential clashes
with other tools use of VERSION (and becuase it is a fitting
description). Again review the POM wiki to learn more.

Changes:

* PACKAGE file is the default name of what was VERSION file.
* Multi-format support for PACKAGE/VERSION file.
* Renamed 'ver' subcommand to 'bump'.


== 2.0.0 / 2010-06-06

Version 2.0 marks a major turning point for POM --it is offically
ready for mass consumption! What separates this version from
previous versions is the adoption of YAML-based metadata files,
over the previous meta directory-based config system. Be sure
to checkout the Wiki to learn more.

Changes:

* Swtich to YAML-based metadata files.
* Announcement generator is much imropved.
* Removed Build class (it was a dumb idea).


== 1.8.0 / 2010-04-30

This release refines the API a bit and adds a few additional niceities.

Changes:

* Add Project#name and #version as shortcuts to metadata.
* README parser is much improved (could still use more though).
* Filestore can be only be one directory (meta/ or .meta/, not both)
* Add Build class for development metadata stored in .build/.
* Simplifed root lookup code.


== 1.7.0 / 2010-02-06

This release introduced Metadata extensions, which can be defined
to augment the primary metadata via a meta/ subdirectory. Currently
only a RubyForge extension is built-in. Also, the +Metabuild+ class
introduced in the last version has been deprecated --it may be
replaced by a Metadata extension in the furture, but for now it has
been determined that it is not a vital need. In addition a new
+maintianer+ field has been added to complement the +contact+ 
field. Finally this release fixes a major bug that prevented certain
metadata fields from being accessed properly.

Changes:

* New Metadata extension system.
* Deprecated Metabuild class.
* Add maintainer field to Metadata.
* Fix special reader bug.


== 1.6.0 / 2009-12-07

This release introduce the Metabuild class, which is like the
Metadata class but supports general build configuration
information.

Changes:

* Added Metabuild class.


== 1.5.0 / 2009-11-14

Between version 1.1 and the current 1.5, a great deal of polish
has been applied to the project. There are no longer any metadata
aliases, save one (collection/suite). A new Release class provides
encapsualted access to the current release notes, either from
a standard file or from the top entry of the HISTORY file. And a
+pom+ command-line utility now provides a variety of POM releated
functions from printing out a project summary to generating meta
entries from a +README+ and/or +.gemspec+ file.

Changes:

* Added +pom+ command-line tool.
* Added new Release class to handle current release notes.
* Removed all metadata aliases (save one).
* Metadata is no longer lazy-loaded.
* Can generate meta entries from +README+ and/or +.gemspec+ file.
* Polished code, removing vestages of old code.
* Separated cli commands into separate classes.


== 1.1.0 / 2009-08-14

This release brings some nice improements to POM, in particular
the addition of the Project class and it's supporting classes
History and Manifest, which were taken and deprecated from Syckle.

Changes:

* Metadata is loaded passively as needed.
* Metadata fallback is parsed README.
* Project class has added, taken from Reap.


== 1.0.0 / 2009-07-22

This is the initial release of POM. POM is a "Project Object Model"
designed for Ruby projects.

Changes:

* Happy Birthday!

