# Nautilus "Open in IDE" Extension

A Python extension for the Nautilus file manager that adds a right-click context menu item to open files and folders directly in your preferred IDE (VS Code, Cursor, etc).

## Features

**Open Files & Folders**: Select one or more files or folders, right-click, and open them in a new IDE window.
**Open Current Directory**: Right-click on the background of any folder to open the entire directory in your IDE.
**Multiple IDE Support**: Works with VS Code, Cursor, or any custom IDE command.

## Requirements

**Python Bindings for Nautilus**: You must have the `python3-nautilus` package installed. This package allows Python scripts to interact with Nautilus.
**IDE Installation**: By default it calls the `code` command, but you can configure it for any IDE.

Might not be compatible with some Nautilus versions, works for me on v46.

## Installation

You can install it quickly by opening a terminal in this folder and running:

````bash
chmod +x ./install.sh
sudo ./install.sh
```

> Quick Reminder: Always read scripts you get from random people on the internet (like me) before running them.
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

## Uninstallation

To uninstall the extension, you just need to remove the python script and restart Nautilus:

```bash
rm ~/.local/share/nautilus-python/extensions/open_in_ide.py
nautilus -q
```

## Configuration

The IDE command and label are set during installation. If you want to change them later, you have two options:

1.  **Re-run the installation script**:

    ```bash
    sudo ./install.sh
    ```

2.  **Use environment variables**:

    You can override the installed configuration by setting the following environment variables. This is useful for temporary changes or for testing.

    ```bash
    export NAUTILUS_OPEN_IDE_BIN="/path/to/your/ide"
    export NAUTILUS_OPEN_IDE_LABEL="Open in My Custom IDE"
    ```

    **Note**: Environment variables will always take precedence over the configuration set during installation.

## Troubleshooting

**"Open in IDE" menu does not appear:**

- Ensure that `python3-nautilus` is installed correctly.
- Make sure you have restarted Nautilus completely (`nautilus -q`).
- Check the permissions of the `open_in_ide.py` file in `~/.local/share/nautilus-python/extensions/`.
- Look for errors in the system log (`journalctl -f`) when you restart Nautilus.

**IDE does not open:**

- Verify that the IDE command is correct and that it is in your system's PATH.
- Try running the command directly in your terminal to see if it works.
- If you are using a custom command with special characters, make sure it is properly quoted.
