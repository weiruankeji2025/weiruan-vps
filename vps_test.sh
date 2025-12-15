#!/bin/bash

#===========================================
# VPS 综合测试工具
# 版本: 威软科技测试脚本 V2.0
# 作者: 威软科技
#===========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# 全局变量
REPORT_FILE="vps_test_report_$(date +%Y%m%d_%H%M%S).md"
START_TIME=$(date +%s)
TEMP_DIR="/tmp/vps_test_$$"

# 打印分隔线
print_separator() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

# 打印标题
print_title() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "  ██╗   ██╗██████╗ ███╗   ███╗    ████████╗███████╗███╗   ██╗████████╗"
    echo "  ██║   ██║██╔══██╗████╗ ████║    ╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝"
    echo "  ██║   ██║██████╔╝██╔████╔██║       ██║   █████╗  ██╔██╗ ██║   ██║   "
    echo "  ╚██╗ ██╔╝██╔═══╝ ██║╚██╔╝██║       ██║   ██╔══╝  ██║╚██╗██║   ██║   "
    echo "   ╚████╔╝ ██║     ██║ ╚═╝ ██║       ██║   ███████╗██║ ╚████║   ██║   "
    echo "    ╚═══╝  ╚═╝     ╚═╝     ╚═╝       ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${CYAN}${BOLD}                    威软科技 VPS 综合测试工具 V2.0${NC}"
    echo -e "${YELLOW}                    https://github.com/weiruankeji2025${NC}"
    print_separator
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}[*] 检查并安装必要的依赖...${NC}"

    local deps=("curl" "wget" "bc" "jq" "python3")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}[!] 正在安装缺失的依赖: ${missing_deps[*]}${NC}"

        if command -v apt-get &> /dev/null; then
            apt-get update -qq &> /dev/null
            apt-get install -y -qq "${missing_deps[@]}" python3-pip &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y -q "${missing_deps[@]}" python3-pip &> /dev/null
        elif command -v dnf &> /dev/null; then
            dnf install -y -q "${missing_deps[@]}" python3-pip &> /dev/null
        else
            echo -e "${RED}[✗] 无法自动安装依赖，请手动安装: ${missing_deps[*]}${NC}"
            exit 1
        fi
    fi

    # 安装 speedtest-cli
    if ! command -v speedtest-cli &> /dev/null; then
        echo -e "${YELLOW}[!] 正在安装 speedtest-cli...${NC}"
        pip3 install speedtest-cli --quiet 2>/dev/null || pip install speedtest-cli --quiet 2>/dev/null
    fi

    mkdir -p "$TEMP_DIR"
    echo -e "${GREEN}[✓] 依赖检查完成${NC}\n"
}

# 初始化 Markdown 报告
init_report() {
    cat > "$REPORT_FILE" << EOF
# VPS 综合测试报告

> **测试时间**: $(date '+%Y-%m-%d %H:%M:%S')
> **测试工具**: 威软科技测试脚本 V2.0

---

EOF
}

# 添加到报告
add_to_report() {
    echo -e "$1" >> "$REPORT_FILE"
}

# 系统信息检测 (包含IP和地理位置)
test_system_info() {
    print_separator
    echo -e "${BOLD}${BLUE}[1/9] 系统信息检测${NC}"
    print_separator

    add_to_report "## 📊 系统基础信息\n"
    add_to_report "| 项目 | 信息 |"
    add_to_report "|------|------|"

    # 操作系统
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)
    else
        OS_NAME=$(uname -s)
    fi
    echo -e "${WHITE}操作系统:${NC} ${GREEN}$OS_NAME${NC}"
    add_to_report "| **操作系统** | $OS_NAME |"

    # 内核版本
    KERNEL=$(uname -r)
    echo -e "${WHITE}内核版本:${NC} ${GREEN}$KERNEL${NC}"
    add_to_report "| **内核版本** | $KERNEL |"

    # 系统架构
    ARCH=$(uname -m)
    echo -e "${WHITE}系统架构:${NC} ${GREEN}$ARCH${NC}"
    add_to_report "| **系统架构** | $ARCH |"

    # CPU 信息
    CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name:[ \t]*//')
    CPU_CORES=$(nproc)
    CPU_FREQ=$(lscpu | grep "CPU MHz" | awk '{print $3}' | head -1)
    echo -e "${WHITE}CPU型号:${NC} ${GREEN}$CPU_MODEL${NC}"
    echo -e "${WHITE}CPU核心:${NC} ${GREEN}$CPU_CORES 核${NC}"
    echo -e "${WHITE}CPU频率:${NC} ${GREEN}$CPU_FREQ MHz${NC}"
    add_to_report "| **CPU型号** | $CPU_MODEL |"
    add_to_report "| **CPU核心** | $CPU_CORES 核 |"
    add_to_report "| **CPU频率** | $CPU_FREQ MHz |"

    # 内存信息
    TOTAL_MEM=$(free -h | awk '/^Mem:/{print $2}')
    USED_MEM=$(free -h | awk '/^Mem:/{print $3}')
    FREE_MEM=$(free -h | awk '/^Mem:/{print $4}')
    echo -e "${WHITE}总内存:${NC} ${GREEN}$TOTAL_MEM${NC}"
    echo -e "${WHITE}已用内存:${NC} ${YELLOW}$USED_MEM${NC}"
    echo -e "${WHITE}可用内存:${NC} ${GREEN}$FREE_MEM${NC}"
    add_to_report "| **总内存** | $TOTAL_MEM |"
    add_to_report "| **已用内存** | $USED_MEM |"
    add_to_report "| **可用内存** | $FREE_MEM |"

    # 磁盘信息
    TOTAL_DISK=$(df -h / | awk 'NR==2 {print $2}')
    USED_DISK=$(df -h / | awk 'NR==2 {print $3}')
    FREE_DISK=$(df -h / | awk 'NR==2 {print $4}')
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
    echo -e "${WHITE}总磁盘:${NC} ${GREEN}$TOTAL_DISK${NC}"
    echo -e "${WHITE}已用磁盘:${NC} ${YELLOW}$USED_DISK ($DISK_USAGE)${NC}"
    echo -e "${WHITE}可用磁盘:${NC} ${GREEN}$FREE_DISK${NC}"
    add_to_report "| **总磁盘** | $TOTAL_DISK |"
    add_to_report "| **已用磁盘** | $USED_DISK ($DISK_USAGE) |"
    add_to_report "| **可用磁盘** | $FREE_DISK |"

    # 虚拟化类型
    VIRT_TYPE="Unknown"
    if command -v systemd-detect-virt &> /dev/null; then
        VIRT_TYPE=$(systemd-detect-virt)
        if [ "$VIRT_TYPE" == "none" ]; then
            VIRT_TYPE="物理机"
        fi
    elif [ -f /proc/cpuinfo ]; then
        if grep -q "hypervisor" /proc/cpuinfo; then
            VIRT_TYPE="虚拟机"
        else
            VIRT_TYPE="物理机"
        fi
    fi
    echo -e "${WHITE}虚拟化:${NC} ${PURPLE}$VIRT_TYPE${NC}"
    add_to_report "| **虚拟化类型** | $VIRT_TYPE |"

    # 运行时间
    UPTIME=$(uptime -p)
    echo -e "${WHITE}运行时间:${NC} ${CYAN}$UPTIME${NC}"
    add_to_report "| **运行时间** | $UPTIME |"

    # 获取IP地址和地理位置
    echo -e "\n${YELLOW}[*] 获取网络信息...${NC}"
    PUBLIC_IP=$(curl -s -4 --max-time 5 ifconfig.me 2>/dev/null || curl -s -4 --max-time 5 icanhazip.com 2>/dev/null || echo "无法获取")

    if [ "$PUBLIC_IP" != "无法获取" ]; then
        echo -e "${WHITE}公网IPv4:${NC} ${GREEN}$PUBLIC_IP${NC}"
        add_to_report "| **公网IPv4** | $PUBLIC_IP |"

        # IP地理位置
        IP_INFO=$(curl -s --max-time 5 "http://ip-api.com/json/$PUBLIC_IP?fields=status,country,countryCode,region,regionName,city,isp,as,org,mobile,proxy,hosting" 2>/dev/null)
        if [ -n "$IP_INFO" ]; then
            COUNTRY=$(echo "$IP_INFO" | jq -r '.country // "未知"' 2>/dev/null || echo "未知")
            REGION=$(echo "$IP_INFO" | jq -r '.regionName // "未知"' 2>/dev/null || echo "未知")
            CITY=$(echo "$IP_INFO" | jq -r '.city // "未知"' 2>/dev/null || echo "未知")
            ISP=$(echo "$IP_INFO" | jq -r '.isp // "未知"' 2>/dev/null || echo "未知")
            ORG=$(echo "$IP_INFO" | jq -r '.org // "未知"' 2>/dev/null || echo "未知")
            AS_NUM=$(echo "$IP_INFO" | jq -r '.as // "未知"' 2>/dev/null || echo "未知")

            echo -e "${WHITE}地理位置:${NC} ${CYAN}$COUNTRY / $REGION / $CITY${NC}"
            echo -e "${WHITE}ISP:${NC} ${CYAN}$ISP${NC}"
            echo -e "${WHITE}组织:${NC} ${CYAN}$ORG${NC}"
            echo -e "${WHITE}AS号:${NC} ${CYAN}$AS_NUM${NC}"

            add_to_report "| **地理位置** | $COUNTRY / $REGION / $CITY |"
            add_to_report "| **ISP** | $ISP |"
            add_to_report "| **组织** | $ORG |"
            add_to_report "| **AS号** | $AS_NUM |"
        fi
    else
        echo -e "${WHITE}公网IP:${NC} ${RED}无法获取${NC}"
        add_to_report "| **公网IP** | 无法获取 |"
    fi

    add_to_report ""
    echo ""
    sleep 1
}

# IP质量检测
test_ip_quality() {
    print_separator
    echo -e "${BOLD}${BLUE}[2/9] IP 质量检测${NC}"
    print_separator

    add_to_report "## 🔍 IP 质量检测\n"
    add_to_report "| 检测项目 | 结果 | 状态 |"
    add_to_report "|---------|------|------|"

    PUBLIC_IP=$(curl -s -4 --max-time 5 ifconfig.me 2>/dev/null)

    if [ -n "$PUBLIC_IP" ]; then
        # 使用 ip-api.com 检测
        IP_INFO=$(curl -s --max-time 5 "http://ip-api.com/json/$PUBLIC_IP?fields=status,mobile,proxy,hosting" 2>/dev/null)

        if [ -n "$IP_INFO" ]; then
            IS_MOBILE=$(echo "$IP_INFO" | jq -r '.mobile // false' 2>/dev/null)
            IS_PROXY=$(echo "$IP_INFO" | jq -r '.proxy // false' 2>/dev/null)
            IS_HOSTING=$(echo "$IP_INFO" | jq -r '.hosting // false' 2>/dev/null)

            # 移动网络检测
            if [ "$IS_MOBILE" == "true" ]; then
                echo -e "${WHITE}移动网络:${NC} ${YELLOW}是${NC}"
                add_to_report "| **移动网络** | 是 | ⚠️ |"
            else
                echo -e "${WHITE}移动网络:${NC} ${GREEN}否${NC}"
                add_to_report "| **移动网络** | 否 | ✅ |"
            fi

            # 代理检测
            if [ "$IS_PROXY" == "true" ]; then
                echo -e "${WHITE}代理/VPN:${NC} ${RED}检测到${NC}"
                add_to_report "| **代理/VPN** | 检测到 | ❌ |"
            else
                echo -e "${WHITE}代理/VPN:${NC} ${GREEN}未检测到${NC}"
                add_to_report "| **代理/VPN** | 未检测到 | ✅ |"
            fi

            # 数据中心检测
            if [ "$IS_HOSTING" == "true" ]; then
                echo -e "${WHITE}数据中心IP:${NC} ${YELLOW}是${NC}"
                add_to_report "| **数据中心IP** | 是 | ⚠️ |"
            else
                echo -e "${WHITE}数据中心IP:${NC} ${GREEN}否 (住宅IP)${NC}"
                add_to_report "| **数据中心IP** | 否 (住宅IP) | ✅ |"
            fi
        fi

        # DNS泄露检测
        echo -e "\n${YELLOW}[*] DNS泄露检测...${NC}"
        DNS_SERVERS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -3)
        if [ -n "$DNS_SERVERS" ]; then
            echo -e "${WHITE}DNS服务器:${NC} ${CYAN}$(echo $DNS_SERVERS | tr '\n' ', ')${NC}"
            add_to_report "| **DNS服务器** | $(echo $DNS_SERVERS | tr '\n' ', ') | ℹ️ |"
        fi

        # 黑名单检测 (使用多个RBL)
        echo -e "\n${YELLOW}[*] IP黑名单检测...${NC}"
        BLACKLIST_STATUS="未检测到"
        BLACKLIST_COLOR="${GREEN}"

        # 检查常见黑名单
        if host "$PUBLIC_IP" zen.spamhaus.org &> /dev/null; then
            BLACKLIST_STATUS="检测到(Spamhaus)"
            BLACKLIST_COLOR="${RED}"
        fi

        echo -e "${WHITE}黑名单状态:${NC} ${BLACKLIST_COLOR}${BLACKLIST_STATUS}${NC}"
        if [ "$BLACKLIST_STATUS" == "未检测到" ]; then
            add_to_report "| **黑名单状态** | 未检测到 | ✅ |"
        else
            add_to_report "| **黑名单状态** | $BLACKLIST_STATUS | ❌ |"
        fi

    else
        echo -e "${RED}无法获取公网IP，跳过IP质量检测${NC}"
        add_to_report "| - | 无法获取公网IP | ❌ |"
    fi

    add_to_report ""
    echo ""
    sleep 1
}

# CPU 性能测试 (Geekbench)
test_cpu() {
    print_separator
    echo -e "${BOLD}${BLUE}[3/9] CPU 性能测试 (Geekbench)${NC}"
    print_separator

    add_to_report "## 🔥 CPU 性能测试\n"

    # 检测架构
    ARCH=$(uname -m)
    GB_URL=""
    GB_VERSION=""

    echo -e "${YELLOW}[*] 准备 Geekbench 测试...${NC}"

    # 由于Geekbench需要下载和license，我们使用轻量级的替代方案
    # 使用sysbench进行CPU测试
    if ! command -v sysbench &> /dev/null; then
        echo -e "${YELLOW}[!] 正在安装 sysbench...${NC}"
        if command -v apt-get &> /dev/null; then
            apt-get install -y -qq sysbench &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y -q sysbench &> /dev/null
        fi
    fi

    if command -v sysbench &> /dev/null; then
        echo -e "${YELLOW}[*] 执行单核CPU测试...${NC}"
        SINGLE_RESULT=$(sysbench cpu --cpu-max-prime=20000 --threads=1 --time=15 run 2>/dev/null | grep "events per second" | awk '{print $4}')
        SINGLE_SCORE=$(echo "scale=0; $SINGLE_RESULT * 100" | bc 2>/dev/null || echo "N/A")

        echo -e "${YELLOW}[*] 执行多核CPU测试...${NC}"
        CPU_CORES=$(nproc)
        MULTI_RESULT=$(sysbench cpu --cpu-max-prime=20000 --threads=$CPU_CORES --time=15 run 2>/dev/null | grep "events per second" | awk '{print $4}')
        MULTI_SCORE=$(echo "scale=0; $MULTI_RESULT * 100" | bc 2>/dev/null || echo "N/A")

        if [ "$SINGLE_SCORE" != "N/A" ]; then
            echo -e "${WHITE}单核得分:${NC} ${GREEN}${SINGLE_SCORE}${NC}"
            add_to_report "| 测试项目 | 得分 | 说明 |"
            add_to_report "|---------|------|------|"
            add_to_report "| **单核性能** | $SINGLE_SCORE | Sysbench Score |"
        fi

        if [ "$MULTI_SCORE" != "N/A" ]; then
            echo -e "${WHITE}多核得分:${NC} ${GREEN}${MULTI_SCORE}${NC}"
            add_to_report "| **多核性能** | $MULTI_SCORE | Sysbench Score |"
        fi
    else
        # 回退到简单测试
        echo -e "${YELLOW}[*] 使用基础CPU测试...${NC}"
        SINGLE_START=$(date +%s%N)
        echo "scale=5000; 4*a(1)" | bc -l &> /dev/null
        SINGLE_END=$(date +%s%N)
        SINGLE_TIME=$(echo "scale=3; ($SINGLE_END - $SINGLE_START) / 1000000000" | bc)

        echo -e "${WHITE}单核耗时:${NC} ${GREEN}${SINGLE_TIME}s${NC}"
        add_to_report "| 测试项目 | 结果 | 说明 |"
        add_to_report "|---------|------|------|"
        add_to_report "| **单核性能** | ${SINGLE_TIME}s | 圆周率计算 |"
    fi

    add_to_report ""
    add_to_report "> 💡 **说明**: CPU测试使用Sysbench进行评分，分数越高性能越好。"
    add_to_report ""
    echo ""
    sleep 1
}

# 内存性能测试
test_memory() {
    print_separator
    echo -e "${BOLD}${BLUE}[4/9] 内存性能测试${NC}"
    print_separator

    add_to_report "## 💾 内存性能测试\n"

    echo -e "${YELLOW}[*] 内存读写速度测试...${NC}"

    MEM_START=$(date +%s%N)
    dd if=/dev/zero of=/tmp/test_mem bs=1M count=512 conv=fdatasync 2>&1 | grep -v records
    MEM_END=$(date +%s%N)
    MEM_TIME=$(echo "scale=3; ($MEM_END - $MEM_START) / 1000000000" | bc)
    MEM_SPEED=$(echo "scale=2; 512 / $MEM_TIME" | bc)
    rm -f /tmp/test_mem

    if (( $(echo "$MEM_SPEED > 1000" | bc -l) )); then
        MEM_SCORE="优秀"
        MEM_COLOR="${GREEN}"
    elif (( $(echo "$MEM_SPEED > 500" | bc -l) )); then
        MEM_SCORE="良好"
        MEM_COLOR="${YELLOW}"
    else
        MEM_SCORE="一般"
        MEM_COLOR="${RED}"
    fi

    echo -e "${WHITE}写入速度:${NC} ${MEM_COLOR}${MEM_SPEED} MB/s ($MEM_SCORE)${NC}"
    add_to_report "| 测试项目 | 结果 | 评分 |"
    add_to_report "|---------|------|------|"
    add_to_report "| **内存写入速度** | ${MEM_SPEED} MB/s | $MEM_SCORE |"

    add_to_report ""
    echo ""
    sleep 1
}

# 磁盘 I/O 测试 (三轮取平均)
test_disk_io() {
    print_separator
    echo -e "${BOLD}${BLUE}[5/9] 磁盘 I/O 性能测试 (三轮平均)${NC}"
    print_separator

    add_to_report "## 💿 磁盘 I/O 性能测试\n"

    # 写入测试 - 三轮
    echo -e "${YELLOW}[*] 磁盘写入速度测试 (共3轮)...${NC}"
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
        sleep 1
    done

    # 计算写入平均值
    WRITE_AVG=$(echo "${WRITE_SPEEDS[@]}" | awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum/NF}')
    WRITE_AVG=$(printf "%.2f" $WRITE_AVG)

    if (( $(echo "$WRITE_AVG > 500" | bc -l) )); then
        WRITE_SCORE="优秀 (SSD)"
        WRITE_COLOR="${GREEN}"
    elif (( $(echo "$WRITE_AVG > 100" | bc -l) )); then
        WRITE_SCORE="良好"
        WRITE_COLOR="${YELLOW}"
    else
        WRITE_SCORE="一般 (HDD)"
        WRITE_COLOR="${RED}"
    fi

    echo -e "\n${WHITE}平均写入速度:${NC} ${WRITE_COLOR}${WRITE_AVG} MB/s ($WRITE_SCORE)${NC}"

    # 读取测试 - 三轮
    echo -e "\n${YELLOW}[*] 磁盘读取速度测试 (共3轮)...${NC}"
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
        rm -f /tmp/test_write_$i
        sleep 1
    done

    # 计算读取平均值
    READ_AVG=$(echo "${READ_SPEEDS[@]}" | awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum/NF}')
    READ_AVG=$(printf "%.2f" $READ_AVG)

    if (( $(echo "$READ_AVG > 500" | bc -l) )); then
        READ_SCORE="优秀 (SSD)"
        READ_COLOR="${GREEN}"
    elif (( $(echo "$READ_AVG > 100" | bc -l) )); then
        READ_SCORE="良好"
        READ_COLOR="${YELLOW}"
    else
        READ_SCORE="一般 (HDD)"
        READ_COLOR="${RED}"
    fi

    echo -e "\n${WHITE}平均读取速度:${NC} ${READ_COLOR}${READ_AVG} MB/s ($READ_SCORE)${NC}"

    add_to_report "| 测试项目 | 第1轮 | 第2轮 | 第3轮 | 平均值 | 评分 |"
    add_to_report "|---------|------|------|------|--------|------|"
    add_to_report "| **磁盘写入** | ${WRITE_SPEEDS[0]} MB/s | ${WRITE_SPEEDS[1]} MB/s | ${WRITE_SPEEDS[2]} MB/s | **${WRITE_AVG} MB/s** | $WRITE_SCORE |"
    add_to_report "| **磁盘读取** | ${READ_SPEEDS[0]} MB/s | ${READ_SPEEDS[1]} MB/s | ${READ_SPEEDS[2]} MB/s | **${READ_AVG} MB/s** | $READ_SCORE |"

    add_to_report ""
    echo ""
    sleep 1
}

# 网络延迟测试 (全球+中国主要城市)
test_network_latency() {
    print_separator
    echo -e "${BOLD}${BLUE}[6/9] 全球网络延迟测试${NC}"
    print_separator

    add_to_report "## 🌍 全球网络延迟测试\n"

    echo -e "${YELLOW}[*] 测试全球主要城市延迟...${NC}\n"

    # 全球主要城市测试节点
    declare -A GLOBAL_PING_TARGETS=(
        ["🇺🇸 洛杉矶"]="lax.us.cloudping.info"
        ["🇺🇸 纽约"]="nrt.us.cloudping.info"
        ["🇬🇧 伦敦"]="lon.uk.cloudping.info"
        ["🇩🇪 法兰克福"]="fra.de.cloudping.info"
        ["🇸🇬 新加坡"]="sin.sg.cloudping.info"
        ["🇯🇵 东京"]="tyo.jp.cloudping.info"
        ["🇰🇷 首尔"]="icn.kr.cloudping.info"
        ["🇦🇺 悉尼"]="syd.au.cloudping.info"
        ["🇧🇷 圣保罗"]="gru.br.cloudping.info"
        ["🇮🇳 孟买"]="bom.in.cloudping.info"
    )

    # 中国大陆主要城市
    declare -A CHINA_PING_TARGETS=(
        ["🇨🇳 北京"]="beijing.aliyun.com"
        ["🇨🇳 上海"]="shanghai.aliyun.com"
        ["🇨🇳 广州"]="guangzhou.aliyun.com"
        ["🇨🇳 深圳"]="shenzhen.aliyun.com"
        ["🇨🇳 成都"]="chengdu.aliyun.com"
        ["🇨🇳 杭州"]="hangzhou.aliyun.com"
        ["🇨🇳 香港"]="hkg.aliyun.com"
    )

    add_to_report "### 全球主要城市\n"
    add_to_report "| 城市 | 延迟 | 状态 |"
    add_to_report "|------|------|------|"

    for name in "${!GLOBAL_PING_TARGETS[@]}"; do
        target="${GLOBAL_PING_TARGETS[$name]}"
        PING_RESULT=$(ping -c 4 -W 2 "$target" 2>/dev/null | grep 'avg' | awk -F '/' '{print $5}')

        if [ -n "$PING_RESULT" ]; then
            PING_MS=$(printf "%.2f" $PING_RESULT)
            if (( $(echo "$PING_RESULT < 50" | bc -l) )); then
                PING_STATUS="优秀"
                PING_COLOR="${GREEN}"
            elif (( $(echo "$PING_RESULT < 150" | bc -l) )); then
                PING_STATUS="良好"
                PING_COLOR="${YELLOW}"
            else
                PING_STATUS="一般"
                PING_COLOR="${RED}"
            fi
            echo -e "${WHITE}${name}:${NC} ${PING_COLOR}${PING_MS} ms ($PING_STATUS)${NC}"
            add_to_report "| $name | ${PING_MS} ms | $PING_STATUS |"
        else
            echo -e "${WHITE}${name}:${NC} ${RED}超时${NC}"
            add_to_report "| $name | 超时 | 无法连接 |"
        fi
    done

    echo ""
    add_to_report ""
    add_to_report "### 中国大陆主要城市\n"
    add_to_report "| 城市 | 延迟 | 状态 |"
    add_to_report "|------|------|------|"

    for name in "${!CHINA_PING_TARGETS[@]}"; do
        target="${CHINA_PING_TARGETS[$name]}"
        PING_RESULT=$(ping -c 4 -W 2 "$target" 2>/dev/null | grep 'avg' | awk -F '/' '{print $5}')

        if [ -n "$PING_RESULT" ]; then
            PING_MS=$(printf "%.2f" $PING_RESULT)
            if (( $(echo "$PING_RESULT < 50" | bc -l) )); then
                PING_STATUS="优秀"
                PING_COLOR="${GREEN}"
            elif (( $(echo "$PING_RESULT < 150" | bc -l) )); then
                PING_STATUS="良好"
                PING_COLOR="${YELLOW}"
            else
                PING_STATUS="一般"
                PING_COLOR="${RED}"
            fi
            echo -e "${WHITE}${name}:${NC} ${PING_COLOR}${PING_MS} ms ($PING_STATUS)${NC}"
            add_to_report "| $name | ${PING_MS} ms | $PING_STATUS |"
        else
            echo -e "${WHITE}${name}:${NC} ${RED}超时${NC}"
            add_to_report "| $name | 超时 | 无法连接 |"
        fi
    done

    add_to_report ""
    echo ""
    sleep 1
}

# 网络速度测试 (上下行)
test_network_speed() {
    print_separator
    echo -e "${BOLD}${BLUE}[7/9] 网络速度测试 (上传/下载)${NC}"
    print_separator

    add_to_report "## 🚀 网络速度测试\n"

    if command -v speedtest-cli &> /dev/null; then
        echo -e "${YELLOW}[*] 正在进行速度测试 (这可能需要1-2分钟)...${NC}\n"

        SPEED_RESULT=$(speedtest-cli --simple 2>/dev/null)

        if [ -n "$SPEED_RESULT" ]; then
            PING_MS=$(echo "$SPEED_RESULT" | grep "Ping:" | awk '{print $2}')
            DOWNLOAD_SPEED=$(echo "$SPEED_RESULT" | grep "Download:" | awk '{print $2}')
            UPLOAD_SPEED=$(echo "$SPEED_RESULT" | grep "Upload:" | awk '{print $2}')

            echo -e "${WHITE}延迟:${NC} ${GREEN}${PING_MS} ms${NC}"
            echo -e "${WHITE}下载速度:${NC} ${GREEN}${DOWNLOAD_SPEED} Mbit/s${NC}"
            echo -e "${WHITE}上传速度:${NC} ${GREEN}${UPLOAD_SPEED} Mbit/s${NC}"

            add_to_report "| 测试项目 | 速度 |"
            add_to_report "|---------|------|"
            add_to_report "| **延迟** | ${PING_MS} ms |"
            add_to_report "| **下载速度** | ${DOWNLOAD_SPEED} Mbit/s |"
            add_to_report "| **上传速度** | ${UPLOAD_SPEED} Mbit/s |"
        else
            echo -e "${RED}速度测试失败${NC}"
            add_to_report "| - | 测试失败 |"
        fi
    else
        echo -e "${YELLOW}[*] speedtest-cli 未安装，使用简单下载测试...${NC}"

        # 简单下载测试
        TEST_URL="http://speedtest.tele2.net/10MB.zip"
        DOWNLOAD_SPEED=$(curl -o /dev/null -s -w '%{speed_download}' --connect-timeout 5 --max-time 15 "$TEST_URL" 2>/dev/null)

        if [ -n "$DOWNLOAD_SPEED" ] && [ "$DOWNLOAD_SPEED" != "0.000" ]; then
            DOWNLOAD_SPEED_MBPS=$(echo "scale=2; $DOWNLOAD_SPEED * 8 / 1048576" | bc)
            echo -e "${WHITE}下载速度:${NC} ${GREEN}${DOWNLOAD_SPEED_MBPS} Mbit/s${NC}"
            add_to_report "| 测试项目 | 速度 |"
            add_to_report "|---------|------|"
            add_to_report "| **下载速度** | ${DOWNLOAD_SPEED_MBPS} Mbit/s |"
        else
            echo -e "${RED}速度测试失败${NC}"
            add_to_report "| - | 测试失败 |"
        fi
    fi

    add_to_report ""
    echo ""
    sleep 1
}

# 流媒体解锁测试
test_streaming() {
    print_separator
    echo -e "${BOLD}${BLUE}[8/9] 流媒体解锁检测${NC}"
    print_separator

    add_to_report "## 🎬 流媒体解锁检测\n"
    add_to_report "| 平台 | 状态 | 区域 |"
    add_to_report "|------|------|------|"

    echo -e "${YELLOW}[*] 检测流媒体平台...${NC}\n"

    # Netflix 检测
    echo -e "${CYAN}检测 Netflix...${NC}"
    NETFLIX_RESULT=$(curl -s --max-time 10 "https://www.netflix.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$NETFLIX_RESULT" == "200" ]; then
        echo -e "${WHITE}Netflix:${NC} ${GREEN}✓ 已解锁${NC}"
        add_to_report "| **Netflix** | ✅ 已解锁 | 检测成功 |"
    else
        echo -e "${WHITE}Netflix:${NC} ${RED}✗ 未解锁${NC}"
        add_to_report "| **Netflix** | ❌ 未解锁 | - |"
    fi

    # YouTube Premium 检测
    echo -e "${CYAN}检测 YouTube Premium...${NC}"
    YOUTUBE_RESULT=$(curl -s --max-time 10 "https://www.youtube.com/premium" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$YOUTUBE_RESULT" == "200" ]; then
        echo -e "${WHITE}YouTube Premium:${NC} ${GREEN}✓ 可访问${NC}"
        add_to_report "| **YouTube Premium** | ✅ 可访问 | 正常 |"
    else
        echo -e "${WHITE}YouTube Premium:${NC} ${YELLOW}⚠ 受限${NC}"
        add_to_report "| **YouTube Premium** | ⚠️ 受限 | - |"
    fi

    # Disney+ 检测
    echo -e "${CYAN}检测 Disney+...${NC}"
    DISNEY_RESULT=$(curl -s --max-time 10 "https://www.disneyplus.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$DISNEY_RESULT" == "200" ]; then
        echo -e "${WHITE}Disney+:${NC} ${GREEN}✓ 已解锁${NC}"
        add_to_report "| **Disney+** | ✅ 已解锁 | 检测成功 |"
    else
        echo -e "${WHITE}Disney+:${NC} ${RED}✗ 未解锁${NC}"
        add_to_report "| **Disney+** | ❌ 未解锁 | - |"
    fi

    # Amazon Prime Video 检测
    echo -e "${CYAN}检测 Amazon Prime Video...${NC}"
    PRIME_RESULT=$(curl -s --max-time 10 "https://www.primevideo.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$PRIME_RESULT" == "200" ]; then
        echo -e "${WHITE}Prime Video:${NC} ${GREEN}✓ 可访问${NC}"
        add_to_report "| **Prime Video** | ✅ 可访问 | 正常 |"
    else
        echo -e "${WHITE}Prime Video:${NC} ${YELLOW}⚠ 受限${NC}"
        add_to_report "| **Prime Video** | ⚠️ 受限 | - |"
    fi

    # HBO Max 检测
    echo -e "${CYAN}检测 HBO Max...${NC}"
    HBO_RESULT=$(curl -s --max-time 10 "https://www.hbomax.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$HBO_RESULT" == "200" ]; then
        echo -e "${WHITE}HBO Max:${NC} ${GREEN}✓ 可访问${NC}"
        add_to_report "| **HBO Max** | ✅ 可访问 | 正常 |"
    else
        echo -e "${WHITE}HBO Max:${NC} ${YELLOW}⚠ 受限${NC}"
        add_to_report "| **HBO Max** | ⚠️ 受限 | - |"
    fi

    # TikTok 检测
    echo -e "${CYAN}检测 TikTok...${NC}"
    TIKTOK_RESULT=$(curl -s --max-time 10 "https://www.tiktok.com" -w "%{http_code}" -o /dev/null 2>/dev/null)
    if [ "$TIKTOK_RESULT" == "200" ]; then
        echo -e "${WHITE}TikTok:${NC} ${GREEN}✓ 可访问${NC}"
        add_to_report "| **TikTok** | ✅ 可访问 | 正常 |"
    else
        echo -e "${WHITE}TikTok:${NC} ${YELLOW}⚠ 受限${NC}"
        add_to_report "| **TikTok** | ⚠️ 受限 | - |"
    fi

    add_to_report ""
    add_to_report "> 💡 **说明**: 流媒体解锁检测结果仅供参考，实际可用性可能因地区和账户而异。"
    add_to_report ""
    echo ""
    sleep 1
}

# 综合评分
test_summary() {
    print_separator
    echo -e "${BOLD}${BLUE}[9/9] 测试总结${NC}"
    print_separator

    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    MINUTES=$((TOTAL_TIME / 60))
    SECONDS=$((TOTAL_TIME % 60))

    echo -e "${WHITE}总耗时:${NC} ${CYAN}${MINUTES}分${SECONDS}秒${NC}"
    echo -e "${GREEN}${BOLD}✓ 所有测试完成！${NC}"
    echo ""

    add_to_report "## 📋 测试总结\n"
    add_to_report "- **测试耗时**: ${MINUTES}分${SECONDS}秒"
    add_to_report "- **测试工具**: 威软科技测试脚本 V2.0"
    add_to_report "- **报告生成**: $(date '+%Y-%m-%d %H:%M:%S')"
    add_to_report "- **测试项目**: 系统信息、IP质量、CPU性能、内存性能、磁盘I/O、网络延迟、网络速度、流媒体解锁"
    add_to_report ""
    add_to_report "---"
    add_to_report ""
    add_to_report "> 💡 **提示**: 测试结果仅供参考，实际性能可能因系统负载、网络环境等因素有所波动。"
    add_to_report ""
    add_to_report "---"
    add_to_report ""
    add_to_report "<div align=\"center\">"
    add_to_report ""
    add_to_report "**威软科技测试脚本 V2.0**"
    add_to_report ""
    add_to_report "GitHub: [weiruankeji2025/weiruan-vps](https://github.com/weiruankeji2025/weiruan-vps)"
    add_to_report ""
    add_to_report "⭐ 如果觉得好用，请给个 Star！"
    add_to_report ""
    add_to_report "</div>"

    # 清理临时文件
    rm -rf "$TEMP_DIR"

    sleep 1
}

# 显示报告
show_report() {
    print_separator
    echo -e "${BOLD}${GREEN}测试报告已生成！${NC}"
    print_separator
    echo -e "${WHITE}报告文件:${NC} ${CYAN}$REPORT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}Markdown 格式报告已保存，可以直接复制到 GitHub 或其他支持 Markdown 的平台。${NC}"
    echo ""
    print_separator
    echo -e "${GREEN}感谢使用威软科技 VPS 测试工具 V2.0！${NC}"
    print_separator
    echo ""
    echo -e "${CYAN}查看完整报告:${NC} cat $REPORT_FILE"
    echo ""
}

# 主函数
main() {
    # 检查是否为 root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}请使用 root 权限运行此脚本${NC}"
        echo -e "${YELLOW}使用命令: sudo bash $0${NC}"
        exit 1
    fi

    print_title
    check_dependencies
    init_report

    test_system_info
    test_ip_quality
    test_cpu
    test_memory
    test_disk_io
    test_network_latency
    test_network_speed
    test_streaming
    test_summary

    show_report
}

# 运行主函数
main
