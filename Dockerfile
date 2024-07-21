FROM python:3.9-slim

WORKDIR /app

COPY . /app

# Update package lists
RUN apt-get update

RUN apt-get install -y  \
    netcat-openbsd \
    fortune-mod \
    cowsay \
    && rm -rf /var/lib/apt/lists/*

RUN chmod +x wisecow.sh

EXPOSE 4499

CMD ["./wisecow.sh"]
