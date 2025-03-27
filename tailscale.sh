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
    auto_subnet=$(ip -o -f inet addr show | awk '/scope global/ {
        split($4, a, "/");
        split(a[1], ip, ".");
        printf "%s.%s.%s.0/24", ip[1], ip[2], ip[3];
        exit
    }')
    echo -e "\n🔍 Vorgeschlagenes Subnetz: ${auto_subnet}"
    echo -n "Möchtest du dieses Subnetz verwenden? (j/n): "
    read -r use_auto_subnet

    if [[ "$use_auto_subnet" == "j" ]]; then
      advertise_arg="--advertise-routes=${auto_subnet}"
    else
      echo -n "Bitte Subnetz manuell eingeben (z. B. 192.168.178.0/24): "
      read -r user_subnet

      if [[ "$user_subnet" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
        advertise_arg="--advertise-routes=${user_subnet}"
      else
        echo "⚠️ Ungültiges Subnetz – Subnet-Routing wird übersprungen."
      fi
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

  # IPv4/IPv6 Forwarding aktivieren – nur wenn Subnet-Routing aktiv ist
  if [[ -n "$advertise_arg" ]]; then
    echo -e "\n🌐 Subnet-Routing aktiv – aktiviere IPv4 & IPv6 Forwarding..."
    sudo sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
    sudo sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
  fi

  # Zusammenfassung anzeigen
  echo -e "\n🚀 Tailscale wird mit folgenden Optionen gestartet:"
  [[ -n "$advertise_arg" ]] && echo "   ➤ Subnet Routing: ${advertise_arg#--advertise-routes=}"
  [[ -n "$exitnode_arg" ]] && echo "   ➤ Exit Node: aktiviert"
  echo "   ➤ DNS: $( [[ "$dns_arg" == "--accept-dns=true" ]] && echo "aktiviert" || echo "deaktiviert" )"

  echo -n "Möchtest du Tailscale jetzt mit diesen Einstellungen starten? (j/n): "
  read -r confirm_tailscale
  if [[ "$confirm_tailscale" == "j" ]]; then
    echo -e "\n🌐 Bitte öffne den folgenden Link im Browser, um dich mit Tailscale zu verbinden:"
    sudo tailscale up $advertise_arg $exitnode_arg $dns_arg --qr 2>&1 | tee tailscale-login.log
    echo -e "\n✅ Tailscale wurde gestartet (Login-Link oben oder QR-Code)."
  else
    echo -e "⏩ Start von Tailscale wurde abgebrochen."
  fi

  [[ "$tailscale_install" == "j" ]] && echo -e "\n🟢 Tailscale läuft $( [[ -n "$advertise_arg" ]] && echo "| Subnet Routing aktiv" ) $( [[ "$exitnode_answer" == "j" ]] && echo "| Exit Node" ) $( [[ "$dns_answer" == "j" ]] && echo "| DNS aktiv" || echo "| DNS aus" )"
else
  echo "⏩ Tailscale wird nicht installiert."
fi
