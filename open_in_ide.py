from gi.repository import Nautilus, GObject
import subprocess
import os

# IDE_COMMAND_PLACEHOLDER will be replaced by the chosen command (e.g., "code", "cursor", "my_editor")
# IDE_LABEL_PLACEHOLDER will be replaced by the chosen label (e.g., "Open in Code", "Open in Cursor", "Open in My IDE")
IDE_COMMAND = os.environ.get("NAUTILUS_OPEN_IDE_BIN", "IDE_COMMAND_PLACEHOLDER")
IDE_LABEL = os.environ.get("NAUTILUS_OPEN_IDE_LABEL", "IDE_LABEL_PLACEHOLDER")

class OpenInIDEExtension(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()

    def _open_ide(self, paths):
        if not paths:
            return
        try:
            # Check if the command contains shell redirection or special characters
            if any(char in IDE_COMMAND for char in ['>', '<', '|', '&', ';', '(', ')', '$']):
                # Use shell=True for commands with redirection or special characters
                # Replace $TARGET with the actual paths
                command = IDE_COMMAND.replace('$TARGET', ' '.join(f'"{path}"' for path in paths))
                subprocess.Popen(command, shell=True)
            else:
                # Use the original method for simple commands
                subprocess.Popen([IDE_COMMAND] + paths)
        except FileNotFoundError:
            print(f"Error: IDE command '{IDE_COMMAND}' not found. "
                  "Ensure your chosen IDE is installed and in your PATH, "
                  "or set NAUTILUS_OPEN_IDE_BIN environment variable.")
        except Exception as e:
            print(f"Failed to launch IDE: {e}")

    # For right click on files/folders
    def get_file_items(self, files):
        if not files:
            return

        paths = []
        for f in files:
            if f.get_uri_scheme() == "file":
                paths.append(f.get_location().get_path())

        if not paths:
            return

        item = Nautilus.MenuItem(
            name="OpenInIDEExtension::File",
            label=IDE_LABEL,
        )
        item.connect("activate", lambda _, p=paths: self._open_ide(p))
        return [item]

    # For right click on background of folder
    def get_background_items(self, current_folder):
        if current_folder.get_uri_scheme() != "file":
            return

        path = current_folder.get_location().get_path()

        item = Nautilus.MenuItem(
            name="OpenInIDEExtension::Background",
            label=IDE_LABEL,
        )
        item.connect("activate", lambda _, p=[path]: self._open_ide(p))
        return [item]