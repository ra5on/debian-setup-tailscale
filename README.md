# debian-setup-tailscale

Ein interaktives Bash-Script zum automatischen Einrichten von **Tailscale** auf Debian-Systemen.

## ✅ Funktionen

- Abfrage, ob das System aktualisiert werden soll (`apt update && upgrade`)
- Installation von `curl`, falls nicht vorhanden
- Installation von Tailscale via offizielles Install-Script
- Interaktive Einrichtung:
  - Subnet Routing (optional)
  - Exit Node (optional)
  - DNS-Weiterleitung aktivieren/deaktivieren
- Aktivierung von IPv4 und IPv6 Forwarding (für Subnet-Routing erforderlich)
- Start von Tailscale mit den gewählten Optionen
- Klar strukturierte Ausgaben und Statusmeldungen
- Tailscale Authentifizierung per Link oder QR-Code möglich

## ⚙️ Installation


Script herunterladen
```
wget https://raw.githubusercontent.com/ra5on/tailscale/refs/heads/main/tailscale.sh
```
Script ausführbar machen
```
chmod +x tailscale.sh
```
Script Starten
```
./tailscale.sh
```
> Das Script fragt dich schrittweise durch die Konfiguration. Es ist ideal für private Heimserver, Container-Hosts, Raspberry Pis uvm.

---

## 🧰 Erklärung: Script ausführbar machen & starten

Wenn du das Script heruntergeladen oder mit `nano` erstellt hast, musst du es zunächst **ausführbar machen**, damit du es direkt starten kannst.

### 🔹 1. Rechte setzen mit `chmod +x`

```bash
chmod +x tailscale.sh
```

Dieser Befehl macht das Script „ausführbar“. Ohne das würdest du beim Start eine Fehlermeldung bekommen wie: `Permission denied`.

### 🔹 2. Script starten

```bash
./tailscale.sh
```

Das `./` bedeutet: **"führe die Datei im aktuellen Ordner aus"**.  
Du musst es so schreiben, da der aktuelle Ordner (.) normalerweise nicht automatisch im Suchpfad liegt.

---

## 📦 Voraussetzungen

- Debian 11 oder 12 (ARM64 empfohlen)
- Root-Zugriff (z. B. `sudo`)
- Internetverbindung

---


## ⚠️ Hinweis zur Nutzung

Dieses Skript wird ohne jegliche Garantie bereitgestellt und dient ausschließlich zu Lern-, Test- und Demonstrationszwecken.  
Die Ausführung erfolgt auf eigene Gefahr.

Der Autor (alias „ra5on“) übernimmt keine Verantwortung für:
- Schäden am System
- Fehlfunktionen
- Datenverluste
- rechtliche Konsequenzen

---

## 🧩 Drittsoftware & Rechte

Dieses Skript kann Drittsoftware installieren oder konfigurieren  
(z.B. curl, tailscale).

Der Autor:
- übernimmt keine Verantwortung für diese Software,
- macht sich deren Inhalte, Funktionen oder Lizenzen nicht zu eigen,
- beansprucht keine Rechte an fremder Software.

> **Alle Rechte, Marken und Verantwortlichkeiten verbleiben bei den jeweiligen Rechteinhabern.**

---

## 📌 Abschluss

Die Verwendung dieses Skripts sowie aller damit ausgeführten Aktionen erfolgt **vollständig auf eigenes Risiko**.

Es ist **nicht für den produktiven Einsatz** gedacht, ohne **eigene Prüfung und Anpassung** durch den Nutzer.  
Auch bei Änderung, Erweiterung oder Automatisierung bleibt der Haftungsausschluss bestehen.

