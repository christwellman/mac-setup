#!/usr/bin/env zsh
#------------------------------------------------------------------------------
# Weekly Brew Update Script - Optimized Version
# Updates Homebrew, Cask apps, and Mac App Store packages
# Creates timestamped logs with better error handling and performance
#------------------------------------------------------------------------------

# Strict error handling
set -euo pipefail

# Configuration
readonly LOG_DIR="$HOME/Logs"
readonly LOG_FILE="$LOG_DIR/brew-update.$(date +%Y-%m-%d_%H-%M-%S).log"
readonly MAX_LOG_FILES=10  # Keep only last 10 log files

# Script flags
DRY_RUN=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: brew-update.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -n   Show what would be upgraded without installing"
            echo "  --verbose, -v   Show verbose output during upgrades"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1 (try --help)"
            exit 1
            ;;
    esac
done

# Ensure log directory exists and clean old logs
mkdir -p "$LOG_DIR"
find "$LOG_DIR" -name "brew-update.*.log" -type f | sort -r | tail -n +$((MAX_LOG_FILES + 1)) | while read -r f; do rm -f "$f"; done

# Enhanced logging function with levels
log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Section headers with visual appeal
print_header() {
    local header="$1"
    local line=$(printf '=%.0s' {1..60})
    log_message "INFO" "$line"
    log_message "INFO" "  $header"
    log_message "INFO" "$line"
}

# Enhanced command checker with helpful messages
check_command() {
    local cmd="$1"
    local install_hint="$2"

    if ! command -v "$cmd" &> /dev/null; then
        log_message "ERROR" "$cmd is not installed"
        [[ -n "$install_hint" ]] && log_message "INFO" "Install with: $install_hint"
        return 1
    fi
    log_message "INFO" "$cmd is available"
    return 0
}

# Function to run commands with better error handling (no eval)
run_with_retry() {
    local max_attempts="${1:-3}"
    shift
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        else
            log_message "WARN" "Attempt $attempt/$max_attempts failed for: $*"
            ((attempt++))
            [[ $attempt -le $max_attempts ]] && sleep 2
        fi
    done

    log_message "ERROR" "Command failed after $max_attempts attempts: $*"
    return 1
}

# Check if running on battery (skip intensive operations)
is_on_battery() {
    if command -v pmset &> /dev/null; then
        pmset -g batt | grep -q "Battery Power"
    else
        false
    fi
}

# Enhanced cleanup with size reporting
cleanup_brew() {
    print_header "Cleaning up Homebrew"

    if $DRY_RUN; then
        log_message "INFO" "[DRY RUN] Would run: brew cleanup --prune=7 -s"
        return 0
    fi

    # Show cache size before cleanup
    if [[ -d "$(brew --cache)" ]]; then
        local cache_size=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "unknown")
        log_message "INFO" "Cache size before cleanup: $cache_size"
    fi

    # Cleanup (foreground, so errors propagate)
    brew cleanup --prune=7 -s 2>&1 | tee -a "$LOG_FILE" || {
        log_message "WARN" "Cleanup encountered issues (non-fatal)"
    }

    # Show space saved
    if [[ -d "$(brew --cache)" ]]; then
        local new_cache_size=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "unknown")
        log_message "INFO" "Cache size after cleanup: $new_cache_size"
    fi
}

# Enhanced cask update with better detection
update_casks() {
    print_header "Upgrading Cask applications"

    # Report pinned casks
    if brew tap | grep -q "buo/cask-upgrade"; then
        local pinned
        pinned=$(brew cu pinned 2>/dev/null || true)
        if [[ -n "$pinned" ]]; then
            log_message "INFO" "Pinned casks (will not upgrade):"
            echo "$pinned" | tee -a "$LOG_FILE"
        fi
    fi

    if $DRY_RUN; then
        log_message "INFO" "[DRY RUN] Would upgrade casks:"
        if brew tap | grep -q "buo/cask-upgrade"; then
            brew cu --all --yes --cleanup --dry-run 2>&1 | tee -a "$LOG_FILE" || true
        else
            brew outdated --cask 2>&1 | tee -a "$LOG_FILE" || true
        fi
        return 0
    fi

    # Check for brew-cask-upgrade plugin
    if brew tap | grep -q "buo/cask-upgrade"; then
        log_message "INFO" "Using brew cu for comprehensive cask updates"
        brew cu --all --yes --cleanup 2>&1 | tee -a "$LOG_FILE" || {
            log_message "WARN" "Some cask updates failed - this is often normal"
        }
    else
        log_message "INFO" "brew cu not available, using standard cask upgrade"
        local outdated_casks=$(brew outdated --cask --quiet 2>/dev/null || echo "")

        if [[ -n "$outdated_casks" ]]; then
            log_message "INFO" "Outdated casks found:"
            echo "$outdated_casks" | tee -a "$LOG_FILE"
            brew upgrade --cask 2>&1 | tee -a "$LOG_FILE"
        else
            log_message "INFO" "All casks are up to date"
        fi
    fi
}

# Interactive MAS updates with better UX
update_mas() {
    print_header "Mac App Store Updates"

    local mas_updates
    if mas_updates=$(mas outdated 2>/dev/null); then
        if [[ -n "$mas_updates" ]]; then
            log_message "INFO" "Available App Store updates:"
            echo "$mas_updates" | tee -a "$LOG_FILE"

            if $DRY_RUN; then
                log_message "INFO" "[DRY RUN] Would prompt to install App Store updates"
                return 0
            fi

            # More user-friendly prompt
            echo
            echo "🍎 Install App Store updates?"
            echo "   [y] Yes, install all"
            echo "   [n] No, skip updates"
            echo "   [l] List only (no install)"
            echo
            read -k1 "REPLY?Your choice: "
            echo

            case "$REPLY" in
                y|Y)
                    log_message "INFO" "Installing App Store updates..."
                    mas upgrade 2>&1 | tee -a "$LOG_FILE"
                    ;;
                l|L)
                    log_message "INFO" "App Store updates listed above - no installation performed"
                    ;;
                *)
                    log_message "INFO" "Skipping App Store updates"
                    ;;
            esac
        else
            log_message "INFO" "All App Store applications are up to date"
        fi
    else
        log_message "WARN" "Failed to check Mac App Store updates (try signing in to App Store)"
    fi
}

# Generate summary report (reuses doctor_output from main)
generate_summary() {
    print_header "Update Summary"

    log_message "INFO" "Homebrew packages: $(brew list --formula | wc -l | tr -d ' ')"
    log_message "INFO" "Cask applications: $(brew list --cask | wc -l | tr -d ' ')"

    # Use cached brew doctor output
    local warnings=$(echo "$DOCTOR_OUTPUT" | grep -ic "warning" || true)
    if [[ $warnings -gt 0 ]]; then
        log_message "WARN" "Found $warnings potential issues (run 'brew doctor' for details)"
    else
        log_message "INFO" "No issues found by brew doctor"
    fi

    log_message "INFO" "Log file: $LOG_FILE"
    log_message "INFO" "Update completed at $(date)"
}

# Global for cached brew doctor output
DOCTOR_OUTPUT=""

# Main execution function
main() {
    local start_time=$(date +%s)

    if $DRY_RUN; then
        log_message "INFO" "🧪 DRY RUN MODE - no changes will be made"
    fi

    log_message "INFO" "🚀 Starting weekly Homebrew update"
    log_message "INFO" "macOS version: $(sw_vers -productVersion)"
    log_message "INFO" "Homebrew version: $(brew --version | head -n1)"

    # Battery check
    if is_on_battery; then
        log_message "WARN" "Running on battery power - some operations may be slower"
    fi

    # Dependency checks
    check_command "brew" "Install from https://brew.sh" || exit 1
    check_command "mas" "brew install mas" || {
        log_message "WARN" "mas not available - skipping App Store updates"
    }

    # Core updates with retry logic
    print_header "Updating Homebrew"
    if $DRY_RUN; then
        log_message "INFO" "[DRY RUN] Would run: brew update"
    else
        run_with_retry 3 brew update
    fi

    print_header "Checking for outdated packages"
    local outdated_count=$(brew outdated --quiet | wc -l | tr -d ' ')
    log_message "INFO" "Found $outdated_count outdated formula(e)"

    if [[ $outdated_count -gt 0 ]]; then
        brew outdated | tee -a "$LOG_FILE"

        if $DRY_RUN; then
            log_message "INFO" "[DRY RUN] Would upgrade $outdated_count package(s)"
        else
            print_header "Upgrading Homebrew packages"
            local upgrade_flags=()
            $VERBOSE && upgrade_flags+=(--verbose)
            brew upgrade "${upgrade_flags[@]}" 2>&1 | tee -a "$LOG_FILE" || {
                log_message "WARN" "Some packages failed to upgrade (this can be normal)"
            }
        fi
    else
        log_message "INFO" "All Homebrew packages are up to date"
    fi

    # Cleanup and maintenance
    cleanup_brew

    # Cask updates
    update_casks

    # MAS updates (if available)
    if command -v mas &> /dev/null; then
        update_mas
    fi

    # Run brew doctor once, cache output
    print_header "Running diagnostics"
    DOCTOR_OUTPUT=$(brew doctor 2>&1 || true)
    echo "$DOCTOR_OUTPUT" | tee -a "$LOG_FILE" | grep -i "warning\|error" || log_message "INFO" "All systems green! ✅"

    generate_summary

    # Performance metrics
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    log_message "INFO" "⏱️  Total execution time: ${minutes}m ${seconds}s"

    # macOS notification
    if command -v osascript &> /dev/null; then
        local notify_msg="Updated in ${minutes}m ${seconds}s"
        $DRY_RUN && notify_msg="Dry run complete in ${minutes}m ${seconds}s"
        osascript -e "display notification \"$notify_msg\" with title \"Homebrew Update\"" 2>/dev/null || true
    fi
}

# Trap for cleanup on exit
trap 'log_message "INFO" "Script interrupted - check log for details"' INT TERM

# Execute main function
main "$@" 2>&1

exit 0
