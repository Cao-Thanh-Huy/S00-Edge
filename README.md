# S00-Edge

Kho phát hành **đã mã hóa** của S00 EdgeCore. Repo công khai, nhưng mọi nội dung (code, preset, báo cáo, nghiên cứu, nhật ký)
chỉ nằm trong file `*.age`, mã hóa bằng [age](https://age-encryption.org) cho từng người có khóa trong `keys/recipients.txt`.
Không có mật khẩu chung. Quy tắc làm việc: [`AGENTS.md`](AGENTS.md) · Bảo mật & khóa: [`SECURITY.md`](SECURITY.md).

## Cấu trúc

```
releases/vX.Y/   s00_vXY_<ngày>.tar.age + SHA256SUMS   bản phát hành (python/, mt5/, presets, báo cáo) — không ghi đè tên cũ
research/        s00_research_<ngày>.tar.age           toàn bộ script + kết quả nghiên cứu (không kèm dữ liệu giá)
nhat_ky/         NNNN.age                              MỖI thử nghiệm 1 file — đọc trước khi thử bất cứ gì
keys/            recipients.txt                        khóa công khai được đọc
scripts/s00.sh                                         giải mã / đóng gói / nhật ký / kiểm checksum
```

Dữ liệu giá (không mã hóa, ~500 MB) nằm ở GitHub Release **`data-20261101`** (kèm đặc tả chi tiết `DATA_MT5_XM_README.md`), không nằm trong lịch sử git:
- `python_csv_data.zip` (`49.8 MB`): 17 file CSV (`data/intraday/` + `data/long/`) xuất trực tiếp từ MT5 `XMGlobal-MT5 20` (giờ UTC, kèm spread thật trên từng nến):
  - **Vàng (`XAUUSD` / `GOLDmicro`)**: D1 từ **`2011-01-02`** (`4,079` nến) · Intraday (`M5`, `M15`, `H1`) từ **`2013-05-09`** (`880,199` nến M5 — 13.5 năm).
  - **Yên Nhật (`USDJPY` / `USDJPYmicro`)**: D1 từ **`2011-01-02`** (`4,140` nến) · Intraday (`H1`) từ **`2013-05-16`** (`83,877` nến H1 — 13.5 năm).
  - **S&P 500 (`US500` / `US500Cash`)**: D1 từ **`2011-08-07`** (`4,079` nến) · Intraday (`H1`) từ **`2016-05-26`** (`62,621` nến H1 — 10.5 năm).
  - **Nasdaq 100 (`USTEC` / `US100Cash`)**: D1 từ **`2011-09-18`** (`4,045` nến) · Intraday (`H1`) từ **`2016-05-26`** (`62,563` nến H1 — 10.5 năm).
  - **Bitcoin (`BTCUSD`)**: D1 từ **`2013-01-01`** (`3,966` nến) · Intraday (`M5`, `M15`, `H1`) từ **`2016-12-13`** (`835,805` nến M5 — 10 năm).
  - **Ethereum (`ETHUSD`)**: D1 từ **`2016-11-07`** (`3,178` nến) · Intraday (`M15`, `H1`) từ **`2016-12-05`** (`285,998` nến M15 — 10 năm).
- 6 gói `mt5_xm_<SYMBOL>.zip`: Toàn bộ file `.hcc` gốc (`2010–2026`) của máy chủ `XMGlobal-MT5 20`.

## Bắt đầu (máy mới)

```bash
# 1) cài age:  Windows: winget install FiloSottile.age | macOS: brew install age | Linux: apt install age
# 2) đặt khóa bí mật của bạn ở ~/.s00/age_key.txt  (hoặc đặt biến S00_AGE_KEY trỏ tới file khóa)
git clone https://github.com/Cao-Thanh-Huy/S00-Edge.git && cd S00-Edge
sh scripts/s00.sh verify        # kiểm SHA-256 mọi file .age
sh scripts/s00.sh unpack-all    # bung bản mới nhất + gói nghiên cứu + nhật ký vào ./_giai_ma/ (không bao giờ bị commit)
# 3) dữ liệu giá cho backtest Python (+ lịch sử MT5 XM nếu cần)
curl -fLO https://github.com/Cao-Thanh-Huy/S00-Edge/releases/download/data-20261101/install_data.sh
sh install_data.sh ./_giai_ma/S00_EdgeCore_v51_XM "<thư mục bases/XMGlobal-MT5 20>"
```

Chưa có khóa? Tạo bằng `age-keygen -o ~/.s00/age_key.txt` rồi gửi chủ repo dòng `Public key: age1...` (xem `SECURITY.md`).

## Bản phát hành

| Bản | File | Ghi chú công khai |
|---|---|---|
| v5.1 | `releases/v5.1/s00_v51_20261101.tar.age` | Bản hiện hành — dùng preset ghi trong nhật ký 0003 |
| v5.0 | `releases/v5.0/s00_v50_20261030.tar.age` | Bản trước, để đối chiếu |

## Quy tắc nhật ký (bắt buộc)

1. Trước khi thử: `sh scripts/s00.sh unpack-all` rồi đọc `_giai_ma/nhat_ky/` (bắt đầu từ `0001.md`). Đã thử rồi thì không chạy lại.
2. Sau MỌI lần thử, kể cả thất bại: `sh scripts/s00.sh log-new <file.md> <ĐẠT|BÁC|GHI CHÚ> <người>` → thêm `nhat_ky/NNNN.age`
   và 1 dòng vào bảng dưới. Commit cả hai.
3. Bảng dưới chỉ ghi số / ngày / người / kết luận — KHÔNG ghi tên chân, tham số hay số liệu (repo công khai).

## Nhật ký thử nghiệm

| # | Ngày | Người | Kết luận |
|---|---|---|---|
| 0001 | 2026-11-01 | Claude | GHI CHÚ — tổng hợp mọi giả thuyết v4.4 → v5.1 |
| 0002 | 2026-11-01 | Huy | GHI CHÚ — nhật ký v5.0 → v5.1 (có đính chính) |
| 0003 | 2026-11-01 | Claude | ĐẠT — đánh giá độc lập v5.1, chọn preset |
| 0004 | 2026-11-01 | Claude | GHI CHÚ — kiểm bộ dữ liệu XM xuất từ MT5 (đạt múi giờ/giá; 4 lỗi cần sửa) |
