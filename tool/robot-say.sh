#!/bin/bash
# Renders a line of text as a friendly robot voice.
# Pipeline: macOS `say` -> ffmpeg (higher pitch, short metallic echo, chorus)
# -> HE-AAC in .m4a, which plays natively on both Android and iOS.
#
# Requires macOS with the "Ewa (Premium)" and "Krzysztof (Enhanced)" Polish
# voices installed (System Settings -> Accessibility -> Spoken Content), and ffmpeg.
#
# Usage: tool/robot-say.sh ewa|krzysztof "Text to speak" output.m4a
# Optional env: PITCH=1.30 (voice pitch factor), BITRATE=16000 (bits per second)
set -euo pipefail

usage() {
  echo "Usage: $0 ewa|krzysztof \"text\" output.m4a" >&2
  exit 1
}

[ $# -eq 3 ] || usage
case "$1" in
  ewa)       VOICE="Ewa (Premium)";        RATE=135 ;;
  krzysztof) VOICE="Krzysztof (Enhanced)"; RATE=115 ;;
  *) usage ;;
esac
TEXT="$2"
OUT="$3"
PITCH="${PITCH:-1.30}"
BITRATE="${BITRATE:-16000}"

TMP="$(mktemp -d -t robot)"
trap 'rm -rf "$TMP"' EXIT

say -v "$VOICE" -r "$RATE" -o "$TMP/raw.wav" --data-format=LEI16@44100 "$TEXT"
ffmpeg -nostdin -y -loglevel error -i "$TMP/raw.wav" -af \
"asetrate=44100*$PITCH,atempo=1/$PITCH,aresample=44100,aecho=0.8:0.7:9|18:0.5|0.3,chorus=0.6:0.9:25:0.4:0.25:2,highpass=f=150,loudnorm" \
-ar 44100 "$TMP/fx.wav"
afconvert -f m4af -d aach -b "$BITRATE" "$TMP/fx.wav" "$OUT"
