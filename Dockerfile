# iperf3 in a container
#
# Run as Server:
# docker run  -it --rm --name=iperf3-srv -p 5201:5201 networkstatic/iperf3 -s
#
# Run as Client (first get server IP address):
# docker inspect --format "{{ .NetworkSettings.IPAddress }}" iperf3-srv
# docker run  -it --rm networkstatic/iperf3 -c <SERVER_IP>
#
FROM debian:trixie-slim AS builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       curl \
       ca-certificates \
       libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ARG IPERF3_VERSION=3.21
RUN curl -fsSL https://github.com/esnet/iperf/releases/download/${IPERF3_VERSION}/iperf-${IPERF3_VERSION}.tar.gz \
    | tar xz -C /tmp \
    && cd /tmp/iperf-${IPERF3_VERSION} \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install DESTDIR=/tmp/iperf3-install

FROM debian:trixie-slim
LABEL maintainer="Brent Salisbury <brent.salisbury@gmail.com>"
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/iperf3-install/usr /usr

# Expose the default iperf3 server port
EXPOSE 5201

# entrypoint allows you to pass your arguments to the container at runtime
# very similar to a binary you would run. For example, in the following
# docker run -it <IMAGE> --help' is like running 'iperf3 --help'
ENTRYPOINT ["iperf3"]

