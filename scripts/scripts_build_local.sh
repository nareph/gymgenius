#!/bin/bash
GymGenius - Local AI Build Script
This script builds a production APK with LOCAL AI (no Gemini, 100% offline)
Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
echo -e "BLUE════════════════════════════════════════════{BLUE}════════════════════════════════════════════
BLUE════════════════════════════════════════════{NC}"
echo -e "BLUEGymGeniusLocalAIBuild{BLUE}  GymGenius Local AI Build
BLUEGymGeniusLocalAIBuild{NC}"
echo -e "BLUE════════════════════════════════════════════{BLUE}════════════════════════════════════════════
BLUE════════════════════════════════════════════{NC}"
echo ""

Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "RED❌ERROR:FlutterisnotinstalledornotinPATH{RED}❌ ERROR: Flutter is not installed or not in PATH
RED❌ERROR:FlutterisnotinstalledornotinPATH{NC}"
    echo -e "${YELLOW}Install Flutter from:
https://flutter.dev/docs/get-started/install${NC}"
exit 1
fi
Show Flutter version
echo -e "BLUE📱Flutterversion:{BLUE}📱 Flutter version:
BLUE📱Flutterversion:{NC}"
flutter --version | head -n 1
echo ""

Confirm build
echo -e "YELLOWℹ®ThiswillbuildaLOCALAIAPKwith:{YELLOW}ℹ️  This will build a LOCAL AI APK with:
YELLOWℹR◯ThiswillbuildaLOCALAIAPKwith:{NC}"
echo -e "   • Environment: production"
echo -e "   • AI Mode: Local (100% offline)"
echo -e "   • Privacy: Complete (no cloud calls)"
echo -e "   • Split APKs: Yes (arm64-v8a, armeabi-v7a, x86_64)"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! REPLY= [Yy]REPLY =~ ^[Yy]
REPLY= [Yy] ]]; then
    echo -e "YELLOWBuildcancelled{YELLOW}Build cancelled
YELLOWBuildcancelled{NC}"
    exit 0
fi

echo -e "BLUE🧹Cleaningproject...{BLUE}🧹 Cleaning project...
BLUE🧹Cleaningproject...{NC}"
flutter clean

echo -e "BLUE🔄Gettingdependencies...{BLUE}🔄 Getting dependencies...
BLUE🔄Gettingdependencies...{NC}"
flutter pub get

echo -e "BLUE⚡BuildingproductionAPK(LocalAI)...{BLUE}⚡ Building production APK (Local AI)...
BLUE⚡BuildingproductionAPK(LocalAI)...{NC}"
echo -e "BLUEThismaytake3−5minutes...{BLUE}   This may take 3-5 minutes...
BLUEThismaytake3−5minutes...{NC}"
echo ""

Build with LOCAL AI (no Gemini)
if flutter build apk --split-per-abi 
--release 
--dart-define=ENVIRONMENT=production 
--dart-define=USE_REAL_AI=false 
--obfuscate 
--split-debug-info=build/app/outputs/symbols; then
echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Local AI build completed successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""

# Show generated files
echo -e "${BLUE}📦 Generated APKs:${NC}"
echo ""

APK_DIR="build/app/outputs/flutter-apk"

for apk in $APK_DIR/*.apk; do
    if [ -f "$apk" ]; then
        filename=$(basename "$apk")
        size=$(ls -lh "$apk" | awk '{print $5}')
        echo -e "   ${GREEN}✓${NC} $filename ${BLUE}($size)${NC}"
    fi
done

echo ""

# Calculate total size
if command -v stat &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        TOTAL_SIZE=$(find $APK_DIR -name "*.apk" -exec stat -f%z {} \; | awk '{s+=$1} END {print s}')
    else
        TOTAL_SIZE=$(find $APK_DIR -name "*.apk" -exec stat -c%s {} \; | awk '{s+=$1} END {print s}')
    fi
    TOTAL_MB=$(echo "scale=2; $TOTAL_SIZE/1024/1024" | bc)
    echo -e "${BLUE}📊 Total size: ${TOTAL_MB} MB${NC}"
fi

echo ""
echo -e "${BLUE}📍 Location: $APK_DIR${NC}"
echo ""

# Features
echo -e "${GREEN}✨ This build includes:${NC}"
echo -e "   ✓ 100% offline functionality"
echo -e "   ✓ Complete privacy (no cloud calls)"
echo -e "   ✓ Instant routine generation (<200ms)"
echo -e "   ✓ No API keys needed"
echo -e "   ✓ Local Hive database"
echo ""

# Recommendations
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "   1. Test APK on physical device"
echo -e "   2. Verify offline functionality"
echo -e "   3. Test routine generation"
echo ""
echo -e "${GREEN}Recommended APK:${NC}"
echo -e "   ${GREEN}app-arm64-v8a-release.apk${NC} (64-bit devices)"
echo ""

exit 0

else
    echo ""
    echo -e "RED════════════════════════════════════════════{RED}════════════════════════════════════════════
RED════════════════════════════════════════════{NC}"
    echo -e "RED❌Buildfailed!{RED}❌ Build failed!
RED❌Buildfailed!{NC}"
    echo -e "RED════════════════════════════════════════════{RED}════════════════════════════════════════════
RED════════════════════════════════════════════{NC}"
    echo ""
    exit 1
fi
