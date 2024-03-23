IMAGE := localhost/playbook-runner

define podman-run
podman run --rm -it \
	--ipc host \
	-v '${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}:z' \
	-v '${HOME}/.ssh:/root/.ssh:z' \
	-v '$(CURDIR):$(CURDIR):z' \
	-w '$(CURDIR)' \
	-e SSH_AUTH_SOCK \
	$(IMAGE)
endef

.PHONY: all clean image ansible-lint ansible-playbook

all:
	echo $(podman-run)

clean:
	buildah rmi $(IMAGE)

image:
	podman build -t $(IMAGE) -f Containerfile .

ansible-lint:
	@$(podman-run) ansible-lint $(ARGS)

ansible-playbook:
	@$(podman-run) ansible-playbook $(ARGS)
