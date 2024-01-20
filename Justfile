DOMAIN := 'elektrubadur.se'
IMAGE := 'localhost/playbook-runner'

default:
    just --list

build_image:
    #!/bin/bash

    set -xeuo pipefail

    buildah images -q "{{ IMAGE }}" && exit 0

    ctr="$(buildah from fedora)"
    buildah run "$ctr" dnf -y install ansible-core ansible-lint git
    buildah run "$ctr" dnf clean all
    buildah run "$ctr" rm -rf /var/cache/dnf
    buildah commit $ctr "{{ IMAGE }}"

_in_container *args: build_image
    podman run --rm -it \
    --ipc host \
    -v '{{ env_var("SSH_AUTH_SOCK")}}:{{ env_var("SSH_AUTH_SOCK") }}:z' \
    -v '{{ env_var("HOME") }}/.ssh:/root/.ssh:z' \
    -v '{{ justfile_directory() }}:{{ justfile_directory() }}:z' \
    -w '{{ justfile_directory() }}' \
    -e SSH_AUTH_SOCK \
    '{{ IMAGE }}' \
    {{ args }}

ansible-lint *args:
    @just _in_container ansible-lint {{ args }}

ansible-playbook *args:
    @just _in_container ansible-playbook {{ args }}

clean:
    buildah rmi "{{ IMAGE }}"
