#!/bin/bash

# Parámetros del usuario
USERNAME="admin"
PASSWORD="adminPortainer"

echo "[+] Installing dependencies..."
sudo apt install curl jq -y

# Wait for Portainer to be up and running
echo "[+] Waitin for Portainer to be up and running..."
until curl -s http://localhost:9000/api/status > /dev/null; do
  sleep 2
done

# Create the admin user
echo "[+] Creating admin user..."
curl -s -X POST "http://localhost:9000/api/users/admin/init" \
  -H "Content-Type: application/json" \
  -d "{\"Username\":\"$USERNAME\", \"Password\":\"$PASSWORD\"}" | jq .

echo "[+] Done! User: $USERNAME Password: $PASSWORD"
