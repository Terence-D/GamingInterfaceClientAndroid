#!/bin/bash
echo "Choose your option"
echo "  1) Build for Google Play"
echo "  2) Build for Other"
echo "  3) Run Google Play version"
echo "  4) Run Other version" 

read n
case $n in
  1) flutter build appbundle -v -t lib/main_gplay.dart --flavor gplay;;
  2) flutter build apk --split-per-abi -t lib/main_other.dart --flavor other --target-platform android-arm;;
  3) flutter run --flavor gplay -v -t lib/main_gplay.dart;;
  4) flutter run --flavor other -v -t lib/main_other.dart --target-platform android-arm;;
  *) echo "invalid option";;
esac