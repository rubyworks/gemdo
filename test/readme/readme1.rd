Load the ReadMe library.

  require 'pom/readme'

Create a new ReadMe object from file.

  rm = Pom::ReadMe.load("README1.txt")

It should be able to parse out a description.

  rm.description.should == "This is a description of the fake project."

It should parse out the lincese.

  rm.license.should == "GPL"

QED.
