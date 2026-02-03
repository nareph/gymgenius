#!/bin/bash

# GymGenius - Production Build Script with Gemini AI
# This script builds a production APK with Gemini AI enabled

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    GymGenius Production Build${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if API key is defined
if [ -z "$GEMINI_API_KEY_PRODUCTION" ]; then
    echo -e "${RED}❌ ERROR: GEMINI_API_KEY_PRODUCTION is not defined${NC}"
    echo ""
    echo -e "${YELLOW}📝 To fix this:${NC}"
    echo -e "${YELLOW}   1. Get API key from:"
    echo -e "      https://aistudio.google.com/app/apikey${NC}"
    echo -e "${YELLOW}   2. Export it:${NC}"
    echo -e "      export GEMINI_API_KEY_PRODUCTION=your_api_key${NC}"
    echo ""
    echo -e "${YELLOW}   Or add to your shell profile (~/.bashrc, ~/.zshrc):${NC}"
    echo -e "      echo 'export GEMINI_API_KEY_PRODUCTION=your_key' >> ~/.bashrc${NC}"
    echo ""
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ ERROR: Flutter is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Install Flutter from:"
    echo -e "https://flutter.dev/docs/get-started/install${NC}"
    exit 1
fi

# Show Flutter version
echo -e "${BLUE}📱 Flutter version:${NC}"
flutter --version | head -n 1
echo ""

# Confirm build
echo -e "${YELLOW}⚠️  This will build a PRODUCTION APK with:${NC}"
echo -e "   • Environment: production"
echo -e "   • AI Mode: Gemini AI (enabled)"
echo -e "   • Model: gemini-3-flash-preview"
echo -e "   • Split APKs: Yes (arm64-v8a, armeabi-v7a, x86_64)"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Build cancelled${NC}"
    exit 0
fi

echo -e "${BLUE}🧹 Cleaning project...${NC}"
flutter clean

echo -e "${BLUE}🔄 Getting dependencies...${NC}"
flutter pub get

echo -e "${BLUE}⚡ Building production APK...${NC}"
echo -e "${BLUE}   This may take 3-5 minutes...${NC}"
echo ""

# Build with error handling
if flutter build apk --split-per-abi \
    --release \
    --dart-define=ENVIRONMENT=production \
    --dart-define=USE_REAL_AI=true \
    --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY_PRODUCTION \
    --obfuscate \
    --split-debug-info=build/app/outputs/symbols; then
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Production build completed successfully!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""

    # Show generated files
    echo -e "${BLUE}📦 Generated APKs:${NC}"
    echo ""

    APK_DIR="build/app/outputs/flutter-apk"

    for apk in "$APK_DIR"/*.apk; do
        if [ -f "$apk" ]; then
            filename=$(basename "$apk")
            size=$(ls -lh "$apk" | awk '{print $5}')
            echo -e "   ${GREEN}✓${NC} $filename ${BLUE}($size)${NC}"
        fi
    done

    echo ""

    # Calculate total size (compatible with both Linux and macOS)
    if command -v stat &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            TOTAL_SIZE=$(find "$APK_DIR" -name "*.apk" -exec stat -f%z {} \; | awk '{s+=$1} END {print s}')
        else
            # Linux
            TOTAL_SIZE=$(find "$APK_DIR" -name "*.apk" -exec stat -c%s {} \; | awk '{s+=$1} END {print s}')
        fi
        TOTAL_MB=$(echo "scale=2; $TOTAL_SIZE/1024/1024" | bc)
        echo -e "${BLUE}📊 Total size: ${TOTAL_MB} MB${NC}"
    fi

    echo ""
    echo -e "${BLUE}📍 Location: $APK_DIR${NC}"
    echo ""

    # Recommendations
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo -e "   1. Test APK on physical device"
    echo -e "   2. Upload to Google Play Console"
    echo -e "   3. Keep debug symbols: build/app/outputs/symbols"
    echo ""
    echo -e "${GREEN}Recommended APK for upload:${NC}"
    echo -e "   ${GREEN}app-arm64-v8a-release.apk${NC} (most modern devices)"
    echo ""

    exit 0
else
    echo ""
    echo -e "${RED}════════════════════════════════════════════${NC}"
    echo -e "${RED}❌ Build failed!${NC}"
    echo -e "${RED}════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "   • Check Flutter version (3.19+)"
    echo -e "   • Run 'flutter doctor' to check setup"
    echo -e "   • Verify GEMINI_API_KEY_PRODUCTION is valid"
    echo -e "   • Check internet connection"
    echo ""
    exit 1
fi