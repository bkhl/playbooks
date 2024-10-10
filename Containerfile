FROM fedora:40

RUN dnf -y install ansible-core ansible-lint git && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    ansible-galaxy collection install ansible.posix
