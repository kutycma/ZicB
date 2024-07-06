#!/bin/bash

# Hiển thị menu và lấy lựa chọn của người dùng
echo "Chọn một tùy chọn:"
echo "1. Cài đặt"
echo "2. Cập nhật config"
echo "3. Gỡ cài đặt"
read -p "Nhập lựa chọn của bạn (1/2/3): " choice

# Hàm để cài đặt Aiko-Server
install_aiko_server() {
  # Tải xuống và chạy script cài đặt Aiko-Server
  wget --no-check-certificate -O Aiko-Server.sh https://raw.githubusercontent.com/AikoPanel/AikoServer/master/install.sh && bash Aiko-Server.sh
  
  # Clear màn hình và hiển thị thông báo thành công
  clear
  echo "Cài đặt Aiko Server thành công. Vui lòng config."
  
  # Hỏi người dùng nhập thông tin cần thiết
  read -p "Nhập số lượng node (1 hoặc 2): " num_nodes
  read -p "Nhập ApiHost (có nhập https://): " api_host
  read -p "Nhập ApiKey: " api_key
  
  # Hàm để tạo cấu hình cho một node
  create_node_config() {
    local node_id=$1
    local node_type=$2
    cat <<EOL
  - PanelType: "ZicBoard"
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $node_type
      Timeout: 30
      EnableVless: false
      RuleListPath:
    ControllerConfig:
      EnableProxyProtocol: false
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
      CertConfig:
        CertMode: none
        CertFile: /etc/Aiko-Server/cert/aiko_server.cert
        KeyFile: /etc/Aiko-Server/cert/aiko_server.key
EOL
  }

  # Hàm để tạo cấu hình cho node thứ hai với thông tin bổ sung
  create_node_config_with_cert() {
    local node_id=$1
    local node_type=$2
    local cert_domain=$3
    local email=$4
    local cloudflare_api_key=$5
    cat <<EOL
  - PanelType: "ZicBoard"
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $node_type
      Timeout: 30
      EnableVless: false
      RuleListPath:
    ControllerConfig:
      EnableProxyProtocol: false
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
      CertConfig:
        CertMode: dns
        CertDomain: "$cert_domain"
        CertFile: /etc/Aiko-Server/cert/aiko_server.cert
        KeyFile: /etc/Aiko-Server/cert/aiko_server.key
        Email: "$email"
        Provider: cloudflare
        DNSEnv:
          CLOUDFLARE_EMAIL: "$email"
          CLOUDFLARE_API_KEY: "$cloudflare_api_key"
EOL
  }

  # Tạo file cấu hình aiko.yml
  config_path="/etc/Aiko-Server/aiko.yml"
  echo "Nodes:" > $config_path

  # Thêm cấu hình cho node đầu tiên
  read -p "Nhập NodeID cho node Vmess: " node_id1
  node_type1="V2ray"
  create_node_config $node_id1 $node_type1 >> $config_path

  # Thêm cấu hình cho node thứ hai nếu cần
  if [ "$num_nodes" -eq 2 ]; then
    read -p "Nhập NodeID cho node Trojan: " node_id2
    node_type2="Trojan"
    read -p "Nhập Domain: " cert_domain
    read -p "Nhập Email Cloudflare: " email
    read -p "Nhập Cloudflare API: " cloudflare_api_key
    create_node_config_with_cert $node_id2 $node_type2 $cert_domain $email $cloudflare_api_key >> $config_path
  fi

  clear
  echo "Cấu hình đã được tạo tại $config_path"
  echo "Khởi động Aiko-Server sau 3 giây"
  sleep 3
  Aiko-Server restart
}

# Hàm để cập nhật config
update_config() {
  # Hỏi người dùng nhập thông tin cần thiết
  read -p "Nhập số lượng node (1 hoặc 2): " num_nodes
  read -p "Nhập ApiHost: " api_host
  read -p "Nhập ApiKey: " api_key
  
  # Hàm để tạo cấu hình cho một node
  create_node_config() {
    local node_id=$1
    local node_type=$2
    cat <<EOL
  - PanelType: "AikoPanel"
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $node_type
      Timeout: 30
      EnableVless: false
      RuleListPath:
    ControllerConfig:
      EnableProxyProtocol: false
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
      CertConfig:
        CertMode: none
        CertFile: /etc/Aiko-Server/cert/aiko_server.cert
        KeyFile: /etc/Aiko-Server/cert/aiko_server.key
EOL
  }

  # Hàm để tạo cấu hình cho node thứ hai với thông tin bổ sung
  create_node_config_with_cert() {
    local node_id=$1
    local node_type=$2
    local cert_domain=$3
    local email=$4
    local cloudflare_api_key=$5
    cat <<EOL
  - PanelType: "ZicBoard"
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $node_type
      Timeout: 30
      EnableVless: false
      RuleListPath:
    ControllerConfig:
      EnableProxyProtocol: false
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
      CertConfig:
        CertMode: dns
        CertDomain: "$cert_domain"
        CertFile: /etc/Aiko-Server/cert/aiko_server.cert
        KeyFile: /etc/Aiko-Server/cert/aiko_server.key
        Email: "$email"
        Provider: cloudflare
        DNSEnv:
          CLOUDFLARE_EMAIL: "$email"
          CLOUDFLARE_API_KEY: "$cloudflare_api_key"
EOL
  }

  # Tạo file cấu hình aiko.yml
  config_path="/etc/Aiko-Server/aiko.yml"
  echo "Nodes:" > $config_path

  # Thêm cấu hình cho node đầu tiên
  read -p "Nhập NodeID cho Vmess: " node_id1
  node_type1="V2ray"
  create_node_config $node_id1 $node_type1 >> $config_path

  # Thêm cấu hình cho node thứ hai nếu cần
  if [ "$num_nodes" -eq 2 ]; then
    read -p "Nhập NodeID cho Trojan: " node_id2
    node_type2="Trojan"
    read -p "Nhập Domain : " cert_domain
    read -p "Nhập Email Cloudflare: " email
    read -p "Nhập Cloudflare API: " cloudflare_api_key
    create_node_config_with_cert $node_id2 $node_type2 $cert_domain $email $cloudflare_api_key >> $config_path
  fi
  clear
  echo "Cấu hình đã được tạo tại $config_path"
  echo "Khởi động Aiko-Server sau 3 giây"
  sleep 3
  Aiko-Server restart
}

# Hàm để gỡ cài đặt Aiko-Server
uninstall_aiko_server() {
  Aiko-Server uninstall
  echo "Aiko-Server đã được gỡ cài đặt."
}

# Xử lý lựa chọn của người dùng
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
