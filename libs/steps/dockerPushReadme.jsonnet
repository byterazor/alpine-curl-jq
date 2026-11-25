local step = import '../drone/step.jsonnet';
local droneStd = import '../drone/std.jsonnet';

{
    new(dockerRegistry, manifest):: step.new("docker-push-readme-"+manifest.name, "byterazor/drone-docker-readme-push:latest")
    .withSettings({
      REPOSITORY_NAME: dockerRegistry.path + '/' + manifest.name,
      FILENAME: manifest.readme,
      USERNAME: {
          from_secret: dockerRegistry.usernameSecret.name
      },
      PASSWORD: {
          from_secret: dockerRegistry.passwordSecret.name
      }
    })
}
