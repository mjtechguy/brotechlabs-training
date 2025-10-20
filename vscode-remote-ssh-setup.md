# VS Code Remote SSH Setup & CodeLab Extension Installation

This guide walks you through setting up Remote SSH in Visual Studio Code and installing the CodeLab extension in both your local and remote environments.

## Prerequisites

- Visual Studio Code installed on your local machine
- SSH access to a remote server
- SSH key pair (recommended) or password authentication

## Part 1: Setting Up Remote SSH in VS Code

### Step 1: Install Remote SSH Extension

1. Open VS Code
2. Click on the Extensions icon in the sidebar (or press `Ctrl+Shift+X` / `Cmd+Shift+X`)
3. Search for "Remote - SSH"
4. Install the extension published by Microsoft

### Step 2: Configure SSH Connection

#### Option A: Using the Command Palette

1. Press `Ctrl+Shift+P` / `Cmd+Shift+P` to open the Command Palette
2. Type "Remote-SSH: Connect to Host..." and select it
3. Choose "Add New SSH Host..."
4. Enter your SSH connection string:
   ```
   ssh username@hostname
   ```
   Example: `ssh user@192.168.1.100` or `ssh user@example.com`
5. Select the SSH configuration file to update (usually `~/.ssh/config`)

#### Option B: Manual SSH Config File

1. Open your SSH config file:
   - Windows: `C:\Users\YourUsername\.ssh\config`
   - Mac/Linux: `~/.ssh/config`

2. Add your host configuration:
   ```
   Host myserver
       HostName 192.168.1.100
       User username
       Port 22
       IdentityFile ~/.ssh/id_rsa
   ```

3. Save the file

### Step 3: Connect to Remote Host

1. Press `Ctrl+Shift+P` / `Cmd+Shift+P`
2. Type "Remote-SSH: Connect to Host..." and select it
3. Choose your configured host from the list
4. A new VS Code window will open
5. If prompted, enter your password or SSH key passphrase
6. Wait for VS Code to install the VS Code Server on the remote machine

### Step 4: Verify Connection

- Check the bottom-left corner of VS Code - it should show "SSH: hostname"
- You can now open folders and files on the remote machine

## Part 2: Installing CodeLab Extension

The CodeLab extension (v1.1.0) needs to be installed manually using the VSIX file from the GitHub release.

### Installing Locally

1. Download the VSIX file:
   - Go to https://github.com/mjtechguy/codelabv2/releases/tag/v1.1.0
   - Download the `.vsix` file from the release assets

2. Install the extension:
   - Open VS Code (local window, not connected to remote)
   - Press `Ctrl+Shift+P` / `Cmd+Shift+P`
   - Type "Extensions: Install from VSIX..." and select it
   - Browse to the downloaded `.vsix` file and select it
   - Wait for installation to complete
   - Restart VS Code if prompted

### Installing on Remote Server

1. Ensure you're connected to your remote server via SSH in VS Code

2. Download the VSIX file to your remote server:
   ```bash
   cd ~/Downloads  # or any directory of your choice
   wget https://github.com/mjtechguy/codelabv2/releases/download/v1.1.0/[filename].vsix
   ```

   Or transfer the file you downloaded locally:
   ```bash
   scp path/to/extension.vsix username@hostname:~/Downloads/
   ```

3. Install the extension in the remote VS Code:
   - In the VS Code window connected to remote (check bottom-left corner)
   - Press `Ctrl+Shift+P` / `Cmd+Shift+P`
   - Type "Extensions: Install from VSIX..." and select it
   - Browse to the VSIX file location on the remote server
   - Select the file and wait for installation to complete
   - Restart the VS Code window if prompted

### Verifying Installation

**Local Installation:**
- Open Extensions view (`Ctrl+Shift+X` / `Cmd+Shift+X`)
- Search for "CodeLab"
- You should see it listed in the "Installed" section

**Remote Installation:**
- Connect to your remote server
- Open Extensions view
- The extension should appear under the "SSH: hostname" section

## Troubleshooting

### SSH Connection Issues

- **Authentication failed**: Verify your SSH credentials or key permissions
  ```bash
  chmod 600 ~/.ssh/id_rsa
  ```

- **Connection timeout**: Check firewall settings and ensure the remote server is accessible

- **Host key verification failed**: Remove old host keys
  ```bash
  ssh-keygen -R hostname
  ```

### Extension Installation Issues

- **VSIX installation fails**: Ensure you have write permissions and sufficient disk space

- **Extension not working after install**: Try reloading the VS Code window
  - Press `Ctrl+Shift+P` / `Cmd+Shift+P`
  - Type "Developer: Reload Window" and select it

- **Extension works locally but not remotely**: Some extensions need to be installed on both local and remote. CodeLab likely needs to be installed on the remote server to work with remote files.

## Tips

- Use SSH keys instead of passwords for better security and convenience
- Keep your VS Code and extensions updated
- The Remote SSH extension also supports SSH config file features like ProxyJump
- You can have multiple remote connections configured simultaneously

## Additional Resources

- [VS Code Remote SSH Documentation](https://code.visualstudio.com/docs/remote/ssh)
- [SSH Config File Guide](https://www.ssh.com/academy/ssh/config)
- [CodeLab Extension Repository](https://github.com/mjtechguy/codelabv2)
