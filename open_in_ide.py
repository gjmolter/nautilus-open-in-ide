from gi.repository import Nautilus, GObject
import subprocess
import os
import shlex
from typing import List

# IDE_COMMAND_PLACEHOLDER will be replaced by the chosen command (e.g., "code", "cursor", "my_editor")
# IDE_LABEL_PLACEHOLDER will be replaced by the chosen label (e.g., "Open in Code", "Open in Cursor", "Open in My IDE")
IDE_COMMAND: str = os.environ.get("NAUTILUS_OPEN_IDE_BIN", "IDE_COMMAND_PLACEHOLDER")
IDE_LABEL: str = os.environ.get("NAUTILUS_OPEN_IDE_LABEL", "IDE_LABEL_PLACEHOLDER")

MENU_ITEM_FILE: str = "OpenInIDEExtension::File"
MENU_ITEM_BACKGROUND: str = "OpenInIDEExtension::Background"


class OpenInIDEExtension(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self) -> None:
        super().__init__()

    def _open_ide(self, paths: List[str]) -> None:
        if not paths:
            return

        try:
            # Always use shell=False for security
            # Handle special characters by escaping them properly
            if any(char in IDE_COMMAND for char in ['>', '<', '|', '&', ';', '(', ')', '$']):
                # For complex commands, use shlex.quote for proper escaping
                command_parts = shlex.split(IDE_COMMAND)
                # Replace $TARGET placeholder safely
                final_command = []
                for part in command_parts:
                    if '$TARGET' in part:
                        part = part.replace('$TARGET', ' '.join(shlex.quote(path) for path in paths))
                    final_command.append(part)
                subprocess.Popen(final_command)
            else:
                subprocess.Popen([IDE_COMMAND] + paths)
        except FileNotFoundError:
            print(f"Error: IDE command '{IDE_COMMAND}' not found...")
        except Exception as e:
            print(f"Failed to launch IDE: {e}")

    # For right click on files/folders
    def get_file_items(self, files: List[Nautilus.FileInfo]) -> List[Nautilus.MenuItem]:
        if not files:
            return []

        paths: List[str] = []
        for f in files:
            if f.get_uri_scheme() == "file":
                paths.append(f.get_location().get_path())

        if not paths:
            return []

        item = Nautilus.MenuItem(
            name=MENU_ITEM_FILE,
            label=IDE_LABEL,
        )
        item.connect("activate", lambda _, p=paths: self._open_ide(p))
        return [item]

    # For right click on background of folder
    def get_background_items(self, current_folder: Nautilus.FileInfo) -> List[Nautilus.MenuItem]:
        if current_folder.get_uri_scheme() != "file":
            return []

        path: str = current_folder.get_location().get_path()

        item = Nautilus.MenuItem(
            name=MENU_ITEM_BACKGROUND,
            label=IDE_LABEL,
        )
        item.connect("activate", lambda _, p=[path]: self._open_ide(p))
        return [item]
