local fedhq             = import '../../build/fedhq.jsonnet';
local containerImage    = import '../../container/image.jsonnet';
local buildContainer    = import '../../pipelines/buildContainerImage.jsonnet';
local publishManifest   = import '../../pipelines/publishContainerManifest.jsonnet';
local trigger           = import '../../drone/trigger.jsonnet';
local platform          = import '../../drone/platform.jsonnet';
local containerRegistry = import '../../container/registry.jsonnet';
local containerBuildMod = import '../../container/build.jsonnet';
local secret            = import '../../drone/secret.jsonnet';
local dockerPushReadme  = import '../../steps/dockerPushReadme.jsonnet';


local dockerUsernameSecret = secret.new("docker-username","docker","username");
local dockerPasswordSecret = secret.new("docker-password","docker","secret");

local fedhqRegistry = containerRegistry.new("registry.cloud.federationhq.de");
local dockerRegistry = containerRegistry.new("registry.hub.docker.com").withPath("/byterazor").withAuth().withK8sCredentials(dockerUsernameSecret,dockerPasswordSecret);

local mainPushSuccess = trigger.new().withBranch("main").withStatus("success").withEvent(["push"]);

{
    new(manifests)::
        local containerBuild = containerBuildMod.new(manifests)
                                .withRegistries([fedhqRegistry, dockerRegistry])
                                .withCacheRegistry(fedhqRegistry);
        self + fedhq.new()
             .withSecrets(containerBuild.allSecrets())
             .addPipelines(
                 [
                     // we have to split the pipelines here depending on architecture
                     buildContainer.new(
                         containerImage.new(containerBuild.manifest.name)
                                         .withTags(containerBuild.manifest.tags[0] + "-" + arch),
                         containerBuild,
                         false)
                     .withPlatform(platform.new("linux", arch))
                     .withName("Test-Image-" + containerBuild.manifest.name + "-" + arch)
                     for arch in containerBuild.manifest.archs
                 ]
                 +
                 [
                     // we have to split the pipelines here depending on architecture
                     buildContainer.new(
                         containerImage.new(containerBuild.manifest.name)
                                         .withTags(containerBuild.manifest.tags[0] + "-" + arch),
                         containerBuild,
                         true)
                     .withPlatform(platform.new("linux", arch))
                     .withName("Build-Image-" + containerBuild.manifest.name + "-" + arch)
                     .withDependsOn([
                         "Test-Image-" + containerBuild.manifest.name + "-" + arch,
                     ])
                     .withTrigger(mainPushSuccess)
                     for arch in containerBuild.manifest.archs
                 ])
             .addFinishSuccessPipelines([
                 publishManifest.new(containerBuild)
                                .withTrigger(mainPushSuccess)
             ]),

    withDockerReadme(manifests, file)::
            local mf = if std.type(manifests) == 'array' then manifests else [manifests];
            self.addFinishSuccessPipelines(
              [
                dockerPushReadme.new(dockerRegistry, m, file)
                for m in mf
              ]
            )
}
