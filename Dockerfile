FROM pytorch/pytorch:1.2-cuda10.0-cudnn7-devel

COPY deepMirCut /usr/local/deepMirCut
COPY bpRNA /usr/local/deepMirCut/bpRNA
COPY deepMirCut_env_viennarna.yml /usr/local/deepMirCut/
COPY setup-deepMirCut.sh /usr/local/deepMirCut/
WORKDIR /usr/local/deepMirCut

ENV DEBIAN_FRONTEND=noninteractive

# Install wget to fetch
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://www.cpan.org/authors/id/E/ET/ETJ/Graph-0.9735.tar.gz -O Graph-0.9735.tar.gz && \
    tar xzf Graph-0.9735.tar.gz && \
    cd Graph-0.9735 && \
    perl Makefile.PL && \
    make && \
    make install && \
    cd .. && \
    rm Graph-0.9735.tar.gz

ENV PATH="/opt/miniforge3/bin:${PATH}"
ARG PATH="/opt/miniforge3/bin:${PATH}"

# Install Miniforge on x86 or ARM platforms
RUN arch=$(uname -m) && \
    if [ "$arch" = "x86_64" ]; then \
    MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"; \
    elif [ "$arch" = "aarch64" ]; then \
    MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh"; \
    else \
    echo "Unsupported architecture: $arch"; \
    exit 1; \
    fi && \
    wget $MINIFORGE_URL -O miniforge.sh && \
    mkdir -p /opt/.conda && \
    bash miniforge.sh -b -p /opt/miniforge3 && \
    rm -f miniforge.sh
    
RUN /opt/miniforge3/bin/conda init bash && \
    /opt/miniforge3/bin/conda config --add channels bioconda && \
    /opt/miniforge3/bin/conda config --add channels conda-forge && \
    /opt/miniforge3/bin/conda update conda -y && \
    /opt/miniforge3/bin/conda clean -afy
    
RUN mamba env create -f deepMirCut_env_viennarna.yml -y

RUN bash setup-deepMirCut.sh

SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]

