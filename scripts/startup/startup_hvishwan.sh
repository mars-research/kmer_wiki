#!/bin/sh

# installs oh-my-tmux and ugdb (+rust)
# run as user, not sudo

cd ~
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
sed -i -E 's!(C-a)!C-q!' ~/.tmux.conf &&
echo "#####################################"
echo "[INFO] Installing oh-my-tmux ... DONE"
echo "#####################################"

cd ~
curl https://sh.rustup.rs -sSf > install_rust.sh &&
chmod +x install_rust.sh &&
./install_rust.sh -y &&
cargo install ugdb &&
echo "######################################"
echo "[INFO] Installing rust + ugdb ... DONE"
echo "######################################"
