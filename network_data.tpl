network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: false
      addresses:
      - ${ip}
      routes:
      - to: 0.0.0.0/0
        via: 192.168.100.1
        on-link: true
        type: unicast
        metric: 100
      mtu: 1500
      nameservers:
        addresses:
        - 1.1.1.1
        - 8.8.4.4
