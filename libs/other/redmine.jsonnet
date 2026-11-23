local redmine = {
    new(name, url):: self.withName(name).withUrl(url),
    withName(name):: self + {name: name},
    withUrl(url):: self + {url: url},
    withSecret(s):: self + {secret: s},
    withExtendedApi():: self + {extendedApi: true},
    apiUrl():: self.url + (if std.objectHas(self, 'extendedApi') && self.extendedApi then '/extended_api' else ''),
};

redmine
