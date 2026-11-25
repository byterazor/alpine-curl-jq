local pipeline = import '../drone/pipeline.jsonnet';
local step     = import '../drone/step.jsonnet';
local droneStd = import '../drone/std.jsonnet';

{
    new(redmine, project)::
        local tokenVar = droneStd.envVarForSecret(redmine.secret);
        local auth = ' -H "X-Redmine-API-Key: $' + tokenVar + '"';
        local apiBase = redmine.apiUrl();
        local hasParent = std.objectHas(project, 'parent');
        local parentResolve = if hasParent then [
            'parent_id=$(curl -sf' + auth + ' "' + apiBase + '/projects/' + project.parent.projectId + '.json" | jq -r ".project.id")',
            '[ -n "$parent_id" ] || { echo "Redmine parent project ' + project.parent.projectId + ' not found"; exit 1; }'
        ] else [];
        local parentArgs = if hasParent
            then ' --data-urlencode "project[parent_id]=$parent_id"'
            else '';
        local categoryStep = if std.objectHas(project, 'category') then [
            'if ! curl -sf' + auth + ' "' + apiBase + '/projects/' + project.projectId + '/issues_categories.json"'
            + ' | grep -qF "' + project.category + '"; then',
            '  code=$(curl -s -o /tmp/redmine_cat_resp -w "%{http_code}" -X POST' + auth
            + ' --data-urlencode "issues_category[name]=' + project.category + '"'
            + ' "' + apiBase + '/projects/' + project.projectId + '/issues_categories.json")',
            '  if [ "$code" = "200" ] && jq -e ".issues_category.id" /tmp/redmine_cat_resp > /dev/null; then',
            '    echo "issue category ' + project.category + ' created";',
            '  else',
            '    echo "issue category creation failed: HTTP $code $(cat /tmp/redmine_cat_resp)";',
            '    exit 1;',
            '  fi',
            'else',
            '  echo "issue category ' + project.category + ' already exists, skipping";',
            'fi'
        ] else [];
        pipeline.new()
            .withName("RedmineCreateProject-" + project.name)
            .withoutClone()
            .withSteps([
                step.new("Create-Project", "docker.io/byterazor/alpine-curl-jq:latest")
                    .withEnv({ [tokenVar]: { from_secret: redmine.secret.name } })
                    .withCommands([
                        'if curl -sf' + auth + ' "' + apiBase + '/projects/' + project.projectId + '.json" > /dev/null; then',
                        '  echo "Redmine project ' + project.projectId + ' already exists, skipping";',
                        'else',
                    ] + parentResolve + [
                        '  curl -sf -X POST' + auth
                            + ' --data-urlencode "project[name]=' + project.name + '"'
                            + ' --data-urlencode "project[identifier]=' + project.projectId + '"'
                            + parentArgs
                            + ' "' + apiBase + '/projects.json";',
                        '  echo "Redmine project ' + project.projectId + ' created";',
                        'fi'
                    ] + categoryStep)
            ])
}
