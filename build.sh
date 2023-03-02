#!/bin/bash

shaderFile="./shader_master.json"

# build ios
# flutter build ipa --bundle-sksl-path $shaderFile
flutter build ipa

# build android
# flutter build appbundle --bundle-sksl-path $shaderFile
flutter build appbundle 
