# S00-Edge

Kho phát hành **đã mã hóa** của S00 EdgeCore. Repo công khai, nhưng mọi nội dung (code, preset, báo cáo, nghiên cứu, nhật ký)
chỉ nằm trong file `*.age`, mã hóa bằng [age](https://age-encryption.org) cho từng người có khóa trong `keys/recipients.txt`.
Không có mật khẩu chung. Quy tắc làm việc: [`AGENTS.md`](AGENTS.md) · Bảo mật & khóa: [`SECURITY.md`](SECURITY.md) · Quy trình kiểm định: [`QUY_TRINH_KIEM_DINH.md`](QUY_TRINH_KIEM_DINH.md).

## Cấu trúc

```
releases/vX.Y/   s00_vXY_<ngày>.tar.age + SHA256SUMS   bản phát hành (python/, mt5/, presets, báo cáo) — không ghi đè tên cũ
research/        s00_research_<ngày>.tar.age           toàn bộ script + kết quả nghiên cứu (không kèm dữ liệu giá)
nhat_ky/         NNNN.age                              MỖI thử nghiệm 1 file — đọc trước khi thử bất cứ gì
keys/            recipients.txt                        khóa công khai được đọc
scripts/s00.sh                                         giải mã / đóng gói / nhật ký / kiểm checksum
```

Dữ liệu giá (không mã hóa, ~550 MB) nằm ở GitHub Release **`data-20261101`** (kèm đặc tả chi tiết `DATA_MT5_XM_README.md`), không nằm trong lịch sử git.
`install_data.sh` tải đủ, kiểm `SHA256SUMS` rồi bung. **Chọn đúng bộ cho đúng việc:**

| Gói | Thư mục | Dùng để |
|---|---|---|
| **`s00_data_xm_20261021.zip`** (48.5 MB) — **BỘ CHUẨN** | `data/xm_20261021/` | So Python ↔ MT5, và giữa các máy. Cùng nến MT5 XM dùng, đã làm sạch. Dấu vân tay `21bf2452159ac879` (`python du_lieu_chuan.py kiem <thư mục>`). Chạy `--data ../data/xm_20261021`, **không** thêm `--xm` (spread đã là spread thật). |
| `s00_data_python_full_20261101.zip` (92 MB) | `data/xasset_h1`, `intraday_long`, `intraday_eth`, `intraday_fx`, `holdout_*` | Nghiên cứu 3 giai đoạn 2014-17 / 2017-21 / 2022-26 (chuẩn ĐẠT 10/10 ô). Nhiều nguồn (Binance, HistData, Exness) — **không** dùng để so với MT5. |
| `python_csv_data.zip` (49.8 MB) — bản THÔ | `data/intraday/` | Chỉ để đối chiếu: còn nến D1/H1 thưa lẫn đầu file intraday và spread = 0 trước 2017 (engine sẽ coi là phí 0). |
| `mt5_xm_<SYMBOL>.zip` × 6 | `bases/XMGlobal-MT5 20/history/` | Lịch sử `.hcc` gốc cho MT5 Strategy Tester. |

Vùng dùng được của bộ chuẩn XM: Vàng/USDJPY từ 6/2014, S&P/Nasdaq từ 6/2016, BTC/ETH từ 7/2017 (tin cậy từ 2018).
XM **không có nến cuối tuần BTC/ETH trước 2022** và spread crypto 2018–2021 rất cao — kết quả giai đoạn đó trên XM khác hẳn sàn 24/7.

Độ sâu bản THÔ `python_csv_data.zip` (17 file CSV xuất trực tiếp từ MT5 `XMGlobal-MT5 20`, giờ UTC, spread thật trên từng nến):
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
| v5.2 | `releases/v5.2/s00_v52_20261103.tar.age` | Bản hiện hành — v5.1.2 + một thay đổi tỉ trọng có điều kiện theo quyết định chủ repo (nhật ký 0017); EA CHƯA biên dịch, preset cũ = v5.1.2 (đọc README trong gói) |
| v5.1.2 | `releases/v5.1.2/s00_v512_20261103.tar.age` | Bản trước — nâng cấp một chân theo quyết định chủ repo (nhật ký 0016) |
| v5.1.1 | `releases/v5.1.1/s00_v511_20261102.tar.age` | Bản trước — chiến lược & EA như v5.1, engine Python khớp EA (nhật ký 0008); preset như nhật ký 0003 |
| v5.1 | `releases/v5.1/s00_v51_20261101.tar.age` | Bản trước (engine Python cũ) |
| v5.0 | `releases/v5.0/s00_v50_20261030.tar.age` | Bản trước, để đối chiếu |

## Quy tắc nhật ký (bắt buộc)

1. Trước khi thử: `sh scripts/s00.sh unpack-all` rồi đọc `_giai_ma/nhat_ky/` (bắt đầu từ `0001.md`). Đã thử rồi thì không chạy lại.
2. Sau MỌI lần thử, kể cả thất bại: `sh scripts/s00.sh log-new <file.md> <ĐẠT|BÁC|GHI CHÚ> <người>` → thêm `nhat_ky/NNNN.age`
   và 1 dòng vào bảng dưới. Commit cả hai.
3. Bảng dưới chỉ ghi số / ngày / người / kết luận — KHÔNG ghi tên chân, tham số hay số liệu (repo công khai).

## Nhật ký thử nghiệm

| # | Ngày | Người | Kết luận |
|---|---|---|---|
| 0001 | 2026-11-03 | Claude | GHI CHÚ — tổng hợp mọi giả thuyết v4.4 → v5.1.2 (cập nhật thường xuyên) |
| 0002 | 2026-11-01 | Huy | GHI CHÚ — nhật ký v5.0 → v5.1 (có đính chính) |
| 0003 | 2026-11-01 | Claude | ĐẠT — đánh giá độc lập v5.1, chọn preset |
| 0004 | 2026-11-01 | Claude | GHI CHÚ — kiểm bộ dữ liệu XM xuất từ MT5 (đạt múi giờ/giá; 4 lỗi cần sửa) |
| 0005 | 2026-11-01 | Claude | GHI CHÚ — Python ↔ MT5 cùng dữ liệu XM: lệch giảm 3–5 lần, nguồn dữ liệu là nguyên nhân chính |
| 0006 | 2026-11-01 | Claude | ĐẠT — v5.1 KeepSpx so với v5 trên bộ chuẩn XM: nâng cấp nhỏ nhưng nhất quán |
| 0007 | 2026-11-02 | Claude | BÁC — v5.2: kiểm các đề xuất cải tiến của AI khác (mọi thay đổi bị bác, 1 ghi chú theo dõi) |
| 0008 | 2026-11-02 | Claude | ĐẠT — engine Python khớp EA (sửa parity); v5.1 KeepSpx vẫn đạt trên engine mới |
| 0009 | 2026-11-02 | Claude | BÁC — 3 biến thể bộ lọc nén cho chân lệnh chờ |
| 0010 | 2026-11-02 | Claude | BÁC — ý tưởng chân chỉ số trong phiên (dừng ở Cổng 1) |
| 0011 | 2026-11-02 | Claude | BÁC — giữ lệnh qua đêm cho một chân FX |
| 0012 | 2026-11-02 | Claude | BÁC — đánh đảo chiều / sideway trên 34 mã + cặp (dừng ở Cổng 1) |
| 0013 | 2026-11-02 | Claude | BÁC — bắt đáy theo xu hướng khung lớn (dừng ở Cổng 1) |
| 0014 | 2026-11-03 | Claude | GHI CHÚ — nhường vốn mềm cho một chân FX khi giữ qua đêm (tiền đề của 0016) |
| 0015 | 2026-11-03 | Claude | GHI CHÚ — tinh chỉnh hậu nghiệm cho một chân FX (tiền đề của 0016) |
| 0016 | 2026-11-03 | Claude | ĐẠT — đánh giá toàn diện; chủ repo duyệt nâng cấp một chân, phát hành v5.1.2 |
| 0017 | 2026-11-03 | Claude | ĐẠT — chủ repo duyệt phát hành v5.2 (khung v2: ứng viên forward); các tổ hợp đề xuất kèm theo bị bác |
| 0018 | 2026-11-04 | Claude | GHI CHÚ — rà soát lại các thay đổi trong gói và ứng viên cũ trên engine khớp EA; không đổi gói |
| 0019 | 2026-11-04 | Claude | GHI CHÚ — chi phí thực thi, capacity và đòn bẩy: chỉ xét live ở điều kiện chi phí gần đây, quy mô vốn giới hạn |
| 0020 | 2026-11-04 | Claude | GHI CHÚ — công cụ chấm có phạt đa kiểm định; đề xuất chưa áp dụng vào quy trình |
| 0021 | 2026-11-04 | Claude | BÁC — phân bổ lại tỉ trọng cấp danh mục; giữ tỉ trọng hiện tại |
| 0022 | 2026-11-04 | Antigravity | GHI CHÚ — biên dịch EA v5.2, kiểm định MT5 Strategy Tester và đối chiếu 7 ngày lệnh thực tế (khớp kịch bản code) |
| 0023 | 2026-11-04 | Claude | GHI CHÚ — kiểm lại 0022 bằng dữ liệu & log live: nhiều số liệu sai, tuần live chưa phải forward của v5.2; bản sửa lỗi vận hành v5.2.1 (không đổi logic) |
| 0024 | 2026-11-04 | Claude | GHI CHÚ — rà soát & vá bot Telegram/chart đi kèm: bảo mật danh sách người nhận, không nạp lại EA, chống spam/treo mạng (không đổi chiến lược) |
| 0025 | 2026-11-04 | Claude | GHI CHÚ — hướng dẫn & checklist triển khai bản ổn định trên máy live (dành cho chatbot trên server) |
