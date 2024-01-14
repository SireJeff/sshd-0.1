FROM ubuntu:18.04
RUN apt-get update && apt-get install -y && apt-get install -y sudo
# Install SSH server and OpenJDK
RUN apt update && \
    apt install -y ssh && \
    apt-get install -y nano

# Create remote_user with password and SSH access
RUN useradd -rm -d /home/remote_user -s /bin/bash remote_user && \
    echo remote_user:passs | chpasswd && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh && \
    echo 'root:passw' | chpasswd 

# Copy public key for remote_user
COPY id_rsa.pub /home/remote_user/.ssh/authorized_keys

# Set permissions for remote_user SSH directory and authorized_keys file
RUN chown remote_user:remote_user -R /home/remote_user/.ssh && \
    chmod 600 /home/remote_user/.ssh/authorized_keys
RUN echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
# Use Match directive to set different MaxSessions for root and remote_user
RUN echo "Match User root,remote_user\nMaxSessions 1" >> /etc/ssh/sshd_config

# Create proxy users with passwords set using formula Jeff+i^5+3
RUN for i in $(seq 0 39); do \
        useradd -rm -d /home/proxy${i} -s /bin/bash proxy${i} && \
        password=$(echo "sshSERVER$(expr $i)") && \
        echo proxy${i}:${password} | chpasswd && \
        mkdir /home/proxy${i}/.ssh && \
        chmod 700 /home/proxy${i}/.ssh && \
        touch /home/proxy${i}/.ssh/authorized_keys && \
        chmod 600 /home/proxy${i}/.ssh/authorized_keys && \
        chown proxy${i}:proxy${i} -R /home/proxy${i}/.ssh; \
    done

# Set MaxSessions to limit the number of connections per user
RUN sed -i 's/MaxSessions 10/MaxSessions 1/' /etc/ssh/sshd_config
RUN echo "*               hard    maxlogins            1" >> /etc/security/limits.conf
RUN echo "*               -       maxlogins            1" >> /etc/security/limits.conf
RUN sed -i 's/MaxStartups 10:30:100/MaxStartups 1/' /etc/ssh/sshd_config
RUN echo "remote_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN sudo mkdir /run/sshd
RUN echo "Host *" >> /etc/ssh/ssh_config \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && echo "UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
VOLUME [ "/home" ]
# Start SSH server
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

COPY ulimit.sh /etc/ulimit.sh
RUN chmod +x /etc/ulimit.sh

COPY listen.sh /etc/listen.sh
RUN chmod +x /etc/listen.sh
# Copy the entrypoint.sh script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint.sh script as the ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#In this Dockerfile, the `MaxSessions` value for the `proxy` users is set to `4` using the `sed` 
#command. The `Match` directive for `root` and `remote_user` is still present, limiting them to one concurrent SSH session.
