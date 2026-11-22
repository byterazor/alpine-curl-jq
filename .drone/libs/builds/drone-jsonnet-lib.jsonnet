local build             = import '../build/base.jsonnet';
local containerImage    = import '../container/image.jsonnet';
local baseVerifyBranch  = import '../pipelines/baseVerifyBranch.jsonnet';
local baseVerifyMain    = import '../pipelines/baseVerifyMain.jsonnet';
local generate          = import '../pipelines/hidGenerate.jsonnet';
local buildContainer    = import '../pipelines/buildContainerImage.jsonnet';
local publishManifest   = import '../pipelines/publishContainerManifest.jsonnet';
local trigger           = import '../drone/trigger.jsonnet';
local platform          = import '../drone/platform.jsonnet';
local when              = import '../drone/when.jsonnet';
local test              = import '../steps/testJsonnet.jsonnet';
local pipeline          = import '../drone/pipeline.jsonnet';

{
    new():: self + build.new()
                 .withPipelines([
                     baseVerifyBranch.new(), // check everything commit related on current branch
                     baseVerifyMain.new(),   // check everything commit related on main branch, if build for main branch
                     pipeline.new().withName("Test-Jsonnet").withSteps([
                      test.new()
                      ])
                  ])
}
