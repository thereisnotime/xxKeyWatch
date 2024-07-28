# xxKeyWatch

A tool that monitors remote endpoints for allowed SSH keys and adds them to your local user.

## ✨ Description

TODO

### 🎥 Demo

TODO - Add a demo here.

## 📝 Table of Contents

- [xxKeyWatch](#xxkeywatch)
  - [✨ Description](#-description)
    - [🎥 Demo](#-demo)
  - [📝 Table of Contents](#-table-of-contents)
  - [👍 Pros](#-pros)
  - [👎 Cons](#-cons)
  - [🔩 Technical Details](#-technical-details)
  - [🛠️ Installation](#️-installation)
    - [Via Git](#via-git)
    - [Automate - Setup a Cron Job](#automate---setup-a-cron-job)
    - [Automate - Setup a Systemd Service](#automate---setup-a-systemd-service)
  - [🗑️ Uninstallation](#️-uninstallation)
  - [📚 Usage](#-usage)
  - [📁 Folder Structure](#-folder-structure)
  - [⚙️ Compatability](#️-compatability)
  - [🚀 Roadmap](#-roadmap)
  - [📜 License](#-license)
  - [🙏 Acknowledgements](#-acknowledgements)
  
## 👍 Pros

- **Secure**: Uses TLS for communication.
- **Simple**: Easy to install and use.
- **Lightweight**: Uses minimal resources.
- **Configurable**: Can be configured to run at specific intervals.
- **Flexible**: Can be configured to manage keys of multiple users or all users.
- **Open Source**: You can audit the code and modify it to your needs.

## 👎 Cons

- **Single Point of Failure**: Advanced MITM attacks can become an attack vector.

## 🔩 Technical Details

TODO

## 🛠️ Installation

TODO

### Via Git

This will 'install' the tool in your current user's home directory.

```bash
git clone https://github.com/thereisnotime/xxKeyWatch $HOME/.xxKeyWatch
cd $HOME/.xxKeyWatch && cp .env.example .env
chmod +x xxkeywatch.sh
# NOTE: Configure the .env file as needed.
```

### Automate - Setup a Cron Job

If you want to monitor for key changes every 15 minutes, you can add a cron job like this:

```bash
(crontab -l 2>/dev/null; echo "*/15 * * * * $HOME/.xxKeyWatch/xxkeywatch.sh") | crontab -
```

### Automate - Setup a Systemd Service

TODO - Add user and root options.

If you want to monitor for key changes every 15 minutes, you can add a systemd service like this:

```bash
mkdir -p ~/.config/systemd/user && \
echo -e "[Unit]\nDescription=Run xxKeyWatch\n\n[Service]\nType=simple\nExecStart=$HOME/.xxKeyWatch/xxkeywatch.sh" > ~/.config/systemd/user/xxkeywatch.service && \
echo -e "[Unit]\nDescription=Runs xxKeyWatch every 15 minutes\n\n[Timer]\nOnCalendar=*:0/15\nPersistent=true\n\n[Install]\nWantedBy=timers.target" > ~/.config/systemd/user/xxkeywatch.timer && \
systemctl --user daemon-reload && \
systemctl --user enable --now xxkeywatch.timer
```

## 🗑️ Uninstallation

TODO - Add user and root options.

You can just do:

```bash
rm -rf $HOME/.xxKeyWatch
```

And remove crons or services you have set up for it.

```bash
crontab -e # Remove the cron job
rm -rf ~/.config/systemd/user/xxkeywatch.* # Remove the systemd service and timer
systemctl --user daemon-reload
```

## 📚 Usage

Simple manual usage is as follows:

```bash
bash xxkeywatch.sh
```

## 📁 Folder Structure

```text
.
├── 📦 xxKeyWatch
├── .env - Configuration file for the script.
├── .env.example - Example of above.
├── xxKeyWatch.log - Default log file for the execution logs.
└── xxkeywatch.sh - The script itself.
```

## ⚙️ Compatability

Should work fine with all POSIX compliant shells (and some of the not fully compliant ones). Tested with the following combinations:

- Debian/Ubuntu
- bash/zsh/fish

## 🚀 Roadmap

We dun did it so far but here are some things we might do in the future:

- [ ] Create a basic PoC.
- [ ] Add an auptoupdate mechanism with an example automation setup.
- [ ] Add a mechanism to allow full or partial key management.
- [ ] ADd a test mechanism with a temporary container to test the script.
- [ ] Add a mechanism for user management (full or partial).
- [ ] Add a mechanism to manage SSH parameters for users.
- [ ] Add a mechanism to specify sudo password.
- [ ] Add a mechanism to support encrypted data on the remote endpoints.

## 📜 License

Check the [LICENSE](LICENSE) file for more information.

## 🙏 Acknowledgements

TODO
