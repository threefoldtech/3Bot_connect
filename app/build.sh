#!/bin/bash

gituser=$(git config user.name)
gitbranch=$(git rev-parse --abbrev-ref HEAD)
githash=$(git log --pretty=format:'%h' -n 1)
logcurrent_time=$(date "+%H:%M:%S %d.%m.%Y")
current_time=$(date "+%H.%M.%S-%d.%m.%Y")

compileAndUpload() {
    if [[ $2 == "--$5" ]]
    then
        switchConfigs "$5"

        if [[ $1 == "--run" ]]
        then
            echo "[$5]: Running."
            flutter run -t lib/main.dart
        elif [[ $1 == "--switch" ]]
        then
            echo "[$5]: Switched configs."
        else
            echo "[$5]: Building apk."

            setConfigsAndBuild
            msgTelegram "$5" $4
        fi

        exit 0
    fi
}

switchConfigs() {
    cp android/app/src/main/AndroidManifest_$1 android/app/src/main/AndroidManifest.xml
    cp android/app/src/main/AndroidManifest_$1 android/app/src/debug/AndroidManifest.xml
    cp android/app/build_$1 android/app/build.gradle
    cp lib/helpers/env_config_$1.template lib/helpers/env_config.dart
    cp android/app/src/main/kotlin/org/jimber/threebotlogin/MainActivity_$1 android/app/src/main/kotlin/org/jimber/threebotlogin/MainActivity.kt 

    cp android/app/src/main/res/mipmap-hdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-mdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_$1.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    # cp android/app/google-services_$1 android/app/google-services.json
    # cp ios/Runner/GoogleService-Info_$1 ios/Runner/GoogleService-Info.plist
}

setConfigsAndBuild() {
    sed -i -e "s/githashvalue/$githash/g" lib/helpers/env_config.dart
    sed -i -e "s/timevalue/$logcurrent_time/g" lib/helpers/env_config.dart

    flutter build apk -t lib/main.dart -v --target-platform android-arm,android-arm64 --release
}

msgTelegram () {
    mv build/app/outputs/apk/release/app-release.apk "build/app/outputs/apk/release/$githash-TF-Connect-$1-$current_time.apk"
    
    curl --http1.1 -s -X POST "https://api.telegram.org/bot868129294:AAEd-UDDSru9zGeGklzWL6mPO33NovuXYqo/sendMessage" -d parse_mode=markdown -d chat_id=-1001186043363 -d parse_mode=markdown -d text="Type: *$1* %0AGit user: *$gituser* %0AGit branch: *$gitbranch* %0AGit hash: *$githash* %0ATime: *$logcurrent_time* %0AMessage: *$2*"
    curl --http1.1 -s -X POST "https://api.telegram.org/bot868129294:AAEd-UDDSru9zGeGklzWL6mPO33NovuXYqo/sendDocument" -F chat_id=-1001186043363 -F document="@build/app/outputs/apk/release/$githash-TF-Connect-$1-$current_time.apk"
    
    paplay /usr/share/sounds/gnome/default/alerts/glass.ogg
}

generateFile () {
    if ! test -f "$1"; then
        echo "$1 doesn't exist, generating ..."
        cp $2 $1
     else
        echo "$1 already exists."
    fi
}

if [[ $1 == "--help" ]]
then
    echo "Usage: ./build.sh --[run|build|switch] --[local|testing|staging|production]"
    echo "Usage: ./build.sh --init"
    exit 1
fi

if [[ $1 == "--init" ]]
then
    AndroidManifestMainPath=android/app/src/main/AndroidManifest.xml
    AndroidManifestDebugPath=android/app/src/debug/AndroidManifest.xml

    env_configFilePath=lib/helpers/env_config.dart
    AppConfigLocalFilePath=lib/app_config_local.dart

    BuildGradlePath=android/app/build.gradle

    LauncherImgPath1=android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    LauncherImgPath2=android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    LauncherImgPath3=android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    LauncherImgPath4=android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    LauncherImgPath5=android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

    generateFile $env_configFilePath lib/helpers/env_config_local.template
    generateFile $AppConfigLocalFilePath lib/app_config_local.template

    generateFile $BuildGradlePath android/app/build_local
    
    generateFile $LauncherImgPath1 android/app/src/main/res/mipmap-hdpi/ic_launcher_local.png
    generateFile $LauncherImgPath2 android/app/src/main/res/mipmap-mdpi/ic_launcher_local.png
    generateFile $LauncherImgPath3 android/app/src/main/res/mipmap-xhdpi/ic_launcher_local.png
    generateFile $LauncherImgPath4 android/app/src/main/res/mipmap-xxhdpi/ic_launcher_local.png
    generateFile $LauncherImgPath5 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_local.png

    mkdir android/app/src/debug
    generateFile $AndroidManifestMainPath android/app/src/main/AndroidManifest_local
    generateFile $AndroidManifestDebugPath android/app/src/main/AndroidManifest_local

    exit 0
fi

compileAndUpload "$1" "$2" "$3" "$4" "local"
compileAndUpload "$1" "$2" "$3" "$4" "testing"
compileAndUpload "$1" "$2" "$3" "$4" "staging"
compileAndUpload "$1" "$2" "$3" "$4" "production"

echo "Syntax error."
echo "Usage: ./build.sh --[[run|build|switch]] --[[local|testing|staging|production]]"
echo "Usage: ./build.sh --init"
exit 1
