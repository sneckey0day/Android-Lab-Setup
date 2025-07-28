#!/bin/bash

# ============================================================================
# Android Lab Setup Script
# Automated Android SDK, AVD, and Root Setup for Linux
# Repository: https://github.com/sneckey0day/Android-Lab-Setup
# ============================================================================

# Color codes for better CLI experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
ANDROID_SDK_DIR="$HOME/android-sdk"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
MAGISK_URL="https://github.com/sneckey0day/Android-Lab-Setup/raw/main/Magisk.zip"
ROOTAVD_REPO="https://github.com/newbit1/rootAVD.git"

# Function to print colored output
print_header() {
    echo -e "\n${CYAN}============================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}============================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_step() {
    echo -e "\n${PURPLE}➤ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    print_header "CHECKING SYSTEM DEPENDENCIES"
    
    local missing_deps=()
    
    # Check for required commands
    if ! command_exists "wget"; then
        missing_deps+=("wget")
    fi
    
    if ! command_exists "unzip"; then
        missing_deps+=("unzip")
    fi
    
    if ! command_exists "git"; then
        missing_deps+=("git")
    fi
    
    if ! command_exists "java"; then
        missing_deps+=("openjdk-11-jdk or openjdk-17-jdk")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install missing dependencies and run the script again."
        print_info "Ubuntu/Debian: sudo apt update && sudo apt install wget unzip git openjdk-11-jdk"
        print_info "CentOS/RHEL: sudo yum install wget unzip git java-11-openjdk-devel"
        print_info "Arch: sudo pacman -S wget unzip git jdk11-openjdk"
        exit 1
    fi
    
    print_success "All dependencies are installed"
}

# Function to add Android environment variables to profile
setup_environment() {
    print_header "SETTING UP ENVIRONMENT VARIABLES"
    
    local profile_file=""
    
    # Determine which profile file to use
    if [ -f "$HOME/.bashrc" ]; then
        profile_file="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        profile_file="$HOME/.zshrc"
    elif [ -f "$HOME/.profile" ]; then
        profile_file="$HOME/.profile"
    else
        profile_file="$HOME/.bashrc"
        touch "$profile_file"
    fi
    
    print_info "Adding Android configuration to: $profile_file"
    
    # Check if Android config already exists
    if grep -q "# Android Config" "$profile_file"; then
        print_warning "Android configuration already exists in profile"
    else
        cat >> "$profile_file" << 'EOF'

# Android Config
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/build-tools/34.0.0
export PATH=$PATH:$ANDROID_HOME/emulator
EOF
        print_success "Android environment variables added to profile"
    fi
    
    # Export for current session
    export ANDROID_HOME="$HOME/android-sdk"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export PATH="$PATH:$ANDROID_HOME/build-tools/34.0.0"
    export PATH="$PATH:$ANDROID_HOME/emulator"
}

# Function to download Android command line tools
download_cmdline_tools() {
    print_header "DOWNLOADING ANDROID COMMAND LINE TOOLS"
    
    cd "$HOME/Downloads" || exit 1
    
    if [ -f "commandlinetools-linux-13114758_latest.zip" ]; then
        print_warning "Command line tools already downloaded"
    else
        print_step "Downloading Android Command Line Tools..."
        if wget -q --show-progress "$CMDLINE_TOOLS_URL"; then
            print_success "Download completed"
        else
            print_error "Failed to download command line tools"
            exit 1
        fi
    fi
    
    print_step "Extracting command line tools..."
    if unzip -q commandlinetools-linux-13114758_latest.zip; then
        print_success "Extraction completed"
    else
        print_error "Failed to extract command line tools"
        exit 1
    fi
}

# Function to setup Android SDK directory structure
setup_sdk_structure() {
    print_header "SETTING UP ANDROID SDK STRUCTURE"
    
    cd "$HOME" || exit 1
    
    print_step "Creating android-sdk directory..."
    mkdir -p "$ANDROID_SDK_DIR"
    
    print_step "Moving command line tools to proper location..."
    if [ -d "$HOME/Downloads/cmdline-tools" ]; then
        mv "$HOME/Downloads/cmdline-tools" "$ANDROID_SDK_DIR/"
        cd "$ANDROID_SDK_DIR" || exit 1
        
        # Create proper directory structure
        mkdir -p cmdline-tools/latest
        mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
        
        # Fix the structure - move contents to latest directory
        if [ -d "cmdline-tools/bin" ]; then
            mkdir -p cmdline-tools/temp
            mv cmdline-tools/bin cmdline-tools/lib cmdline-tools/NOTICE.txt cmdline-tools/source.properties cmdline-tools/temp/ 2>/dev/null || true
            rm -rf cmdline-tools/latest
            mv cmdline-tools/temp cmdline-tools/latest
        fi
        
        print_success "SDK structure created successfully"
        print_info "SDK location: $ANDROID_SDK_DIR/cmdline-tools/latest"
    else
        print_error "Command line tools directory not found"
        exit 1
    fi
}

# Function to install SDK components
install_sdk_components() {
    print_header "INSTALLING ANDROID SDK COMPONENTS"
    
    cd "$ANDROID_SDK_DIR" || exit 1
    
    # Make sdkmanager executable
    chmod +x cmdline-tools/latest/bin/sdkmanager
    
    print_step "Installing platform-tools, android-34 platform, and build-tools..."
    print_info "This may take several minutes. The installer will prompt for license acceptance."
    
    # Accept licenses first
    yes | ./cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null 2>&1
    
    # Install required components
    if ./cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"; then
        print_success "SDK components installed successfully"
    else
        print_error "Failed to install SDK components"
        exit 1
    fi
    
    print_step "Installing system images for Android 34..."
    if ./cmdline-tools/latest/bin/sdkmanager "system-images;android-34;google_apis_playstore;x86_64"; then
        print_success "System images installed successfully"
    else
        print_error "Failed to install system images"
        exit 1
    fi
}

# Function to setup root environment
setup_root_environment() {
    print_header "SETTING UP ROOT ENVIRONMENT"
    
    cd "$ANDROID_SDK_DIR" || exit 1
    
    print_step "Cloning rootAVD repository..."
    if [ -d "rootAVD" ]; then
        print_warning "rootAVD already exists, updating..."
        cd rootAVD && git pull && cd ..
    else
        if git clone "$ROOTAVD_REPO"; then
            print_success "rootAVD cloned successfully"
        else
            print_error "Failed to clone rootAVD repository"
            exit 1
        fi
    fi
    
    print_step "Downloading custom Magisk..."
    cd rootAVD || exit 1
    
    # Remove existing Magisk.zip if it exists
    [ -f "Magisk.zip" ] && rm -f Magisk.zip
    
    if wget -q --show-progress -O Magisk.zip "$MAGISK_URL"; then
        print_success "Custom Magisk downloaded successfully"
    else
        print_error "Failed to download custom Magisk"
        exit 1
    fi
    
    # Make rootAVD script executable
    chmod +x rootAVD.sh
}

# Function to apply root to system image
apply_root() {
    print_header "APPLYING ROOT TO ANDROID SYSTEM IMAGE"
    
    cd "$ANDROID_SDK_DIR/rootAVD" || exit 1
    
    local ramdisk_path="$ANDROID_SDK_DIR/system-images/android-34/google_apis_playstore/x86_64/ramdisk.img"
    
    if [ ! -f "$ramdisk_path" ]; then
        print_error "System image not found at: $ramdisk_path"
        exit 1
    fi
    
    print_step "Applying root to system image..."
    print_info "This process modifies the ramdisk.img file to include Magisk"
    
    if ./rootAVD.sh "$ramdisk_path"; then
        print_success "Root successfully applied to system image"
    else
        print_error "Failed to apply root to system image"
        exit 1
    fi
}

# Function to create AVD
create_avd() {
    print_header "CREATING ANDROID VIRTUAL DEVICE"
    
    cd "$ANDROID_SDK_DIR" || exit 1
    
    local avd_name="Android_Lab_API34"
    
    print_step "Creating AVD: $avd_name"
    
    # Create AVD with Google Play Store support
    if echo "no" | ./cmdline-tools/latest/bin/avdmanager create avd \
        -n "$avd_name" \
        -k "system-images;android-34;google_apis_playstore;x86_64" \
        --device "pixel_3a"; then
        print_success "AVD created successfully"
    else
        print_warning "AVD might already exist or creation failed"
    fi
    
    print_info "AVD Name: $avd_name"
    print_info "You can start it with: emulator -avd $avd_name"
}

# Function to display final instructions
show_final_instructions() {
    print_header "SETUP COMPLETED SUCCESSFULLY!"
    
    echo -e "${GREEN}🎉 Android Lab Setup is now complete!${NC}\n"
    
    print_info "Next steps:"
    echo -e "  ${YELLOW}1.${NC} Restart your terminal or run: ${CYAN}source ~/.bashrc${NC}"
    echo -e "  ${YELLOW}2.${NC} Start the emulator: ${CYAN}emulator -avd Android_Lab_API34${NC}"
    echo -e "  ${YELLOW}3.${NC} Wait for Android to boot completely"
    echo -e "  ${YELLOW}4.${NC} Open Magisk app and confirm root access"
    echo -e "  ${YELLOW}5.${NC} The device will reboot automatically after Magisk setup"
    
    echo -e "\n${PURPLE}Useful Commands:${NC}"
    echo -e "  • List AVDs: ${CYAN}emulator -list-avds${NC}"
    echo -e "  • Start emulator: ${CYAN}emulator -avd Android_Lab_API34${NC}"
    echo -e "  • ADB connect: ${CYAN}adb devices${NC}"
    echo -e "  • ADB shell: ${CYAN}adb shell${NC}"
    
    echo -e "\n${PURPLE}Directory Structure:${NC}"
    echo -e "  • Android SDK: ${CYAN}$ANDROID_SDK_DIR${NC}"
    echo -e "  • Platform Tools: ${CYAN}$ANDROID_SDK_DIR/platform-tools${NC}"
    echo -e "  • Emulator: ${CYAN}$ANDROID_SDK_DIR/emulator${NC}"
    echo -e "  • Root Tools: ${CYAN}$ANDROID_SDK_DIR/rootAVD${NC}"
    
    echo -e "\n${GREEN}Repository: https://github.com/sneckey0day/Android-Lab-Setup${NC}"
    
    print_warning "Remember to restart your terminal to use the new PATH variables!"
}

# Function to cleanup on error
cleanup_on_error() {
    print_error "Setup failed. Cleaning up..."
    # Add any cleanup operations here if needed
    exit 1
}

# Main execution function
main() {
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Display banner
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ANDROID LAB SETUP                         ║
    ║              Automated Android SDK & Root Setup             ║
    ║                                                              ║
    ║    Repository: https://github.com/sneckey0day/Android-Lab-Setup    ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    print_info "This script will setup Android SDK, AVD, and root environment"
    print_warning "Make sure you have a stable internet connection"
    
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    
    # Execute setup steps
    check_dependencies
    setup_environment
    download_cmdline_tools
    setup_sdk_structure
    install_sdk_components
    setup_root_environment
    apply_root
    create_avd
    show_final_instructions
}

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi