local base = {
    new(name):: self.withName(name),
    withName(name):: self + {name: name},
    withDescription(desc):: self + {description: desc},
    withHomepage(url):: self + {homepage: url},
};

base
