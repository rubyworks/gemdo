# 2010-07-23 | Seeking Perfection

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

