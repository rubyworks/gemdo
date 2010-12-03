# 2010-07-21 | Find Root

How can we reliably identify the root directory of a Ruby project?
This is an important need that as of yet has gone unatteneded.

In general practice the issue has been largely circumvented by the use of Rake,
since a Rakefile resides in the project's root and it is build tasks that
primarily need to operate out of a project's root. However there are tools that
lie outside of use via Rake, and attempting ot make the Rakefile a more general
requirement also leaves users of alternate build tools in the cold.

It has been suggested that searching for a `lib/` directory is the
best choice. And it is a good idea in that project maintainers would not
have to do anything to support the specification since the `lib/` directory
is already a standard, having been derived from setup.rb. However, as
remarkable as it may seem there are a few Ruby projects in the wild that do not
use a `lib/` directory. Since the loadpath can be adjusted in a gemspec, it is
certainly not necessary. While the Ruby POM specification could require it to
compensate, allowing a modifiable loadpath and requiring a `lib/` directory
are pretty antithetical. It is also not guarenteed that a developer 
will not want to create a lib/ directory somewhere below root.

A more obvious, and rather generic choice, would be the use of special SCM
directories. Directory like `.git`, `.hg`, `_darcs`, and so on, are dead-giveaways
as to the location of the project's root fodler. But here again we run into
off cases. Some persons may use an uncommon SCM or none at all. Worse still,
Subverison can't be include here becuase it puts `.svn/` in _every_ project
directory.

Another option is the `.gemspec` file. This is a farily good option in that
it clearly marks the project as a Ruby project, but many tools generate a
Gem::Specification on demand and thus have no need of a perminantly present
.gempec file (despite what some have urged). Moreover, it is not a DRY
solution since the purpose of POM metadata is a to provide a more complete
and resuable design for storing much of the same information.

Similarly some may suggest the `Gemfile` as a marker, being rapidly
popularized by Bundler. And this I think would be a better notion, however
I have some issues with the Gemfile. Primarily I do not think it is wise
to make a configuration file an executable Ruby script. By doing so, it is no
long declartive in nature. If-conditions are especially unacceptable. 
Indeed this is the very thing that led to the creation of POM's alternativee,
`requires`.

If none of these pre-existing options are fully satisfactory, where does this
leave us? We could define a specific marker just for the purpose. However if
we are going to define a file or a directory to act as marker, clearly the
file of directory should also be of some use beyond being a mere marker.
Having an empty file or directory for the purpose seems rather silly.

One possibility is the `PACKAGE` file. This is the one essential file the
specification designates. Using this file as the marker will almost assuredly
work in every case. However it has a fatal flaw --using would also essentially
entail that one were using the POM. Now clearly I want people to use POM,
but I also don't necessarily want to discourage others from using a viable
standard for reliably identifying the root directory of a Ruby project even if
they do not wish to do so. In addition the name lacks any sort of "this-is-ruby"
quality, which would also be nice to have (IMO).

The final alterantive is to use something more akin to the original POM `.meta/`
directory. This was a good indicator of root in itself. Though again it lacks
the "Ruby" quality and assumes the use of POM. Perhaps it can be called `.ruby/`
instead. I very much like this in that is has an appreciable quality, in much
the same way "Gemfile" does. On the other hand, the more generic approach would
be to use somthing like `.meta/` or `.project/` but have a `ruby` file within
it, e.g. `.project/ruby`. Thus achivieving a generic design but also clearly
indicating a Ruby project at the same time. The trouble with the directory
is what else do we put in the directory? Do we move `PACKAGE`, `PROFILE` and
other into it? Do we really want to hide these files away under a hidden
directory when they offer so much useful general purpose information about
a project? The placing of these files into the directory could be optional but
remember that git will not track an empty directory, so something has to go in
it. On the plus side, other tools could use the location as well. Currently
Setup.rb uses a `.setup/` directory to house install hooks and other optional
files. Potentially it could use the `.ruby/` directory instead. In other words
the directory has more room for growth, where as using a file as a marker is
more limited.

I haven't come to a clear solution yet, but at least the options are narrowing.

