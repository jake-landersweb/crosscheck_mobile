#!/bin/bash

flutter build ipa
flutter build appbundle --android-skip-build-dependency-validation
