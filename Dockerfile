FROM pytorch/pytorch:1.2-cuda10.0-cudnn7-devel

COPY deepMirCut /opt/deepMirCut
COPY bpRNA /opt/bpRNA
COPY setup-deepMirCut.sh /opt/deepMirCut/
COPY deepMirCut_predict.py /opt/deepMirCut/
WORKDIR /opt/deepMirCut

ENV DEBIAN_FRONTEND=noninteractive

# Install wget to fetch
RUN apt-get update && \
    apt-get install -y wget zlib1g && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /opt && \
    wget https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_4_x/ViennaRNA-2.4.18.tar.gz -O ViennaRNA-2.4.18.tar.gz && \
    tar -xzf ViennaRNA-2.4.18.tar.gz && \
    cd ViennaRNA-2.4.18 && \
    mkdir build && \
    ./configure --prefix=/opt/ViennaRNA-2.4.18/build && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm ViennaRNA-2.4.18.tar.gz

ENV PATH="/opt/ViennaRNA-2.4.18/build/bin:${PATH}"
ARG PATH="/opt/ViennaRNA-2.4.18/build/bin:${PATH}"

ENV LD_LIBRARY_PATH="/opt/ViennaRNA-2.4.18/build/lib:${LD_LIBRARY_PATH}"
ARG LD_LIBRARY_PATH="/opt/ViennaRNA-2.4.18/build/lib:${LD_LIBRARY_PATH}"

ENV PKG_CONFIG_PATH="/opt/ViennaRNA-2.4.18/build/pkgconfig"
ARG PKG_CONFIG_PATH="/opt/ViennaRNA-2.4.18/build/pkgconfig"

RUN chmod +x /opt/bpRNA/bpRNA.pl

ENV PATH="/opt/bpRNA:${PATH}"
ARG PATH="/opt/bpRNA:${PATH}"

ENV PERL5LIB="/opt/perl5/lib/perl5"
ARG PERL5LIB="/opt/perl5/lib/perl5"

ENV PATH="/opt/perl5/bin:${PATH}"
ARG PATH="/opt/perl5/bin:${PATH}"

RUN mkdir -p /opt/perl5 && \
    curl -L https://cpanmin.us | perl - --local-lib=/opt/perl5 App::cpanminus && \
    cpanm install Graph

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
    
RUN mamba env create -f deepMirCut_env.yml -y

RUN bash setup-deepMirCut.sh

RUN echo "conda activate dmc" >> /root/.bashrc

