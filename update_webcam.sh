#!/bin/bash

LOCK=/tmp/webcam.lock

if [ -f "$LOCK" ]; then
  echo "Script già in esecuzione, esco."
  exit 0
fi

touch "$LOCK"
trap "rm -f $LOCK" EXIT

cd /opt/webcamlivepontebernardo || exit 1

echo "Scarico immagine..."

ffmpeg -y -rtsp_transport tcp \
-i 'rtsp://admin:Martini87!@192.168.1.119:554/h264Preview_01_main' \
-frames:v 1 -q:v 2 -update 1 webcam.jpg

echo "Applico scritta..."

convert webcam.jpg \
  -gravity northwest \
  -font DejaVu-Sans \
  -pointsize 65 \
  -fill "rgba(200,0,0,0.65)" \
  -stroke "rgba(0,0,0,0.75)" \
  -strokewidth 2 \
  -annotate +20+80 "L'Abri Campanello" \
  webcam.jpg

echo "Push su GitHub..."

git add webcam.jpg CNAME index.html robots.txt .gitignore

git commit --amend -m "Aggiorna webcam" --no-gpg-sign
git push --force origin main

git reflog expire --expire=now --all
git gc --prune=now

echo "Fatto!"
