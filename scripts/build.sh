#!/usr/bin/env bash
set -euo pipefail

echo "Building Lambda package..."

rm -rf dist
mkdir -p dist

# Copiar apenas src, package.json e package-lock
cp -r src dist/
cp package.json dist/
cp package-lock.json dist/

# Instalar deps de produção
cd dist
npm ci --production --silent

# Zippar
zip -qr ../lambda.zip .
cd ..

echo "Package created: lambda.zip ($(du -h lambda.zip | cut -f1))"
