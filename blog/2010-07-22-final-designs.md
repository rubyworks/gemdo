= 2010-07-22 | Final Designs

Over the years POM has evolved...

In that time many considerations have contributed to changes in design.
The most significant of which was the recent move from a directory
based config using the `.meta/` directory to the use of the YAML file-based
PROFILE, PACAKGE, and REQUIRE file. On the whole I am very happy with the
change. It's has proven even better than I had anticipated. Nonetheless
the change has opened up a couple of issues that the previous design 
better addressed.

One of these is the question of how to reliably determine the location
of a project's root directory. The `.meta/` directory worked quite well
in this regard, whereas the PACKAGE file (being the essential POM file)
is not quite as suited --the name is a bit too generic, the name can also
come in too many flavors (PACAKGE, Package, Package.yml, PACKAGE.ymal, etc.)
which makes it less efficient to detect and access, and worse still, it
effectively presupposes the use of POM to gain the benefit of a reliable
root marker.

I touched on the first and last of these in my previous blog entry. The second
bares further explination. It is, of course, easy enough for a file system
to do a file name search. Currently POM is littered with code like:

  Dir.glob('Package{,.yml,.yaml}', File::FNM_CASEFOLD)

Perhaps not as simple as we might like, but perfectly acceptable. If that were
the only naggle, I wouldn't think twice about it. But also consider a web
agent trying to gather information about projects. In this case
access to the file system is much more limited and would require a silly
brute force attempt on every capital and lowercase combination. The web agent
would be better off pulling down all the files and doing the above search, as
inefficent as that will be. The use of fixed names just makes things easier,
arguably a corollary of the "convention over configuration" meme.

Taking these factors into consideration, I have narrow the solutions for
addressing these last issues to three:

1. Rename the `PACKAGE` file to `Rubyfile`, merge in with REQUIRE, and use that as a root marker.
2. Use a `.ruby/` directory, where the metadata files can reside.
3. Use a `.meta/` or `.project/` directory where a `ruby` file resides and the metadata files can reside.

The first option still suffers from the same issue as "PACKAGE", in that it
presupposes the use of POM, though I do not think it as signifficant in this
case, because I think adding a file called "Rubyfile" to one's project
would be readily accepted by most Ruby developers. Of course, despite how
acceptable it may seem, it will still present a barrier. Further more it 
doesn't addresses the multiple naming issues as well as the other two
solutions --in particular the `PROFILE` file remains. For these reasons,
as much as I may be drawn to it, I have to rule out this possibility.

The later is probably the best approach, in that it is the most generic
but still allows us to easiy identify a ruby project. The `.meta/ruby` or
`.project/ruby` file could contain a list of Ruby engines that the project
has been tested against. On the other hand the use of .ruby readily identifies
a project as a Ruby project --one does not have to drill down into `.meta`
or `.project` to figure it out. Although both are hidden files anyway, so why
does it really matter?




