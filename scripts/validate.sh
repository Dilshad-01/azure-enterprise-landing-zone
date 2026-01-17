#!/bin/bash

# Terraform Validation Script
# Validates all Terraform configurations in the infrastructure directory

set -e

echo "========================================="
echo "Terraform Validation"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find all Terraform directories
TERRAFORM_DIRS=$(find infrastructure -name "*.tf" -type f | xargs -n1 dirname | sort -u)

VALIDATION_FAILED=0

for DIR in $TERRAFORM_DIRS; do
    echo "Validating: $DIR"
    
    cd "$DIR"
    
    # Format check
    if ! terraform fmt -check -recursive . > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Formatting issues found${NC}"
        terraform fmt -check -recursive .
    else
        echo -e "${GREEN}✅ Formatting OK${NC}"
    fi
    
    # Initialize
    if terraform init -backend=false > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Init successful${NC}"
    else
        echo -e "${RED}❌ Init failed${NC}"
        VALIDATION_FAILED=1
        cd - > /dev/null
        continue
    fi
    
    # Validate
    if terraform validate > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Validation successful${NC}"
    else
        echo -e "${RED}❌ Validation failed${NC}"
        terraform validate
        VALIDATION_FAILED=1
    fi
    
    echo ""
    cd - > /dev/null
done

echo "========================================="
if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validations failed!${NC}"
    exit 1
fi

