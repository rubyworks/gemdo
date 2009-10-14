Load the ReadMe library.

  require 'pom/readme'

Create a new ReadMe objet from file.

  rm = Pom::ReadMe.load("README2.txt")

It should be able to parse out a description.

  rm.description.should == "This is a description of the fake project."

It should parse out the lincese.

  rm.license.should == "LGPL"

QED.
