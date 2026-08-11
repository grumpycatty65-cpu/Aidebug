#!/bin/bash
set -e

echo "===================================="
echo "1/4: Устанавливаем Android SDK"
echo "===================================="
export ANDROID_HOME=$HOME/android-sdk
mkdir -p "$ANDROID_HOME/cmdline-tools"
cd "$ANDROID_HOME/cmdline-tools"
if [ ! -d "latest" ]; then
  curl -sL -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
  unzip -q cmdline-tools.zip
  mv cmdline-tools latest
  rm cmdline-tools.zip
fi

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

echo "===================================="
echo "2/4: Устанавливаем Gradle"
echo "===================================="
if ! command -v gradle &> /dev/null; then
  curl -s "https://get.sdkman.io" | bash
  set +u
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  set -u
  yes | sdk install gradle 7.6.1
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

echo "===================================="
echo "3/4: Готовим проект"
echo "===================================="
cd /workspace/*/ 2>/dev/null || cd "$(dirname "$0")"
gradle wrapper --gradle-version 7.6.1
chmod +x gradlew

echo "===================================="
echo "4/4: Собираем APK (это займёт несколько минут)"
echo "===================================="
./gradlew assembleDebug --stacktrace

echo ""
echo "===================================="
echo "ГОТОВО! Ваш APK находится тут:"
find . -name "*.apk"
echo "===================================="
