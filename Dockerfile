FROM debian:stretch as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            build-essential \
            clang \
            bison \
            flex \
            libreadline-dev \
            gawk \
            tcl-dev \
            libffi-dev \
            git \
            pkg-config \
            python3 \
            ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN git clone -b master https://github.com/YosysHQ/yosys.git

WORKDIR /yosys
RUN make -j all && \
    make install


FROM debian:stretch
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libreadline7 libffi6 libtcl8.6 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/yosys* /usr/local/bin/
COPY --from=builder /usr/local/share/yosys /usr/local/share/yosys

RUN useradd -m yosys
USER yosys
ENTRYPOINT ["yosys"]
