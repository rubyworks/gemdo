= Development Notes

== 2011-04-22 | Canonical File

Since I last wrote here I moved to an imporved design whereby a single
metadata file called `PROFILE`, and an optional `VERSION` file,
have taken the role of human editable project metadata, which are then
used to generate a canonical `.ruby` file. This has proven the right
approach, even though it requires an additional step of updating the
canonical file. This approach successfully focuses the design around
the canonical file and the others simply are a means for the developer
to "input" the necessay information. In other words, using PROFILE and
VERSION files are just one possible means of filling out the canoncial
file.

Both Bundler and RubyGems use the same basic approach. In the case of RubyGems
the canonical file is never seen, as it only exits in gem pakages. Bundler's
Gemfile on the other hand becomes Gemfile.lock. So in lies my current debate:
Should the Profile file be programmable like Gemfile? Or just another possible
YAML source that another file can optionally use (.e.g. `.pomrc`) to create
the canonical file? And what should this canoncical file be called?


== 2010-07-23 | Seeking Perfection

I realize my biggest problem it working out the various details of design for
a Ruby POM primarily stem from my over baring desire to achieve "perfection",
or at least some close semblance there-of. Though there is likely none to be
found. Which is why I continually toil over the various choices. At some point
a mere choice must be made between varying imperfect solutions. (Not to mention
the fact that I would really like to get this done and move on to other
projects!) Despite this I keep seeking. 

The reoccurring question of POM --indeed the main point of POM is to specifying
a file system based data structure for project information. There are probably
a million ways to sundown to do this, and I assure you I've traveled too many.
From a single unified YAML file to a fully directory-based one-file-per-field 
design, I have teased out their various advantages and disadvantages. My
conclusion is that the best solution lies somewhere between the extremes.
It is better to have small files, which allows greater atomicity in access, but
it is better to have files of multiple related information for quick access and
ease of editing. So for that last few months I have been attempting to ring out
the best compromise. This endeavor gave rise to the PACKAGE, PROFILE and
REQUIRE files. I thought I had finally reach the best choice, but, as is often
the case in exploring new avenues, there remains some issues.

1. Having deprecated the use of a `.meta/` directory. There is no good way
to reliably ascertain the project's root directory.
2. There is nothing in particular that clearly indicates that the project
is a Ruby project.
3. Too many name variations (PACKAGE, Package.yaml, ...).

The remaining possibilities fall into two groups. Using a sub-directory
vs. using toplevel files. Of these, there three significant designs.

The simplest solution relative to what POM has now, would be to simply add
a file to identify the project as Ruby, using it as a marker be able
to detect the root directory. To give the file contents some use it could
contain a list of the versions of Ruby the project has been tested against.

      .ruby
      PACKAGE
      PROFILE
      REQUIRE

One downside to this approach it that it tends to further clutter up
the root directory, where the README is really the most important file.
To remedy we might merge REQUIRE into PACKAGE, leaving us only:

      .ruby
      PACKAGE
      PROFILE

We could also rename the package file in such a way as to use it as a Ruby
root marker as well. Something likes `Rubyfile` or `Ruby.yml`, in which would
be the all the package and requirements information. Thus leaving us with:

      Profile
      Rubyfile

I think for most Rubyists that would seem a more appealing result, as it means
only two extra file, fits is well with ones Rakefile, and says clearly 
"this is Ruby", without looking for hidden files.

The last option would move the metadata files into a `.ruby/` subdirectory.

      .ruby/
        package
        profile
        require

On the downside this hides important metadata away in hidden directory.
To remedy that, instead of `.ruby/` we could use `ruby/` or `RUBY`/.
But it still places the data a directory down which makes it slightly less
convenient to access. In addition, `ruby/` gets kind of lost
among the other directories, while `RUBY/` -- I don't know, it just sort
of sticks out oddly.


== 2010-07-23 | Individual Requirement Files

Today I came up with yet another idea for the layout of project metadata,
one that moves back toward the use of a directory-based configuration, but
still remains well within in the range of middle ground. The idea is to use
a special directory, but break requirements out into individual files.

    RUBY/
      loadpath
      package
      requires/
        qed-2.3
        rdoc-2.5

The name of each requires file is not actually important. They exist simple
for the benefit of the developer to read. The content of the files define the
actual requirements. Each file being a YAML-formatted hash. For example,

    ---
    name: qed
    vers: 2.3+
    type: test

The benefit of this design would be the ease at which requirements could be
swapped about between projects. The `package` file would also be essentialy
identical to ther requirements file, so they too could be used. For example
I could add a a dependency on my current development version of QED to
my development version of POM simply with:

    cp qed/RUBY/package pom/RUBY/requires/qed

Pretty cool! But, as with most <i>good ideas</i>, it is a bad idea as well.
As with any multiple file configuration, editing them all in one fell swoop
is not as easy as editing a single file, though in this case I do not think
that's a show-stopping issue. A more signifficant downside is the inability
to read in a list of requirements in one stream. Moreover, despite being able
to easily copy requirements between projects, one usually doesn't work
with requirements in this manner. The requirements of one package has no
barring on another beyond depending on that package, in which case there 
is certainly no need to "copy" requirements.

It's an intersting concept, but ultimately it seems to be YAGNI. I went ahead
and blogged about it just as a future reminder of this line of reasoning.


== 2010-07-22 | Final Designs

Over the years POM has evolved. Many considerations have contributed to
changes in it's design. The most significant of which was the recent move away
from the directory-based "one piece of data per file" configuration, to the 
the YAML-format file-based design. On the whole this has been a positive change.
It's has proven even better than anticipated. Nonetheless the change has opened
up a couple of issues that the previous design addressed.

One of these is the question of how to reliably determine the location
of a project's root directory. The `.meta/` directory worked quite well
in this regard, whereas the PACKAGE file (being the essential POM file)
is not quite as suited --the name is too generic, the name can also
come in too many flavors (PACAKGE, Package, Package.yml, PACKAGE.ymal, etc.)
which makes it less efficient to detect and access. Worse still, it
effectively presupposes the use of POM to gain the benefit of a reliable
root marker.

I touched on the first and last of these in my previous blog entry. The second
bares further explination. It is, of course, easy enough for a file system
to do a file name search. Currently POM is littered with code like:

    Dir.glob('Package{,.yml,.yaml}', File::FNM_CASEFOLD)

Perhaps not as simple as we might like, but perfectly acceptable, and if that
were the only naggle, I wouldn't think twice about it. But also consider a web
agent trying to gather information about projects. In this case
access to the file system is much more limited and would require a silly
brute force attempt on every capital and lowercase combination. The web agent
would be better off pulling down all the files and doing the above search, as
inefficent as that would be. The use of fixed names just makes things easier,
arguably a corollary of the "convention over configuration" meme.

Taking these factors into consideration, I have narrowed the solutions for
addressing the issue to three:

1. Use a dummy .ruby file, which can retain references to the names of the actual metadata files.
2. Use a `.ruby/` directory, where the metadata files can reside.
3. Use a `.meta/` or `.project/` directory where a `ruby` file resides and the metadata files can reside.

The later is probably the best approach, in that it is the most generic
but still allows us to easiy identify a ruby project. The `.meta/ruby` or
`.project/ruby` file could contain a list of Ruby engines that the project
has been tested against. On the other hand the use of .ruby readily identifies
a project as a Ruby project --one does not have to drill down into `.meta`
or `.project` to figure it out. Although both are hidden files anyway, so why
does it really matter?

For the moment the dummy file approach is being utilized. But the final design
still bares further consideration.


== 2010-07-21 | Find Root

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


== 2010-06-11 | VERSION and RELEASE files

I face an issue with supporting the VERSION file as the source for
a project's current version information. Specifically, tools like
Tim Pease's Mr. Bones and and Josh Nichols' Jeweler utilize the VERSION
file as well, but in more limited formats. Bones looks for a simple text 
entry, e.g. "1.0.0", while Jeweler can accept this as well, but prefers
the YAML layout:

  --
  :major: 1
  :minor: 0
  :patch: 0
  :build: 

Both are fine as far as they go. But POM recognizes additional version
information including *release date*, *code name*, and *revision number*.
This additional information could be added to either format of VERSION file,
but without modification to Bones and Jeweler, they will choke-on and/or
clobber the additional information. I am somewhat hopeful they will repsond
to my email asking for us to work out a common design, but after 4 days
I have yet to heard from them :(  I do not want to step on other's toes.
As much as possible I am trying to conform POM to the way Rubyists already 
organize their projects, rather than the other way around.

If I cannot reach an accord with other developers on a more flexible VERSION
file, the alternative is to fallback to meta/ entries. Yes, those again.
I considered using the RELEASE file instead. I know that a few developer's
already use this file to store a description the the current release, so
it follows logically. I thought it would be possible to utilize a document
header to extract the information, whether it is a line of text or YAML
front matter. But I releazed that the file is inteded for human readability
and not machine, so it won't fly.

Finally there are three important pieces of information that do not seem
to fit properly among the version data, but must be readily available
to many project tools. These are the project's *unixname*, it's *classname*
and the *loadpath*. Initially I simply placed this information in with
the version data, however, strictly speaking it is not version information.
To avoid this I have utilize certain hueristics that infer the information
from other aspects of the project. For example the unixname can be infered
by the name of the directory in lib/. If for the some reason the project
differs from the usual norms, this information can be specifically specified
in the .meta/ directory.


== 2010-05-17 | POM's PROFILE and VERSION Files

A big change is coming to the next release of POM, and in turn
all the tools that utilize it, including Syckle, Roll, Box and WebMe.
So big is the change, in fact, that it requires a mojor verison bump.
So expect the next release ov POM to be 2.0. In itself the change
is straight forward... Instead of the previous use of a <code>meta/</code>
directory for storing project metadata, POM will now use two
YAML files: PROFILE and VERSION.

I believe that in most ways the <code>meta/</code> directory design
is a superior solution. However, I also realize that it is an idea that
is not quite ready for prime time. And I think trying to use POM
to promote it as such ultimately hurts POM. No, today developer's
are quite used to and comfortable with using configuration <i>files</i>,
especially YAML files among Rubyists, and it only makes sense
that it should be the choice for POM as well.

So what is the actual net effect of this change? Basically it is
this. All previous <code>meta/</code> directory fields related to versioning
and library managment go in the VERSION file. Examples include
`name`, the loadpath, now called `paths`, and of course the version number.
The version number howerver is now broken up into five
fields: `major`, `minor`, `patch`, `state` and `build`.
If you have ever used Jeweler you will be probably familiar with all
of these except `state`, which is simply the optional "status" of the
current build, e.g. `pre`, `beta` or `rc`. (In addition, dependency
information may go in the file as well. But that hasn't been decided
upon for sure yet).

All other project metadata goes into PROFILE, such as `title`, `description`,
`authors` list, and so forth. 

The PROFILE and VERSION files have been kept separate because the VERSION
file will be updated regularly , where as the PROFILE will tend to remain
unchanged.


== 2010-05-12 | Directory Store

One of the more "controversial" design decisions made by POM was to store all
metadata in a directory store --one file per peice of information. But there is
a very specific reason for this. Namely that the version number needs to be
accessible indpendently of the other metadata so that it could be easily
updated. While the version could have been singled out, a few other fields were
related to the version number, for instance, the release date. In addition
other fields, such as the package name, are more commonly useful than
most of the other information and it seems wasteful to load up a large amount
of metadata for the sake of single entry. And so, taking all this into account,
the most consitant result was to put all entires in separate files.
There are plenty of advantages to this approach, as I have discussed else 
where, but their are also some unfortunate downsides. 

* Access of metadata via URL is hamperd since it takes multiple http requests to access the data.
* Having to edit multiple files is obviously not as convenient as editing a single file.
* Perhaps, worse of all, it simply strike some developers as "weird".

I have, for some time tried to work out a potential alternative design, one that
uses a small number of files, separating metadata according the needs mentioned
above. While I am not 100% on the exact names of the files, I have worked out 
taht this alternative would have two files:

* <tt>.version</tt> for name, version, release date, status, and also internal load path.
* <tt>.package</tt> for dependencies, with suitable distinction for platforms.
* <tt>.profile</tt> for all other metadata such as description, summary, authors, etc.

This system would work just as well as the per file system as far as the
separation of important concerns --the .version file would be updated regularly
while the .profile file would rarely ever change. I am tempted to support this
design, but I am a little hestitant to break backward compatability and concerned
that future needs might prove this division of information more fragile than it
presently seems. That's one of the big advantages of the file store design
actually, adding new stuff to it has essentially no ramifications on the design.
POM could support both designs, but I worry this would only further complicate
matters.


== 2010-05-05 | Resourcess Subdirectory

To subdirectory or not to subdirectory? That is the question. Whether it is better
to separate relavent sets of information into their own little area of concern or
to leave them adrift within all the other metadata, it is a difficult choice.
On the one hand, the simplicity of a single depth store is very attractive, on the
other the sepration of concerns leads to a cleaner layout. And then I must ask,
how far does it go? Does separating "requirements", like +requires+, +provides+,
and so on, into a separate subdirectory, make more sense as well?


== 2010-01-17 | Wiki's Make the Best User Manuals

Today I have finally decided that a Wiki is the best place
to keep user documentation. There is of course the obvious
advantage to this: online access, editable by any user, anywhere
at anytime. There are some subtle advantages as well. For instance,
I get automatic spell-checking via my browser.

Of course the big disadvantage is that should the Wiki Host
go kaputz, then no more documentation. I trust GitHub is not
going anywhere anytime soon, but I have had such a thing happen
to me before so I will be sure to look into making backups just in case.


== 2010-01-16 | Build Metadata

Debated a long time about what to do about "build metadata".
At issue is the fact that it is almost entirely information that
the end-user never needs to see, so it does not need to be
shipped with the package(s), as regular metadata generally
does. So this build data doesn't belong in the same location
as the regular metadata --with one exception. Build requirements
to actually compile and install the pacakge are needed.

After much consideration I have decided that such build requirements
should be included in the regular requirements field when
they are needed to compile and/or install.

As for the rest, I have for now at least declared a YAGNI.
The build fields would only act as defaults for other tools in
anycase. One might as well provide the configuration settings
for the tools themselves (e.g. setting them in a Rakefile).


== 2009-10-05 | Rubyforge Entries

Thought about adding rubyforge entries to metadata, eg. unixname, groupid, etc.
Putting the difficulty of supporting the use of a rubyforge/ subdirectory in
the meta/ directory to store this information, I've further decided it's not
appropriate information for project metadata. It's really build configuration
and thus should be specified via mechanisms specific to the build tool used,
such a Syckle configs.


== 2009-01-05 | Build Metadata Class

Considered adding a separate class for build metadata. However, I could
not think of a good place to store this information. The best bet
seemes to to be meta/build/, though that likely means making a special
exlusion in one's package configs, since build data is not needed in
packages but the rest of meta/ is.

On the other hand, it occurs to me that almost all build data would be used
by specific build tools, so it's just as well that each tool handle it's
own configuration needs. The only exception I've thought of is the "build
requirements". So, I've decided to add that field to Metadata itself,
and forego supporting any other build data, at least for the time being.


== A Note or Two on Version Numbers

(OLD NOTE THAT CAME FROM ROLLS)

Though the taguri standard suggests using a dating scheme to
differentiate library versions in the directory hierarchy, Roll
fully supports both date and dot-series versioning. How to utilize either
of these is a matter to be decided by the project's maintainer.
But we'll touch on them briefly to help understand the two useful methods.

Series-versioning is the most common form versioning in use today. If you take
a close look at the versions put out by a plethora of projects you will also
notice that it is more akin to an art-form than a science[<a href="#foot1">1</a>].
Nonetheless, if you follow a strict Rational Versioning Policy
of "major.minor.tiny" with regards to project changes, it can be helpful
in conveying <i>compatibility</i>, which can in turn provide the end-user
some means of insurance that their programs will remain functional even
after updates.

Date-versioning, OTOH, is not as common mainly because it is not
typically thought to have any semantic value beyond a release timestamp.
But by creatively utilizing the taguri standard, date-versioning can in
fact lend itself to greater version consistency with regard to release
<i>stability</i>. Just follow these four simple rules:
<pre>
  1) Unstable/development releases provide the day (YYYY-MM-DD)
  2) Official/stable releases remove the day (YYYY-MM)
  3) Ultrastable releases provide only the year (YYYY)
  4) For daily builds add a "build moment" by adding the time.
</pre>
With this Rational Versioning Policy, the intent is clear and meaningful and
has a natural way of forcing one to comply to the meaning, which is nice.


<!--
To support versioning and to encourage clean divisions between projects,
Roll has taken a <i>inspiration</i> from the <b>taguri</b>
standard as a basis for library file and directory names.
You can learn more about taguri <a href="http://taguri.org">here</a>.
The taguri standard is not suitable in itself to designate file and
directory names, but with some basic transformations and additions it is
admirably useful. Here is an example of what a projects taguri would be and
how that translates into a directory structure and a tar package file name.

<pre>
  (1) tag:fruitbasket.rubyforge.org,2005-10-31:tryme.rb
  (2) fruitbasket.rubyforge.org/2005-10-31/tryme.rb
  (3) fruitbasket.rubyforge.org-2005.10.31.tgz (contains tryme.rb)
</pre>

The first is the standard taguri. The second is how it is
represented in file system. And the third is, of course,
the directory packed in a tar file. While we would have liked the
packaged file name to more closely resemble the original taguri,
many source host services do not allow file names to have commas.
But also notice how the the date becomes a sub-directory of the uri.
This represents the version, and as such it need not be a date
--it could just as well be a series like '1.0.0'.

For clarity here's the above as it translates into a project's directory
layout.
-->

Footnotes:<br/>
[1] <a href="http://www.newsforge.com/article.pl?sid=05/06/08/136214&from=rss">Decline and fall of the version number</a>

