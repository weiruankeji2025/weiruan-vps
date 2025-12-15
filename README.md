# 🚀 VPS 综合测试工具

<div align="center">

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Linux-orange.svg)
![Shell](https://img.shields.io/badge/shell-bash-brightgreen.svg)

**威软科技出品 - 专业的VPS全方位性能测试工具**

一键测试您的VPS服务器性能，生成精美的专业测试报告

[功能特性](#-功能特性) •
[快速开始](#-快速开始) •
[测试项目](#-测试项目) •
[使用说明](#-使用说明) •
[更新日志](#-更新日志)

</div>

---

## ✨ 功能特性

### V2.0 重大更新 🎉

- 🌍 **全球网络测试** - 覆盖全球主要城市和中国大陆主要城市的延迟测试
- 🔍 **IP质量检测** - 检测IP类型（住宅/数据中心）、代理、黑名单等
- 🎬 **流媒体解锁** - 检测Netflix、Disney+、YouTube Premium等主流平台
- 📊 **三轮平均测试** - 磁盘I/O测试采用三轮测试取平均值，结果更准确
- 🚀 **上下行速度** - 使用speedtest-cli测试真实上传下载速度
- 💻 **CPU基准测试** - 使用Sysbench进行标准化CPU性能评分
- 📍 **地理位置集成** - 系统信息页面直接显示IP和地理位置
- 🎨 **精美报告** - 自动生成Markdown格式的专业测试报告

### 核心特性

- 🎯 **9大测试模块** - 系统、IP质量、CPU、内存、磁盘、网络延迟、网络速度、流媒体、总结
- 🌈 **色彩分明** - 绿色(优秀)、黄色(良好)、红色(一般)，一目了然
- ⚡ **速度适中** - 完整测试约3-5分钟，快速获得全面结果
- 📝 **Markdown报告** - 自动生成格式化报告，支持GitHub展示
- 🔒 **真实可靠** - 采用业界标准的测试方法，数据真实可信
- 🛠️ **开箱即用** - 自动安装所有依赖，无需手动配置

---

## 🚀 快速开始

### 一键测试命令 (推荐)

```bash
curl -fsSL https://raw.githubusercontent.com/weiruankeji2025/weiruan-vps/main/vps_test.sh | sudo bash
```

或者使用 wget：

```bash
wget -qO- https://raw.githubusercontent.com/weiruankeji2025/weiruan-vps/main/vps_test.sh | sudo bash
```

### 手动安装

```bash
# 克隆仓库
git clone https://github.com/weiruankeji2025/weiruan-vps.git
cd weiruan-vps

# 添加执行权限
chmod +x vps_test.sh

# 运行测试
sudo ./vps_test.sh
```

---

## 📋 测试项目

### 1. 📊 系统基础信息
- ✅ 操作系统版本
- ✅ 内核版本
- ✅ 系统架构
- ✅ CPU型号、核心数、频率
- ✅ 内存容量和使用情况
- ✅ 磁盘容量和使用情况
- ✅ 虚拟化类型检测
- ✅ 系统运行时间
- ✅ **公网IP地址** 🆕
- ✅ **地理位置（国家/地区/城市）** 🆕
- ✅ **ISP信息** 🆕
- ✅ **AS号** 🆕

### 2. 🔍 IP质量检测 🆕
- ✅ **移动网络检测**
- ✅ **代理/VPN检测**
- ✅ **数据中心IP识别**
- ✅ **DNS泄露检测**
- ✅ **IP黑名单检测**

### 3. 🔥 CPU性能测试
- ✅ **单核性能测试** - Sysbench标准化评分
- ✅ **多核性能测试** - 多线程并行计算能力
- ✅ 性能等级自动评估

### 4. 💾 内存性能测试
- ✅ 内存读写速度测试
- ✅ 实际写入性能评估
- ✅ 性能等级自动判定

### 5. 💿 磁盘I/O性能测试 (三轮平均) 🆕
- ✅ **写入速度测试** - 3轮测试取平均值
- ✅ **读取速度测试** - 3轮测试取平均值
- ✅ 自动识别SSD/HDD类型
- ✅ 显示每轮详细数据
- ✅ 性能等级评估

### 6. 🌍 全球网络延迟测试 🆕
#### 全球主要城市
- 🇺🇸 美国（洛杉矶、纽约）
- 🇬🇧 英国（伦敦）
- 🇩🇪 德国（法兰克福）
- 🇸🇬 新加坡
- 🇯🇵 日本（东京）
- 🇰🇷 韩国（首尔）
- 🇦🇺 澳大利亚（悉尼）
- 🇧🇷 巴西（圣保罗）
- 🇮🇳 印度（孟买）

#### 中国大陆主要城市
- 🇨🇳 北京
- 🇨🇳 上海
- 🇨🇳 广州
- 🇨🇳 深圳
- 🇨🇳 成都
- 🇨🇳 杭州
- 🇨🇳 香港

### 7. 🚀 网络速度测试 (上传/下载) 🆕
- ✅ **延迟测试**
- ✅ **下载速度测试** - 使用speedtest-cli
- ✅ **上传速度测试** - 真实上行带宽
- ✅ 自动选择最佳测速节点

### 8. 🎬 流媒体解锁检测 🆕
- ✅ **Netflix** - 全球最大流媒体平台
- ✅ **Disney+** - 迪士尼流媒体服务
- ✅ **YouTube Premium** - YouTube高级会员
- ✅ **Amazon Prime Video** - 亚马逊视频
- ✅ **HBO Max** - HBO流媒体服务
- ✅ **TikTok** - 短视频平台

### 9. 📋 测试总结
- ✅ 测试总耗时统计
- ✅ 完整性能评估
- ✅ Markdown格式报告生成
- ✅ 自动清理临时文件

---

## 📖 使用说明

### 系统要求

- **操作系统**: Linux (支持 Ubuntu, Debian, CentOS, RHEL 等)
- **权限**: 需要 root 权限
- **网络**: 需要稳定的网络连接
- **磁盘空间**: 至少 2GB 可用空间用于测试

### 自动安装依赖

工具会自动检测并安装以下依赖：
- `curl` - 网络请求工具
- `wget` - 文件下载工具
- `bc` - 数学计算工具
- `jq` - JSON解析工具
- `python3` - Python运行环境
- `speedtest-cli` - 网络速度测试工具
- `sysbench` - CPU性能测试工具（可选）

### 运行步骤

1. **下载脚本**
   ```bash
   curl -O https://raw.githubusercontent.com/weiruankeji2025/weiruan-vps/main/vps_test.sh
   ```

2. **添加执行权限**
   ```bash
   chmod +x vps_test.sh
   ```

3. **运行测试**
   ```bash
   sudo ./vps_test.sh
   ```

4. **查看报告**
   - 测试完成后会在当前目录生成 `vps_test_report_YYYYMMDD_HHMMSS.md` 文件
   - 使用 `cat` 命令查看：
     ```bash
     cat vps_test_report_*.md
     ```

---

## 📄 示例报告

测试完成后会生成如下格式的Markdown报告：

```markdown
# VPS 综合测试报告

> **测试时间**: 2025-12-15 10:30:00
> **测试工具**: 威软科技测试脚本 V2.0

---

## 📊 系统基础信息

| 项目 | 信息 |
|------|------|
| **操作系统** | Ubuntu 22.04.3 LTS |
| **内核版本** | 5.15.0-89-generic |
| **系统架构** | x86_64 |
| **CPU型号** | Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz |
| **CPU核心** | 4 核 |
| **公网IPv4** | 203.0.113.1 |
| **地理位置** | United States / California / Los Angeles |
| **ISP** | Digital Ocean |

## 🔍 IP 质量检测

| 检测项目 | 结果 | 状态 |
|---------|------|------|
| **移动网络** | 否 | ✅ |
| **代理/VPN** | 未检测到 | ✅ |
| **数据中心IP** | 是 | ⚠️ |
| **黑名单状态** | 未检测到 | ✅ |

## 🔥 CPU 性能测试

| 测试项目 | 得分 | 说明 |
|---------|------|------|
| **单核性能** | 2456 | Sysbench Score |
| **多核性能** | 9824 | Sysbench Score |

## 💿 磁盘 I/O 性能测试

| 测试项目 | 第1轮 | 第2轮 | 第3轮 | 平均值 | 评分 |
|---------|------|------|------|--------|------|
| **磁盘写入** | 856.3 MB/s | 862.1 MB/s | 859.7 MB/s | **859.37 MB/s** | 优秀 (SSD) |
| **磁盘读取** | 1247.8 MB/s | 1253.2 MB/s | 1250.5 MB/s | **1250.50 MB/s** | 优秀 (SSD) |

## 🌍 全球网络延迟测试

### 全球主要城市

| 城市 | 延迟 | 状态 |
|------|------|------|
| 🇺🇸 洛杉矶 | 15.23 ms | 优秀 |
| 🇬🇧 伦敦 | 142.56 ms | 良好 |
| 🇸🇬 新加坡 | 175.89 ms | 一般 |

### 中国大陆主要城市

| 城市 | 延迟 | 状态 |
|------|------|------|
| 🇨🇳 北京 | 185.42 ms | 一般 |
| 🇨🇳 上海 | 178.91 ms | 一般 |
| 🇨🇳 香港 | 145.23 ms | 良好 |

## 🚀 网络速度测试

| 测试项目 | 速度 |
|---------|------|
| **延迟** | 15.23 ms |
| **下载速度** | 982.45 Mbit/s |
| **上传速度** | 956.78 Mbit/s |

## 🎬 流媒体解锁检测

| 平台 | 状态 | 区域 |
|------|------|------|
| **Netflix** | ✅ 已解锁 | 检测成功 |
| **Disney+** | ✅ 已解锁 | 检测成功 |
| **YouTube Premium** | ✅ 可访问 | 正常 |
...
```

---

## 🎨 界面展示

测试过程中的终端输出效果：

```
  ██╗   ██╗██████╗ ███╗   ███╗    ████████╗███████╗███╗   ██╗████████╗
  ██║   ██║██╔══██╗████╗ ████║    ╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝
  ██║   ██║██████╔╝██╔████╔██║       ██║   █████╗  ██╔██╗ ██║   ██║
  ╚██╗ ██╔╝██╔═══╝ ██║╚██╔╝██║       ██║   ██╔══╝  ██║╚██╗██║   ██║
   ╚████╔╝ ██║     ██║ ╚═╝ ██║       ██║   ███████╗██║ ╚████║   ██║
    ╚═══╝  ╚═╝     ╚═╝     ╚═╝       ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝

                    威软科技 VPS 综合测试工具 V2.0
                    https://github.com/weiruankeji2025
═══════════════════════════════════════════════════════════════

[✓] 依赖检查完成

═══════════════════════════════════════════════════════════════
[1/9] 系统信息检测
═══════════════════════════════════════════════════════════════
操作系统: Ubuntu 22.04.3 LTS
内核版本: 5.15.0-89-generic
CPU型号: Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz
公网IPv4: 203.0.113.1
地理位置: United States / California / Los Angeles
...

═══════════════════════════════════════════════════════════════
[2/9] IP 质量检测
═══════════════════════════════════════════════════════════════
移动网络: 否
代理/VPN: 未检测到
数据中心IP: 是
黑名单状态: 未检测到
...
```

---

## 🔧 高级选项

### 自定义测试

如果您想自定义测试项目，可以编辑脚本中的相应函数：

- `test_system_info()` - 系统信息和IP地理位置检测
- `test_ip_quality()` - IP质量检测
- `test_cpu()` - CPU性能测试
- `test_memory()` - 内存性能测试
- `test_disk_io()` - 磁盘I/O测试（三轮）
- `test_network_latency()` - 网络延迟测试
- `test_network_speed()` - 网络速度测试
- `test_streaming()` - 流媒体解锁检测

### 测试节点修改

可以在脚本中修改ping测试节点：

```bash
# 全球主要城市测试节点
declare -A GLOBAL_PING_TARGETS=(
    ["🇺🇸 洛杉矶"]="lax.us.cloudping.info"
    ["🇬🇧 伦敦"]="lon.uk.cloudping.info"
    # 添加更多节点...
)

# 中国大陆主要城市
declare -A CHINA_PING_TARGETS=(
    ["🇨🇳 北京"]="beijing.aliyun.com"
    ["🇨🇳 上海"]="shanghai.aliyun.com"
    # 添加更多节点...
)
```

---

## 🐛 故障排除

### 常见问题

**Q: 提示 "请使用 root 权限运行此脚本"**
```bash
# 使用 sudo 运行
sudo ./vps_test.sh
```

**Q: 网络测试失败**
- 检查服务器是否能正常访问互联网
- 某些VPS可能限制了ICMP协议，导致ping测试失败
- 部分流媒体网站可能被防火墙拦截

**Q: 依赖安装失败**
```bash
# 手动安装依赖
# Ubuntu/Debian:
apt-get update
apt-get install -y curl wget bc jq python3 python3-pip
pip3 install speedtest-cli

# CentOS/RHEL:
yum install -y curl wget bc jq python3 python3-pip
pip3 install speedtest-cli
```

**Q: 磁盘测试速度异常**
- 确保 /tmp 目录有足够的空间（至少2GB）
- 某些VPS可能限制了磁盘I/O性能
- 测试期间其他程序可能影响结果

**Q: speedtest-cli 安装失败**
```bash
# 使用备用方法安装
wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod +x speedtest-cli
mv speedtest-cli /usr/local/bin/
```

**Q: 流媒体检测不准确**
- 流媒体解锁检测结果仅供参考
- 实际可用性取决于具体的地区和账户
- 部分平台可能需要特定的DNS设置

---

## 📊 性能参考标准

### CPU 性能 (Sysbench)
- **单核性能**:
  - 优秀: > 2000 分
  - 良好: > 1000 分
  - 一般: < 1000 分
- **多核性能**:
  - 优秀: > 8000 分
  - 良好: > 4000 分
  - 一般: < 4000 分

### 内存性能
- **优秀**: > 1000 MB/s
- **良好**: > 500 MB/s
- **一般**: < 500 MB/s

### 磁盘 I/O
- **优秀 (SSD)**: > 500 MB/s
- **良好**: > 100 MB/s
- **一般 (HDD)**: < 100 MB/s

### 网络延迟
- **优秀**: < 50ms
- **良好**: < 150ms
- **一般**: > 150ms

### 网络速度
- **千兆**: > 900 Mbit/s
- **百兆**: > 90 Mbit/s
- **低速**: < 90 Mbit/s

---

## 📜 更新日志

### V2.0 (2025-12-15) - 重大更新 🎉
- 🆕 **新增IP质量检测模块** - 检测代理、黑名单、数据中心IP等
- 🆕 **新增流媒体解锁检测** - 支持Netflix、Disney+等主流平台
- 🆕 **全球网络延迟测试** - 覆盖全球10大城市和中国7大城市
- 🆕 **上下行速度测试** - 使用speedtest-cli进行真实速度测试
- 🆕 **磁盘三轮平均测试** - 磁盘I/O测试更加准确
- 🆕 **CPU基准测试** - 使用Sysbench进行标准化评分
- ✨ **IP地理位置集成** - 系统信息页面显示IP和位置
- ✨ **测试模块增至9个** - 更全面的性能评估
- 🐛 修复已知问题

### V1.0 (2025-12-15)
- 🎉 首次发布
- ✅ 完整的系统信息检测
- ✅ CPU、内存、磁盘性能测试
- ✅ 网络性能和延迟测试
- ✅ Markdown格式报告生成
- ✅ 彩色终端输出
- ✅ 自动依赖安装

---

## 🌟 特性对比

| 功能 | V1.0 | V2.0 |
|------|------|------|
| 测试模块数量 | 6个 | **9个** |
| 系统信息 | ✅ | ✅ 增强 |
| IP质量检测 | ❌ | ✅ 新增 |
| CPU测试 | 基础 | ✅ Sysbench |
| 内存测试 | ✅ | ✅ |
| 磁盘测试 | 单轮 | ✅ 三轮平均 |
| 网络延迟 | 4个节点 | ✅ 17个节点 |
| 网络速度 | 下载 | ✅ 上传+下载 |
| 流媒体解锁 | ❌ | ✅ 新增 |
| 地理位置 | 分离 | ✅ 集成 |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献指南

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

### 开发建议

- 保持代码简洁易读
- 添加必要的注释
- 测试所有修改
- 遵循现有的代码风格

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 📧 联系我们

- **GitHub**: [@weiruankeji2025](https://github.com/weiruankeji2025)
- **Repository**: [weiruan-vps](https://github.com/weiruankeji2025/weiruan-vps)
- **Issues**: [提交问题](https://github.com/weiruankeji2025/weiruan-vps/issues)

---

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

特别感谢以下开源项目：
- [speedtest-cli](https://github.com/sivel/speedtest-cli) - 网络速度测试
- [sysbench](https://github.com/akopytov/sysbench) - 性能基准测试
- [ip-api.com](https://ip-api.com/) - IP地理位置查询

---

## 📝 免责声明

- 本工具仅供学习和测试使用
- 测试结果仅供参考，实际性能可能因多种因素而异
- 流媒体解锁检测结果不代表实际使用体验
- 使用本工具造成的任何问题，开发者不承担责任

---

<div align="center">

**⭐ 如果这个项目对您有帮助，请给我们一个 Star！⭐**

**威软科技测试脚本 V2.0**

Made with ❤️ by 威软科技

[⬆ 回到顶部](#-vps-综合测试工具)

</div>
