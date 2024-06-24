#!/bin/bash

# This script updates the iOS and Android icons using the flutter_icons package
# Ensure you have added the necessary configuration in pubspec.yaml

# Run flutter packages get to ensure all dependencies are installed
flutter packages get

# Run the flutter_icons generator
flutter pub run flutter_launcher_icons:main
