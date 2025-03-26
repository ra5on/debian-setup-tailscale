#!/bin/bash

# ── System aktualisieren ──────────────────────────────────────
echo -n "Möchtest du ein Update und Upgrade durchführen? (j/n): "
read -r update_system
if [[ "$update_system" == "j" ]]; then
  echo -e "\n🔄 System wird aktualisiert..."
  sudo apt update && sudo apt upgrade -y
else
  echo "⏩ System-Update übersprungen."
fi

# ── Tailscale ──────────────────────────────────────────────────
echo -n "Möchtest du Tailscale installieren und einrichten? (j/n): "
read -r tailscale_install
if [[ "$tailscale_install" == "j" ]]; then

  # curl installieren falls nicht vorhanden
  if ! command -v curl >/dev/null 2>&1; then
    echo -e "\n⚠️  'curl' ist nicht installiert. Wird jetzt automatisch installiert..."
    sudo apt update && sudo apt install -y curl
  fi

  # Tailscale installieren
  curl -fsSL https://tailscale.com/install.sh | sh

  # Parameter vorbereiten
  advertise_arg=""
  exitnode_arg=""
  dns_arg=""

  # Subnet-Routing abfragen (inkl. Vorschlag & Validierung)
  echo -n "Möchtest du Subnet-Routing aktivieren? (j/n): "
  read -r subnet_enable

  if [[ "$subnet_enable" == "j" ]]; then
    auto_subnet=$(ip -o -f inet addr show | awk '/scope global/ {split($4, a, "/"); print a[1]"/24"; exit}')
    echo -e "\nDein vorgeschlagenes Subnetz wäre z. B.: ${auto_subnet}"
    echo -n "Bitte Subnetz eingeben (z. B. 192.168.10.0/24): "
    read -r user_subnet

    if [[ "$user_subnet" =~ ^([0-9]{1,3}\.){3}0/([0-9]{1,2})$ ]]; then
      advertise_arg="--advertise-routes=${user_subnet}"
    else
      echo "⚠️ Ungültiges Subnetz eingegeben – Subnet-Routing wird übersprungen."
    fi
  fi

  # Exit Node abfragen
  echo -n "Als Exit Node fungieren? (j/n): "
  read -r exitnode_answer
  [[ "$exitnode_answer" == "j" ]] && exitnode_arg="--advertise-exit-node"

  # DNS aktivieren?
  echo -n "Tailscale DNS aktivieren? (j/n): "
  read -r dns_answer
  [[ "$dns_answer" == "j" ]] && dns_arg="--accept-dns=true" || dns_arg="--accept-dns=false"

  # IPv4/IPv6 Forwarding aktivieren
  echo -e "\n🌐 Aktiviere IPv4 & IPv6 Forwarding..."
  sudo sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf
  echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
  echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p

  # Tailscale starten
  echo -e "\n🚀 Starte Tailscale mit deiner Konfiguration..."
  sudo tailscale up $advertise_arg $exitnode_arg $dns_arg

  echo -e "\n✅ Tailscale wurde gestartet. Jetzt ggf. im Browser autorisieren."
else
  echo "⏩ Tailscale wird nicht installiert."
fi
