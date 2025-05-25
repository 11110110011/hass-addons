#!/bin/sh

echo "[START] NAT & DHCP для IoT подсети"

# Чтение параметров из опций Add-on
DHCP_RANGE_START=$(jq -r '.dhcp_range_start' /data/options.json)
DHCP_RANGE_END=$(jq -r '.dhcp_range_end' /data/options.json)
INTERFACE=$(jq -r '.interface' /data/options.json)
MAIN_IFACE=$(jq -r '.main_interface' /data/options.json)

echo "[CONFIG] Интерфейс IoT: $INTERFACE"
echo "[CONFIG] Основной интерфейс: $MAIN_IFACE"
echo "[CONFIG] DHCP: $DHCP_RANGE_START - $DHCP_RANGE_END"

# Включение NAT
iptables -t nat -A POSTROUTING -o $MAIN_IFACE -j MASQUERADE
iptables -A FORWARD -i $INTERFACE -o $MAIN_IFACE -j ACCEPT
iptables -A FORWARD -i $MAIN_IFACE -o $INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Запуск dnsmasq
dnsmasq -i $INTERFACE \
  --dhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,12h \
  --log-facility=/dev/stdout \
  --log-queries

tail -f /dev/null
