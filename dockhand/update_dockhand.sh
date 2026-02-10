#!/bin/bash

CONTAINER_NAME="dockhand"
IMAGE_NAME="fnsys/dockhand:latest"

echo "Checking for updates..."

# Pull and capture the status message
PULL_RESULT=$(docker pull $IMAGE_NAME)

# Check if the image was already current
if echo "$PULL_RESULT" | grep -q "Image is up to date"; then
    echo "Success: $IMAGE_NAME is already the latest version. No update needed."
    exit 0
fi

echo "New version found! Proceeding with update..."

echo "Step 1: Stopping and removing old container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Step 2: Starting updated container..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v dockhand_data:/app/data \
  $IMAGE_NAME

echo "Step 3: Cleaning up old image versions..."
# Removes previous versions of this specific image name only
docker image rm $(docker images -q fnsys/dockhand | sed -n '2,10p') 2>/dev/null || true

echo "Update complete. Dockhand is now running the latest version."
