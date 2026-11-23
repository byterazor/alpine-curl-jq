local redmine = {
    new(name, url):: self.withName(name).withUrl(url),
    withName(name):: self + {name: name},
    withUrl(url):: self + {url: url},
    withSecret(s):: self + {secret: s},
};

redmine
