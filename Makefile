IMAGE := localhost/playbook-runner

define podman-run
podman run --rm -it \
   --ipc host \
	-v '${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}:z' \
	-v '${HOME}/.ssh:/root/.ssh:z' \
	-v '${PWD}:${PWD}:z' \
	-w '${PWD}' \
	-e SSH_AUTH_SOCK \
	$(IMAGE)
endef

.PHONY: all clean image ansible-lint ansible-playbook

all:
	echo $(podman-run)

clean:
	buildah rmi $(IMAGE)

image:
	$(eval CTR := $(shell buildah from fedora))
	buildah run $(CTR) dnf -y install ansible-core ansible-lint git
	buildah run $(CTR) dnf clean all
	buildah run $(CTR) rm -rf /var/cache/dnf
	buildah commit $(CTR) $(IMAGE)

ansible-lint:
	@$(podman-run) ansible-lint $(ARGS)

ansible-playbook:
	@$(podman-run) ansible-playbook $(ARGS)
