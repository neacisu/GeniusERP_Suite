#!/bin/bash
#######################################################
# Script de Validare: Fișiere .env GeniusSuite
# Verifică convenția PREFIX_CATEGORIE_NUME
#######################################################

# Nu folosim set -e pentru că (( )) poate returna 1
set -u

SUITE_ROOT="/var/www/GeniusSuite"
cd "$SUITE_ROOT"

echo "========================================="
echo "  Validare Fișiere .env - GeniusSuite"
echo "========================================="
echo ""

# Contoare
total_files=0
valid_files=0
total_vars=0
invalid_vars=0

# Categorii valide conform Tabelul 2
VALID_CATEGORIES="DB|MQ|BPM|AUTH|API|SVC|APP|OBS"

# Funcție de validare variabile
validate_env_file() {
    local file=$1
    local prefix_expected=$2
    
    if [ ! -f "$file" ]; then
        echo "  ⚠️  LIPSEȘTE: $file"
        return 1
    fi
    
    total_files=$((total_files + 1))
    
    echo "  📄 $file"
    
    # Extrage variabilele (exclude comentariile și liniile goale)
    local vars=$(grep -E "^[A-Z_]+=" "$file" 2>/dev/null | cut -d'=' -f1)
    local file_valid=true
    
    for var in $vars; do
        total_vars=$((total_vars + 1))
        
        # Verifică dacă variabila începe cu prefixul așteptat
        if [[ ! "$var" =~ ^${prefix_expected}_ ]]; then
            echo "    ❌ INVALID PREFIX: $var (așteptat: ${prefix_expected}_*)"
            invalid_vars=$((invalid_vars + 1))
            file_valid=false
            continue
        fi
        
        # Verifică structura PREFIX_CATEGORIE_NUME
        if [[ "$var" =~ ^[A-Z]+_(${VALID_CATEGORIES})_[A-Z_]+$ ]] || [[ "$var" =~ ^[A-Z]+_APP_[A-Z_]+$ ]]; then
            echo "    ✓ $var"
        else
            echo "    ⚠️  NON-STANDARD: $var (structură neconformă cu PREFIX_CATEGORIE_NUME)"
        fi
    done
    
    if [ "$file_valid" = true ]; then
        valid_files=$((valid_files + 1))
    fi
    
    echo ""
}

echo "=== 1. CONFIGURAȚIE GLOBALĂ ==="
validate_env_file ".suite.general.env" "SUITE"

echo "=== 2. INFRASTRUCTURĂ ==="
validate_env_file "gateway/.gateway.env" "GW"
validate_env_file "proxy/.proxy.env" "PROXY"
validate_env_file "shared/observability/.observability.env" "OBS"

echo "=== 3. CONTROL PLANE ==="
validate_env_file "cp/suite-shell/.cp.suite-shell.env" "CP_SHELL"
validate_env_file "cp/suite-admin/.cp.suite-admin.env" "CP_ADMIN"
validate_env_file "cp/suite-login/.cp.suite-login.env" "CP_LOGIN"
validate_env_file "cp/identity/.cp.identity.env" "CP_IDT"
validate_env_file "cp/licensing/.cp.licensing.env" "CP_LIC"
validate_env_file "cp/analytics-hub/.cp.analytics-hub.env" "CP_ANLY"
validate_env_file "cp/ai-hub/.cp.ai-hub.env" "CP_AI"

echo "=== 4. APLICAȚII ==="
validate_env_file "archify.app/.archify.env" "ARCHY"
validate_env_file "cerniq.app/.cerniq.env" "CERNIQ"
validate_env_file "flowxify.app/.flowxify.env" "FLOWX"
validate_env_file "i-wms.app/.i-wms.env" "IWMS"
validate_env_file "mercantiq.app/.mercantiq.env" "MERCQ"
validate_env_file "numeriqo.app/.numeriqo.env" "NUMQ"
validate_env_file "triggerra.app/.triggerra.env" "TRIGR"
validate_env_file "vettify.app/.vettify.env" "VETFY"
validate_env_file "geniuserp.app/.geniuserp.env" "GENERP"

echo "========================================="
echo "  SUMAR VALIDARE"
echo "========================================="
echo "Fișiere verificate: $total_files"
echo "Fișiere valide: $valid_files"
echo "Total variabile: $total_vars"
echo "Variabile invalide (prefix greșit): $invalid_vars"
echo ""

if [ $invalid_vars -eq 0 ]; then
    echo "✅ TOATE VARIABILELE RESPECTĂ CONVENȚIA!"
    exit 0
else
    echo "⚠️  ATENȚIE: $invalid_vars variabile cu prefix invalid găsite."
    exit 1
fi
