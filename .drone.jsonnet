local containerManifest = import '.drone/libs/container/manifest.jsonnet';
local build = import '.drone/libs/builds/fedhq/ContainerImageBuild.jsonnet';
local repo   = import '.drone/libs/other/repo.jsonnet';
local project = import '.drone/libs/other/project.jsonnet';

local redmineProject = project.new("container","Container").withCategory("alpine-curl-jq");

local githubRepo = repo.new("alpine-curl-jq")
                       .withDescription("base alpine image including curl and jq")
                       .withHomepage("https://rm.geraffel.org/projects/container");


local manifest = containerManifest.new("alpine-curl-jq").withTags(["latest"])
                                             .withArchs(["amd64","arm64"]);



build.new(manifest).withGithubPush(githubRepo).withDockerReadme(manifest,"README.md").render()
