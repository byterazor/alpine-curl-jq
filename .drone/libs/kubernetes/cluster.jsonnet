local base = {
    new(url):: self.withUrl(url),
    withUrl(url):: self + { url: url },
    withUsername(username):: self + {username: username},
    withToken(token):: self + { token: token},
    withCrt(crt):: self + { crt: crt},
    withNamespace(ns):: self + {ns: ns}
};


base
