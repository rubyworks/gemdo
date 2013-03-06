## Project History

Given a complete project example, a Project class insteance should be able to
access the history file.

    project = POM::Project.new('example')

    history = project.history

    history.assert.is_a?(::History)



