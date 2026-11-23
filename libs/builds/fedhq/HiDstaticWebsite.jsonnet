local fedhq             = import '../../build/fedhq.jsonnet';
local containerImage    = import '../../container/image.jsonnet';
local generate          = import '../../pipelines/hidGenerate.jsonnet';
local publishWebsite    = import '../../pipelines/publishHiDWebsite.jsonnet';
local publishManifest   = import '../../pipelines/publishContainerManifest.jsonnet';
local trigger           = import '../../drone/trigger.jsonnet';
local platform          = import '../../drone/platform.jsonnet';
local containerRegistry = import '../../container/registry.jsonnet';
local containerBuildMod = import '../../container/build.jsonnet';
local secret            = import '../../drone/secret.jsonnet';

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
                     generate.new() // check if we can build the website
                 ]
                 +
                 [
                     // we have to split the pipelines here depending on architecture
                     publishWebsite.new(
                         containerImage.new(containerBuild.manifest.name)
                                         .withTags(containerBuild.manifest.tags[0] + "-" + arch),
                         containerBuild,
                         false)
                     .withPlatform(platform.new("linux", arch))
                     .withName("Test-Image-" + containerBuild.manifest.name + "-" + arch)
                     .withDependsOn([
                         "HiD-Generate",
                     ])
                     for arch in containerBuild.manifest.archs
                 ]
                 +
                 [
                     // we have to split the pipelines here depending on architecture
                     publishWebsite.new(
                         containerImage.new(containerBuild.manifest.name)
                                         .withTags(containerBuild.manifest.tags[0] + "-" + arch),
                         containerBuild,
                         true)
                     .withPlatform(platform.new("linux", arch))
                     .withName("Build-Image-" + containerBuild.manifest.name + "-" + arch)
                     .withDependsOn([
                         "HiD-Generate",
                         "Test-Image-" + containerBuild.manifest.name + "-" + arch,
                     ])
                     .withTrigger(mainPushSuccess)
                     for arch in containerBuild.manifest.archs
                 ])
             .addFinishSuccessPipelines([
                 publishManifest.new(containerBuild)
                                .withTrigger(mainPushSuccess)
             ])
}
