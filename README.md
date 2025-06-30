
#!/bin/bash

set -e

echo "[*] Updating system..."
sudo apt update && sudo apt -y full-upgrade

echo "[*] Installing base tools..."
sudo apt install -y git curl wget python3 python3-pip python3-venv \
  build-essential gcc g++ make \
  tmux vim nano nmap netcat socat \
  gobuster dirb seclists wfuzz \
  unzip p7zip-full rar unrar \
  gdb gdb-multiarch \
  binwalk steghide exiftool foremost \
  hashcat john hydra \
  docker.io docker-compose \
  fzf fd-find ripgrep \
  zsh fonts-powerline \
  powershell \
  openvpn \
  jq jq \
  ltrace strace \
  default-jre \
  flameshot \
  tcpdump \
  sudo tree htop lsof \
  xclip \
  gobuster ffuf \
  dnsutils whois \
  gh \
  rlwrap \
  pwntools

echo "[*] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "[*] Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "[*] Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "[*] Installing Powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh && cd .. && rm -rf fonts

echo "[*] Configuring .zshrc..."
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi

echo "[*] Downloading SecLists (wordlists)..."
if [ ! -d "/usr/share/seclists" ]; then
  sudo git clone https://github.com/danielmiessler/SecLists.git /usr/share/seclists
fi

echo "[*] Setting zsh as default shell..."
chsh -s $(which zsh)

echo "[*] Installing pipx and Python CTF libs..."
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install pwntools
pipx install r2pipe

echo "[*] All done! Open a new terminal, select a Powerline font (like 'MesloLGS NF'), and enjoy your CTF Kali box."
echo "Don't forget to run 'p10k configure' on your first shell to finish Powerlevel10k setup."
