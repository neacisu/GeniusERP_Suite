#!/bin/bash

################################################################################
# GeniusSuite Environment Variables Validation Script
#
# Purpose: Validate that all required .env files exist and contain necessary
#          configuration for the entire GeniusSuite ecosystem.
#
# Usage:
#   ./scripts/validate-env.sh              # Check all apps
#   ./scripts/validate-env.sh archify      # Check specific app
#   ./scripts/validate-env.sh --help       # Show this help
#
# Exit Codes:
#   0 = All validations passed
#   1 = Some validations failed
#   2 = Invalid arguments
#
################################################################################

# Don't exit on error - we want to check all validations
# set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Applications in the suite
APPS=(
  "archify"
  "cerniq"
  "flowxify"
  "i-wms"
  "mercantiq"
  "numeriqo"
  "triggerra"
  "vettify"
  "geniuserp"
)

CP_SERVICES=(
  "suite-shell"
  "suite-admin"
  "suite-login"
  "identity"
  "licensing"
  "analytics-hub"
  "ai-hub"
)

################################################################################
# Helper Functions
################################################################################

print_header() {
  echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║ $1${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_check() {
  local message=$1
  echo -n "  ▪ $message ... "
}

print_pass() {
  echo -e "${GREEN}✓${NC}"
  ((PASSED++))
}

print_fail() {
  local reason=$1
  echo -e "${RED}✗${NC}"
  echo -e "    ${RED}Reason: $reason${NC}"
  ((FAILED++))
}

print_warning() {
  local message=$1
  echo -e "${YELLOW}⚠${NC}"
  echo -e "    ${YELLOW}Warning: $message${NC}"
  ((WARNINGS++))
}

print_info() {
  echo -e "    ${BLUE}ℹ $1${NC}"
}

file_exists() {
  [ -f "$1" ]
}

dir_exists() {
  [ -d "$1" ]
}

has_required_var() {
  local file=$1
  local var=$2

  if grep -q "^${var}=" "$file" 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

################################################################################
# Validation Functions
################################################################################

check_root_env() {
  print_header "Checking Root Environment Files"

  # Check .env exists
  print_check ".env file exists"
  if file_exists "$ROOT_DIR/.env"; then
    print_pass
  else
    print_fail ".env file not found at $ROOT_DIR/.env"
  fi

  # Check .env.example exists
  print_check ".env.example template exists"
  if file_exists "$ROOT_DIR/.env.example"; then
    print_pass
  else
    print_fail ".env.example template not found"
  fi

  # Check .env.local is in .gitignore (if it exists)
  print_check ".env.local is gitignored"
  if grep -q "\.env\.local" "$ROOT_DIR/.gitignore" 2>/dev/null; then
    print_pass
  else
    print_warning ".env.local not in .gitignore - make sure to add it!"
  fi

  # Check .env.production is in .gitignore
  print_check ".env.production is gitignored"
  if grep -q "\.env\.production" "$ROOT_DIR/.gitignore" 2>/dev/null; then
    print_pass
  else
    print_warning ".env.production not in .gitignore"
  fi
}

check_control_plane() {
  print_header "Checking Control Plane Configuration"

  # Check CP directory exists
  print_check "cp directory exists"
  if dir_exists "$ROOT_DIR/cp"; then
    print_pass
  else
    print_fail "cp directory not found at $ROOT_DIR/cp"
    return
  fi

  # Check .env.geniussuite.example exists
  print_check "cp/.env.geniussuite.example exists"
  if file_exists "$ROOT_DIR/cp/.env.geniussuite.example"; then
    print_pass
  else
    print_fail "cp/.env.geniussuite.example not found"
  fi

  # Check each CP service directory
  for service in "${CP_SERVICES[@]}"; do
    print_check "cp/$service directory exists"
    if dir_exists "$ROOT_DIR/cp/$service"; then
      print_pass
    else
      print_fail "cp/$service directory not found"
    fi
  done
}

check_application() {
  local app=$1
  local app_dir="$ROOT_DIR/${app}.app"
  
  # Map app names to their env file naming conventions
  local env_name="$app"
  case "$app" in
    i-wms) env_name="iwms" ;;
  esac

  print_check "${app}.app directory exists"
  if ! dir_exists "$app_dir"; then
    print_fail "${app}.app directory not found"
    return
  fi
  print_pass

  # Check .env.{app}.example exists (with correct naming)
  print_check "${app}.app/.env.${env_name}.example exists"
  if file_exists "$app_dir/.env.${env_name}.example"; then
    print_pass
  else
    print_fail ".env.${env_name}.example not found"
  fi

  # Check .env.{app} working config exists
  print_check "${app}.app/.env.${env_name} (working config) exists"
  if file_exists "$app_dir/.env.${env_name}"; then
    print_pass
  else
    print_fail ".env.${env_name} (working config) not found"
  fi

  # Check env schema exists (optional - will be created in next phase)
  print_check "${app}.app/src/config/env.schema.ts exists"
  if file_exists "$app_dir/src/config/env.schema.ts"; then
    print_pass
  else
    print_warning "env.schema.ts not yet created (will be added in next phase)"
  fi
}

check_docker_compose() {
  print_header "Checking Docker Compose Configuration"

  # Check docker-compose.yml exists
  print_check "docker-compose.yml exists"
  if file_exists "$ROOT_DIR/docker-compose.yml"; then
    print_pass
  else
    print_info "docker-compose.yml will be created in next phase for full integration"
  fi

  # Check docker-compose.prod.yml exists
  print_check "docker-compose.prod.yml exists"
  if file_exists "$ROOT_DIR/docker-compose.prod.yml"; then
    print_pass
  else
    print_info "docker-compose.prod.yml will be created in next phase for production"
  fi
}

check_documentation() {
  print_header "Checking Documentation"

  # Check ENV-STRATEGY.md exists
  print_check "docs/ENV-STRATEGY.md exists"
  if file_exists "$ROOT_DIR/docs/ENV-STRATEGY.md"; then
    print_pass
  else
    print_fail "ENV-STRATEGY.md not found"
  fi

  # Check ENV-IMPLEMENTATION-GUIDE.md exists
  print_check "docs/ENV-IMPLEMENTATION-GUIDE.md exists"
  if file_exists "$ROOT_DIR/docs/ENV-IMPLEMENTATION-GUIDE.md"; then
    print_pass
  else
    print_fail "ENV-IMPLEMENTATION-GUIDE.md not found"
  fi

  # Note: SECRETS-REQUIRED.md will be created per app in future phases
  print_info "SECRETS-REQUIRED.md files will be created per app in next phase"
}

check_shared_config() {
  print_header "Checking Shared Configuration Module"

  # Check env-loader exists
  print_check "libs/shared/src/config/env-loader.ts exists"
  if file_exists "$ROOT_DIR/libs/shared/src/config/env-loader.ts"; then
    print_pass
  else
    print_fail "env-loader.ts not found in shared library"
    return
  fi

  # Check exports
  print_check "env-loader exports EnvLoader class"
  if grep -q "export class EnvLoader" "$ROOT_DIR/libs/shared/src/config/env-loader.ts"; then
    print_pass
  else
    print_fail "EnvLoader class not exported from env-loader.ts"
  fi

  print_check "env-loader exports setupEnv function"
  if grep -q "export function setupEnv" "$ROOT_DIR/libs/shared/src/config/env-loader.ts"; then
    print_pass
  else
    print_fail "setupEnv function not exported from env-loader.ts"
  fi
}

check_env_examples() {
  print_header "Checking Environment Template Examples"

  # Check root .env.example has required sections
  print_check ".env.example has DATABASE configuration"
  if grep -q "DATABASE_URL" "$ROOT_DIR/.env.example"; then
    print_pass
  else
    print_warning ".env.example missing DATABASE_URL section"
  fi

  print_check ".env.example has REDIS configuration"
  if grep -q "REDIS" "$ROOT_DIR/.env.example"; then
    print_pass
  else
    print_warning ".env.example missing REDIS configuration"
  fi

  print_check ".env.example has OTEL configuration"
  if grep -q "OTEL" "$ROOT_DIR/.env.example"; then
    print_pass
  else
    print_warning ".env.example missing OTEL configuration"
  fi
}

show_help() {
  cat << EOF

${BLUE}GeniusSuite Environment Variables Validation${NC}

Usage:
  $(basename "$0")              # Validate all applications
  $(basename "$0") [app]        # Validate specific app (e.g., archify, cerniq)
  $(basename "$0") --help       # Show this help message

Supported Applications:
  ${APPS[*]}

Control Plane Services:
  ${CP_SERVICES[*]}

Exit Codes:
  0 = All validations passed
  1 = Some validations failed
  2 = Invalid arguments

Examples:
  # Validate all apps
  ./scripts/validate-env.sh

  # Validate specific app
  ./scripts/validate-env.sh archify

  # Show help
  ./scripts/validate-env.sh --help

EOF
}

################################################################################
# Main Execution
################################################################################

main() {
  print_header "GeniusSuite Environment Validation"

  # Handle arguments
  if [[ $# -gt 0 ]]; then
    case "$1" in
      --help | -h)
        show_help
        exit 0
        ;;
      *)
        # Validate specific app
        local requested_app=$1
        local found=0
        for app in "${APPS[@]}"; do
          if [ "$app" = "$requested_app" ]; then
            found=1
            break
          fi
        done

        if [ $found -eq 0 ]; then
          echo -e "${RED}Error: Unknown application '$requested_app'${NC}"
          echo "Supported: ${APPS[*]}"
          exit 2
        fi

        check_application "$requested_app"
        ;;
    esac
  else
    # Full validation
    check_root_env
    check_control_plane
    check_shared_config
    check_docker_compose

    print_header "Checking All Applications"
    for app in "${APPS[@]}"; do
      echo -e "\n${BLUE}Validating ${app}...${NC}"
      check_application "$app"
    done

    check_env_examples
    check_documentation
  fi

  # Print summary
  print_header "Validation Summary"
  echo -e "  ${GREEN}Passed:  $PASSED${NC}"
  echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
  echo -e "  ${RED}Failed:  $FAILED${NC}\n"

  if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}\n"
    
    if [ $WARNINGS -gt 0 ]; then
      echo -e "${YELLOW}⚠ Please review the warnings above.${NC}\n"
      exit 0
    fi
    
    exit 0
  else
    echo -e "${RED}✗ Some validations failed. Please fix the issues above.${NC}\n"
    exit 1
  fi
}

# Run main function
main "$@"
