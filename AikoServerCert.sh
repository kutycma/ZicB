#!/bin/bash

echo "Chọn một tùy chọn:"
echo "1. Cài đặt"
echo "2. Cập nhật config"
echo "3. Gỡ cài đặt"
read -p "Nhập lựa chọn của bạn (1/2/3): " choice

install_aiko_server() {
  wget --no-check-certificate -O Aiko-Server.sh https://raw.githubusercontent.com/AikoPanel/AikoServer/master/install.sh && bash Aiko-Server.sh

  mkdir -p /etc/Aiko-Server/cert

  if [[ -f /etc/Aiko-Server/cert/zicboard.crt ]]; then
    rm /etc/Aiko-Server/cert/zicboard.crt
  fi
  
  if [[ -f /etc/Aiko-Server/cert/zicboard.key ]]; then
    rm /etc/Aiko-Server/cert/zicboard.key
  fi
  
  openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes -out /etc/Aiko-Server/cert/zicboard.crt -keyout /etc/Aiko-Server/cert/zicboard.key -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=Google Trust Services LLC/CN=google.com"

  if [[ ! -f /etc/Aiko-Server/cert/zicboard.crt || ! -f /etc/Aiko-Server/cert/zicboard.key ]]; then
    echo "Tạo chứng chỉ không thành công. Kiểm tra lại lệnh openssl."
    exit 1
  fi
  
  clear
  echo "Cài đặt Aiko Server thành công. Vui lòng config."
  
  read -p "Nhập số lượng node (1 hoặc 2): " num_nodes
  read -p "Nhập ApiHost (có nhập https://): " api_host
  read -p "Nhập ApiKey: " api_key
  
  create_node_config() {
    local node_id=$1
    local node_type=$2
    local enable_vless=$3
    cat <<EOL
  - PanelType: "ZicBoard"
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $node_type
      Timeout: 30
      EnableVless: $enable_vless
      RuleListPath:
    ControllerConfig:
      EnableProxyProtocol: false
      DeviceOnlineMinTraffic: 100
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
      CertConfig:
        CertMode: file
        CertDomain: "8.8.8.8"
        CertFile: /etc/Aiko-Server/cert/zicboard.crt
        KeyFile: /etc/Aiko-Server/cert/zicboard.key
        Provider: alidns
        Email: zicboard@zic.com
        DNSEnv: 
          ALICLOUD_ACCESS_KEY: zicdz
          ALICLOUD_SECRET_KEY: zicdz
EOL
  }

  config_path="/etc/Aiko-Server/aiko.yml"
  echo "Nodes:" > $config_path

  read -p "Nhập NodeID cho node 1: " node_id1
  echo "Chọn loại Node cho node 1:"
  echo "1. V2ray"
  echo "2. Trojan"
  read -p "Nhập lựa chọn của bạn (1/2): " node_choice1
  if [ "$node_choice1" -eq 1 ]; then
    node_type1="V2ray"
    read -p "Có mở Vless không? (y/n): " enable_vless1
    if [ "$enable_vless1" == "y" ]; then
      enable_vless1="true"
    else
      enable_vless1="false"
    fi
  else
    node_type1="Trojan"
    enable_vless1="false"
  fi
  create_node_config $node_id1 $node_type1 $enable_vless1 >> $config_path

  if [ "$num_nodes" -eq 2 ]; then
    read -p "Nhập NodeID cho node 2: " node_id2
    echo "Chọn loại Node cho node 2:"
    echo "1. V2ray"
    echo "2. Trojan"
    read -p "Nhập lựa chọn của bạn (1/2): " node_choice2
    if [ "$node_choice2" -eq 1 ]; then
      node_type2="V2ray"
      read -p "Có mở Vless không? (y/n): " enable_vless2
      if [ "$enable_vless2" == "y" ]; then
        enable_vless2="true"
      else
        enable_vless2="false"
      fi
    else
      node_type2="Trojan"
      enable_vless2="false"
    fi
    create_node_config $node_id2 $node_type2 $enable_vless2 >> $config_path
  fi

  clear
  echo "Cấu hình đã được tạo tại $config_path"
  echo "Khởi động Aiko-Server sau 3 giây"
  sleep 3
  Aiko-Server restart
}

update_config() {
  read -p "Nhập số lượng node (1 hoặc 2): " num_nodes
  read -p "Nhập ApiHost: " api_host
  read -p "Nhập ApiKey: " api_key
  
  create_node_config() {
    local node_id=$1
    local node_type=$2
    local enable_vless=$3
    cat <<EOL
  - PanelType: "ZicBoard"
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $node_type
      Timeout: 30
      EnableVless: $enable_vless
      RuleListPath:
    ControllerConfig:
      EnableProxyProtocol: false
      DeviceOnlineMinTraffic: 100
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
      CertConfig:
        CertMode: file
        CertDomain: "8.8.8.8"
        CertFile: /etc/Aiko-Server/cert/zicboard.crt
        KeyFile: /etc/Aiko-Server/cert/zicboard.key
        Provider: alidns
        Email: zicboard@zic.com
        DNSEnv: 
          ALICLOUD_ACCESS_KEY: zicdz
          ALICLOUD_SECRET_KEY: zicdz
EOL
  }

  config_path="/etc/Aiko-Server/aiko.yml"
  echo "Nodes:" > $config_path

  read -p "Nhập NodeID cho node 1: " node_id1
  echo "Chọn loại Node cho node 1:"
  echo "1. V2ray"
  echo "2. Trojan"
  read -p "Nhập lựa chọn của bạn (1/2): " node_choice1
  if [ "$node_choice1" -eq 1 ]; then
    node_type1="V2ray"
    read -p "Có mở Vless không? (y/n): " enable_vless1
    if [ "$enable_vless1" == "y" ]; then
      enable_vless1="true"
    else
      enable_vless1="false"
    fi
  else
    node_type1="Trojan"
    enable_vless1="false"
  fi
  create_node_config $node_id1 $node_type1 $enable_vless1 >> $config_path

  if [ "$num_nodes" -eq 2 ]; then
    read -p "Nhập NodeID cho node 2: " node_id2
    echo "Chọn loại Node cho node 2:"
    echo "1. V2ray"
    echo "2. Trojan"
    read -p "Nhập lựa chọn của bạn (1/2): " node_choice2
    if [ "$node_choice2" -eq 1 ]; then
      node_type2="V2ray"
      read -p "Có mở Vless không? (y/n): " enable_vless2
      if [ "$enable_vless2" == "y" ]; then
        enable_vless2="true"
      else
        enable_vless2="false"
      fi
    else
      node_type2="Trojan"
      enable_vless2="false"
    fi
    create_node_config $node_id2 $node_type2 $enable_vless2 >> $config_path
  fi

  clear
  echo "Cấu hình đã được tạo tại $config_path"
  echo "Khởi động Aiko-Server sau 3 giây"
  sleep 3
  Aiko-Server restart
}

uninstall_aiko_server() {
  Aiko-Server uninstall
  echo "Aiko-Server đã được gỡ cài đặt."
}

case $choice in
  1)
    install_aiko_server
    ;;
  2)
    update_config
    ;;
  3)
    uninstall_aiko_server
    ;;
  *)
    echo "Lựa chọn không hợp lệ. Vui lòng chạy lại script và chọn 1, 2 hoặc 3."
    ;;
esac
