## Project Readme

Given a complete project example, a Project class insteance should be able to
access the readme file.

    project = POM::Project.new('example')

    readme = project.readme

    readme.assert.is_a?(::Readme)

