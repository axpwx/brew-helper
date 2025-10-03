#!/bin/bash

# macOS Tahoe (26.0) 兼容性检查脚本
# 检查已安装的 Homebrew 软件包是否支持 macOS Tahoe

set -euo pipefail

CURL_CMD="curl"
[[ -n "${HOMEBREW_API_DOMAIN:-}" ]] && unset HOMEBREW_API_DOMAIN

# 语言检测和设置
detect_language() {
    local detected_lang="en_US"  # 默认英文

    # 优先级1: 检查 macOS 系统界面语言偏好设置
    local macos_lang=""
    if command -v defaults >/dev/null 2>&1; then
        # 获取系统首选语言列表的第一项
        macos_lang=$(defaults read -g AppleLanguages 2>/dev/null | grep -o '"[^"]*"' | head -1 | tr -d '"' 2>/dev/null || echo "")

        # 如果第一种方法失败，尝试获取系统语言设置
        if [[ -z "$macos_lang" ]]; then
            macos_lang=$(defaults read -g AppleLocale 2>/dev/null || echo "")
        fi

        # 检查是否为中文
        if [[ "$macos_lang" =~ zh-Hans|zh_CN|zh-Hant|zh_CN|zh_TW|zh_HK|Chinese ]]; then
            detected_lang="zh_CN"
        fi
    fi

    # 优先级2: 如果 macOS 检测失败，检查终端应用的语言设置
    if [[ "$detected_lang" == "en_US" ]] && command -v osascript >/dev/null 2>&1; then
        local terminal_lang=""
        # 尝试获取当前终端应用的语言设置
        terminal_lang=$(osascript -e 'tell application "System Events" to get localized string "OK"' 2>/dev/null || echo "")

        # 检查返回的本地化字符串是否为中文
        if [[ "$terminal_lang" =~ 好|确定|是 ]]; then
            detected_lang="zh_CN"
        fi
    fi

    # 优先级3: 检查用户目录下的语言偏好文件
    if [[ "$detected_lang" == "en_US" ]] && [[ -f "$HOME/.CFUserTextEncoding" ]]; then
        local encoding_info=""
        encoding_info=$(cat "$HOME/.CFUserTextEncoding" 2>/dev/null | head -1 || echo "")

        # 检查编码信息中是否包含中文相关标识
        if [[ "$encoding_info" =~ 0x804|0x404|Chinese ]]; then
            detected_lang="zh_CN"
        fi
    fi

    # 优先级4: 作为备选，检查环境变量（但优先级较低）
    if [[ "$detected_lang" == "en_US" ]]; then
        local lang_env="${LANG:-${LC_ALL:-${LC_MESSAGES:-}}}"
        if [[ "$lang_env" =~ zh_CN|zh_Hans|zh-CN|zh-Hans ]] || \
           [[ "${LC_CTYPE:-}" =~ zh_CN|zh_Hans|zh-CN|zh-Hans ]]; then
            detected_lang="zh_CN"
        fi
    fi

    echo "$detected_lang"
}

# 设置语言
SCRIPT_LANG=$(detect_language)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 多语言文本定义
if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
    # 中文文本
    MSG_TITLE="🍺 macOS Tahoe (26.0) 兼容性检查"
    MSG_SEPARATOR="=================================================="
    MSG_DEPS_PASS="所有依赖工具检查通过"
    MSG_DEPS_MISSING="缺少必要的依赖工具："
    MSG_NOT_INSTALLED="未安装"
    MSG_INSTALL_CMD="安装命令"
    MSG_MANUAL_INSTALL="请手动安装上述缺失的工具后重新运行此脚本"
    MSG_NO_AUTO_INSTALL="注意：本脚本不会自动安装任何软件，请您手动执行上述安装命令"
    MSG_HOMEBREW_INSTALL="请访问 https://brew.sh 安装 Homebrew"
    MSG_HOMEBREW_NOT_FOUND="未检测到 Homebrew"
    MSG_HOMEBREW_REQUIRED="此脚本用来检查Homebrew已安装的软件包兼容性"
    MSG_TRYING_SOURCE="尝试使用源"
    MSG_API_AVAILABLE="API 可用"
    MSG_API_UNAVAILABLE="API 不可用"
    MSG_CUSTOM_API="使用自定义 HOMEBREW_API_DOMAIN"
    MSG_CUSTOM_API_FAIL="自定义 API 域名不可用，尝试其他源"
    MSG_ALL_SOURCES_FAIL="所有镜像源都不可用，使用官方源作为最后尝试"
    MSG_CHECKING_PACKAGES="开始检查"
    MSG_PACKAGES_UNIT="个已安装软件包"
    MSG_EXPLICIT_SUPPORT="明确支持 macOS Tahoe"
    MSG_UNIVERSAL_ARCH="通用架构"
    MSG_UNCLEAR_SUPPORT="未明确支持"
    MSG_CHECK_FAILED="检查失败"
    MSG_SUMMARY="检查完成摘要"
    MSG_TOTAL_PACKAGES="总检查软件包"
    MSG_EXPLICIT_ARM64="明确支持 arm64_tahoe"
    MSG_CURRENT_API="当前使用的 API 源"
    MSG_NOTES="注意事项"
    MSG_NOTE1="此检查基于 Homebrew 公式的架构声明"
    MSG_NOTE2="'未明确支持' 不意味着完全不兼容，可能只是尚未测试或声明"
    MSG_THIRD_PARTY_TAPS="第三方 Tap"
    MSG_CORE_PACKAGES="核心软件包"
    MSG_TAP_PACKAGES="Tap 软件包"
    MSG_CHECKING_THIRD_PARTY_TAPS="检查第三方 Tap"
    MSG_TAP_FORMULA_CHECK="从本地 Formula 检查"
    MSG_NO_TAP_PACKAGES="未发现第三方 Tap 软件包"
else
    # 英文文本
    MSG_TITLE="🍺 macOS Tahoe (26.0) Compatibility Check"
    MSG_SEPARATOR="=================================================="
    MSG_DEPS_PASS="All dependency tools check passed"
    MSG_DEPS_MISSING="Missing required dependency tools:"
    MSG_NOT_INSTALLED="not installed"
    MSG_INSTALL_CMD="Install command"
    MSG_MANUAL_INSTALL="Please manually install the missing tools above and re-run this script"
    MSG_NO_AUTO_INSTALL="Note: This script will not automatically install any software, please execute the installation commands manually"
    MSG_HOMEBREW_INSTALL="Please visit https://brew.sh to install Homebrew"
    MSG_HOMEBREW_NOT_FOUND="Homebrew not detected"
    MSG_HOMEBREW_REQUIRED="This script is used to check Homebrew installed package compatibility"
    MSG_TRYING_SOURCE="Trying source"
    MSG_API_AVAILABLE="API available"
    MSG_API_UNAVAILABLE="API unavailable"
    MSG_CUSTOM_API="Using custom HOMEBREW_API_DOMAIN"
    MSG_CUSTOM_API_FAIL="Custom API domain unavailable, trying other sources"
    MSG_ALL_SOURCES_FAIL="All mirror sources unavailable, using official source as last attempt"
    MSG_CHECKING_PACKAGES="Starting to check"
    MSG_PACKAGES_UNIT="installed packages"
    MSG_EXPLICIT_SUPPORT="Explicitly supports macOS Tahoe"
    MSG_UNIVERSAL_ARCH="Universal Architecture"
    MSG_UNCLEAR_SUPPORT="Unclear support"
    MSG_CHECK_FAILED="Check failed"
    MSG_SUMMARY="Check completion summary"
    MSG_TOTAL_PACKAGES="Total packages checked"
    MSG_EXPLICIT_ARM64="Explicitly supports arm64_tahoe"
    MSG_CURRENT_API="Currently using API source"
    MSG_NOTES="Notes"
    MSG_NOTE1="This check is based on Homebrew formula architecture declarations"
    MSG_NOTE2="'Unclear support' does not mean complete incompatibility, may just be untested or undeclared"
    MSG_THIRD_PARTY_TAPS="Third-party Taps"
    MSG_CORE_PACKAGES="Core packages"
    MSG_TAP_PACKAGES="Tap packages"
    MSG_CHECKING_THIRD_PARTY_TAPS="Checking third-party Taps"
    MSG_TAP_FORMULA_CHECK="Checking from local Formula"
    MSG_NO_TAP_PACKAGES="No third-party Tap packages found"
fi

# 日志函数
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_debug() { echo -e "${CYAN}🐛 $1${NC}"; }

# 测试 API 可用性
test_api_availability() {
    local api_base=$1
    local test_url="${api_base}/formula/git.json"

    if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
        log_debug "测试 API 可用性: $test_url" >&2
    else
        log_debug "Testing API availability: $test_url" >&2
    fi

    # 使用 curl 测试连接，设置较短的超时时间，禁用代理
    if "$CURL_CMD" --proxy "" -s --connect-timeout 5 --max-time 10 "$test_url" > /dev/null 2>&1; then
        log_success "$MSG_API_AVAILABLE: $api_base" >&2
        return 0
    else
        log_warning "$MSG_API_UNAVAILABLE: $api_base" >&2
        return 1
    fi
}

# 确定 API 基础地址
determine_api_base() {
    # 优先使用用户自定义的 API 域名
    if [[ -n "${HOMEBREW_API_DOMAIN:-}" ]]; then
        if test_api_availability "$HOMEBREW_API_DOMAIN"; then
            echo "$HOMEBREW_API_DOMAIN"
            log_info "使用自定义 HOMEBREW_API_DOMAIN: $HOMEBREW_API_DOMAIN" >&2
            return 0
        else
            log_warning "自定义 API 域名不可用，尝试其他源" >&2
        fi
    fi

    # 定义多个镜像源，按优先级排序（国内镜像优先，官方源最后）
    local api_sources=(
        "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
        "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
        "https://mirrors.aliyun.com/homebrew/homebrew-bottles/api"
    )

    # 逐个测试镜像源
    for api_base in "${api_sources[@]}"; do
        log_info "$MSG_TRYING_SOURCE: $api_base" >&2
        if test_api_availability "$api_base"; then
            echo "$api_base"
            return 0
        fi
    done

    # 如果所有源都不可用，返回官方源作为最后尝试
    if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
        log_error "所有镜像源都不可用，使用官方源作为最后尝试" >&2
    else
        log_error "All mirror sources unavailable, using official source as last attempt" >&2
    fi
    echo "https://formulae.brew.sh/api"
}

# 检查 Ruby 源码中的 bottle 信息
check_ruby_source_bottles() {
    local package="$1"
    local ruby_source_url="https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/${package:0:1}/${package}.rb"

    [[ -n "${DEBUG:-}" ]] && log_debug "检查 Ruby 源码: $ruby_source_url"
    local ruby_content
    ruby_content=$("$CURL_CMD" --proxy "" -s --max-time 10 --connect-timeout 5 "$ruby_source_url" 2>/dev/null)

    if [[ $? -eq 0 && -n "$ruby_content" ]]; then
        if echo "$ruby_content" | grep -q "arm64_tahoe:"; then
            return 0
        fi
    fi
    return 1
}

# 检查软件包是否支持 arm64_tahoe
check_package_arch_support() {
    local package=$1
    local api_base=$2
    local api_url="${api_base}/formula/${package}.json"

    # 使用 curl 获取 JSON 数据，增加容错参数，绕过代理
    local json_response
    local curl_output
    [[ -n "${DEBUG:-}" ]] && log_debug "使用的 curl: $CURL_CMD"
    [[ -n "${DEBUG:-}" ]] && log_debug "API URL: $api_url"
    [[ -n "${DEBUG:-}" ]] && log_debug "执行 curl 命令..."
    curl_output=$("$CURL_CMD" --proxy "" -g -s --connect-timeout 10 --max-time 30 -w "HTTPCODE:%{http_code}" "$api_url" 2>&1)
    local curl_exit_code=$?
    [[ -n "${DEBUG:-}" ]] && log_debug "curl 退出码: $curl_exit_code"
    [[ -n "${DEBUG:-}" ]] && log_debug "curl 输出前100字符: ${curl_output:0:100}..."

    # 分离响应内容和HTTP状态码
    local http_code=$(echo "$curl_output" | grep -o "HTTPCODE:[0-9]*" | cut -d: -f2)
    json_response=$(echo "$curl_output" | sed 's/HTTPCODE:[0-9]*$//')

    if [[ $curl_exit_code -ne 0 ]]; then
        case $curl_exit_code in
            6) log_warning "$package - 无法解析主机名" ;;
            7) log_warning "$package - 无法连接到服务器" ;;
            22) log_warning "$package - HTTP 错误 (状态码: ${http_code:-未知})" ;;
            28) log_warning "$package - 请求超时" ;;
            *) log_warning "$package - 网络错误 (curl 错误: $curl_exit_code)" ;;
        esac
        # API 失败时，尝试检查 Ruby 源码
        if check_ruby_source_bottles "$package"; then
            log_success "$package - ✅ 明确支持 macOS Tahoe (从源码确认)"
            return 0
        fi
        return 2
    fi

    # 检查HTTP状态码
    if [[ -n "$http_code" && "$http_code" != "200" ]]; then
        if [[ "$http_code" == "404" ]]; then
            log_warning "$package - 软件包不存在或API路径错误"
        else
            log_warning "$package - HTTP错误 (状态码: $http_code)"
        fi
        # API 失败时，尝试检查 Ruby 源码
        if check_ruby_source_bottles "$package"; then
            if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
                log_success "$package - ✅ 明确支持 macOS Tahoe (从源码确认)"
            else
                log_success "$package - ✅ Explicitly supports macOS Tahoe (confirmed from source)"
            fi
            return 0
        fi
        return 2
    fi

    # 检查获取到的内容是否为空
    if [[ -z "$json_response" ]]; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$package - API 返回空响应"
        else
            log_warning "$package - API returned empty response"
        fi
        # API 失败时，尝试检查 Ruby 源码
        if check_ruby_source_bottles "$package"; then
            if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
                log_success "$package - ✅ 明确支持 macOS Tahoe (从源码确认)"
            else
                log_success "$package - ✅ Explicitly supports macOS Tahoe (confirmed from source)"
            fi
            return 0
        fi
        return 2
    fi

    # 验证响应是否为有效的JSON
    if ! echo "$json_response" | jq . > /dev/null 2>&1; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$package - API 返回无效的JSON格式"
        else
            log_warning "$package - API returned invalid JSON format"
        fi
        # API 失败时，尝试检查 Ruby 源码
        if check_ruby_source_bottles "$package"; then
            if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
                log_success "$package - ✅ 明确支持 macOS Tahoe (从源码确认)"
            else
                log_success "$package - ✅ Explicitly supports macOS Tahoe (confirmed from source)"
            fi
            return 0
        fi
        return 2
    fi

    # 解析 JSON 响应，检查架构支持
    local tahoe_support
    local bottle_architectures

    # 检查是否有 Tahoe 变体支持
     tahoe_support=$(echo "$json_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'variations' in data and 'tahoe' in data['variations']:
        print('yes')
    else:
        print('no')
except:
    print('no')
" 2>/dev/null)

     # 检查 bottle 文件中的架构
     bottle_architectures=$(echo "$json_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'bottle' in data and isinstance(data['bottle'], dict) and 'stable' in data['bottle'] and 'files' in data['bottle']['stable']:
        files = data['bottle']['stable']['files']
        print(' '.join(files.keys()))
    else:
        print('')
except:
    print('')
" 2>/dev/null)



    # 检查 Tahoe 兼容性
    if [[ "$tahoe_support" != "no" && "$tahoe_support" != "null" ]]; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_success "$package - ✅ 明确支持 macOS Tahoe"
        else
            log_success "$package - ✅ Explicitly supports macOS Tahoe"
        fi
        return 0
    elif echo "$bottle_architectures" | grep -q "arm64_tahoe"; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_success "$package - ✅ 明确支持 macOS Tahoe (arm64_tahoe)"
        else
            log_success "$package - ✅ Explicitly supports macOS Tahoe (arm64_tahoe)"
        fi
        return 0
    elif echo "$bottle_architectures" | grep -q "all"; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_success "$package - ✅ 明确支持 macOS Tahoe (通用架构)"
        else
            log_success "$package - ✅ Explicitly supports macOS Tahoe (universal architecture)"
        fi
        return 0
    elif echo "$bottle_architectures" | grep -q "arm64"; then
        local arm64_archs
        arm64_archs=$(echo "$bottle_architectures" | grep "arm64" || true)
        local arch_list=$(echo "$arm64_archs" | tr '\n' ', ' | sed 's/,$//')
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_info "$package - ⚠️  支持 ARM64 架构: $arch_list (可能兼容 Tahoe)"
        else
            log_info "$package - ⚠️  Supports ARM64 architectures: $arch_list (may be compatible with Tahoe)"
        fi
        return 0
    elif echo "$bottle_architectures" | grep -q "x86_64"; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$package - ❌ 仅支持 x86_64，需要 Rosetta 2"
        else
            log_warning "$package - ❌ Only supports x86_64, requires Rosetta 2"
        fi
        return 1
    else
        # API 数据不完整时，检查 Ruby 源码
        if check_ruby_source_bottles "$package"; then
            if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
                log_success "$package - ✅ 明确支持 macOS Tahoe (从源码确认)"
            else
                log_success "$package - ✅ Explicitly supports macOS Tahoe (confirmed from source)"
            fi
            return 0
        fi
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$package - ❓ 未找到明确的架构信息"
        else
            log_warning "$package - ❓ No clear architecture information found"
        fi
        return 1
    fi
}

# 检查第三方 tap 软件包的架构支持
check_tap_package_arch_support() {
    local full_package_name=$1  # 格式: tap_user/tap_repo/package_name
    local tap_user=$(echo "$full_package_name" | cut -d'/' -f1)
    local tap_repo=$(echo "$full_package_name" | cut -d'/' -f2)
    local package_name=$(echo "$full_package_name" | cut -d'/' -f3)

    # 构建本地 formula 文件路径
    local formula_path="/opt/homebrew/Library/Taps/${tap_user}/homebrew-${tap_repo}/Formula/${package_name}.rb"

    [[ -n "${DEBUG:-}" ]] && log_debug "$MSG_TAP_FORMULA_CHECK: $formula_path"

    # 检查 formula 文件是否存在
    if [[ ! -f "$formula_path" ]]; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$full_package_name - Formula 文件不存在: $formula_path"
        else
            log_warning "$full_package_name - Formula file not found: $formula_path"
        fi
        return 2
    fi

    # 从 formula 文件中提取 bottle 架构信息
    local bottle_content
    bottle_content=$(sed -n '/bottle do/,/end/p' "$formula_path" 2>/dev/null)

    if [[ -z "$bottle_content" ]]; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$full_package_name - 未找到 bottle 信息，可能需要从源码编译"
        else
            log_warning "$full_package_name - No bottle information found, may need to compile from source"
        fi
        return 1
    fi



    # 检查是否明确支持 arm64_tahoe
    if echo "$bottle_content" | grep -q "arm64_tahoe"; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_success "$full_package_name - ✅ 明确支持 macOS Tahoe (arm64_tahoe)"
        else
            log_success "$full_package_name - ✅ Explicitly supports macOS Tahoe (arm64_tahoe)"
        fi
        return 0
    elif echo "$bottle_content" | grep -q "all"; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_success "$full_package_name - ✅ 明确支持 macOS Tahoe (通用架构)"
        else
            log_success "$full_package_name - ✅ Explicitly supports macOS Tahoe (universal architecture)"
        fi
        return 0
    elif echo "$bottle_content" | grep -q "arm64"; then
        local arm64_archs
        arm64_archs=$(echo "$bottle_content" | grep -o "arm64_[a-z]*" | tr '\n' ', ' | sed 's/,$//')
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_info "$full_package_name - ⚠️  支持 ARM64 架构: $arm64_archs (可能兼容 Tahoe)"
        else
            log_info "$full_package_name - ⚠️  Supports ARM64 architectures: $arm64_archs (may be compatible with Tahoe)"
        fi
        return 0
    elif echo "$bottle_content" | grep -q "x86_64"; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$full_package_name - ❌ 仅支持 x86_64，需要 Rosetta 2"
        else
            log_warning "$full_package_name - ❌ Only supports x86_64, requires Rosetta 2"
        fi
        return 1
    else
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_warning "$full_package_name - ❓ 未找到明确的架构信息"
        else
            log_warning "$full_package_name - ❓ No clear architecture information found"
        fi
        return 1
    fi
}

# 检查依赖工具
check_dependencies() {
    # 首先检查 Homebrew 是否安装
    if ! command -v brew &> /dev/null; then
        log_error "$MSG_HOMEBREW_NOT_FOUND"
        echo ""
        echo "  ❌ $MSG_HOMEBREW_REQUIRED"
        echo ""
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            echo "  💡 如需安装 Homebrew，请访问: https://brew.sh"
        else
            echo "  💡 To install Homebrew, please visit: https://brew.sh"
        fi
        echo ""
        exit 1
    fi

    local missing_deps=()
    local install_commands=()

    # 检查 curl 命令
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
        install_commands+=("brew install curl")
    fi

    # 检查 jq 命令
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
        install_commands+=("brew install jq")
    fi

    # 检查 python3 命令
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
        install_commands+=("brew install python3")
    fi

    # 如果有缺失的依赖，显示安装提示
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "$MSG_DEPS_MISSING"
        echo ""
        for i in "${!missing_deps[@]}"; do
            echo "  ❌ ${missing_deps[$i]} - $MSG_NOT_INSTALLED"
            echo "     $MSG_INSTALL_CMD: ${install_commands[$i]}"
        done
        echo ""
        log_warning "$MSG_MANUAL_INSTALL"
        echo "$MSG_NO_AUTO_INSTALL"
        exit 1
    fi

    log_success "$MSG_DEPS_PASS"
}

# 主检查函数
main_check() {
    echo "$MSG_TITLE"
    echo "$MSG_SEPARATOR"

    # 检查依赖工具
    check_dependencies

    # 获取已安装的软件包列表（包含完整名称以区分 tap）
    local all_packages
    all_packages=$(brew list --formula --full-name 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$all_packages" ]; then
        if [[ "$SCRIPT_LANG" == "zh_CN" ]]; then
            log_error "无法获取已安装的 Homebrew 软件包列表"
        else
            log_error "Unable to get installed Homebrew package list"
        fi
        exit 1
    fi

    # 分离核心软件包和第三方 tap 软件包
    local core_packages=""
    local tap_packages=""

    while IFS= read -r package; do
        if [[ "$package" == *"/"* ]]; then
            # 包含 "/" 的是第三方 tap 软件包
            tap_packages="$tap_packages$package"$'\n'
        else
            # 不包含 "/" 的是核心软件包
            core_packages="$core_packages$package"$'\n'
        fi
    done <<< "$all_packages"

    # 移除末尾的空行
    core_packages=$(echo "$core_packages" | sed '/^$/d')
    tap_packages=$(echo "$tap_packages" | sed '/^$/d')

    # 确定 API 地址
    local api_base
    api_base=$(determine_api_base)
    echo ""

    local total=0
    local supported=0
    local unsupported=0
    local failed=0

    # 计算软件包总数
    local core_count=0
    local tap_count=0
    if [ -n "$core_packages" ]; then
        core_count=$(echo "$core_packages" | wc -l | tr -d ' ')
    fi
    if [ -n "$tap_packages" ]; then
        tap_count=$(echo "$tap_packages" | wc -l | tr -d ' ')
    fi
    local total_count=$((core_count + tap_count))

    log_info "$MSG_CHECKING_PACKAGES $total_count $MSG_PACKAGES_UNIT..."
    echo ""

    # 检查核心软件包
    if [ $core_count -gt 0 ]; then
        log_info "$MSG_CORE_PACKAGES ($core_count):"
        while IFS= read -r package; do
            if [ -n "$package" ]; then
                ((total++))
                if check_package_arch_support "$package" "$api_base"; then
                    ((supported++))
                else
                    case $? in
                        1) ((unsupported++)) ;;
                        2) ((failed++)) ;;
                    esac
                fi
                # 添加短暂延迟避免请求过快
                sleep 0.2
            fi
        done <<< "$core_packages"
        echo ""
    fi

    # 检查第三方 tap 软件包
    if [ $tap_count -gt 0 ]; then
        log_info "$MSG_CHECKING_THIRD_PARTY_TAPS"
        log_info "$MSG_TAP_PACKAGES ($tap_count):"
        while IFS= read -r package; do
            if [ -n "$package" ]; then
                ((total++))
                if check_tap_package_arch_support "$package"; then
                    ((supported++))
                else
                    case $? in
                        1) ((unsupported++)) ;;
                        2) ((failed++)) ;;
                    esac
                fi
            fi
        done <<< "$tap_packages"
        echo ""
    else
        log_info "$MSG_NO_TAP_PACKAGES"
        echo ""
    fi

    # 生成报告
    echo "$MSG_SEPARATOR"
    log_info "$MSG_SUMMARY:"
    echo "  $MSG_TOTAL_PACKAGES: $total"
    echo "  ✅ $MSG_EXPLICIT_ARM64: $supported"
    echo "  ⚠️  $MSG_UNCLEAR_SUPPORT: $unsupported"
    if [ $failed -gt 0 ]; then
        echo "  ❌ $MSG_CHECK_FAILED: $failed"
    fi
    echo ""

    # 提供额外信息
    log_info "$MSG_CURRENT_API: $api_base"
    echo ""
    log_info "$MSG_NOTES:"
    echo "  • $MSG_NOTE1"
    echo "  • $MSG_NOTE2"
}

# 初始化语言设置
detect_language

# 运行主函数
main_check