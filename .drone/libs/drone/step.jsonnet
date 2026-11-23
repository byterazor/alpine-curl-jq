local base      = import 'base.jsonnet';



local step = {
            new(name='', image=''):: self.withName(name).withImage(image),
            withName(name):: self + { name: name },
            withImage(image):: self + if image != '' then { image: image } else {},
            withAlwaysPull():: self + { pull: 'always' },
            withCommands(commands):: self + if std.type(commands) == 'array' then { commands: commands } else { commands: [commands] },
            withTrigger(trigger):: self + { trigger: trigger },
            withEnv(envs):: self + { environment: envs },
            withWhen(when):: self + { when: when },
            withSettings(settings):: self + { settings: settings },
            withVolumes(volumes):: self + if std.type(volumes) == 'array' then { volumes: volumes } else { volumes: [volumes] },
            withDependsOn(n):: self + { depends_on: n },
            addDependsOn(n)::
                local prev = if std.objectHas(self, 'depends_on') then self.depends_on else [];
                local x = if std.type(n) == 'array' then n else [n];
                local merged = prev + [i for i in x if !std.member(prev, i)];
                if merged == [] then self else self + { depends_on: merged },
            withPrivileged():: self + { privileged: true }
};

step
