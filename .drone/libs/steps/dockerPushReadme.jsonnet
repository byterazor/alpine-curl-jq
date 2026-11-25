local step = import '../drone/step.jsonnet';
local droneStd = import '../drone/std.jsonnet';

{
    new(dockerRegistry, manifest, filename):: step.new("docker-push-readme", "byterazor/drone-docker-readme-push:latest")
    .withSettings({
      REPOSITORY_NAME: dockerRegistry.path + '/' + manifest.name,
      FILENAME: filename,
      USERNAME: {
          from_secret: droneStd.envVarForSecret(dockerRegistry.usernameSecret)
      },
      PASSWORD: {
          from_secret: droneStd.envVarForSecret(dockerRegistry.passwordSecret)
      }
    })
}
