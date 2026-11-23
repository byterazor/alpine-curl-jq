#
# jsonnet library representing one drone build
#
# pipelines live in slots, in execution order:
#   initpipelines, prepipelines, pipelines, postpipelines, finishsuccesspipelines
# render() wires every slot to depend on all pipelines of the slots before it.
# finishfailurepipelines are not wired to anything: they run without depends_on
# and render() forces their trigger to build status failure, so they fire when
# the build fails (e.g. notifications).
#
local base = {
    secrets: [],
    initpipelines: [],
    prepipelines: [],
    pipelines: [],
    postpipelines: [],
    finishsuccesspipelines: [],
    finishfailurepipelines: [],
    new():: self + {},
    withSecrets(secrets)::
         local prev = if std.objectHas(self,'secrets') then self.secrets else [];
         local s = if std.type(secrets) == 'array' then secrets else [secrets];
         self + { secrets: prev + s },
    withInitPipelines(pipelines):: self + {initpipelines: pipelines},
    withPrePipelines(pipelines):: self + {prepipelines: pipelines},
    withPipelines(pipelines):: self + {pipelines: pipelines},
    withPostPipelines(pipelines):: self + {postpipelines: pipelines},
    withFinishSuccessPipelines(pipelines):: self + {finishsuccesspipelines: pipelines},
    withFinishFailurePipelines(pipelines):: self + {finishfailurepipelines: pipelines},
    addInitPipelines(pipelines)::
        local prev = if std.objectHas(self, 'initpipelines') then self.initpipelines else [];
        local s = if std.type(pipelines) == 'array' then pipelines else [pipelines];
        self + { initpipelines: prev + s },
    addPrePipelines(pipelines)::
        local prev = if std.objectHas(self, 'prepipelines') then self.prepipelines else [];
        local s = if std.type(pipelines) == 'array' then pipelines else [pipelines];
        self + { prepipelines: prev + s },
    addPipelines(pipelines)::
        local prev = if std.objectHas(self, 'pipelines') then self.pipelines else [];
        local s = if std.type(pipelines) == 'array' then pipelines else [pipelines];
        self + { pipelines: prev + s },
    addPostPipelines(pipelines)::
        local prev = if std.objectHas(self, 'postpipelines') then self.postpipelines else [];
        local s = if std.type(pipelines) == 'array' then pipelines else [pipelines];
        self + { postpipelines: prev + s },
    addFinishSuccessPipelines(pipelines)::
        local prev = if std.objectHas(self, 'finishsuccesspipelines') then self.finishsuccesspipelines else [];
        local s = if std.type(pipelines) == 'array' then pipelines else [pipelines];
        self + { finishsuccesspipelines: prev + s },
    addFinishFailurePipelines(pipelines)::
        local prev = if std.objectHas(self, 'finishfailurepipelines') then self.finishfailurepipelines else [];
        local s = if std.type(pipelines) == 'array' then pipelines else [pipelines];
        self + { finishfailurepipelines: prev + s },
    render()::
        local init = [p.name for p in self.initpipelines];
        local pre  = [p.name for p in self.prepipelines];
        local main = [p.name for p in self.pipelines];
        local post = [p.name for p in self.postpipelines];
        [
            s for s in self.secrets
           ]
           +
           [
            p for p in self.initpipelines
           ]
           +
           [
            p.addDependsOn(init)
            for p in self.prepipelines
           ]
           +
           [
            p.addDependsOn(init + pre)
            for p in self.pipelines
           ]
           +
           [
            p.addDependsOn(init + pre + main)
            for p in self.postpipelines
           ]
           +
           [
            p.addDependsOn(init + pre + main + post)
            for p in self.finishsuccesspipelines
           ]
           +
           [
            p.withTrigger((if std.objectHas(p, 'trigger') then p.trigger else {}) + { status: ['failure'] })
            for p in self.finishfailurepipelines
           ]
};


base
