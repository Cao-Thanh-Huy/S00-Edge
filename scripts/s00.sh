#!/bin/sh
# S00-Edge — giải mã / đóng gói / nhật ký thử nghiệm. Mã hóa bằng age cho mọi khóa công khai trong keys/recipients.txt.
#   sh scripts/s00.sh unpack <file.tar.age> [thư_mục_ra]   giải mã + bung (mặc định ./_giai_ma/)
#   sh scripts/s00.sh unpack-all                            bung bản phát hành mới nhất + gói nghiên cứu + toàn bộ nhật ký
#   sh scripts/s00.sh pack <nguồn> <ra.tar.age> [tên]     đóng gói + mã hóa (tự bỏ .env, __pycache__, *.pkl)
#   sh scripts/s00.sh log-new <file.md> <ĐẠT|BÁC|GHI CHÚ> <người>   mã hóa 1 thử nghiệm -> nhat_ky/NNNN.age + thêm dòng vào README
#   sh scripts/s00.sh log-list                              giải mã & in toàn bộ nhật ký
#   sh scripts/s00.sh scan <thư_mục>...                     quét chuỗi bí mật trước khi pack · verify: kiểm SHA-256
# Khóa bí mật: $S00_AGE_KEY hoặc ~/.s00/age_key.txt (KHÔNG BAO GIỜ đưa vào repo).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REC="$ROOT/keys/recipients.txt"
KEY="${S00_AGE_KEY:-$HOME/.s00/age_key.txt}"
AGE="${AGE:-age}"
OUT_DEFAULT="$ROOT/_giai_ma"

need_age() {
  command -v "$AGE" >/dev/null 2>&1 && return
  la="$(cygpath -u "$LOCALAPPDATA" 2>/dev/null || echo "$LOCALAPPDATA")"   # Git Bash: C:\... -> /c/...
  w="$(ls -d "$la"/Microsoft/WinGet/Packages/FiloSottile.age_*/age/age.exe 2>/dev/null | head -1)"
  [ -n "$w" ] && AGE="$w" && return
  echo "Chưa cài age (https://age-encryption.org): winget install FiloSottile.age | brew install age | apt install age" >&2
  exit 1
}

sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }

sums() {  # cập nhật SHA256SUMS của thư mục chứa file .age
  (cd "$1" && sha *.age > SHA256SUMS)
}

decrypt() { "$AGE" -d -i "$KEY" "$1"; }

case "$1" in
  unpack)
    need_age
    [ -f "$2" ] || { echo "Không thấy file: $2" >&2; exit 1; }
    out="${3:-$OUT_DEFAULT}"
    mkdir -p "$out"
    decrypt "$2" | tar -xzf - -C "$out"
    echo "== Đã bung $2 -> $out"
    ;;
  unpack-all)
    need_age
    rel="$(ls "$ROOT"/releases/*/*.tar.age 2>/dev/null | sort -V | tail -1)"
    res="$(ls "$ROOT"/research/*.tar.age 2>/dev/null | sort | tail -1)"
    for f in $rel $res; do sh "$0" unpack "$f"; done
    mkdir -p "$OUT_DEFAULT/nhat_ky"
    for f in "$ROOT"/nhat_ky/*.age; do decrypt "$f" > "$OUT_DEFAULT/nhat_ky/$(basename "$f" .age).md"; done
    echo "== Nhật ký: $OUT_DEFAULT/nhat_ky/ — ĐỌC 0001.md TRƯỚC khi thử bất cứ gì"
    ;;
  pack)
    need_age
    src="$2"; dst="$3"; name="$4"   # name: đổi tên thư mục gốc trong gói (cần GNU tar)
    [ -d "$src" ] && [ -n "$dst" ] || { echo "Cú pháp: pack <thư_mục_nguồn> <file_ra.tar.age> [tên_trong_gói]" >&2; exit 1; }
    set -- ${name:+--transform=s#^$(basename "$src")#$name#}
    if find "$src" -name ".env*" ! -name ".env.example" | grep -q .; then
      echo "CẢNH BÁO: có file .env trong $src — sẽ bị bỏ qua khi đóng gói" >&2
    fi
    mkdir -p "$(dirname "$dst")" "$OUT_DEFAULT"
    tmp="$OUT_DEFAULT/.pack_$$.tar.gz"
    man="$OUT_DEFAULT/manifest_$(basename "$dst" .tar.age).txt"   # danh sách file bản gốc (thư mục không bao giờ commit)
    tar -czf "$tmp" --exclude=".env" --exclude=".env.*" --exclude="__pycache__" --exclude="*.pkl" --exclude="*.pyc" "$@" \
      -C "$(dirname "$src")" "$(basename "$src")"
    { echo "# sha256 tar.gz gốc: $(sha "$tmp" | cut -d' ' -f1)"; tar -tzf "$tmp"; } > "$man"
    "$AGE" -R "$REC" -o "$dst" "$tmp"
    rm -f "$tmp"
    sums "$(dirname "$dst")"
    echo "== $dst ($(wc -c < "$dst") byte, $(($(wc -l < "$man") - 1)) mục) — danh sách: $man"
    ;;
  log-new)
    need_age
    src="$2"; verdict="$3"; who="$4"
    [ -f "$src" ] && [ -n "$verdict" ] && [ -n "$who" ] || { echo "Cú pháp: log-new <file.md> <ĐẠT|BÁC|GHI CHÚ> <người>" >&2; exit 1; }
    last="$(ls "$ROOT"/nhat_ky/*.age 2>/dev/null | sed 's#.*/##; s#\.age##' | sort -n | tail -1)"
    n="$(printf '%04d' $(( ${last:-0} + 1 )))"
    "$AGE" -R "$REC" -o "$ROOT/nhat_ky/$n.age" "$src"
    sums "$ROOT/nhat_ky"
    printf '| %s | %s | %s | %s |\n' "$n" "$(date +%Y-%m-%d)" "$who" "$verdict" >> "$ROOT/README.md"
    echo "== nhat_ky/$n.age + 1 dòng README. Nhớ commit cả hai."
    ;;
  log-list)
    need_age
    for f in "$ROOT"/nhat_ky/*.age; do
      echo "################ $(basename "$f" .age) ################"
      decrypt "$f"
      echo
    done
    ;;
  scan)  # quét thư mục nguồn TRƯỚC khi pack: chuỗi giống token Telegram / khóa bí mật — chỉ in tên file
    shift
    hits="$(grep -rIlE --exclude-dir=__pycache__ --exclude-dir=.git --exclude='.env' --exclude='.env.*' \
      '\b[0-9]{8,10}:[A-Za-z0-9_-]{35}\b|AGE-SECRET-KEY-1|-----BEGIN [A-Z ]*PRIVATE KEY' "$@" || true)"
    if [ -n "$hits" ]; then echo "NGHI CÓ BÍ MẬT — xem và gỡ trước khi đóng gói:"; echo "$hits"; exit 1; fi
    echo "== Không thấy chuỗi bí mật trong: $*"
    ;;
  verify)
    for d in "$ROOT"/releases/* "$ROOT"/research "$ROOT"/nhat_ky; do
      [ -f "$d/SHA256SUMS" ] && (cd "$d" && sha -c SHA256SUMS)
    done
    ;;
  *)
    sed -n '2,9p' "$0"
    exit 1
    ;;
esac
