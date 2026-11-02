local step = import '../drone/step.jsonnet';

{
    new(kubectl):: local c = kubectl.cluster;
                   step.new("Deploy-Kubernetes", "registry.cloud.federationhq.de/drone-kubectl:latest")
                    .withSettings({
                      kubernetes: {
                        server: c.url,
                        user: c.username,
                        namespace: c.ns,
                        token: { from_secret: c.token.name }
                      } + (if std.objectHas(c, 'crt') then { cert: c.crt } else {}),
                      kubectl_args: kubectl.command
                    })
}
