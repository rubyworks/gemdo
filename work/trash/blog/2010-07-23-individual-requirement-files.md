# 2010-07-23 | Individual Requirement Files

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

