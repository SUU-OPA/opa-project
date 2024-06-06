package kubernetes.admission

import rego.v1

import data.kubernetes.ingress

deny contains msg if {
    some container
    input_containers[container]
    not startswith(container.image, "docker.io/andrzejstarzyk/suu_")
    image := container.image
    msg := sprintf("invalid image registry %q", [image])
}

input_containers := {container |
    container := input.request.object.spec.template.spec.containers[_]
}
