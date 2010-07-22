# 2010-07-21 | Find Root

How can we reliably identify the root directory of a Ruby project?
This is an important need and yet has gone unatteneded.

The issue has been largely circumvented by the use of Rake, since a Rakefile
resides in the project's root and it is build task that primarily need to locate
the root directory. However there are tools that lie outside of use via Rake,
and attempting ot make the Rakefile more general requirement also leaves users
of alternate build tools in the cold.

It has been suggested to me that searching for a `lib/` directory is the
best choice. And it is a nice idea in that project maintainers would not
have to do anything to support the specification since the `lib/` directory
is already a standard, having been derived from setup.rb. However, as
remarkable as it may seem there are a few Ruby projects out there that do not
use a `lib/` directory. Since the loadpath can be adjusted in a gemspec, it is
certainly not necessary to do so. We could require it's existance as part of
the POM specification, but I believe allowing a modifiable loadpath yet
requiring a `lib/` directory are antithetical to one another.

A more obvious, and rather generic choice, would be the use of special SCM
directories. Directory like .git, .hg, _darcs, and so on, are dead-giveaways
as to the location of the project's root fodler. But here again we run into
off cases. Some persons may use an uncommon SCM or none at all. Worse still,
Subverison can't be include here becuase it puts `.svn/` in _every_ project
directory.

Another option is the +.gemspec+ file. This is a farily good option in that
it clearly marks the project as a Ruby project, but many tools generate a
Gem::Specification on demand and thus have no need of a perminanely present
.gempec file (despite what some have urged). Moreover, it undermines the 
purpose of POM which is a more complete and resuable design for storing much
of the same information.

Similarly some may suggest the Gemfile as a marker, being rapidly
popularized by Bundler. And this I think would be a better notion, however
I have some issues with the Gemfile. Primarily I do not think it is wise
to make a configuration file an executable Ruby script. By doing so it is no
long declartive in nature. If condistions are especially unacceptable. 
This is what led me to create the alteranate REQUIRE file.

If none of these pre-existing options are full satisfactory, where does this
leave us? We could define a specific marker just for the purpose. However if
we are going to define a file or a directory to act as marker, clearly the
file of directory also should be of some use beyond being a mere marker.
Having an empty file or directory for the purpose would be silly.

One possibility is POM's PACKAGE file. This is the one essential file the POM
specification designates. And it will almost assuredly work in every case.
Except, since the name is so generic, there remains the small chance of a
conflict. This is a difficulty I ran into when I originally wented to use
the name "VERSION" instead of "PACKAGE". I realized that too many other
projects were already using a VERSION file in incompatiable ways (even I 
had done so in the past), in particular any project using Mr. Bones or Jeweler.
But this is very minor point, and if it were really an issue a more esoteric
name, like `PKGFILE`, would suffice. The larger concern is that the name lacks
any sort of "This is a Ruby" quality. In this respect, we must acknowledge
a a trade-off. On the one hand it would be nice for POM to define a fully
generic specification, so that POM might be useful to other project types
as well --not just Ruby projects. On the other hand, it would also be nice to
readily see that a project is a Ruby project. I am torn between the two choices,
though I suppose I must favor the later simply because there is a greater
tendency to stick to one's langauge of choice than to cross tools 
Java and C are the only two exception that I know of where it is not
uncommon to do so). So perhaps the solution then is simply to rename the
`PACKAGE` file to something a little more Ruby-esque? Something like `RUBYPKG`,
`RUBY.pkg` or `RUBY.spec` and use that as the marker.

The final alterantive is to use something more akin to the original POM .meta/
directory. This was a good indicator in itself. Though again it lacks the "Ruby"
quality. So perhaps it can be called `.ruby/` instead? I very much like this in
that is has an appreciable quality, in much the same way "Gemfile" does. On
the other hand, the more generic approach would be to use somthing like
`.meta/`, `.project/` or `.pom/` but have `ruby` file within it, e.g.
`.project/ruby`. Thus achivieving a generic design but also clearly
indicating a Ruby project at the same time. The trouble with the `.ruby/` or
`.pom/ruby` however is what else do we put in the directory? Do we move 
`PACKAGE`, `REQUIRE` and/or `PROFILE` into it? Do we really want to hide these
files away under a hidden directory when they offer so much useful general
purpose information about a project? The placing of these files into the
directory could be optional but git will not track an empty directory, so
something has to go in it. On the plus side, other tools could use the location
as well. Currently Setup.rb uses a `.setup/` directory to house install hooks
and other optional files. Potentially it could use the `.ruby/` directory
instead. In other words the directory has more room for growth where as using
a file is more limited.


