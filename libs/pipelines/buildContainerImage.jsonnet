local pipeline          = import '../drone/pipeline.jsonnet';
local gitSteps          = import '../steps/git.jsonnet';
local emptyStep         = import '../steps/empty.jsonnet';
local hid               = import '../steps/hid.jsonnet';
local buildah           = import '../steps/buildah.jsonnet';
local kubectlStep       = import '../steps/kubectl.jsonnet';
local when              = import '../drone/when.jsonnet';

{
        new(image,build,push=true)::
            local deploySteps =
                if push && std.objectHas(build, 'kubectl')
                then [kubectlStep.new(build.kubectl).withDependsOn(["Container-Build"])]
                else [];
            pipeline.new()
                .withName("Build-Container-Image-" + image.name + ":" + image.tags[0])
                .withSteps([
                        gitSteps.checkoutSubmodules().withName("CheckoutSubmodules"),
                        buildah.new(image, build, push).withDependsOn(["CheckoutSubmodules"])
                    ] + deploySteps)
}
