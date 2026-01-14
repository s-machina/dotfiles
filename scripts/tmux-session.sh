#!/usr/bin/env bash

# Tmux session management script for remote development
# Usage: tmux-session.sh [session_name] [--three-split]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default session name
DEFAULT_SESSION="dev"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to list existing tmux sessions
list_sessions() {
    if tmux list-sessions &>/dev/null; then
        print_info "Existing tmux sessions:"
        tmux list-sessions -F "  #{session_name} (#{session_windows} windows, created #{session_created})"
        return 0
    else
        print_info "No tmux sessions found."
        return 1
    fi
}

# Function to create a new session with optional three-split layout
create_session() {
    local session_name="$1"
    local three_split="${2:-false}"

    if tmux has-session -t "$session_name" &>/dev/null; then
        print_error "Session '$session_name' already exists."
        return 1
    fi

    print_info "Creating new session: $session_name"

    if [[ "$three_split" == "true" ]]; then
        # Create session with three-split layout
        tmux new-session -d -s "$session_name"
        tmux split-window -h -p 50 -t "$session_name"
        tmux split-window -v -p 50 -t "$session_name"
        tmux select-pane -t "$session_name:0.0"
        print_success "Created session '$session_name' with three-split layout"
    else
        # Create regular session
        tmux new-session -d -s "$session_name"
        print_success "Created session '$session_name'"
    fi
}

# Function to attach to a session
attach_session() {
    local session_name="$1"

    if tmux has-session -t "$session_name" &>/dev/null; then
        print_info "Attaching to session: $session_name"
        tmux attach-session -t "$session_name"
    else
        print_error "Session '$session_name' does not exist."
        return 1
    fi
}

# Function to show interactive session selector
select_session() {
    if ! command -v fzf &>/dev/null; then
        print_warning "fzf not found. Install it for better session selection experience."
        list_sessions
        echo
        read -p "Enter session name to attach to: " selected_session
        if [[ -n "$selected_session" ]]; then
            attach_session "$selected_session"
        fi
        return
    fi

    local sessions
    if sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null); then
        local selected_session
        selected_session=$(echo "$sessions" | fzf --prompt="Select session: " --height=10 --border)

        if [[ -n "$selected_session" ]]; then
            attach_session "$selected_session"
        fi
    else
        print_info "No existing sessions to select from."
    fi
}

# Function to show help
show_help() {
    cat << EOF
Tmux Session Management Script

Usage: $0 [OPTIONS] [SESSION_NAME]

OPTIONS:
    -h, --help          Show this help message
    -l, --list          List existing tmux sessions
    -s, --select        Interactive session selection (requires fzf)
    -3, --three-split   Create new session with three-split layout
    -n, --new           Force create new session (fail if exists)
    -a, --attach        Attach to existing session (fail if doesn't exist)

SESSION_NAME:
    Name of the tmux session (default: '$DEFAULT_SESSION')

Examples:
    $0                          # Connect to or create default session
    $0 myproject               # Connect to or create 'myproject' session
    $0 -3 dev                  # Create 'dev' session with three-split layout
    $0 --list                  # List all existing sessions
    $0 --select                # Interactive session selection
    $0 --new work              # Force create new 'work' session
    $0 --attach work           # Attach to existing 'work' session

The script will:
1. Try to attach to existing session if it exists
2. Create new session if it doesn't exist
3. Use --new to force creation (fail if exists)
4. Use --attach to force attachment (fail if doesn't exist)
EOF
}

# Main logic
main() {
    local session_name="$DEFAULT_SESSION"
    local three_split=false
    local force_new=false
    local force_attach=false
    local list_only=false
    local select_mode=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -s|--select)
                select_mode=true
                shift
                ;;
            -3|--three-split)
                three_split=true
                shift
                ;;
            -n|--new)
                force_new=true
                shift
                ;;
            -a|--attach)
                force_attach=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
            *)
                session_name="$1"
                shift
                ;;
        esac
    done

    # Check if tmux is installed
    if ! command -v tmux &>/dev/null; then
        print_error "tmux is not installed or not in PATH"
        exit 1
    fi

    # Handle list-only mode
    if [[ "$list_only" == "true" ]]; then
        list_sessions
        exit 0
    fi

    # Handle select mode
    if [[ "$select_mode" == "true" ]]; then
        select_session
        exit 0
    fi

    # Handle force new session
    if [[ "$force_new" == "true" ]]; then
        create_session "$session_name" "$three_split"
        attach_session "$session_name"
        exit 0
    fi

    # Handle force attach
    if [[ "$force_attach" == "true" ]]; then
        attach_session "$session_name"
        exit 0
    fi

    # Default behavior: attach if exists, create if doesn't
    if tmux has-session -t "$session_name" &>/dev/null; then
        print_info "Session '$session_name' exists. Attaching..."
        attach_session "$session_name"
    else
        print_info "Session '$session_name' does not exist. Creating..."
        create_session "$session_name" "$three_split"
        attach_session "$session_name"
    fi
}

# Run main function with all arguments
main "$@"