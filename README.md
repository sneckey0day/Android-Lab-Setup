# 🔬 Android Lab Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Linux](https://img.shields.io/badge/OS-Linux-blue.svg)](https://www.linux.org/)
[![Android](https://img.shields.io/badge/Android-API%2034-green.svg)](https://developer.android.com/)
[![Magisk](https://img.shields.io/badge/Root-Magisk-red.svg)](https://github.com/topjohnwu/Magisk)

> **Automated Android SDK, AVD, and Root Environment Setup for Security Research and Testing**

A comprehensive bash script that automates the complete setup of an Android development and security testing environment on Linux systems. Perfect for malware analysis, security research, penetration testing, and Android development.

## 🌟 Features

- **🚀 One-Click Setup** - Fully automated installation with zero manual intervention
- **🎨 Beautiful CLI** - Colored output with progress indicators and clear status messages
- **🔧 Complete SDK Setup** - Downloads and configures Android SDK with all necessary components
- **📱 Ready-to-Use AVD** - Creates a pre-configured Android Virtual Device with Google Play Store
- **🔓 Pre-Rooted Environment** - Automatically applies Magisk root to the system image
- **🛡️ Error Handling** - Robust error detection and recovery mechanisms
- **🔄 Cross-Distro Support** - Works on Ubuntu, Debian, CentOS, RHEL, Arch, and other Linux distributions
- **📋 Dependency Checking** - Automatically verifies and guides installation of required packages

## 🎯 What Gets Installed

### Core Components
- **Android SDK Command Line Tools** (Latest version)
- **Platform Tools** (ADB, Fastboot, etc.)
- **Android API 34** (Android 14)
- **Build Tools 34.0.0**
- **System Images** (x86_64 with Google Play Store)
- **Android Emulator**

### Security Tools
- **rootAVD** - Advanced AVD rooting toolkit
- **Custom Magisk** - Modified Magisk for enhanced compatibility
- **Pre-rooted System Image** - Ready for security testing

### Development Environment
- **Proper PATH Configuration** - All tools accessible from command line
- **Environment Variables** - ANDROID_HOME and PATH automatically configured
- **AVD Management** - Pre-configured virtual device ready to use

## 🚀 Quick Start

### Prerequisites

The script will check for these automatically, but you can install them beforehand:

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install wget unzip git openjdk-11-jdk
```

**CentOS/RHEL:**
```bash
sudo yum install wget unzip git java-11-openjdk-devel
```

**Arch Linux:**
```bash
sudo pacman -S wget unzip git jdk11-openjdk
```

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sneckey0day/Android-Lab-Setup.git
   cd Android-Lab-Setup
   ```

2. **Make the script executable:**
   ```bash
   chmod +x android_lab_setup.sh
   ```

3. **Run the setup:**
   ```bash
   ./android_lab_setup.sh
   ```

4. **Follow the on-screen instructions** and wait for completion (5-15 minutes depending on internet speed)

5. **Restart your terminal** or reload your profile:
   ```bash
   source ~/.bashrc  # or ~/.zshrc if using zsh
   ```

## 📱 Using Your Android Lab

### Starting the Emulator

```bash
# Start the pre-configured rooted Android device
emulator -avd Android_Lab_API34
```

### Common Commands

```bash
# List all available AVDs
emulator -list-avds

# Check connected devices
adb devices

# Connect to device shell
adb shell

# Check root access
adb shell su

# Install APK
adb install app.apk

# Push files to device
adb push file.txt /sdcard/

# Pull files from device
adb pull /sdcard/file.txt ./
```

### Magisk Root Verification

1. Start the emulator and wait for complete boot
2. Open the **Magisk** app from the app drawer
3. Grant superuser permissions when prompted
4. The device will automatically reboot
5. Root access is now active and ready for use

## 🗂️ Directory Structure

After installation, your setup will look like this:

```
~/android-sdk/
├── cmdline-tools/
│   └── latest/
│       ├── bin/          # SDK manager, AVD manager
│       └── lib/          # SDK libraries
├── platform-tools/      # ADB, Fastboot
├── platforms/
│   └── android-34/       # Android 14 platform
├── build-tools/
│   └── 34.0.0/          # Build tools
├── emulator/            # Android emulator
├── system-images/       # Rooted system images
│   └── android-34/
└── rootAVD/             # Rooting toolkit
    ├── rootAVD.sh       # Root application script
    └── Magisk.zip       # Custom Magisk package
```

## 🔧 Configuration Details

### Environment Variables

The script automatically adds these to your shell profile:

```bash
# Android Config
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/build-tools/34.0.0
export PATH=$PATH:$ANDROID_HOME/emulator
```

### AVD Configuration

- **Name:** Android_Lab_API34
- **System Image:** Android 14 (API 34)
- **Architecture:** x86_64
- **Features:** Google Play Store, Hardware acceleration
- **Root:** Pre-rooted with Magisk
- **Device Profile:** Pixel 3a

## 🛠️ Advanced Usage

### Creating Additional AVDs

```bash
# List available system images
sdkmanager --list | grep system-images

# Create new AVD
avdmanager create avd -n MyCustomAVD -k "system-images;android-34;google_apis_playstore;x86_64"
```

### Updating SDK Components

```bash
# Update all installed packages
sdkmanager --update

# Install specific packages
sdkmanager "platforms;android-33" "build-tools;33.0.2"
```

### Applying Root to Additional Images

```bash
cd ~/android-sdk/rootAVD
./rootAVD.sh ../system-images/android-XX/google_apis_playstore/x86_64/ramdisk.img
```

## 🔍 Use Cases

### Security Research
- **Malware Analysis** - Analyze Android malware in a controlled environment
- **Reverse Engineering** - Decompile and analyze Android applications
- **Dynamic Analysis** - Monitor app behavior with root access
- **Network Analysis** - Intercept and analyze network traffic

### Penetration Testing
- **Mobile App Security Testing** - Test Android applications for vulnerabilities
- **Root Detection Bypass** - Test and bypass root detection mechanisms
- **Certificate Pinning Bypass** - Intercept HTTPS traffic for security testing
- **Privilege Escalation Testing** - Test privilege escalation techniques

### Development & Research
- **Android Development** - Full development environment with debugging capabilities
- **Custom ROM Testing** - Test custom Android modifications
- **Framework Research** - Research Android framework internals
- **Tool Development** - Develop Android security tools and utilities

## 🔧 Troubleshooting

### Common Issues

**Issue: Java not found**
```bash
# Install OpenJDK
sudo apt install openjdk-11-jdk  # Ubuntu/Debian
sudo yum install java-11-openjdk-devel  # CentOS/RHEL
```

**Issue: Emulator won't start**
```bash
# Check virtualization support
egrep -c '(vmx|svm)' /proc/cpuinfo

# Enable KVM acceleration (if available)
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

**Issue: ADB not detecting device**
```bash
# Restart ADB server
adb kill-server
adb start-server

# Check emulator status
adb devices
```

**Issue: Root not working**
```bash
# Verify Magisk installation
adb shell su -c "magisk --version"

# Reinstall Magisk if needed
cd ~/android-sdk/rootAVD
./rootAVD.sh ../system-images/android-34/google_apis_playstore/x86_64/ramdisk.img
```

### Getting Help

If you encounter issues:

1. Check the [Issues](https://github.com/sneckey0day/Android-Lab-Setup/issues) page
2. Review the troubleshooting section above
3. Enable verbose logging by editing the script
4. Create a new issue with detailed error information

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/amazing-feature`
3. **Commit your changes:** `git commit -m 'Add amazing feature'`
4. **Push to the branch:** `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Areas for Contribution

- Support for additional Linux distributions
- ARM64 system image support
- Additional security tools integration
- Performance optimizations
- Documentation improvements
- Bug fixes and testing

## 📊 System Requirements

### Minimum Requirements
- **OS:** Linux (64-bit)
- **RAM:** 8GB (4GB available for emulator)
- **Storage:** 10GB free space
- **CPU:** x86_64 with virtualization support
- **Network:** Stable internet connection for downloads

### Recommended Requirements
- **OS:** Ubuntu 20.04+ or equivalent
- **RAM:** 16GB or more
- **Storage:** 20GB+ SSD storage
- **CPU:** Multi-core processor with VT-x/AMD-V
- **Network:** High-speed internet connection

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This tool is intended for legitimate security research, penetration testing, and educational purposes only. Users are responsible for complying with applicable laws and regulations. The authors are not responsible for any misuse of this software.

## 🙏 Acknowledgments

- **[rootAVD](https://github.com/newbit1/rootAVD)** - For the excellent AVD rooting toolkit
- **[Magisk](https://github.com/topjohnwu/Magisk)** - For the powerful root solution
- **Google Android Team** - For the Android SDK and development tools
- **Android Security Community** - For continuous improvements and feedback

## 📞 Support

- **Documentation:** Check this README and inline script comments
- **Issues:** [GitHub Issues](https://github.com/sneckey0day/Android-Lab-Setup/issues)
- **Discussions:** [GitHub Discussions](https://github.com/sneckey0day/Android-Lab-Setup/discussions)
- **Security:** For security-related issues, please email privately

---

<div align="center">

**⭐ If this project helped you, please consider giving it a star! ⭐**

Made with ❤️ for the Android Security Community

</div>
