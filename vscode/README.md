
### Settings
Steps to use provided settings.json
* press the “Ctrl + Shift + P” shortcut to access the Command Palette.
* Type “Settings.json” in the search bar and select the specific settings.json file
* Copy and paste the settings.json file into the user settings file

#### Theme
- [gruvbox](https://marketplace.visualstudio.com/items?itemName=jdinhlife.gruvbox)

### Keybindings
For user who would like to use my vscode settings, please follow the steps in this [link](https://code.visualstudio.com/docs/getstarted/keybindings) to set up the keybindings.

The philosophy of my keybindings is to use the same intuition of keybindings as vim.

#### Read first

* To open a file/dir in terminal, use `code` command and file/dir following it
* The vim extension is enabled by default, and `jj` is used instead of `Esc` since normal mode is the most used mode in vim
* User could use `j/k` to move up/down in the file explorer instead of arrow keys
* `Enter` to open the file in the current window and `r` to rename the file
* `Enter` to toggle the folder when foucs on a folder
* `Ctrl + Enter` to open the file in a splited window
* `E`/`R` is modified to goto next/previous tab like [surfingkeys](https://github.com/brookhong/Surfingkeys) in normal mode
* leader key is set to `Space`
* `<Leader> cn/cp` to go to next/previous error suggested by the linter

##### Ctrl keybindings tutorial
* `Ctrl + h/l` to switch between splited windows/compared files, h for left, l for right
* `Ctrl + f` to jump to the definition of the function, really useful for python

#### Cmd keybindings tutorial
* `Cmd + P` to open a file of the current project
* `Cmd + Shift + P` to open the vscode command palette
* `Cmd + J` to toggle the terminal window
* `Cmd + J` to the next sidebar view (when foucs on sidebar / quickopen)
* `Cmd + K` to the previous sidebar view (when foucs on sidebar / quickopen)
* `Cmd + H/L` to switch focus between text editor and file explorer sidebar
* `Cmd + H` to the previous panel view (when foucs on panel)
* `Cmd + L` to the next panel view (when foucs on panel)
* `Cmd + E` to toggle the file explorer
* `Cmd + Shift + F` to search text in the current project,
 and after pressing `Enter`, you could use `j`/`k` to move up/down in the search result.
 Pres `Enter` again to open the file in the current window.

##### Ctrl+a hotkey tutorial
* `Ctrl+a cmd+v` to toggle Vim extension
* `Ctrl+a t` to focus on the terminal
* `Ctrl+a c` to compare the current file with the selected file
* `Ctrl+a p` to display markdown/latex preview in other groups
* `Ctrl+a x` to close text editor in other groups, useful when you splited windows and close it.
 Could combine with `Ctrl+a p` to close the splited preview window

### Plugins

#### General
- [vim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim)
- [copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)
- [gitlens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [remote ssh](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)

#### Language Specific
- [python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
- [jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
- [latex-workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
- [markdown](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
- [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)

### Extensions

#### Frome the Command Palette
* press the “Ctrl + Shift + P” shortcut to access the Command Palette.
* Type “extensions” in the search bar and select the specific extensions.json file.
* Copy and paste the extensions.json file into the user settings file.


#### From terminal

Save the extenstions to a file (vscode_ext.txt)
```shell
code --list-extensions > vscode_ext.txt
```

Install the extensions from the file
```shell
cat vscode_ext.txt | xargs -L 1 code --install-extension
```
