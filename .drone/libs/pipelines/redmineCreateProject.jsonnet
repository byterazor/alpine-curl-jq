local pipeline      = import '../drone/pipeline.jsonnet';
local createProject = import '../steps/redmineCreateProject.jsonnet';

{
        new(redmineServer, project):: pipeline.new()
                .withName("redmine-create-project")
                .withSteps([
                        createProject.new(redmineServer, project)
                    ])
}
