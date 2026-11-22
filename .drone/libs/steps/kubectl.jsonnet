local step = import '../drone/step.jsonnet';

{
    new(kubectl):: local c = kubectl.cluster;
                   step.new("Deploy-Kubernetes", "registry.cloud.federationhq.de/drone-kubectl:latest")
                    .withSettings({
                      kubernetes_server: c.url,
                      kubernetes_user: c.username,
                      kubernetes_namespace: c.ns,
                      kubernetes_token: { from_secret: c.token.name },
                      kubectl_args: kubectl.command
                    } + (if std.objectHas(c, 'crt') then { kubernetes_cert: c.crt } else {}))
}
