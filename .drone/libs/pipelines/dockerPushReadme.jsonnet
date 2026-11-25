local pipeline          = import '../drone/pipeline.jsonnet';
local dockerPush        = import '../steps/dockerPushReadme.jsonnet';

{
        new(dockerRegistry, manifest):: pipeline.new()
                .withName("docker-push-readme")
                .withSteps([
                        dockerPush.new(dockerRegistry, manifest)
                    ])
}
