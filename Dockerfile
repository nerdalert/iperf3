FROM debian:latest

MAINTAINER Brent Salisbury <brent.salisbury@gmail.com>

# build intial apt binary cache and install wget
RUN apt-get update \
    && apt-get install -y iperf3

# clean up cached binaries after install
RUN apt-get clean

# Expose the default iperf3 server port
EXPOSE 5201

# entrypoint allows you to pass your arguments to the container at runtime
# very similar to a binary you would run. For example, in the following
# docker run -it <IMAGE> --help' is like running 'iperf3 --help'
ENTRYPOINT ["iperf3"]
