FROM ubuntu

RUN apt update && apt install -y curl sudo

RUN useradd -m -s /bin/bash testuser

RUN passwd -d testuser

RUN echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN su - testuser

CMD ["bash", "-c", "$(curl -fsSL https://raw.githubusercontent.com/LeighS95/pc-starter/main/run.sh)"]

# apt update && apt install -y curl sudo && useradd -m -s /bin/bash testuser && passwd -d testuser && echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && su - testuser