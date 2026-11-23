#
# fedhq build: a base build for the fedhq setup
# the verify pipelines run before the build, the github push (optional) after everything
#
local base             = import 'base.jsonnet';
local trigger          = import '../drone/trigger.jsonnet';
local githubPush       = import '../other/githubPush.jsonnet';
local secret           = import '../drone/secret.jsonnet';
local baseVerifyBranch = import '../pipelines/baseVerifyBranch.jsonnet';
local baseVerifyMain   = import '../pipelines/baseVerifyMain.jsonnet';
local redmine          = import '../other/redmine.jsonnet';
local redmineCreateProject = import '../pipelines/redmineCreateProject.jsonnet';

local githubSecret  = secret.new("github-token","github","token");
local redmineSecret = secret.new("redmine-token","redmine","token");
local giteaSecret   = secret.new("gitea-token","gitea","token");

local redmineServer = redmine.new("Geraffel Redmine","https://rm.geraffel.org").withExtendedApi().withSecret(redmineSecret);

local fedhq = {
    new()::
        self + base.new()
            .addPrePipelines([
                baseVerifyBranch.new(), // check everything commit related on current branch
                baseVerifyMain.new(),   // check everything commit related on main branch, if build for main branch
             ]),

    withGithubPush(repo)::
        local push = githubPush.new("byterazor", githubSecret)
                            .withRepoName(repo.name)
                            .withDescription(repo.description)
                            .withHomepage(repo.homepage);
        self.withSecrets(githubSecret)
            .addFinishSuccessPipelines(push.pushPipeline()),


    withRedmine(project)::
      self.withSecrets(redmineSecret)
          .addInitPipelines(redmineCreateProject.new(redmineServer, project))



};


fedhq
