local imageBase = import 'image.jsonnet';

local base = {
    new(name):: imageBase.new(name) + self.withReadme("README.md"),
    withArchs(archs):: self + if std.type(archs) == 'array' then { archs: archs } else { archs: [archs] },
    withReadme(readme):: self + {readme: readme}
};


base
