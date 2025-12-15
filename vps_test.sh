#!/bin/bash

#===========================================
# VPS 综合测试工具
# 版本: 威软科技测试脚本 V1.0
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
    echo -e "${CYAN}${BOLD}                    威软科技 VPS 综合测试工具 V1.0${NC}"
    echo -e "${YELLOW}                    https://github.com/weiruankeji2025${NC}"
    print_separator
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}[*] 检查并安装必要的依赖...${NC}"

    local deps=("curl" "wget" "bc" "sysstat")
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
            apt-get install -y -qq "${missing_deps[@]}" &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y -q "${missing_deps[@]}" &> /dev/null
        elif command -v dnf &> /dev/null; then
            dnf install -y -q "${missing_deps[@]}" &> /dev/null
        else
            echo -e "${RED}[✗] 无法自动安装依赖，请手动安装: ${missing_deps[*]}${NC}"
            exit 1
        fi
    fi

    echo -e "${GREEN}[✓] 依赖检查完成${NC}\n"
}

# 初始化 Markdown 报告
init_report() {
    cat > "$REPORT_FILE" << EOF
# VPS 综合测试报告

> **测试时间**: $(date '+%Y-%m-%d %H:%M:%S')
> **测试工具**: 威软科技测试脚本 V1.0

---

EOF
}

# 添加到报告
add_to_report() {
    echo -e "$1" >> "$REPORT_FILE"
}

# 系统信息检测
test_system_info() {
    print_separator
    echo -e "${BOLD}${BLUE}[1/6] 系统信息检测${NC}"
    print_separator

    add_to_report "## 📊 系统信息\n"

    # 操作系统
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)
    else
        OS_NAME=$(uname -s)
    fi
    echo -e "${WHITE}操作系统:${NC} ${GREEN}$OS_NAME${NC}"
    add_to_report "| 项目 | 信息 |"
    add_to_report "|------|------|"
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

    add_to_report ""
    echo ""
    sleep 1
}

# CPU 性能测试
test_cpu() {
    print_separator
    echo -e "${BOLD}${BLUE}[2/6] CPU 性能测试${NC}"
    print_separator

    add_to_report "## 🔥 CPU 性能测试\n"

    echo -e "${YELLOW}[*] 单核性能测试 (计算圆周率)...${NC}"
    SINGLE_START=$(date +%s%N)
    echo "scale=5000; 4*a(1)" | bc -l &> /dev/null
    SINGLE_END=$(date +%s%N)
    SINGLE_TIME=$(echo "scale=3; ($SINGLE_END - $SINGLE_START) / 1000000000" | bc)

    if (( $(echo "$SINGLE_TIME < 10" | bc -l) )); then
        SINGLE_SCORE="优秀"
        SINGLE_COLOR="${GREEN}"
    elif (( $(echo "$SINGLE_TIME < 20" | bc -l) )); then
        SINGLE_SCORE="良好"
        SINGLE_COLOR="${YELLOW}"
    else
        SINGLE_SCORE="一般"
        SINGLE_COLOR="${RED}"
    fi

    echo -e "${WHITE}单核耗时:${NC} ${SINGLE_COLOR}${SINGLE_TIME}s ($SINGLE_SCORE)${NC}"
    add_to_report "| 测试项目 | 结果 | 评分 |"
    add_to_report "|---------|------|------|"
    add_to_report "| **单核性能** | ${SINGLE_TIME}s | $SINGLE_SCORE |"

    echo -e "${YELLOW}[*] 多核性能测试 (并行压缩)...${NC}"
    dd if=/dev/zero bs=1M count=100 2>/dev/null | gzip > /dev/null 2>&1 &
    MULTI_START=$(date +%s%N)
    for i in $(seq 1 $CPU_CORES); do
        dd if=/dev/zero bs=1M count=50 2>/dev/null | gzip > /dev/null 2>&1 &
    done
    wait
    MULTI_END=$(date +%s%N)
    MULTI_TIME=$(echo "scale=3; ($MULTI_END - $MULTI_START) / 1000000000" | bc)

    if (( $(echo "$MULTI_TIME < 5" | bc -l) )); then
        MULTI_SCORE="优秀"
        MULTI_COLOR="${GREEN}"
    elif (( $(echo "$MULTI_TIME < 10" | bc -l) )); then
        MULTI_SCORE="良好"
        MULTI_COLOR="${YELLOW}"
    else
        MULTI_SCORE="一般"
        MULTI_COLOR="${RED}"
    fi

    echo -e "${WHITE}多核耗时:${NC} ${MULTI_COLOR}${MULTI_TIME}s ($MULTI_SCORE)${NC}"
    add_to_report "| **多核性能** | ${MULTI_TIME}s | $MULTI_SCORE |"

    add_to_report ""
    echo ""
    sleep 1
}

# 内存性能测试
test_memory() {
    print_separator
    echo -e "${BOLD}${BLUE}[3/6] 内存性能测试${NC}"
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

# 磁盘 I/O 测试
test_disk_io() {
    print_separator
    echo -e "${BOLD}${BLUE}[4/6] 磁盘 I/O 性能测试${NC}"
    print_separator

    add_to_report "## 💿 磁盘 I/O 性能测试\n"

    echo -e "${YELLOW}[*] 磁盘写入速度测试...${NC}"
    WRITE_SPEED=$(dd if=/dev/zero of=/tmp/test_write bs=1M count=1024 conv=fdatasync 2>&1 | grep -oP '\d+\.?\d* MB/s' | awk '{print $1}')

    if [ -z "$WRITE_SPEED" ]; then
        WRITE_SPEED=$(dd if=/dev/zero of=/tmp/test_write bs=1M count=1024 conv=fdatasync 2>&1 | tail -1 | awk '{print $(NF-1)}')
    fi

    if (( $(echo "$WRITE_SPEED > 500" | bc -l) )); then
        WRITE_SCORE="优秀 (SSD)"
        WRITE_COLOR="${GREEN}"
    elif (( $(echo "$WRITE_SPEED > 100" | bc -l) )); then
        WRITE_SCORE="良好"
        WRITE_COLOR="${YELLOW}"
    else
        WRITE_SCORE="一般 (HDD)"
        WRITE_COLOR="${RED}"
    fi

    echo -e "${WHITE}写入速度:${NC} ${WRITE_COLOR}${WRITE_SPEED} MB/s ($WRITE_SCORE)${NC}"

    echo -e "${YELLOW}[*] 磁盘读取速度测试...${NC}"
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    READ_SPEED=$(dd if=/tmp/test_write of=/dev/null bs=1M count=1024 2>&1 | grep -oP '\d+\.?\d* MB/s' | awk '{print $1}')

    if [ -z "$READ_SPEED" ]; then
        READ_SPEED=$(dd if=/tmp/test_write of=/dev/null bs=1M count=1024 2>&1 | tail -1 | awk '{print $(NF-1)}')
    fi

    rm -f /tmp/test_write

    if (( $(echo "$READ_SPEED > 500" | bc -l) )); then
        READ_SCORE="优秀 (SSD)"
        READ_COLOR="${GREEN}"
    elif (( $(echo "$READ_SPEED > 100" | bc -l) )); then
        READ_SCORE="良好"
        READ_COLOR="${YELLOW}"
    else
        READ_SCORE="一般 (HDD)"
        READ_COLOR="${RED}"
    fi

    echo -e "${WHITE}读取速度:${NC} ${READ_COLOR}${READ_SPEED} MB/s ($READ_SCORE)${NC}"

    add_to_report "| 测试项目 | 结果 | 评分 |"
    add_to_report "|---------|------|------|"
    add_to_report "| **磁盘写入速度** | ${WRITE_SPEED} MB/s | $WRITE_SCORE |"
    add_to_report "| **磁盘读取速度** | ${READ_SPEED} MB/s | $READ_SCORE |"

    add_to_report ""
    echo ""
    sleep 1
}

# 网络性能测试
test_network() {
    print_separator
    echo -e "${BOLD}${BLUE}[5/6] 网络性能测试${NC}"
    print_separator

    add_to_report "## 🌐 网络性能测试\n"

    # 获取IP地址
    echo -e "${YELLOW}[*] 获取网络信息...${NC}"
    PUBLIC_IP=$(curl -s -4 ifconfig.me 2>/dev/null || curl -s -4 icanhazip.com 2>/dev/null || echo "无法获取")
    echo -e "${WHITE}公网IP:${NC} ${GREEN}$PUBLIC_IP${NC}"
    add_to_report "| 测试项目 | 结果 |"
    add_to_report "|---------|------|"
    add_to_report "| **公网IP** | $PUBLIC_IP |"

    # IP地理位置
    if [ "$PUBLIC_IP" != "无法获取" ]; then
        IP_INFO=$(curl -s "http://ipinfo.io/$PUBLIC_IP/json" 2>/dev/null)
        if [ -n "$IP_INFO" ]; then
            CITY=$(echo "$IP_INFO" | grep -oP '"city":\s*"\K[^"]+' || echo "未知")
            REGION=$(echo "$IP_INFO" | grep -oP '"region":\s*"\K[^"]+' || echo "未知")
            COUNTRY=$(echo "$IP_INFO" | grep -oP '"country":\s*"\K[^"]+' || echo "未知")
            ORG=$(echo "$IP_INFO" | grep -oP '"org":\s*"\K[^"]+' || echo "未知")
            echo -e "${WHITE}位置:${NC} ${CYAN}$COUNTRY / $REGION / $CITY${NC}"
            echo -e "${WHITE}运营商:${NC} ${CYAN}$ORG${NC}"
            add_to_report "| **地理位置** | $COUNTRY / $REGION / $CITY |"
            add_to_report "| **运营商** | $ORG |"
        fi
    fi

    # 网络延迟测试
    echo -e "${YELLOW}[*] 网络延迟测试...${NC}"
    add_to_report ""
    add_to_report "### 网络延迟测试\n"
    add_to_report "| 目标 | 延迟 | 状态 |"
    add_to_report "|------|------|------|"

    declare -A PING_TARGETS=(
        ["百度"]="baidu.com"
        ["腾讯云"]="cloud.tencent.com"
        ["阿里云"]="aliyun.com"
        ["Google"]="google.com"
    )

    for name in "${!PING_TARGETS[@]}"; do
        target="${PING_TARGETS[$name]}"
        PING_RESULT=$(ping -c 4 -W 2 "$target" 2>/dev/null | grep 'avg' | awk -F '/' '{print $5}')

        if [ -n "$PING_RESULT" ]; then
            PING_MS="${PING_RESULT} ms"
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
        else
            PING_MS="超时"
            PING_STATUS="无法连接"
            PING_COLOR="${RED}"
        fi

        echo -e "${WHITE}${name}:${NC} ${PING_COLOR}${PING_MS} ($PING_STATUS)${NC}"
        add_to_report "| $name | $PING_MS | $PING_STATUS |"
    done

    # 下载速度测试
    echo -e "${YELLOW}[*] 下载速度测试...${NC}"
    add_to_report ""
    add_to_report "### 下载速度测试\n"
    add_to_report "| 测试节点 | 速度 | 评分 |"
    add_to_report "|---------|------|------|"

    # 测试文件下载速度
    TEST_URL="http://cachefly.cachefly.net/10mb.test"
    DOWNLOAD_SPEED=$(curl -o /dev/null -s -w '%{speed_download}' --connect-timeout 5 --max-time 10 "$TEST_URL" 2>/dev/null)

    if [ -n "$DOWNLOAD_SPEED" ] && [ "$DOWNLOAD_SPEED" != "0.000" ]; then
        DOWNLOAD_SPEED_MB=$(echo "scale=2; $DOWNLOAD_SPEED / 1048576" | bc)

        if (( $(echo "$DOWNLOAD_SPEED_MB > 10" | bc -l) )); then
            DOWNLOAD_SCORE="优秀"
            DOWNLOAD_COLOR="${GREEN}"
        elif (( $(echo "$DOWNLOAD_SPEED_MB > 5" | bc -l) )); then
            DOWNLOAD_SCORE="良好"
            DOWNLOAD_COLOR="${YELLOW}"
        else
            DOWNLOAD_SCORE="一般"
            DOWNLOAD_COLOR="${RED}"
        fi

        echo -e "${WHITE}国际节点:${NC} ${DOWNLOAD_COLOR}${DOWNLOAD_SPEED_MB} MB/s ($DOWNLOAD_SCORE)${NC}"
        add_to_report "| 国际节点 | ${DOWNLOAD_SPEED_MB} MB/s | $DOWNLOAD_SCORE |"
    else
        echo -e "${WHITE}国际节点:${NC} ${RED}测试失败${NC}"
        add_to_report "| 国际节点 | 测试失败 | - |"
    fi

    add_to_report ""
    echo ""
    sleep 1
}

# 综合评分
test_summary() {
    print_separator
    echo -e "${BOLD}${BLUE}[6/6] 测试总结${NC}"
    print_separator

    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))

    echo -e "${WHITE}总耗时:${NC} ${CYAN}${TOTAL_TIME}秒${NC}"
    echo -e "${GREEN}${BOLD}测试完成！${NC}"
    echo ""

    add_to_report "## 📋 测试总结\n"
    add_to_report "- **测试耗时**: ${TOTAL_TIME}秒"
    add_to_report "- **测试工具**: 威软科技测试脚本 V1.0"
    add_to_report "- **报告生成**: $(date '+%Y-%m-%d %H:%M:%S')"
    add_to_report ""
    add_to_report "---"
    add_to_report ""
    add_to_report "> 💡 **提示**: 测试结果仅供参考，实际性能可能因系统负载、网络环境等因素有所波动。"
    add_to_report ""
    add_to_report "---"
    add_to_report ""
    add_to_report "<div align=\"center\">"
    add_to_report ""
    add_to_report "**威软科技测试脚本 V1.0**"
    add_to_report ""
    add_to_report "GitHub: [weiruankeji2025](https://github.com/weiruankeji2025)"
    add_to_report ""
    add_to_report "</div>"

    sleep 1
}

# 显示报告
show_report() {
    print_separator
    echo -e "${BOLD}${GREEN}测试报告已生成！${NC}"
    print_separator
    echo -e "${WHITE}报告文件:${NC} ${CYAN}$REPORT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}Markdown 格式报告预览:${NC}"
    print_separator
    echo ""
    cat "$REPORT_FILE"
    echo ""
    print_separator
    echo -e "${GREEN}感谢使用威软科技 VPS 测试工具！${NC}"
    print_separator
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
    test_cpu
    test_memory
    test_disk_io
    test_network
    test_summary

    show_report
}

# 运行主函数
main
