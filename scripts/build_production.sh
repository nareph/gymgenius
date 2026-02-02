#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Building production APK...${NC}"

# Check if API key is defined
if [ -z "$GEMINI_API_KEY_PRODUCTION" ]; then
  echo -e "${RED}❌ ERROR: GEMINI_API_KEY_PRODUCTION is not defined${NC}"
  echo -e "${YELLOW}Export it with: export GEMINI_API_KEY_PRODUCTION=your_api_key${NC}"
  echo -e "${YELLOW}Or set it in your shell profile (.bashrc, .zshrc, etc.)${NC}"
  exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ ERROR: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Cleaning project...${NC}"
flutter clean

echo -e "${BLUE}🔄 Getting dependencies...${NC}"
flutter pub get

echo -e "${BLUE}⚡ Building production APK with split ABI...${NC}"

# Build with error handling
if flutter build apk --split-per-abi \
  --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=USE_REAL_AI=true \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY_PRODUCTION; then
  
  echo -e "${GREEN}✅ Production build completed successfully!${NC}"
  echo -e "${GREEN}📦 APKs generated in: build/app/outputs/flutter-apk/${NC}"
  
  # Show generated files
  echo -e "${BLUE}📋 Generated files:${NC}"
  ls -la build/app/outputs/flutter-apk/ | grep "\.apk$"
  
  # Calculate total size
  TOTAL_SIZE=$(find build/app/outputs/flutter-apk/ -name "*.apk" -exec stat -f%z {} \; | awk '{s+=$1} END {print s}')
  echo -e "${BLUE}📊 Total APK size: $(echo "scale=2; $TOTAL_SIZE/1024/1024" | bc) MB${NC}"
  
  exit 0
else
  echo -e "${RED}❌ Build failed!${NC}"
  exit 1
fi