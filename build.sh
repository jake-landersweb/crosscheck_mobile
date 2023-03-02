#!/bin/bash

shaderFile="./shader_master.json"

# build ios
flutter build ipa --enable-impeller --bundle-sksl-path $shaderFile

# build android
flutter build appbundle --bundle-sksl-path $shaderFile
