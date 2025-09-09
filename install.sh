#!/bin/bash

echo "------------------------------------------------------"
echo "Nautilus 'Open in IDE' Extension Installer"
echo "------------------------------------------------------"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT_TEMPLATE=$(cat "$SCRIPT_DIR/open_in_ide.py")
EXTENSION_FILE_NAME="open_in_ide.py" 
INSTALL_DIR="$HOME/.local/share/nautilus-python/extensions"
PACKAGE_NAME="python3-nautilus"

install_package() {
    local pkg_name="$1"
    echo "Attempting to install '$pkg_name'..."

    if command -v apt &> /dev/null; then
        echo "Detected Debian/Ubuntu (apt)..."
        sudo apt update && sudo apt install -y "$pkg_name"
    elif command -v dnf &> /dev/null; then
        echo "Detected Fedora (dnf)..."
        sudo dnf install -y "$pkg_name"
    elif command -v pacman &> /dev/null; then
        echo "Detected Arch Linux (pacman)..."
        sudo pacman -S --noconfirm "$pkg_name"
    elif command -v zypper &> /dev/null; then
        echo "Detected openSUSE (zypper)..."
        sudo zypper install -y "$pkg_name"
    elif command -v yum &> /dev/null; then
        echo "Detected RHEL/CentOS (yum)..."
        sudo yum install -y "$pkg_name"
    else
        echo "------------------------------------------------------"
        echo "Error: Could not determine your package manager."
        echo "Please install '$pkg_name' manually."
        echo "------------------------------------------------------"
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "------------------------------------------------------"
        echo "Error: Package installation failed for '$pkg_name'."
        echo "Please check your internet connection or try installing it manually."
        echo "------------------------------------------------------"
        exit 1
    fi
    echo "'$pkg_name' installed successfully (or already present)."
}

CHOSEN_IDE_CMD=""
IDE_LABEL=""

echo ""
echo "------------------------------------------------------"
echo "Which IDE would you like to open files/folders with?"
echo "1) VS Code (command: code)"
echo "2) Cursor (command: cursor)"
echo "3) Other (specify your own command and label)"
echo "------------------------------------------------------"
read -p "Enter your choice (1, 2, or 3): " IDE_CHOICE

case "$IDE_CHOICE" in
    1)
        CHOSEN_IDE_CMD="code"
        IDE_LABEL="Open in Code"
        ;;
    2)
        CHOSEN_IDE_CMD="cursor"
        IDE_LABEL="Open in Cursor"
        ;;
    3)
        echo "Enter the command for your preferred IDE."
        read -p "Command: " CUSTOM_CMD
        if [ -z "$CUSTOM_CMD" ]; then
            echo "Error: Custom command cannot be empty. Aborting."
            exit 1
        fi
        read -p "Enter the label for the menu item: " CUSTOM_LABEL
        if [ -z "$CUSTOM_LABEL" ]; then
            echo "Error: Custom label cannot be empty. Aborting."
            exit 1
        fi
        CHOSEN_IDE_CMD="$CUSTOM_CMD"
        IDE_LABEL="$CUSTOM_LABEL"
        ;;
    *)
        echo "Invalid choice. Aborting installation."
        exit 1
        ;;
esac

echo ""
echo "Checking if '$CHOSEN_IDE_CMD' is available in your PATH..."
if ! command -v "$CHOSEN_IDE_CMD" &> /dev/null; then
    echo "Warning: The command '$CHOSEN_IDE_CMD' was not found in your PATH."
    echo ""
    read -p "Press Enter to continue, or Ctrl+C to abort if your IDE is not installed/configured..."
fi

echo "1. Installing 'python3-nautilus' bindings... (might need sudo)"
install_package "$PACKAGE_NAME"

echo "2. Creating extension directory if it doesn't exist..."
mkdir -p "$INSTALL_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Could not create directory '$INSTALL_DIR'."
    exit 1
fi
echo "Extension directory: $INSTALL_DIR"

echo "3. Creating the Nautilus extension script..."
FINAL_PYTHON_SCRIPT=$(echo "$PYTHON_SCRIPT_TEMPLATE" | sed "s|IDE_COMMAND_PLACEHOLDER|$CHOSEN_IDE_CMD|g" | sed "s|IDE_LABEL_PLACEHOLDER|$IDE_LABEL|g")
echo "$FINAL_PYTHON_SCRIPT" > "$INSTALL_DIR/$EXTENSION_FILE_NAME"
if [ $? -ne 0 ]; then
    echo "Error: Could not write extension file '$INSTALL_DIR/$EXTENSION_FILE_NAME'."
    exit 1
fi
echo "Extension script '$EXTENSION_FILE_NAME' placed, configured for '$CHOSEN_IDE_CMD' with label '$IDE_LABEL'."

echo "4. Restarting Nautilus to load the extension..."
nautilus -q
if [ $? -ne 0 ]; then
    echo "Warning: Failed to gracefully quit Nautilus. It might be already closed."
fi
echo "Nautilus restart command issued."

echo ""
echo "------------------------------------------------------"
echo "Installation complete!"
echo "The '$IDE_LABEL' option should now appear in Nautilus"
echo "context menus. If not, try logging out and logging back in."
echo ""
echo "Your chosen IDE command: '$CHOSEN_IDE_CMD'"
echo "Your chosen menu label: '$IDE_LABEL'"
echo "To change them later without reinstalling, set the environment variables:"
echo "  export NAUTILUS_OPEN_IDE_BIN=\"/path/to/new_ide_command\""
echo "  export NAUTILUS_OPEN_IDE_LABEL=\"New Menu Label\""
echo "------------------------------------------------------"

exit 0