= Pom::Metadata

Require metadata library.

  require 'pom/metadata'

Load metadata from fixture.

  metadata = Pom::Metadata.new('fixture')

Verify metadata is being read from directory location.

  metadata.package.should == "myapp"

Verify metadata is being read from metadata file.

  metadata.contact.should == "trans <transfire@gmail.com>"
  metadata.project.should == "ProUtils"
  metadata.version.should == "2.0.0"

Verify metadata is being read from README file.

  metadata.description.should == "This is the description for the example."
  metadata.license.should == "GPL"

Verify metadata is falling back to defaults.

  metadata.loadpath.should == ['lib']

QED.

