#!/bin/bash
#!/bin/bash

# Script to install packages with validation, logging, and root check
# Usage: ./install_packages.sh <package1> <package2> ...

# Global variables
SCRIPT_NAME=$(basename "$0")
LOG_FOLDER="/var/log/${SCRIPT_NAME%.*}_logs"  # e.g., /var/log/install_packages_logs
LOG_FILE="${LOG_FOLDER}/${SCRIPT_NAME%.*}_$(date +%Y%m%d_%H%M%S).log"  # e.g., install_packages_20260121_1857.log
PACKAGES=("$@")  # User-provided packages as array

# Function to log messages (to both screen and file)
log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "This script must be run as root (sudo). Exiting."
        exit 1
    fi
    log_message "INFO" "Root access confirmed. Proceeding."
}

# Function to create log folder and file
setup_logging() {
    if [[ ! -d "$LOG_FOLDER" ]]; then
        mkdir -p "$LOG_FOLDER"
        log_message "INFO" "Created log folder: $LOG_FOLDER"
    fi
    touch "$LOG_FILE"
    log_message "INFO" "Log file created: $LOG_FILE"
    log_message "INFO" "Starting package installation process for: ${PACKAGES[*]}"
}

# Function to check if a package is already installed (using apt)
is_package_installed() {
    local package="$1"
    if dpkg -l "$package" 2>/dev/null | grep -q "^ii  $package "; then
        return 0  # Installed
    else
        return 1  # Not installed
    fi
}

# Function to install a package (using apt) and validate
install_package() {
    local package="$1"
    local install_success=1

    log_message "INFO" "Processing package: $package"

    # Check if already installed
    if is_package_installed "$package"; then
        log_message "INFO" "Package $package is already installed. Skipping."
        return 0  # Success (skipped)
    fi

    log_message "INFO" "Package $package is not installed. Attempting installation..."

    # Update apt cache if needed (for safety)
    apt update -qq 2>/dev/null

    # Install the package
    if apt install -y "$package" >> "$LOG_FILE" 2>&1; then
        # Validate installation
        if is_package_installed "$package"; then
            log_message "SUCCESS" "Package $package installed and validated successfully."
            return 0
        else
            log_message "ERROR" "Installation of $package succeeded but validation failed."
            install_success=0
        fi
    else
        log_message "ERROR" "Installation of $package failed. Check apt logs for details."
        install_success=0
    fi

    return $install_success
}

# Function to process all packages sequentially
process_packages() {
    local all_success=1

    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        log_message "WARN" "No packages provided. Nothing to install."
        return 1
    fi

    for package in "${PACKAGES[@]}"; do
        if ! install_package "$package"; then
            log_message "ERROR" "Failed to install $package. Stopping the entire process."
            all_success=0
            break  # Stop on first failure
        fi
        log_message "INFO" "Successfully processed $package. Continuing to next."
    done

    if [[ $all_success -eq 1 ]]; then
        log_message "SUCCESS" "All packages processed successfully."
    else
        log_message "ERROR" "Process failed due to installation error(s)."
        exit 1
    fi
}

# Function to finalize and store logs
finalize_logging() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    log_message "INFO" "Process completed at $timestamp."
    log_message "INFO" "All logs safely stored in: $LOG_FILE"
    log_message "INFO" "Log folder: $LOG_FOLDER"
}

# Main execution flow
main() {
    check_root
    setup_logging
    process_packages
    finalize_logging
}

# Run main function
main "$@"