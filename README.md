# SDDM Matrix Theme

Matrix rain login theme for SDDM, made for triple monitor setup (left: 1080p - portrait, center: 4k - landscape, right: 2k - landscape). Hyprland + Wayland compatible.



## Features

- Matrix rain effect on all monitors (rotated for portrait).
- Login panel and power buttons only on the main 4K monitor.
- Animated fade-in for the login panel.

## Requirements

- SDDM (Simple Desktop Display Manager)
- QtQuick 2.15
- QtQuick.Controls 2.15

## Installation

1. **Clone this repository:**
    ```sh
    git clone https://github.com/0hscar/sddm-matrix-theme.git
    ```

2. **Copy or symlink the theme to SDDM's themes directory:**
    ```sh
    sudo cp -r sddm-matrix-theme /usr/share/sddm/themes/matrix
    # OR for development:
    sudo ln -s /path/to/sddm-matrix-theme /usr/share/sddm/themes/matrix
    ```

3. **Set the theme in SDDM config:**
    - Edit `/etc/sddm.conf` or `/etc/sddm.conf.d/theme.conf` and set:
      ```
      [Theme]
      Current=matrix
      ```

4. **Restart SDDM:**
    ```sh
    sudo systemctl restart sddm
    ```

## Customization

- I kinda whacked it with a bat until it wanted to work with my setup, my monitor setup as below:
    - Left: 1920x1080 portrait
    - Center: 3840x2160 landscape (login panel & power buttons)
    - Right: 2560x1440 landscape
- To adapt for other setups, you must edit the monitor detection logic in `Main.qml`.
