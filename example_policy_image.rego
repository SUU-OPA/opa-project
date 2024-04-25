package admission

import future.keywords

import rego.v1
import future.keywords

default deny = true

deny := false if {
    not any_wrong_registry
}

any_wrong_registry if {
    some container
    input_containers[container]
	not startswith(container.image, "foo.com/")
}

input_containers contains container if {
	container := input.request.object.spec.containers[_]
}
