# dot-files

1. save back ups
```bash
mv ~/.gitconfig ~/.gitconfig.backup
mv ~/.vimrc ~/.vimrc.backup
mv ~/.zshrc ~/.zshrc.backup
```

1. create sym links
```bash
ln -s /Users/laurengregg/dot-files/.gitconfig ~/.gitconfig
ln -s /Users/laurengregg/dot-files/.vimrc ~/.vimrc
ln -s /Users/laurengregg/dot-files/.zshrc ~/.zshrc
```
1. verify 
```bash
ls -l ~/.gitconfig ~/.vimrc  ~/.zshrc
```

You should see something like: 
```bash
.gitconfig -> /Users/laurengregg/dot-files/.gitconfig
.vimrc -> /Users/laurengregg/dot-files/.vimrc
```

1. Apply or Test
For .gitconfig:
```bash
git config --global --list
```

For .vimrc:
Open Vim and confirm settings are applied: `vim`. 

To load your new .zshrc right away:
```bash
source ~/.zshrc
```
