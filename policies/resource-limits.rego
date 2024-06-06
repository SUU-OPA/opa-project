package kubernetes.admission

import rego.v1

import data.kubernetes.ingress

max_cpu = 2
max_memory = 4 * 1024 * 1024 * 1024

deny contains msg if {
    container := input.request.object.spec.template.spec.containers[_]
	not container.resources.limits.cpu
    msg := sprintf("Pod contains container %v without cpu limit defined.", [container.name])
}

deny contains msg if {
    container := input.request.object.spec.template.spec.containers[_]
	not container.resources.limits.memory
    msg := sprintf("Pod contains container %v without memory limit defined.", [container.name])
}

deny contains msg if {
	container := input.request.object.spec.template.spec.containers[_]
	memory := parse_memory(container.resources.limits.memory)
    memory > max_memory

    msg := sprintf("Container %v in the pod exceeds resource quotas. Memory: %v Memory limit: %v", [container.name, container.resources.limits.memory, max_memory])
}

deny contains msg if {
	container := input.request.object.spec.template.spec.containers[_]
    cpu := parse_cpu(container.resources.limits.cpu)
	cpu > max_cpu

    msg := sprintf("Container %v in the pod exceeds resource quotas. CPU: %v CPU limit: %v", [container.name, container.resources.limits.cpu, max_cpu])
}

parse_memory(mem) = result if {
	endswith(mem, "G")
	num_str := substring(mem, 0, count(mem) - 2)
	num := to_number(num_str)
	result := num * 1e9
}

parse_memory(mem) = result if {
	endswith(mem, "M")
	num_str := substring(mem, 0, count(mem) - 2)
	num := to_number(num_str)
	result := num * 1e6
}

parse_memory(mem) = result if {
	endswith(mem, "K")
	num_str := substring(mem, 0, count(mem) - 2)
	num := to_number(num_str)
	result := num * 1e3
}

parse_memory(mem) = result if {
	endswith(mem, "Gi")
	num_str := substring(mem, 0, count(mem) - 2)
	num := to_number(num_str)
	result := num * 1024 * 1024 * 1024
}

parse_memory(mem) = result if {
	endswith(mem, "Mi")
	num_str := substring(mem, 0, count(mem) - 2)
	num := to_number(num_str)
	result := num * 1024 * 1024
}

parse_memory(mem) = result if {
	endswith(mem, "Ki")
	num_str := substring(mem, 0, count(mem) - 2)
	num := to_number(num_str)
	result := num * 1024
}

parse_cpu(cpu) = result if {
	endswith(cpu, "m")
	num_str := substring(cpu, 0, count(cpu) - 2)
	num := to_number(num_str)
	result := num * 0.001
}

parse_cpu(cpu) = result if {
	num := to_number(cpu)
	result := num
}