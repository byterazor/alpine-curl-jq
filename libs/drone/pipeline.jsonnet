local base      = import 'base.jsonnet';
local platform  = import 'platform.jsonnet';

local pipeline = {
    new():: (self + base.new().withKind("pipeline"))
                             .withType("kubernetes"),
    withType(type):: self + { type: type },
    withPlatform(platform):: self + { platform: platform },
    withTrigger(t):: self + { trigger: t },
    withSteps(steps):: self + if std.type(steps) == 'array' then { steps: steps } else { steps: [steps] },
    withDependsOn(n):: self + { depends_on: n },
    addDependsOn(n)::
        local prev = if std.objectHas(self, 'depends_on') then self.depends_on else [];
        local x = if std.type(n) == 'array' then n else [n];
        local merged = prev + [i for i in x if !std.member(prev, i)];
        if merged == [] then self else self + { depends_on: merged },

    withoutClone():: self + { clone: {disable: true} },
    withVolumes(volumes):: self + if std.type(volumes) == 'array' then { volumes: volumes } else { volumes: [volumes] },
};

pipeline
