local project = {
    new(projectId, name):: self.withProjectId(projectId).withName(name),
    withProjectId(id):: self + {projectId: id},
    withName(name):: self + {name: name},
    withCategory(category):: self + {category: category},
    withParent(parent):: self + {parent: parent},
};

project
