# 2010-07-23 | Seeking Perfection

I releaize my biggest problem it working out the various details of desing for
POM primarily stem from my over baring desire to achieve "perfection", or at
least some osrt of semblaance of it. However, there problaby is none to find.
Which is why I continuely toil over the various choices. At some point a mere
choice must be made between varying impoerfect solutions. (Not to mention
the fact that I would really like to get this doen and move on to other
projects!) Desipte this I keep seeking. 

The reoccuring question of POM --indeed the point of POM is to specifying
a file system based data structure for project information. There are probably
a million ways to sundown to do this, and I assure you I've travalled too many.
From a single unified YAML file to a fully directory-based one-file-per-field 
design, I have teased out their various advantages and disadvantages. My
conclusion is that the best solution lies somewhere between the extremes.
It is better to have small files, which allows greate atomicity in access, but
it is better to have files of multiple related information for quick access and
ease of editing. So for that last few months I have been attempting to ring out
a better approach ... This endeavor gave rise to the PACAKGE, PROFILE and
REQUIRE files. I thought I had finally reach the best choice....
But, as is often the case in exploring new avenues, there remains some ...
issues.

1. Having deprecated the use of a `.meta/` directory. There is no good way
to reliably ascertain the project's root directory.
2. There is nothing in particular that clearly indicates that the project
is a Ruby project.
3. Too many name variations (PACKAGE, Package.yaml, ...).

The remaining possibilites fall into two groups. Using a sub-directory
vs. using toplevel files. Of these, there three significant designs.

The simplist solution relative to what POM has now, would be to simply add
a file to identify the project as Ruby, using it as a marker be able
to detect the root directory. To give the file contents some use it could
contain a list of the versions of Ruby the project has been tested against.

      .ruby
      PACKAGE
      PROFILE
      REQUIRE

Possibly we might also merge REQUIRE into PACKAGE, leaving us a single file,
and if we did that we could rename it in such a way as to use it as a Ruby
root marker as well. Something likes `Rubyfile` or `Ruby.yml`, in which would
be the all the package and requirements information. Thus leaving us with
simply:

      Profile
      Rubyfile

The subdirectory approach moves the current files into a `.ruby` directory.

      .ruby/
        loadpath
        package
        profile
        require

Notice that this allows for spliting the loadpath out a separate entry,
it we wish. On the downside this hides important metadata away into
a hidden directory. To remedy that, instead of .ruby/ we could use `ruby/`
or `RUBY`/. But it still places the data a directory down which makes it
slighty less convenient to access. In addition, `ruby/` gets kind of lost
among the other directories, while `RUBY/` -- I don't know, it just sort
of seems odd.

After further consideration I think the first choice feels too much like
an after thought (which make sense, b/c it is). It also tends to clutter up
the root directory, where the README is really the most important file.
So the choice boils down to the last two. The question is, "which of the two?".

