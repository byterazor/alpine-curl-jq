#
# jsonnet library representing one drone build
#
local trigger           = import '../drone/trigger.jsonnet';

local base = {
    secrets: [],
    pipelines: [],
    finishpipelines: [],
    initpipelines: [],
    new():: self + {},
    withPushGithub(github):: self.withSecrets(github.token) + {github: github},
    withSecrets(secrets)::
         local prev = if std.objectHas(self,'secrets') then self.secrets else [];
         local s = if std.type(secrets) == 'array' then secrets else [secrets];
         self + { secrets: prev + s },
    withPipelines(pipelines):: self + {pipelines: pipelines},
    withInitPipelines(pipelines):: self + {initpipelines: pipelines},
    withFinishPipelines(pipelines):: self + {finishpipelines:  pipelines},
    render():: [
                s for s in self.secrets
               ]
               +
               [
                p for p in self.initpipelines
               ]
               +
               [
                local prev = if std.objectHas(p, 'depends_on') then p.depends_on else [];
                p.withDependsOn(prev + [n for n in [p2.name for p2 in self.initpipelines] if !std.member(prev, n)])
                for p in self.pipelines
               ]
               +
               [
                local prev = if std.objectHas(p, 'depends_on') then p.depends_on else [];
                p.withDependsOn(prev + [n for n in [p2.name for p2 in self.pipelines] if !std.member(prev, n)])
                for p in self.finishpipelines
               ]

               +
               (
                if std.objectHas(self, "github") then
                  [
                    self.github.pushPipeline().withDependsOn([p2.name for p2 in self.finishpipelines]).withTrigger(trigger.new()+ trigger.withBranch("main") + trigger.withStatus("success") + trigger.withEvent(["push"]))
                  ]
                else
                  []
               )
};


base
