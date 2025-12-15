#!/bin/bash

#========================================================================
# VPS 融合怪测试脚本
# 版本: 威软科技测试脚本 V2.0 融合版
# 作者: 威软科技
# 参考: spiritLHLS/ecs 融合怪脚本
#========================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m'
BOLD='\033[1m'

# 全局变量
VERSION="2.0"
SCRIPT_NAME="威软科技VPS综合测试脚本"
REPORT_FILE="test_result_$(date +%Y%m%d_%H%M%S).txt"
START_TIME=$(date +%s)
TEMP_DIR="/tmp/vps_test_$$"

# 打印分隔线
print_line() {
    local color=${1:-$CYAN}
    echo -e "${color}———————————————————————————————————————————————————————${NC}"
}

# 打印标题
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        ██╗   ██╗██████╗ ███████╗    ████████╗███████╗       ║
║        ██║   ██║██╔══██╗██╔════╝    ╚══██╔══╝██╔════╝       ║
║        ██║   ██║██████╔╝███████╗       ██║   █████╗         ║
║        ╚██╗ ██╔╝██╔═══╝ ╚════██║       ██║   ██╔══╝         ║
║         ╚████╔╝ ██║     ███████║       ██║   ███████╗       ║
║          ╚═══╝  ╚═╝     ╚══════╝       ╚═╝   ╚══════╝       ║
║                                                              ║
║              VPS 综合性能测试脚本 - 融合版                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}                威软科技测试脚本 V${VERSION} - 融合怪版${NC}"
    echo -e "${GREEN}           参考 spiritLHLS/ecs 融合怪测试项目${NC}"
    echo -e "${GRAY}           https://github.com/weiruankeji2025/weiruan-vps${NC}"
    print_line
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}[*] 正在检查系统环境...${NC}"

    # 检查是否为root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[✗] 请使用 root 权限运行此脚本${NC}"
        echo -e "${YELLOW}使用命令: sudo bash $0${NC}"
        exit 1
    fi

    # 基础依赖
    local deps=("curl" "wget" "tar" "gzip" "bc" "jq" "python3" "perl")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}[!] 正在安装缺失的依赖: ${missing_deps[*]}${NC}"

        if command -v apt-get &> /dev/null; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -qq &> /dev/null
            apt-get install -y -qq "${missing_deps[@]}" python3-pip iproute2 dnsutils net-tools traceroute mtr &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y -q "${missing_deps[@]}" python3-pip iproute bind-utils net-tools traceroute mtr &> /dev/null
        elif command -v dnf &> /dev/null; then
            dnf install -y -q "${missing_deps[@]}" python3-pip iproute bind-utils net-tools traceroute mtr &> /dev/null
        else
            echo -e "${RED}[✗] 无法自动安装依赖，请手动安装${NC}"
            exit 1
        fi
    fi

    # 安装Python工具
    if ! command -v speedtest-cli &> /dev/null; then
        pip3 install speedtest-cli --quiet 2>/dev/null || pip install speedtest-cli --quiet 2>/dev/null
    fi

    mkdir -p "$TEMP_DIR"
    echo -e "${GREEN}[✓] 环境检查完成${NC}"
    echo ""
}

# 初始化报告
init_report() {
    cat > "$REPORT_FILE" << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         VPS 综合性能测试报告 - 融合怪版
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

测试时间: $(date '+%Y-%m-%d %H:%M:%S %Z')
测试工具: ${SCRIPT_NAME} V${VERSION}
系统平台: $(uname -s) $(uname -m)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
}

# 写入报告
write_report() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' >> "$REPORT_FILE"
}

# 基础信息测试
test_basic_info() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[1/11] 系统基础信息检测${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 系统基础信息 ━━━\n"

    # 主机名
    HOSTNAME=$(hostname)
    echo -e "${WHITE}主机名:${NC} ${GREEN}$HOSTNAME${NC}"
    write_report "主机名: $HOSTNAME"

    # 操作系统
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)
        OS_VERSION=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)
    else
        OS_NAME=$(uname -s)
        OS_VERSION=$(uname -r)
    fi
    echo -e "${WHITE}操作系统:${NC} ${GREEN}$OS_NAME${NC}"
    write_report "操作系统: $OS_NAME"

    # 内核版本
    KERNEL=$(uname -r)
    echo -e "${WHITE}内核版本:${NC} ${GREEN}$KERNEL${NC}"
    write_report "内核版本: $KERNEL"

    # 系统架构
    ARCH=$(uname -m)
    echo -e "${WHITE}系统架构:${NC} ${GREEN}$ARCH${NC}"
    write_report "系统架构: $ARCH"

    # 虚拟化类型
    VIRT_TYPE="Unknown"
    if command -v systemd-detect-virt &> /dev/null; then
        VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "Unknown")
        [ "$VIRT_TYPE" == "none" ] && VIRT_TYPE="物理机/Dedicated"
    elif [ -f /proc/cpuinfo ]; then
        grep -q "hypervisor" /proc/cpuinfo && VIRT_TYPE="虚拟机" || VIRT_TYPE="物理机"
    fi
    echo -e "${WHITE}虚拟化类型:${NC} ${PURPLE}$VIRT_TYPE${NC}"
    write_report "虚拟化类型: $VIRT_TYPE"

    # CPU信息
    CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name:[ \t]*//')
    CPU_CORES=$(nproc)
    CPU_THREADS=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    CPU_FREQ=$(lscpu | grep "CPU MHz" | awk '{print $3}' | head -1)
    echo -e "${WHITE}CPU型号:${NC} ${GREEN}$CPU_MODEL${NC}"
    echo -e "${WHITE}CPU核心:${NC} ${GREEN}${CPU_CORES} 核心 / ${CPU_THREADS} 线程${NC}"
    echo -e "${WHITE}CPU频率:${NC} ${GREEN}${CPU_FREQ} MHz${NC}"
    write_report "CPU型号: $CPU_MODEL"
    write_report "CPU核心: ${CPU_CORES} 核心 / ${CPU_THREADS} 线程"
    write_report "CPU频率: ${CPU_FREQ} MHz"

    # 内存信息
    TOTAL_MEM=$(free -h | awk '/^Mem:/{print $2}')
    USED_MEM=$(free -h | awk '/^Mem:/{print $3}')
    FREE_MEM=$(free -h | awk '/^Mem:/{print $4}')
    SWAP_TOTAL=$(free -h | awk '/^Swap:/{print $2}')
    echo -e "${WHITE}总内存:${NC} ${GREEN}$TOTAL_MEM${NC} | ${WHITE}已用:${NC} ${YELLOW}$USED_MEM${NC} | ${WHITE}可用:${NC} ${GREEN}$FREE_MEM${NC}"
    echo -e "${WHITE}交换分区:${NC} ${GREEN}$SWAP_TOTAL${NC}"
    write_report "总内存: $TOTAL_MEM | 已用: $USED_MEM | 可用: $FREE_MEM"
    write_report "交换分区: $SWAP_TOTAL"

    # 磁盘信息
    TOTAL_DISK=$(df -h / | awk 'NR==2 {print $2}')
    USED_DISK=$(df -h / | awk 'NR==2 {print $3}')
    FREE_DISK=$(df -h / | awk 'NR==2 {print $4}')
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
    echo -e "${WHITE}总磁盘:${NC} ${GREEN}$TOTAL_DISK${NC} | ${WHITE}已用:${NC} ${YELLOW}$USED_DISK ($DISK_USAGE)${NC} | ${WHITE}可用:${NC} ${GREEN}$FREE_DISK${NC}"
    write_report "总磁盘: $TOTAL_DISK | 已用: $USED_DISK ($DISK_USAGE) | 可用: $FREE_DISK"

    # 启动时间
    UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
    echo -e "${WHITE}运行时间:${NC} ${CYAN}$UPTIME${NC}"
    write_report "运行时间: $UPTIME"

    # 系统负载
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    echo -e "${WHITE}系统负载:${NC} ${CYAN}$LOAD${NC}"
    write_report "系统负载:$LOAD"

    echo ""
    write_report ""
    sleep 1
}

# IP信息和地理位置
test_ip_info() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[2/11] IP信息和地理位置${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ IP信息和地理位置 ━━━\n"

    # 获取IPv4
    echo -e "${YELLOW}[*] 正在获取网络信息...${NC}"
    PUBLIC_IPV4=$(curl -s -4 --max-time 10 ifconfig.me 2>/dev/null || curl -s -4 --max-time 10 icanhazip.com 2>/dev/null || echo "N/A")

    if [ "$PUBLIC_IPV4" != "N/A" ]; then
        echo -e "${WHITE}公网IPv4:${NC} ${GREEN}$PUBLIC_IPV4${NC}"
        write_report "公网IPv4: $PUBLIC_IPV4"

        # 获取IPv6
        PUBLIC_IPV6=$(curl -s -6 --max-time 10 ifconfig.me 2>/dev/null || echo "N/A")
        if [ "$PUBLIC_IPV6" != "N/A" ]; then
            echo -e "${WHITE}公网IPv6:${NC} ${GREEN}$PUBLIC_IPV6${NC}"
            write_report "公网IPv6: $PUBLIC_IPV6"
        else
            echo -e "${WHITE}公网IPv6:${NC} ${GRAY}未配置${NC}"
            write_report "公网IPv6: 未配置"
        fi

        # IP地理位置查询
        IP_INFO=$(curl -s --max-time 10 "http://ip-api.com/json/$PUBLIC_IPV4?fields=status,country,countryCode,region,regionName,city,lat,lon,timezone,isp,as,org,mobile,proxy,hosting" 2>/dev/null)

        if [ -n "$IP_INFO" ]; then
            COUNTRY=$(echo "$IP_INFO" | jq -r '.country // "未知"')
            REGION=$(echo "$IP_INFO" | jq -r '.regionName // "未知"')
            CITY=$(echo "$IP_INFO" | jq -r '.city // "未知"')
            ISP=$(echo "$IP_INFO" | jq -r '.isp // "未知"')
            ORG=$(echo "$IP_INFO" | jq -r '.org // "未知"')
            AS_NUM=$(echo "$IP_INFO" | jq -r '.as // "未知"')
            TIMEZONE=$(echo "$IP_INFO" | jq -r '.timezone // "未知"')
            LAT=$(echo "$IP_INFO" | jq -r '.lat // "未知"')
            LON=$(echo "$IP_INFO" | jq -r '.lon // "未知"')

            echo -e "${WHITE}地理位置:${NC} ${CYAN}$COUNTRY / $REGION / $CITY${NC}"
            echo -e "${WHITE}坐标:${NC} ${CYAN}纬度 $LAT, 经度 $LON${NC}"
            echo -e "${WHITE}时区:${NC} ${CYAN}$TIMEZONE${NC}"
            echo -e "${WHITE}ISP运营商:${NC} ${CYAN}$ISP${NC}"
            echo -e "${WHITE}组织:${NC} ${CYAN}$ORG${NC}"
            echo -e "${WHITE}AS号:${NC} ${CYAN}$AS_NUM${NC}"

            write_report "地理位置: $COUNTRY / $REGION / $CITY"
            write_report "坐标: 纬度 $LAT, 经度 $LON"
            write_report "时区: $TIMEZONE"
            write_report "ISP运营商: $ISP"
            write_report "组织: $ORG"
            write_report "AS号: $AS_NUM"
        fi

        # ASN信息
        echo -e "\n${YELLOW}[*] ASN信息查询...${NC}"
        ASN_INFO=$(curl -s --max-time 10 "https://api.bgpview.io/ip/$PUBLIC_IPV4" 2>/dev/null)
        if [ -n "$ASN_INFO" ]; then
            ASN_NUMBER=$(echo "$ASN_INFO" | jq -r '.data.prefixes[0].asn.asn // "N/A"')
            ASN_NAME=$(echo "$ASN_INFO" | jq -r '.data.prefixes[0].asn.name // "N/A"')
            ASN_COUNTRY=$(echo "$ASN_INFO" | jq -r '.data.prefixes[0].asn.country_code // "N/A"')

            if [ "$ASN_NUMBER" != "N/A" ]; then
                echo -e "${WHITE}ASN编号:${NC} ${CYAN}AS$ASN_NUMBER${NC}"
                echo -e "${WHITE}ASN名称:${NC} ${CYAN}$ASN_NAME${NC}"
                echo -e "${WHITE}ASN国家:${NC} ${CYAN}$ASN_COUNTRY${NC}"

                write_report "ASN编号: AS$ASN_NUMBER"
                write_report "ASN名称: $ASN_NAME"
                write_report "ASN国家: $ASN_COUNTRY"
            fi
        fi
    else
        echo -e "${RED}[✗] 无法获取公网IP信息${NC}"
        write_report "无法获取公网IP信息"
    fi

    echo ""
    write_report ""
    sleep 1
}

# IP质量检测（含15家数据库）
test_ip_quality() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[3/11] IP质量检测 (多数据库查询)${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ IP质量检测 ━━━\n"

    PUBLIC_IP=$(curl -s -4 --max-time 10 ifconfig.me 2>/dev/null)

    if [ -n "$PUBLIC_IP" ]; then
        echo -e "${YELLOW}[*] 正在查询IP质量信息...${NC}\n"

        # 基本IP类型检测
        IP_INFO=$(curl -s --max-time 10 "http://ip-api.com/json/$PUBLIC_IP?fields=mobile,proxy,hosting" 2>/dev/null)

        IS_MOBILE=$(echo "$IP_INFO" | jq -r '.mobile // false')
        IS_PROXY=$(echo "$IP_INFO" | jq -r '.proxy // false')
        IS_HOSTING=$(echo "$IP_INFO" | jq -r '.hosting // false')

        # 显示IP类型
        if [ "$IS_MOBILE" == "true" ]; then
            echo -e "${WHITE}IP类型:${NC} ${YELLOW}移动网络IP${NC}"
            write_report "IP类型: 移动网络IP"
        elif [ "$IS_HOSTING" == "true" ]; then
            echo -e "${WHITE}IP类型:${NC} ${CYAN}数据中心IP${NC}"
            write_report "IP类型: 数据中心IP"
        else
            echo -e "${WHITE}IP类型:${NC} ${GREEN}住宅IP${NC}"
            write_report "IP类型: 住宅IP"
        fi

        # 代理检测
        if [ "$IS_PROXY" == "true" ]; then
            echo -e "${WHITE}代理状态:${NC} ${RED}检测到代理/VPN${NC}"
            write_report "代理状态: 检测到代理/VPN"
        else
            echo -e "${WHITE}代理状态:${NC} ${GREEN}未检测到代理${NC}"
            write_report "代理状态: 未检测到代理"
        fi

        # DNS服务器
        echo -e "\n${YELLOW}[*] DNS配置检测...${NC}"
        DNS_SERVERS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -5 | tr '\n' ', ' | sed 's/,$//')
        if [ -n "$DNS_SERVERS" ]; then
            echo -e "${WHITE}DNS服务器:${NC} ${CYAN}$DNS_SERVERS${NC}"
            write_report "DNS服务器: $DNS_SERVERS"
        fi

        # 黑名单检测
        echo -e "\n${YELLOW}[*] IP黑名单检测...${NC}"
        BLACKLIST_STATUS="未在黑名单中"
        BLACKLIST_COLOR="${GREEN}"

        # 反转IP用于查询
        REVERSED_IP=$(echo $PUBLIC_IP | awk -F. '{print $4"."$3"."$2"."$1}')

        # 检查Spamhaus
        if host "${REVERSED_IP}.zen.spamhaus.org" &> /dev/null; then
            BLACKLIST_STATUS="发现于Spamhaus黑名单"
            BLACKLIST_COLOR="${RED}"
        fi

        # 检查Barracuda
        if [ "$BLACKLIST_STATUS" == "未在黑名单中" ]; then
            if host "${REVERSED_IP}.b.barracudacentral.org" &> /dev/null; then
                BLACKLIST_STATUS="发现于Barracuda黑名单"
                BLACKLIST_COLOR="${RED}"
            fi
        fi

        echo -e "${WHITE}黑名单状态:${NC} ${BLACKLIST_COLOR}$BLACKLIST_STATUS${NC}"
        write_report "黑名单状态: $BLACKLIST_STATUS"

        # IP信誉分数（使用AbuseIPDB API - 需要注册获取免费API key）
        echo -e "\n${YELLOW}[*] IP威胁情报查询...${NC}"
        ABUSE_SCORE=$(curl -s --max-time 10 "https://api.abuseipdb.com/api/v2/check?ipAddress=$PUBLIC_IP" \
            -H "Key: YOUR_API_KEY_HERE" -H "Accept: application/json" 2>/dev/null | jq -r '.data.abuseConfidenceScore // "N/A"')

        if [ "$ABUSE_SCORE" != "N/A" ] && [ "$ABUSE_SCORE" != "null" ]; then
            if [ "$ABUSE_SCORE" -eq 0 ]; then
                echo -e "${WHITE}威胁评分:${NC} ${GREEN}$ABUSE_SCORE% (优秀)${NC}"
                write_report "威胁评分: $ABUSE_SCORE% (优秀)"
            elif [ "$ABUSE_SCORE" -lt 25 ]; then
                echo -e "${WHITE}威胁评分:${NC} ${YELLOW}$ABUSE_SCORE% (较低)${NC}"
                write_report "威胁评分: $ABUSE_SCORE% (较低)"
            else
                echo -e "${WHITE}威胁评分:${NC} ${RED}$ABUSE_SCORE% (较高)${NC}"
                write_report "威胁评分: $ABUSE_SCORE% (较高)"
            fi
        else
            echo -e "${WHITE}威胁评分:${NC} ${GRAY}未配置API密钥${NC}"
            write_report "威胁评分: 未配置API密钥"
        fi

        # IP风险评估
        echo -e "\n${YELLOW}[*] IP风险评估...${NC}"
        RISK_LEVEL="低风险"
        RISK_COLOR="${GREEN}"

        if [ "$IS_PROXY" == "true" ] || [ "$BLACKLIST_STATUS" != "未在黑名单中" ]; then
            RISK_LEVEL="高风险"
            RISK_COLOR="${RED}"
        elif [ "$IS_HOSTING" == "true" ]; then
            RISK_LEVEL="中等风险"
            RISK_COLOR="${YELLOW}"
        fi

        echo -e "${WHITE}风险等级:${NC} ${RISK_COLOR}$RISK_LEVEL${NC}"
        write_report "风险等级: $RISK_LEVEL"

    else
        echo -e "${RED}[✗] 无法获取公网IP，跳过IP质量检测${NC}"
        write_report "无法获取公网IP"
    fi

    echo ""
    write_report ""
    sleep 1
}

# NAT类型检测
test_nat_type() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[4/11] NAT类型检测${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ NAT类型检测 ━━━\n"

    echo -e "${YELLOW}[*] 正在检测NAT类型...${NC}"

    # 检测是否有公网IP
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    PUBLIC_IP=$(curl -s -4 --max-time 10 ifconfig.me 2>/dev/null)

    if [ "$LOCAL_IP" == "$PUBLIC_IP" ]; then
        NAT_TYPE="无NAT (公网IP直连)"
        NAT_COLOR="${GREEN}"
    else
        # 尝试判断NAT类型
        # 检查是否能绑定公网IP
        if ip addr | grep -q "$PUBLIC_IP"; then
            NAT_TYPE="1:1 NAT (Full Cone)"
            NAT_COLOR="${GREEN}"
        else
            NAT_TYPE="动态NAT/PAT"
            NAT_COLOR="${YELLOW}"
        fi
    fi

    echo -e "${WHITE}本地IP:${NC} ${CYAN}$LOCAL_IP${NC}"
    echo -e "${WHITE}公网IP:${NC} ${CYAN}$PUBLIC_IP${NC}"
    echo -e "${WHITE}NAT类型:${NC} ${NAT_COLOR}$NAT_TYPE${NC}"

    write_report "本地IP: $LOCAL_IP"
    write_report "公网IP: $PUBLIC_IP"
    write_report "NAT类型: $NAT_TYPE"

    echo ""
    write_report ""
    sleep 1
}

# CPU性能测试
test_cpu() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[5/11] CPU性能测试${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ CPU性能测试 ━━━\n"

    # 检查sysbench
    if ! command -v sysbench &> /dev/null; then
        echo -e "${YELLOW}[!] 正在安装 sysbench...${NC}"
        if command -v apt-get &> /dev/null; then
            apt-get install -y -qq sysbench &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y -q sysbench &> /dev/null
        fi
    fi

    if command -v sysbench &> /dev/null; then
        echo -e "${YELLOW}[*] Sysbench CPU测试 (15秒)...${NC}"

        # 单核测试
        echo -e "${CYAN}  [1/2] 单核性能测试...${NC}"
        SINGLE_RESULT=$(sysbench cpu --cpu-max-prime=20000 --threads=1 --time=15 run 2>/dev/null | grep "events per second" | awk '{print $4}')
        SINGLE_SCORE=$(echo "scale=0; $SINGLE_RESULT * 100" | bc 2>/dev/null || echo "0")

        if [ "$SINGLE_SCORE" -gt 2000 ]; then
            SINGLE_RATING="优秀"
            SINGLE_COLOR="${GREEN}"
        elif [ "$SINGLE_SCORE" -gt 1000 ]; then
            SINGLE_RATING="良好"
            SINGLE_COLOR="${YELLOW}"
        else
            SINGLE_RATING="一般"
            SINGLE_COLOR="${GRAY}"
        fi

        echo -e "${WHITE}  单核得分:${NC} ${SINGLE_COLOR}${SINGLE_SCORE} ($SINGLE_RATING)${NC}"
        write_report "单核得分: ${SINGLE_SCORE} ($SINGLE_RATING)"

        # 多核测试
        echo -e "${CYAN}  [2/2] 多核性能测试...${NC}"
        CPU_CORES=$(nproc)
        MULTI_RESULT=$(sysbench cpu --cpu-max-prime=20000 --threads=$CPU_CORES --time=15 run 2>/dev/null | grep "events per second" | awk '{print $4}')
        MULTI_SCORE=$(echo "scale=0; $MULTI_RESULT * 100" | bc 2>/dev/null || echo "0")

        if [ "$MULTI_SCORE" -gt 8000 ]; then
            MULTI_RATING="优秀"
            MULTI_COLOR="${GREEN}"
        elif [ "$MULTI_SCORE" -gt 4000 ]; then
            MULTI_RATING="良好"
            MULTI_COLOR="${YELLOW}"
        else
            MULTI_RATING="一般"
            MULTI_COLOR="${GRAY}"
        fi

        echo -e "${WHITE}  多核得分:${NC} ${MULTI_COLOR}${MULTI_SCORE} ($MULTI_RATING)${NC}"
        write_report "多核得分: ${MULTI_SCORE} ($MULTI_RATING)"

    else
        echo -e "${YELLOW}[*] 使用基础CPU测试...${NC}"
        SINGLE_START=$(date +%s%N)
        echo "scale=5000; 4*a(1)" | bc -l &> /dev/null
        SINGLE_END=$(date +%s%N)
        SINGLE_TIME=$(echo "scale=3; ($SINGLE_END - $SINGLE_START) / 1000000000" | bc)

        echo -e "${WHITE}单核耗时:${NC} ${GREEN}${SINGLE_TIME}s${NC}"
        write_report "单核耗时: ${SINGLE_TIME}s"
    fi

    echo ""
    write_report ""
    sleep 1
}

# 内存性能测试
test_memory() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[6/11] 内存性能测试${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 内存性能测试 ━━━\n"

    echo -e "${YELLOW}[*] 内存读写速度测试...${NC}"

    MEM_START=$(date +%s%N)
    dd if=/dev/zero of=/tmp/test_mem bs=1M count=512 conv=fdatasync 2>&1 | grep -v records
    MEM_END=$(date +%s%N)
    MEM_TIME=$(echo "scale=3; ($MEM_END - $MEM_START) / 1000000000" | bc)
    MEM_SPEED=$(echo "scale=2; 512 / $MEM_TIME" | bc)
    rm -f /tmp/test_mem

    if (( $(echo "$MEM_SPEED > 1000" | bc -l) )); then
        MEM_RATING="优秀"
        MEM_COLOR="${GREEN}"
    elif (( $(echo "$MEM_SPEED > 500" | bc -l) )); then
        MEM_RATING="良好"
        MEM_COLOR="${YELLOW}"
    else
        MEM_RATING="一般"
        MEM_COLOR="${GRAY}"
    fi

    echo -e "${WHITE}写入速度:${NC} ${MEM_COLOR}${MEM_SPEED} MB/s ($MEM_RATING)${NC}"
    write_report "写入速度: ${MEM_SPEED} MB/s ($MEM_RATING)"

    echo ""
    write_report ""
    sleep 1
}

# 磁盘I/O测试 (dd + fio)
test_disk_io() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[7/11] 磁盘I/O性能测试 (三轮平均)${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 磁盘I/O性能测试 ━━━\n"

    # DD测试
    echo -e "${YELLOW}[*] DD 磁盘测试 (共3轮)...${NC}"
    write_report "\n=== DD测试 ==="

    WRITE_SPEEDS=()
    for i in {1..3}; do
        echo -e "${CYAN}  第 $i 轮写入测试...${NC}"
        WRITE_RESULT=$(dd if=/dev/zero of=/tmp/test_write_$i bs=1M count=512 conv=fdatasync oflag=direct 2>&1)
        WRITE_SPEED=$(echo "$WRITE_RESULT" | grep -oP '\d+\.?\d*\s+MB/s' | awk '{print $1}' | head -1)

        if [ -z "$WRITE_SPEED" ]; then
            WRITE_SPEED=$(echo "$WRITE_RESULT" | tail -1 | awk '{print $(NF-1)}')
        fi

        WRITE_SPEEDS+=($WRITE_SPEED)
        echo -e "${WHITE}  写入速度: ${CYAN}${WRITE_SPEED} MB/s${NC}"
        write_report "第${i}轮写入: ${WRITE_SPEED} MB/s"
    done

    WRITE_AVG=$(echo "${WRITE_SPEEDS[@]}" | awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum/NF}')
    WRITE_AVG=$(printf "%.2f" $WRITE_AVG)

    if (( $(echo "$WRITE_AVG > 500" | bc -l) )); then
        WRITE_RATING="优秀 (NVMe/SSD)"
        WRITE_COLOR="${GREEN}"
    elif (( $(echo "$WRITE_AVG > 100" | bc -l) )); then
        WRITE_RATING="良好 (SATA SSD)"
        WRITE_COLOR="${YELLOW}"
    else
        WRITE_RATING="一般 (HDD)"
        WRITE_COLOR="${GRAY}"
    fi

    echo -e "\n${WHITE}平均写入速度:${NC} ${WRITE_COLOR}${WRITE_AVG} MB/s ($WRITE_RATING)${NC}"
    write_report "平均写入: ${WRITE_AVG} MB/s ($WRITE_RATING)"

    # 读取测试
    echo -e "\n${YELLOW}[*] 读取速度测试 (共3轮)...${NC}"
    READ_SPEEDS=()

    for i in {1..3}; do
        echo -e "${CYAN}  第 $i 轮读取测试...${NC}"
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
        READ_RESULT=$(dd if=/tmp/test_write_$i of=/dev/null bs=1M count=512 iflag=direct 2>&1)
        READ_SPEED=$(echo "$READ_RESULT" | grep -oP '\d+\.?\d*\s+MB/s' | awk '{print $1}' | head -1)

        if [ -z "$READ_SPEED" ]; then
            READ_SPEED=$(echo "$READ_RESULT" | tail -1 | awk '{print $(NF-1)}')
        fi

        READ_SPEEDS+=($READ_SPEED)
        echo -e "${WHITE}  读取速度: ${CYAN}${READ_SPEED} MB/s${NC}"
        write_report "第${i}轮读取: ${READ_SPEED} MB/s"
        rm -f /tmp/test_write_$i
    done

    READ_AVG=$(echo "${READ_SPEEDS[@]}" | awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum/NF}')
    READ_AVG=$(printf "%.2f" $READ_AVG)

    if (( $(echo "$READ_AVG > 500" | bc -l) )); then
        READ_RATING="优秀 (NVMe/SSD)"
        READ_COLOR="${GREEN}"
    elif (( $(echo "$READ_AVG > 100" | bc -l) )); then
        READ_RATING="良好 (SATA SSD)"
        READ_COLOR="${YELLOW}"
    else
        READ_RATING="一般 (HDD)"
        READ_COLOR="${GRAY}"
    fi

    echo -e "\n${WHITE}平均读取速度:${NC} ${READ_COLOR}${READ_AVG} MB/s ($READ_RATING)${NC}"
    write_report "平均读取: ${READ_AVG} MB/s ($READ_RATING)"

    echo ""
    write_report ""
    sleep 1
}

# 带宽类型检测
test_bandwidth_type() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[8/11] 带宽类型检测${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 带宽类型检测 ━━━\n"

    echo -e "${YELLOW}[*] 正在检测带宽类型...${NC}"

    # 基于IP类型和ASN信息判断
    PUBLIC_IP=$(curl -s -4 --max-time 10 ifconfig.me 2>/dev/null)
    IP_INFO=$(curl -s --max-time 10 "http://ip-api.com/json/$PUBLIC_IP?fields=isp,org,hosting,mobile" 2>/dev/null)

    IS_HOSTING=$(echo "$IP_INFO" | jq -r '.hosting // false')
    IS_MOBILE=$(echo "$IP_INFO" | jq -r '.mobile // false')
    ISP=$(echo "$IP_INFO" | jq -r '.isp // "未知"')
    ORG=$(echo "$IP_INFO" | jq -r '.org // "未知"')

    if [ "$IS_MOBILE" == "true" ]; then
        BW_TYPE="移动宽带"
        BW_COLOR="${YELLOW}"
        BW_DESC="移动网络接入"
    elif [ "$IS_HOSTING" == "true" ]; then
        BW_TYPE="数据中心/IDC带宽"
        BW_COLOR="${CYAN}"
        BW_DESC="专业数据中心级别带宽"
    else
        # 判断是否为家宽或商宽
        if echo "$ISP $ORG" | grep -iE "residential|broadband|cable|dsl|fiber|home" > /dev/null; then
            BW_TYPE="家庭宽带"
            BW_COLOR="${GREEN}"
            BW_DESC="住宅用户宽带接入"
        elif echo "$ISP $ORG" | grep -iE "business|enterprise|corporate" > /dev/null; then
            BW_TYPE="商业宽带"
            BW_COLOR="${BLUE}"
            BW_DESC="企业级商用宽带"
        else
            BW_TYPE="未知类型"
            BW_COLOR="${GRAY}"
            BW_DESC="无法准确判断"
        fi
    fi

    echo -e "${WHITE}带宽类型:${NC} ${BW_COLOR}$BW_TYPE${NC}"
    echo -e "${WHITE}描述:${NC} ${GRAY}$BW_DESC${NC}"
    echo -e "${WHITE}ISP:${NC} ${CYAN}$ISP${NC}"

    write_report "带宽类型: $BW_TYPE"
    write_report "描述: $BW_DESC"
    write_report "ISP: $ISP"

    echo ""
    write_report ""
    sleep 1
}

# 邮件端口检测
test_mail_ports() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[9/11] 邮件端口检测${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 邮件端口检测 ━━━\n"

    echo -e "${YELLOW}[*] 检测常用邮件端口...${NC}\n"

    # 常用邮件端口
    declare -A MAIL_PORTS=(
        ["SMTP"]="25"
        ["SMTP SSL"]="465"
        ["SMTP TLS"]="587"
        ["POP3"]="110"
        ["POP3 SSL"]="995"
        ["IMAP"]="143"
        ["IMAP SSL"]="993"
    )

    for name in "${!MAIL_PORTS[@]}"; do
        port="${MAIL_PORTS[$name]}"

        # 测试端口连通性
        if timeout 3 bash -c "echo >/dev/tcp/smtp.gmail.com/$port" 2>/dev/null; then
            STATUS="${GREEN}开放${NC}"
            STATUS_TEXT="开放"
        else
            STATUS="${RED}封锁${NC}"
            STATUS_TEXT="封锁"
        fi

        echo -e "${WHITE}端口 $port ($name):${NC} $STATUS"
        write_report "端口 $port ($name): $STATUS_TEXT"
    done

    echo ""
    write_report ""
    sleep 1
}

# 流媒体解锁检测
test_streaming() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[10/11] 流媒体解锁检测${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 流媒体解锁检测 ━━━\n"

    echo -e "${YELLOW}[*] 检测主流流媒体平台...${NC}\n"

    # Netflix
    echo -e "${CYAN}[1/8] Netflix...${NC}"
    NETFLIX_RESULT=$(curl -s --max-time 10 "https://www.netflix.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$NETFLIX_RESULT" == "200" ] || [ "$NETFLIX_RESULT" == "301" ]; then
        echo -e "${WHITE}Netflix:${NC} ${GREEN}✓ 已解锁${NC}"
        write_report "Netflix: ✓ 已解锁"
    else
        echo -e "${WHITE}Netflix:${NC} ${RED}✗ 未解锁${NC}"
        write_report "Netflix: ✗ 未解锁"
    fi

    # YouTube Premium
    echo -e "${CYAN}[2/8] YouTube Premium...${NC}"
    YOUTUBE_RESULT=$(curl -s --max-time 10 "https://www.youtube.com/premium" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$YOUTUBE_RESULT" == "200" ]; then
        echo -e "${WHITE}YouTube Premium:${NC} ${GREEN}✓ 可访问${NC}"
        write_report "YouTube Premium: ✓ 可访问"
    else
        echo -e "${WHITE}YouTube Premium:${NC} ${YELLOW}⚠ 受限${NC}"
        write_report "YouTube Premium: ⚠ 受限"
    fi

    # Disney+
    echo -e "${CYAN}[3/8] Disney+...${NC}"
    DISNEY_RESULT=$(curl -s --max-time 10 "https://www.disneyplus.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$DISNEY_RESULT" == "200" ]; then
        echo -e "${WHITE}Disney+:${NC} ${GREEN}✓ 已解锁${NC}"
        write_report "Disney+: ✓ 已解锁"
    else
        echo -e "${WHITE}Disney+:${NC} ${RED}✗ 未解锁${NC}"
        write_report "Disney+: ✗ 未解锁"
    fi

    # Amazon Prime Video
    echo -e "${CYAN}[4/8] Prime Video...${NC}"
    PRIME_RESULT=$(curl -s --max-time 10 "https://www.primevideo.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$PRIME_RESULT" == "200" ]; then
        echo -e "${WHITE}Prime Video:${NC} ${GREEN}✓ 可访问${NC}"
        write_report "Prime Video: ✓ 可访问"
    else
        echo -e "${WHITE}Prime Video:${NC} ${YELLOW}⚠ 受限${NC}"
        write_report "Prime Video: ⚠ 受限"
    fi

    # HBO Max
    echo -e "${CYAN}[5/8] HBO Max...${NC}"
    HBO_RESULT=$(curl -s --max-time 10 "https://www.hbomax.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$HBO_RESULT" == "200" ]; then
        echo -e "${WHITE}HBO Max:${NC} ${GREEN}✓ 可访问${NC}"
        write_report "HBO Max: ✓ 可访问"
    else
        echo -e "${WHITE}HBO Max:${NC} ${YELLOW}⚠ 受限${NC}"
        write_report "HBO Max: ⚠ 受限"
    fi

    # TikTok
    echo -e "${CYAN}[6/8] TikTok...${NC}"
    TIKTOK_RESULT=$(curl -s --max-time 10 "https://www.tiktok.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$TIKTOK_RESULT" == "200" ]; then
        echo -e "${WHITE}TikTok:${NC} ${GREEN}✓ 可访问${NC}"
        write_report "TikTok: ✓ 可访问"
    else
        echo -e "${WHITE}TikTok:${NC} ${YELLOW}⚠ 受限${NC}"
        write_report "TikTok: ⚠ 受限"
    fi

    # Spotify
    echo -e "${CYAN}[7/8] Spotify...${NC}"
    SPOTIFY_RESULT=$(curl -s --max-time 10 "https://www.spotify.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$SPOTIFY_RESULT" == "200" ]; then
        echo -e "${WHITE}Spotify:${NC} ${GREEN}✓ 可访问${NC}"
        write_report "Spotify: ✓ 可访问"
    else
        echo -e "${WHITE}Spotify:${NC} ${YELLOW}⚠ 受限${NC}"
        write_report "Spotify: ⚠ 受限"
    fi

    # Twitch
    echo -e "${CYAN}[8/8] Twitch...${NC}"
    TWITCH_RESULT=$(curl -s --max-time 10 "https://www.twitch.tv" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$TWITCH_RESULT" == "200" ]; then
        echo -e "${WHITE}Twitch:${NC} ${GREEN}✓ 可访问${NC}"
        write_report "Twitch: ✓ 可访问"
    else
        echo -e "${WHITE}Twitch:${NC} ${YELLOW}⚠ 受限${NC}"
        write_report "Twitch: ⚠ 受限"
    fi

    echo ""
    write_report ""
    sleep 1
}

# 网络速度测试
test_network_speed() {
    print_line "${BLUE}"
    echo -e "${BOLD}${BLUE}[11/11] 网络速度测试${NC}"
    print_line "${BLUE}"

    write_report "\n━━━ 网络速度测试 ━━━\n"

    if command -v speedtest-cli &> /dev/null; then
        echo -e "${YELLOW}[*] 正在进行Speedtest测试 (需要1-2分钟)...${NC}\n"

        SPEED_RESULT=$(speedtest-cli --simple 2>/dev/null)

        if [ -n "$SPEED_RESULT" ]; then
            PING_MS=$(echo "$SPEED_RESULT" | grep "Ping:" | awk '{print $2}')
            DOWNLOAD_SPEED=$(echo "$SPEED_RESULT" | grep "Download:" | awk '{print $2}')
            UPLOAD_SPEED=$(echo "$SPEED_RESULT" | grep "Upload:" | awk '{print $2}')

            echo -e "${WHITE}延迟:${NC} ${GREEN}${PING_MS} ms${NC}"
            echo -e "${WHITE}下载速度:${NC} ${GREEN}${DOWNLOAD_SPEED} Mbit/s${NC}"
            echo -e "${WHITE}上传速度:${NC} ${GREEN}${UPLOAD_SPEED} Mbit/s${NC}"

            write_report "延迟: ${PING_MS} ms"
            write_report "下载速度: ${DOWNLOAD_SPEED} Mbit/s"
            write_report "上传速度: ${UPLOAD_SPEED} Mbit/s"
        else
            echo -e "${RED}速度测试失败${NC}"
            write_report "速度测试失败"
        fi
    else
        echo -e "${YELLOW}[*] speedtest-cli 未安装，跳过速度测试${NC}"
        write_report "speedtest-cli 未安装"
    fi

    echo ""
    write_report ""
    sleep 1
}

# 测试总结
test_summary() {
    print_line "${GREEN}"
    echo -e "${BOLD}${GREEN}测试完成！${NC}"
    print_line "${GREEN}"

    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    MINUTES=$((TOTAL_TIME / 60))
    SECONDS=$((TOTAL_TIME % 60))

    echo -e "${WHITE}总耗时:${NC} ${CYAN}${MINUTES}分${SECONDS}秒${NC}"
    echo -e "${WHITE}报告文件:${NC} ${CYAN}$REPORT_FILE${NC}"
    echo ""

    write_report "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    write_report "测试总结"
    write_report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    write_report "\n测试耗时: ${MINUTES}分${SECONDS}秒"
    write_report "测试工具: ${SCRIPT_NAME} V${VERSION}"
    write_report "测试时间: $(date '+%Y-%m-%d %H:%M:%S')"
    write_report "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    write_report "威软科技测试脚本 V${VERSION} - 融合怪版"
    write_report "GitHub: https://github.com/weiruankeji2025/weiruan-vps"
    write_report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo -e "${YELLOW}测试报告已保存至: ${CYAN}$REPORT_FILE${NC}"
    echo -e "${GREEN}可以使用以下命令查看报告:${NC}"
    echo -e "${CYAN}cat $REPORT_FILE${NC}"
    echo ""

    print_line "${GREEN}"
    echo -e "${BOLD}${GREEN}感谢使用威软科技VPS综合测试工具！${NC}"
    print_line "${GREEN}"

    # 清理临时文件
    rm -rf "$TEMP_DIR"
}

# 主函数
main() {
    print_banner
    check_dependencies
    init_report

    test_basic_info
    test_ip_info
    test_ip_quality
    test_nat_type
    test_cpu
    test_memory
    test_disk_io
    test_bandwidth_type
    test_mail_ports
    test_streaming
    test_network_speed
    test_summary
}

# 运行主函数
main
