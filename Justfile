DOMAIN := 'elektrubadur.se'
IMAGE := 'playbook-runner'

default:
    just --list

build_image:
    podman build -f Containerfile -t '{{ IMAGE }}' .

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
