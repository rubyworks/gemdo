# News Class

The News class encapsulates the current release notes for the project.
It parses a text file by the name of NEWS in the same way that
individual release entries are parsed in the History class.

Given a NEWS project file containing:

    # Foo 1.2.1 (2010-10-18)

    1. This is change 1.
    2. This is change 2.
    3. This is change 3.

    Some Dandy description of the 1.2.1 release.
    Notice this time that the changes are listed
    first and are numerically enumerated.

The News class provides an interface to this information.
The initializer takes the root directory for the project
and looks for a file called +NEWS+, optionally ending
in an extension such as +.txt+ or +.rdoc+, etc.

    news = POM::Project::News.new('example')

Now we have access to the latest release notes as given in the
the NEWS file.

    news.header.assert == '# Foo 1.2.1 (2010-10-18)'
    news.notes.assert.index('description of the 1.2.1')
    news.changes.assert.index('This is change 1')

The header is further parsed into version, date and nickname if given.

    news.version.assert == '1.2.1'
    news.date.assert    == '2010-10-18'

If there is no NEWS file in a project, the News class will fallback
to the HISTORY file's first rentry.

Given a HISTORY project file containing:

    # RELEASE HISTORY

    ## 1.2.1 / 2010-10-18

    1. This is change 1.
    2. This is change 2.
    3. This is change 3.

    Some Dandy description of the 1.2.1 release.
    Notice this time that the changes are listed
    first and are numerically enumerated.

    ## 1.1.0 / 2010-01-01

    1. This is change 1.
    2. This is change 2.
    3. This is change 3.

    Some Dandy description of the 1.1.0 release.
    Notice this time that the changes are listed
    first and are numerically enumerated.

Since the NEWS file is not present, we will get the top entry of the
HISOTRY file above from the News object.

    news = POM::Project::News.new('example')
    news.header.assert == '## 1.2.1 / 2010-10-18'
    news.version.assert == '1.2.1'
    news.date.assert == '2010-10-18'

Like the history parser, the news parser is farily simplistic,
but again it is designed to handle the most common cases.

