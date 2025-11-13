#!/usr/bin/env bash

# Test script to validate symlink detection fix
# This creates test scenarios and verifies the install script handles them correctly

# Don't use set -e since we want to continue testing even if individual tests fail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$HOME/.dotfiles_test_$$"
BACKUP_DIR="$HOME/.dotfiles_test_backup_$$"

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

cleanup() {
    echo ""
    log_test "Cleaning up test environment..."

    # Remove test symlinks
    [ -L "$HOME/.config/fish" ] && rm "$HOME/.config/fish" 2>/dev/null || true
    [ -L "$HOME/.config/nvim" ] && rm "$HOME/.config/nvim" 2>/dev/null || true
    [ -L "$HOME/.config/zed" ] && rm "$HOME/.config/zed" 2>/dev/null || true
    [ -L "$HOME/.config/fish/config.fish" ] && rm "$HOME/.config/fish/config.fish" 2>/dev/null || true

    # Restore backups if they exist
    if [ -d "$BACKUP_DIR" ]; then
        log_test "Restoring original configs from backup..."
        cp -a "$BACKUP_DIR"/.config/* "$HOME/.config/" 2>/dev/null || true
        rm -rf "$BACKUP_DIR"
    fi

    # Remove test directory
    [ -d "$TEST_DIR" ] && rm -rf "$TEST_DIR" 2>/dev/null || true

    log_pass "Cleanup complete"
    echo ""
}

# Source the install script functions
source_install_functions() {
    log_test "Sourcing install script functions..."

    # Extract just the functions we need to test
    eval "$(sed -n '/^path_points_to_repo()/,/^}/p' "$DOTFILES_REPO/install.sh")"
    eval "$(sed -n '/^remove_repo_symlinks()/,/^}/p' "$DOTFILES_REPO/install.sh")"

    # Set required variables
    export DOTFILES_REPO

    log_pass "Functions loaded"
}

# Test 1: Detect symlink pointing to repo
test_symlink_detection() {
    log_test "Test 1: Detecting symlinks pointing to repository..."

    # Create a symlink to repo
    ln -sf "$DOTFILES_REPO/common/fish/.config/fish" "$TEST_DIR/test_fish"

    if path_points_to_repo "$TEST_DIR/test_fish"; then
        log_pass "✓ Correctly detected symlink pointing to repo"
        return 0
    else
        log_fail "✗ Failed to detect symlink pointing to repo"
        return 1
    fi
}

# Test 2: Detect nested symlink (parent directory)
test_nested_symlink_detection() {
    log_test "Test 2: Detecting nested symlinks (parent directory points to repo)..."

    # Create parent directory symlink
    mkdir -p "$TEST_DIR/nested"
    ln -sf "$DOTFILES_REPO/common/fish/.config" "$TEST_DIR/nested/fish_config"

    if path_points_to_repo "$TEST_DIR/nested/fish_config/fish/config.fish"; then
        log_pass "✓ Correctly detected nested symlink"
        return 0
    else
        log_fail "✗ Failed to detect nested symlink"
        return 1
    fi
}

# Test 3: Normal path should not be detected
test_normal_path() {
    log_test "Test 3: Normal paths should not be flagged..."

    mkdir -p "$TEST_DIR/normal/config"
    echo "test" > "$TEST_DIR/normal/config/file.txt"

    if ! path_points_to_repo "$TEST_DIR/normal/config/file.txt"; then
        log_pass "✓ Normal path correctly identified as safe"
        return 0
    else
        log_fail "✗ False positive: normal path flagged as pointing to repo"
        return 1
    fi
}

# Test 4: Remove repo symlinks function
test_remove_symlinks() {
    log_test "Test 4: Removing symlinks pointing to repository..."

    # Create symlink to repo
    mkdir -p "$TEST_DIR/remove_test"
    ln -sf "$DOTFILES_REPO/common/fish/.config/fish" "$TEST_DIR/remove_test/fish"

    # Verify it exists and points to repo
    if [ ! -L "$TEST_DIR/remove_test/fish" ]; then
        log_fail "✗ Test setup failed: symlink not created"
        return 1
    fi

    # Run remove function
    remove_repo_symlinks "$TEST_DIR/remove_test/fish/config.fish"

    # Verify symlink was removed
    if [ ! -L "$TEST_DIR/remove_test/fish" ]; then
        log_pass "✓ Symlink successfully removed"
        return 0
    else
        log_fail "✗ Symlink was not removed"
        return 1
    fi
}

# Test 5: Symlink in path components
test_symlink_in_path() {
    log_test "Test 5: Detecting symlink in path components..."

    # Create ~/.config as symlink to repo
    mkdir -p "$TEST_DIR/path_test"
    ln -sf "$DOTFILES_REPO/common/fish/.config" "$TEST_DIR/path_test/.config"

    # Check if file within symlinked directory is detected
    if path_points_to_repo "$TEST_DIR/path_test/.config/fish/config.fish"; then
        log_pass "✓ Detected symlink in path component"
        return 0
    else
        log_fail "✗ Failed to detect symlink in path component"
        return 1
    fi
}

# Test 6: Broken symlink handling
test_broken_symlink() {
    log_test "Test 6: Handling broken symlinks..."

    # Create broken symlink
    ln -sf "/nonexistent/path" "$TEST_DIR/broken_link"

    # Should return false (safe) for broken symlinks
    if ! path_points_to_repo "$TEST_DIR/broken_link"; then
        log_pass "✓ Broken symlink handled safely"
        return 0
    else
        log_fail "✗ Broken symlink mishandled"
        return 1
    fi
}

# Test 7: Real-world scenario - fish config
test_fish_config_scenario() {
    log_test "Test 7: Real-world scenario - fish config symlink..."

    # Backup existing fish config if it exists
    if [ -e "$HOME/.config/fish" ]; then
        mkdir -p "$BACKUP_DIR/.config"
        cp -a "$HOME/.config/fish" "$BACKUP_DIR/.config/"
    fi

    # Create the problematic scenario
    rm -rf "$HOME/.config/fish"
    ln -sf "$DOTFILES_REPO/common/fish/.config/fish" "$HOME/.config/fish"

    # Verify symlink points to repo
    if ! path_points_to_repo "$HOME/.config/fish/config.fish"; then
        log_fail "✗ Test setup failed: symlink not detected"
        return 1
    fi

    # Run remove function
    remove_repo_symlinks "$HOME/.config/fish/config.fish"

    # Verify symlink was removed
    if [ ! -L "$HOME/.config/fish" ]; then
        log_pass "✓ Fish config symlink successfully removed"
        return 0
    else
        log_fail "✗ Fish config symlink was not removed"
        return 1
    fi
}

# Main test runner
main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Dotfiles Symlink Fix Validation Tests          ║${NC}"
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo ""

    # Setup
    mkdir -p "$TEST_DIR"
    mkdir -p "$BACKUP_DIR"

    # Load functions
    source_install_functions

    # Run tests
    local passed=0
    local failed=0

    if test_symlink_detection; then ((passed++)); else ((failed++)); fi
    echo ""

    if test_nested_symlink_detection; then ((passed++)); else ((failed++)); fi
    echo ""

    if test_normal_path; then ((passed++)); else ((failed++)); fi
    echo ""

    if test_remove_symlinks; then ((passed++)); else ((failed++)); fi
    echo ""

    if test_symlink_in_path; then ((passed++)); else ((failed++)); fi
    echo ""

    if test_broken_symlink; then ((passed++)); else ((failed++)); fi
    echo ""

    if test_fish_config_scenario; then ((passed++)); else ((failed++)); fi
    echo ""

    # Summary
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Test Summary                                    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}Passed:${NC} $passed"
    echo -e "  ${RED}Failed:${NC} $failed"
    echo ""

    # Cleanup
    cleanup

    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo ""
        log_test "The symlink detection fix is working correctly."
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        echo ""
        log_warn "Please review the failed tests above."
        return 1
    fi
}

# Run main
main "$@"
exit_code=$?

exit $exit_code
