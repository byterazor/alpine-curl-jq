local pipeline          = import '../drone/pipeline.jsonnet';
local gitSteps          = import '../steps/git.jsonnet';
local emptyStep         = import '../steps/empty.jsonnet';
local hid               = import '../steps/hid.jsonnet';
local buildahManifest   = import '../steps/buildah-manifest.jsonnet';
local kubectlStep       = import '../steps/kubectl.jsonnet';
local when              = import '../drone/when.jsonnet';

{
        new(build):: local deploySteps =
                    if std.objectHas(build, 'kubectl')
                    then [kubectlStep.new(build.kubectl).withDependsOn(["Build-Manifest"])]
                    else [];
               pipeline.new()
                .withName("Publish-Static-Website")
                .withoutClone()
                .withSteps([
                        buildahManifest.new(build)
                    ] + deploySteps)
}
