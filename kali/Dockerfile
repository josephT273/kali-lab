FROM kalilinux/kali-rolling:latest

LABEL maintainer="NovaSpectra"
LABEL description="Dockerized Kali hacking lab - CLI only, no GUI"

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# ── Base system ──────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git vim nano tmux unzip \
    build-essential gcc g++ make cmake python3 python3-pip python3-venv python3-dev \
    bash-completion zsh less man-db \
    net-tools iputils-ping traceroute dnsutils whois \
    nmap nikto sqlmap gobuster ffuf \
    wfuzz hydra medusa \
    httpie \
    netcat-openbsd tcpdump wireshark-common tshark \
    masscan hping3 arp-scan \
    openssl sslscan \
    gdb gdb-multiarch \
    radare2 \
    binwalk \
    binutils file xxd bsdextrautils \
    ltrace strace \
    upx-ucl \
    socat \
    wordlists \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Python pentesting libs ────────────────────────────────────────────────────
RUN pip3 install --break-system-packages \
    pwntools \
    requests \
    scapy \
    impacket \
    paramiko \
    cryptography \
    ropper \
    pycparser

# ── pwncat-cs (separate step — needs python3-dev headers) ────────────────────
RUN pip3 install --break-system-packages pwncat-cs || echo "[!] pwncat-cs install failed, skipping"

# ── uv (required by pwndbg setup) ────────────────────────────────────────────
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"

# ── pwndbg (GDB plugin) ───────────────────────────────────────────────────────
RUN git clone --depth=1 https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg && ./setup.sh

# ── Ghidra headless (CLI only) ────────────────────────────────────────────────
ARG GHIDRA_VERSION=11.1.2
ARG GHIDRA_DATE=20240709
RUN wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" \
        -O /tmp/ghidra.zip \
    && unzip -q /tmp/ghidra.zip -d /opt \
    && mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra \
    && rm /tmp/ghidra.zip \
    && apt-get update \
    && apt-get install -y --no-install-recommends default-jdk-headless \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV GHIDRA_HOME=/opt/ghidra
ENV PATH="$PATH:/opt/ghidra/support"

# ── SecLists wordlists ────────────────────────────────────────────────────────
RUN git clone --depth=1 https://github.com/danielmiessler/SecLists /opt/seclists

# ── Entrypoint (recreates workspace dirs at runtime — volume mount hides build-time mkdir) ──
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ── Shell config ──────────────────────────────────────────────────────────────
COPY config/.zshrc /root/.zshrc
COPY config/.tmux.conf /root/.tmux.conf

# ── Set zsh as default shell ──────────────────────────────────────────────────
RUN chsh -s /bin/zsh root

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/zsh"]
