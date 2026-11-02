local base = {
    new(cluster):: self.withCluster(cluster),
    withCluster(cluster):: self + { cluster: cluster },
    withCommand(command):: self + { command: command}
};


base
