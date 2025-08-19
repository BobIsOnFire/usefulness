# Setting up `niri` on plain Fedora (no spin, no default desktop)

## Initial setup

Install from Fedora Everything image: https://fedoraproject.org/everything/download.
During installation, select 'Custom OS' option to run a 'desktop-less' setup.

## Install and enable Niri as default session

1. Install Niri: `dnf copr enable yalter/niri && dnf install niri`

2. Install greetd for default session management: `dnf install greetd`

3. Configure greetd to run `agreety` for credential access and pass execution to `niri`:

```bash
$ cat /etc/greetd/config.toml
```

```toml
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]

# `agreety` is the bundled agetty/login-lookalike. You can replace `/bin/sh`
# with whatever you want started, such as `sway`.
command = "agreety --cmd /usr/bin/niri-session"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "<session_user>"
```

Replace `<session_user>` with user configured during OS setup.

4. Set `greetd` as default graphical session manager: `systemctl enable greetd.service`

5. Create graphical session on system boot (by default, it will run `multi-user` target
   because we've selected a desktop-less setup when configured OS):
   `systemctl set-default graphical.target`

6. Reboot

7. Install some essential packages: `dnf install vim git make firefox`

## Load custom configs from this repo

1. Clone repository and run `make SWAY=1` from its root. Resolve possible conflicts as
   reported by make.

2. Install desktop components referenced by the configs:
   `dnf install fuzzel swayidle kitty swaybg wlogout SwayNotificationCenter pavucontrol`

3. Reboot

## Fonts

https://github.com/be5invis/Iosevka

1. Install Iosevka: `dnf copr enable peterwu/iosevka && dnf install iosevka-fonts`

2. Install additional glyphs for displaying Unicode that are unavailable in system fonts
   or in Iosevka (emojis, math symbols, FontAwesome, East Asian glyphs):
   `dnf install default-fonts-core default-fonts-cjk`

## Flatpaks (Telegram, Slack)

1. Install Flatpak and non-Fedora FlatHub configs: `dnf install flatpak fedora-flathub-remote`

2. Enable non-Fedora FlatHub configs: `fedora-third-party enable`

3. Install packages directly from FlatHub: `flatpak install flathub telegram`

## VSCode

https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions

## Docker

https://docs.docker.com/engine/install/fedora/

## Fix screencast errors

Simplest way to check if media-related portal calls work is through Mozilla WebRTC test page:
https://mozilla.github.io/webrtc-landing/gum_test.html

If portal dialog does not open when selecting window for screencast, check portal logs:
`journalctl --user -u xdg-desktop-portal-gnome.service`. If the portal crashes because it
cannot find `libGLESv2.so.2`, install `libglvnd-gles.x86_64` package into the system.

(possible portal dependency bug -- it depends on libglvnd-gles package, but installs i686
version by default so dependency is not actually satisfied. Although maybe it's hardware-specific,
I haven't checked that.)

