#!/usr/bin/env bash

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host="Arch Linux"

shutdown='  Shutdown'
reboot='  Reboot'
logout='  Logout'
lock='  Lock'
suspend='  Suspend'
yes='  Yes'
no='  No'

# Rofi CMD (clean)
rofi_cmd() {
  rofi -dmenu \
    -p "$host"
}

# Confirmation CMD (clean)
confirm_cmd() {
  rofi -dmenu \
    -p "Confirmation" \
    -mesg "Are you sure?" \
    -theme-str 'textbox {
    background-color: #ffffff00;
    text-color: #7d9bba;
    margin: 5px;
    padding: 0 0 0 20px;
    }'
}

confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
  echo -e "$shutdown\n$reboot\n$logout\n$lock\n$suspend" | rofi_cmd
}

run_cmd() {
  selected="$(confirm_exit)"

  if [[ "$selected" == "$yes" ]]; then
    case $1 in
    --shutdown) systemctl poweroff ;;
    --reboot) systemctl reboot ;;
    --suspend)
      mpc -q pause
      amixer set Master mute
      systemctl suspend
      ;;
    --logout)
      case "$DESKTOP_SESSION" in
      openbox) openbox --exit ;;
      bspwm) bspc quit ;;
      i3) i3-msg exit ;;
      plasma) qdbus org.kde.ksmserver /KSMServer logout 0 0 0 ;;
      Hyprland) hyprctl dispatch exit 1 ;;
      esac
      ;;
    esac
  else
    exit 0
  fi
}

chosen="$(run_rofi)"

case $chosen in
$shutdown) run_cmd --shutdown ;;
$reboot) run_cmd --reboot ;;
$lock)
  if [[ -x '/usr/bin/betterlockscreen' ]]; then
    betterlockscreen -l
  elif [[ -x '/usr/bin/i3lock' ]]; then
    i3lock
  elif [[ -x '/usr/bin/Hyprland' ]]; then
    swaylock
  fi
  ;;
$suspend) run_cmd --suspend ;;
$logout) run_cmd --logout ;;
esac
