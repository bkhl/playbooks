FROM registry.fedoraproject.org/fedora:38

RUN dnf -y install ansible-core ansible-lint git && dnf clean all && rm -rf /var/cache/dnf
