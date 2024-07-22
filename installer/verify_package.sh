#!/bin/bash

echo "Verifying package content..."
pkgutil --payload-files DuplicateFileUpdater.pkg

echo "\nChecking package info..."
pkgutil --check-signature DuplicateFileUpdater.pkg

echo "\nDisplaying package info..."
pkgutil --info DuplicateFileUpdater.pkg