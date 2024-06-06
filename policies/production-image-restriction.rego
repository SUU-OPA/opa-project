package kubernetes.admission

import rego.v1

import data.kubernetes.ingress

allowed_tags = {"stable"}

deny contains msg if {
    input.request.namespace == "production"
    container := input.request.object.spec.template.spec.containers[_]
    image := container.image
    not endswith(image,"stable")
    allowed_tags_list := {tag | tag := allowed_tags[_]}
    msg := sprintf("Image %s does not have an allowed tag. Allowed tags are: %v", [image, allowed_tags])
}
