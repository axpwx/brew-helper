# Homebrew软件包升到macOS Tahoe (26.0)的兼容性检查工具

[English](#english) | [中文](#中文)

---

## 中文

### 📖 项目简介

这是一个用于检查已安装的Homebrew软件包是否支持升级到macOS Tahoe (26.0)的兼容性检查工具。该脚本能够自动检查您已安装的Homebrew软件包是否支持 ARM64架构的macOS Tahoe，帮助您在升级系统前了解软件兼容性状况。

### 📦 使用方法

```bash
curl -fsSL https://github.com/axpwx/brew-helper/raw/main/brew_tahoe_compat_check.sh | bash
```

### ⚠️ 注意事项

1. **网络连接**：脚本需要访问 Homebrew API，请确保网络连接正常
2. **权限要求**：脚本需要读取 Homebrew 安装信息的权限
3. **结果解释**：
   - ✅ **明确支持**：软件包明确声明支持 arm64_tahoe
   - ⚠️ **未明确支持**：未找到明确的架构声明，但不代表不兼容
   - ❌ **检查失败**：无法获取软件包信息或网络错误

---

## English

### 📖 Project Introduction

This is a compatibility checking tool for verifying whether your installed Homebrew packages support upgrading to macOS Tahoe (26.0). The script automatically checks if your installed Homebrew packages support ARM64 architecture on macOS Tahoe, helping you understand software compatibility before upgrading your system.

### 📦 Usage

```bash
curl -fsSL https://github.com/axpwx/brew-helper/raw/main/brew_tahoe_compat_check.sh | bash
```

### ⚠️ Important Notes

1. **Network Connection**: The script needs to access Homebrew API, please ensure your network connection is stable
2. **Permission Requirements**: The script needs permission to read Homebrew installation information
3. **Result Interpretation**:
   - ✅ **Explicitly Supported**: Package explicitly declares support for arm64_tahoe
   - ⚠️ **Not Explicitly Supported**: No explicit architecture declaration found, but this doesn't mean incompatible
   - ❌ **Check Failed**: Unable to retrieve package information or network error
