= Version Bumping

In the demonstration to follow we will uses this macro to reload
the PACKAGE file.

  def package
    YAML.load(File.new('tmp/example/PACKAGE'))
  end

Given a PACKAGE project file containing ...

    name: foo
    vers: 1.0.0

First, the `pom bump` command, when given no other arguments will
display the current version.

  `cd tmp/example; pom bump`.assert == "1.0.0\n"

This is the same as using `pom show version`.

  `cd tmp/example; pom show version`.assert == "1.0.0\n"

We can use the `pom bump` command to bump the `patch` version
using the `--patch` flag.

  `cd tmp/example; pom bump --patch`

We can see that the `patch` number has been incremented.

  package['vers'].assert = '1.0.1'

Again, we can use the `pom bump` command to bump the `minor` version
with the `--minor` flag.

  `cd tmp/example; pom bump --minor`

And we can see that the `minor` number has been incremented.

  package['vers'].assert = '1.1.0'

We can use the `pom bump` command to bump the `major` version by
using the `--major` flag.

  `cd tmp/example; pom bump --major`

We can see that the `major` number has been incremented.

  package['vers'].assert = '2.0.0'

