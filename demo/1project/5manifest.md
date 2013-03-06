## Project Manifest

Given a complete project example, a Project class insteance should be able to
access the manifest file.

    project = POM::Project.new('example')

    manifest = project.manifest

    manifest.assert.is_a?(POM::Project::Manifest)

