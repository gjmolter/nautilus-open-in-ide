# Nautilus "Open in IDE" Extension

A Python extension for the Nautilus file manager that adds a right-click context menu item to open files and folders directly in your preferred IDE (VS Code, Cursor, etc).

## Features

**Open Files & Folders**: Select one or more files or folders, right-click, and open them in a new IDE window.
**Open Current Directory**: Right-click on the background of any folder to open the entire directory in your IDE.
**Multiple IDE Support**: Works with VS Code, Cursor, or any custom IDE command.

## Requirements

**Python Bindings for Nautilus**: You must have the `python3-nautilus` package installed. This package allows Python scripts to interact with Nautilus.
**IDE Installation**: By default it calls the `code` command, but you can configure it for any IDE. You can change the command via the `NAUTILUS_OPEN_IDE_BIN` environment variable and the menu label via the `NAUTILUS_OPEN_IDE_LABEL` environment variable. The context menu will dynamically show "Open in Code", "Open in Cursor", or "Open in [Your IDE]" based on your configuration.

Might not be compatible with some Nautilus versions, works for me on v46.

## Installation

You can install it quickly by opening a terminal in this folder and running:

````bash
chmod +x ./install.sh
sudo ./install.sh
```

> Quick Reminder: Always read scripts you get from ramdom people on the internet (like me) before running them.
> If you don't want to read/run it and prefers to install manually, follow these steps:

### 1. Install Dependencies

First, install the necessary Python bindings for Nautilus using your distribution's package manager.

- **For Debian / Ubuntu:**

  ```bash
  sudo apt update
  sudo apt install python3-nautilus
````

- **For Fedora:**

  ```bash
  sudo dnf install python3-nautilus
  ```

### 2. Place the Extension File

You need to place the Python script file in the Nautilus extensions directory.

First, create the directory if it doesn't exist:

```bash
mkdir -p ~/.local/share/nautilus-python/extensions/
```

Next, copy the extension file `open_in_ide.py` into that directory.

### 3. Restart Nautilus

For the extension to be loaded, you must completely quit Nautilus. The easiest way is to run:

```bash
nautilus -q
```

After running the command, open your file manager again. The extension will now be active.
