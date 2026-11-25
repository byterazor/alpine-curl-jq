local project = {
    new(projectId, name):: self.withProjectId(projectId).withName(name).withNotPublic(),
    withProjectId(id):: self + {projectId: id},
    withName(name):: self + {name: name},
    withCategory(category):: self + {category: category},
    withParent(parent):: self + {parent: parent},
    withPublic():: self + {public: true},
    withNotPublic():: self + {public: false}
};

project
