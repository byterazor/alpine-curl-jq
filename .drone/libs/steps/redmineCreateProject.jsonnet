local step = import '../drone/step.jsonnet';

{
    new(redmineServer, project):: step.new("redmine-create-project-"+project.name, "byterazor/drone-redmine:dev")
    .withSettings({
      REDMINE_URL: redmineServer.url,
      REDMINE_TOKEN: {
                  from_secret: redmineServer.secret.name
                },
      ACTION: "createProject",
      PROJECT_ID: project.projectId,
      PROJECT_NAME: project.name,
    }
    + (if std.objectHas(project, 'parent') then {PROJECT_PARENT: std.toString(project.parent)} else {})
    + (if std.objectHas(project, 'public') then {PROJECT_PUBLIC: std.toString(project.public)} else {})
    + (if std.objectHas(project, 'category') then {CATEGORY: project.category} else {}))
}
