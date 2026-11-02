# Quy trình kiểm định chuẩn — S00 EdgeCore

Luồng làm việc MẶC ĐỊNH cho mọi thay đổi chiến lược (thêm/bỏ chân, đổi tham số, bộ lọc, quản lý vốn…).
Đây là khung chung để mọi người làm giống nhau và so được với nhau — **không phải luật cứng 100%**. Luật nào thấy chưa hợp lý thì
cứ đề xuất và thử luật mới (xem mục cuối "Bổ sung / thay đổi luật"); chỉ cần ghi rõ mình làm khác chỗ nào và vì sao.
Bỏ qua bước nào thì ghi vào nhật ký để người sau biết kết quả đó được kiểm tới đâu.
Script & ví dụ nằm trong gói nghiên cứu (`research/quy_trinh/`, `research/v51_review/`, `research/data_audit/`) — giải mã bằng `sh scripts/s00.sh unpack-all`.

## Bước 0 — Chuẩn bị (máy nào cũng giống nhau)
1. `git pull` → `sh scripts/s00.sh verify` → `sh scripts/s00.sh unpack-all`.
2. Dữ liệu: `sh install_data.sh <thư mục gói>` (Release `data-20261101`).
3. Kiểm dấu vân tay dữ liệu — PHẢI khớp, không khớp thì dừng:
   - bộ chuẩn XM `data/xm_20261021`: **`21bf2452159ac879`**
   - bộ nghiên cứu (xasset_h1 + intraday_long + intraday_eth + intraday_fx): **`2e1bd9b47845f530`**
   - lệnh: `python du_lieu_chuan.py kiem <thư mục>...`

## Bước 1 — Đọc nhật ký trước
`_giai_ma/nhat_ky/` (bắt đầu từ `0001.md`). Ý tưởng đã thử thì KHÔNG chạy lại trừ khi có lý do mới (dữ liệu/sàn/luật khác) và ghi rõ lý do.

## Bước 2 — Viết giả thuyết TRƯỚC khi chạy
Ghi: thay đổi gì, vì sao kỳ vọng tốt hơn, dự đoán ở đâu sẽ tốt/xấu. Viết sau khi đã thấy kết quả = chọn theo dữ liệu (overfit).

## Bước 3 — Cài thành công tắc, mặc định TẮT
- Thêm tham số vào `config.py` (Python) và input EA (MQL5) với giá trị mặc định = hành vi cũ.
- **Kiểm khớp (parity):** công tắc tắt phải cho ra ĐÚNG số của bản gốc (vd vốn $1k 6 tháng, so từng xu). Lệch = có thay đổi lọt ra ngoài công tắc.

## Bước 4 — Kiểm định bằng 1 lệnh
```
python -I research/quy_trinh/kiem_dinh.py --ten "<tên>" --moi "inp_a=1,inp_b=true" [--goc "..."]
```
Script chạy 3 bộ (≈ 48 lần chạy) và tự chấm:

| Bộ | Dữ liệu · vốn | Ô | Luật ĐẠT |
|---|---|---|---|
| **A** nghiên cứu | nhiều nguồn · $100k không trần lot · CHUẨN 8% + phanh 50 | 2014-17, 2017-21, 2022-26, sau COVID nửa 1 (3/2020→6/2023), nửa 2 (6/2023→10/2026) × phí XM / STRESS = 10 | **10/10** |
| **B** chuẩn XM | `xm_20261021` (cùng nến MT5 XM) · $100k · CHUẨN | 2018-21, 2022-26, 2 nửa sau COVID × XM / STRESS = 8 | **≥ 6/8** và 2022-26 thắng ở cả 2 phí |
| **C** vốn nhỏ | `xm_20261021` · $1,000 XM Micro (lot nhỏ nhất thật) · phí XM | DD50 và DD30 × 2018-26, 2022-26, 2 năm, 1 năm, 6 tháng = 10 | **≥ 7/10** |
| Rủi ro | ô của A và B | — | MaxDD mới ≤ gốc + 2 điểm |

- "Thắng" = tiền cuối kỳ mới > gốc (nửa sau COVID tính từ số dư tại mốc). Kết luận **ĐẠT** khi A, B, C, rủi ro đều đạt.
- Ngưỡng là MẶC ĐỊNH, chỉnh được: `--luat-a 9 --luat-b 5 --luat-c 6 --dd-them 3` (và `--bo A,B` nếu chỉ chạy một phần).
  Dùng ngưỡng khác mặc định → ghi rõ trong nhật ký. Ca "sát nút" (vd 9/10, thua 1 ô rất nhỏ) → ghi GHI CHÚ, chủ repo quyết định.
- Ví dụ đã qua quy trình: v5.1 KeepSpx (A 10/10, B 6/8, C 9/10 → ĐẠT); v5.1 Clean (A 4/10 → BÁC). Xem nhật ký 0003, 0006.
- Phí: XM = spread + swap thật (bộ nghiên cứu cộng thêm chênh lệch phí XM đo từ báo cáo MT5; bộ XM đã là spread thật nên KHÔNG cộng).
  STRESS bộ A = spread crypto ≈ ×2 + swap crypto ×2; STRESS bộ B = spread ×1.5 + trượt 1 bps + swap crypto ×2.
- Muốn so giữa nhiều phương án: chấm thêm log-lợi theo trọng số giai đoạn 2014-17 : 2017-21 : 2022-26 = 1 : 2 : 4,
  điều kiện giai đoạn gần và 2 năm gần không âm.
- Gói nhiều thay đổi: chạy thêm TỪNG thay đổi riêng để biết lợi đến từ đâu. KHÔNG tự chọn lại thành phần sau khi thấy kết quả —
  muốn bỏ một thành phần là một giả thuyết mới, kiểm lại từ Bước 2.

## Bước 5 — Xác minh trên MT5 (EA)
1. Biên dịch EA (0 lỗi), chạy Strategy Tester trên lịch sử `.hcc` chuẩn (Release `mt5_xm_*.zip`), "1 minute OHLC", cùng preset.
2. Chạy Python trên bộ XM với ĐÚNG tham số đọc từ Inputs của báo cáo (`research/data_audit/py_vs_mt5.py` làm mẫu).
3. Yêu cầu khớp: giai đoạn gần (2025-26) vốn cuối lệch ≤ 10%, số lệnh lệch ≤ 10%, cùng dấu lời/lỗ theo năm.
   Lệch hơn → tìm lỗi EA ↔ Python trước (đối chiếu từng lệnh: `python/doi_chieu.py`), KHÔNG kết luận chiến lược.
4. MT5 dùng để XÁC MINH EA và chi phí, KHÔNG dùng để chọn tham số. Chọn trên 2022-26 / 2025-26 rồi gọi là "OOS" là SAI (trong mẫu).

## Bước 6 — Ghi nhật ký (cả khi BÁC)
1. Lấy bản nháp `research/quy_trinh/out/<tên>_nhat_ky.md`, điền giả thuyết (Bước 2) và kết luận.
2. `sh scripts/s00.sh log-new <file.md> <ĐẠT|BÁC|GHI CHÚ> <người>` → `nhat_ky/NNNN.age` + 1 dòng README (không ghi tham số).
3. Script/kết quả lớn: đóng gói lại `research/` (`s00.sh pack`). Push khi chủ repo cho phép.

## Cạm bẫy đã gặp (đừng lặp)
| Cạm bẫy | Hậu quả | Cách tránh |
|---|---|---|
| Thiếu thư mục dữ liệu | `backtest.py` (trước 2026-11-02) bỏ qua IM LẶNG chân thiếu dữ liệu | Kiểm dấu vân tay (Bước 0); engine mới báo lỗi (`strict=True`) |
| Python cập nhật đỉnh vốn ở giá mở nến, EA mỗi tick | Python phanh DD nhẹ hơn EA → lạc quan (rõ nhất khi phanh chặt) | Engine từ 2026-11-02 đã sửa mặc định (nhật ký 0008) |
| Ghép deal out ↔ in báo cáo MT5 theo (symbol, volume) FIFO | gán sai chân ~2% lệnh | Ghép theo giá vào suy ra từ lời (script trong gói nghiên cứu, nhật ký 0007) |
| Bộ B/C với thay đổi "tăng rủi ro khi có X" | dễ "đạt" chỉ nhờ tăng đòn bẩy cho chân đang lời gần đây | Chạy thêm đối chứng đảo (tăng khi KHÔNG có X), nhật ký 0007 |
| Thư mục `--data` trùng tên file | engine lấy thư mục ĐẦU TIÊN có file | Chỉ dùng đúng 2 bộ chuẩn |
| Spread = 0 trong CSV | engine coi là phí 0 | Dùng bộ đã làm sạch; ô trống = spread mô phỏng |
| Nến khung lớn lẫn trong file khung nhỏ | chỉ báo sai | Dùng bộ đã làm sạch |
| Đặc trưng H1 cho lệnh M15 dùng nến H1 chưa đóng | nhìn trước tương lai, kết quả ảo | Chỉ dùng nến đã đóng |
| Chọn trên 2022-26/2025-26 rồi gọi là OOS | overfit | Luật 10/10 ô (Bộ A) |
| Cắt chân theo bảng xếp hạng chân | thứ hạng đảo giữa các giai đoạn | Không cắt theo xếp hạng; kiểm như mọi thay đổi |
| Lọc giờ/thứ/chế độ thị trường | đa số là nhiễu (xáo ngẫu nhiên ra số "vững" tương tự) | So với phép xáo ngẫu nhiên trước khi tin |
| Lãi theo chân bằng $ trong lãi kép | bị chi phối bởi lệnh cuối kỳ (vốn lớn) | Dùng đóng góp log %/năm |
| So Python ↔ MT5 khác dữ liệu | lệch 3–5 lần do dữ liệu, tưởng EA sai | Python dùng bộ XM khi so với MT5 |
| Báo cáo MT5 vốn quá nhỏ ($200) | méo do lot tối thiểu | $1k Micro trở lên |
| XM crypto trước 2022 | không có cuối tuần, spread rất cao | Đọc kết quả 2018-21 trên bộ XM với lưu ý này |

## Bổ sung / thay đổi luật
Quy trình này sẽ được sửa dần. Ai thấy một luật nên khác (ngưỡng, giai đoạn, mức phí STRESS, chỉ số rủi ro mới, cách chọn giữa
các phương án…) thì:
1. Ghi đề xuất thành 1 nhật ký `GHI CHÚ`: luật hiện tại, luật đề xuất, vì sao.
2. Thử luật mới SONG SONG với luật cũ trên vài thay đổi đã có kết luận trong nhật ký (vd KeepSpx, Clean, các hướng đã bác):
   luật tốt phải giữ được các kết luận đúng và bắt được cái sai mà luật cũ bỏ sót — không chỉ làm cho phương án mình thích "đạt".
3. Thêm cạm bẫy mới vào bảng trên ngay khi gặp (đây là phần quý nhất của tài liệu).
4. Chủ repo duyệt → sửa file này + `kiem_dinh.py` (ngưỡng mặc định), ghi ngày và lý do vào mục lịch sử dưới đây.

### Lịch sử thay đổi luật
| Ngày | Thay đổi | Lý do |
|---|---|---|
| 2026-11-02 | Bản đầu: Bộ A 10/10 (luật dùng từ v4.99c), thêm Bộ B/C trên dữ liệu chuẩn XM, xác minh MT5 cùng dữ liệu | Chuẩn hóa sau khi có bộ dữ liệu XM và đo được Python ↔ MT5 khớp khi cùng dữ liệu |
| 2026-11-02 (chiều) | Engine Python mặc định = engine KHỚP EA (cách tính lot lệnh chờ và đỉnh vốn như EA; báo lỗi khi thiếu dữ liệu). Kết quả kiểm định trước ngày này chạy trên engine cũ (lạc quan hơn) — so sánh CÙNG engine thì kết luận vẫn dùng được | Đo trên báo cáo MT5: lot Python lệch EA khi đang sụt vốn; sau sửa khớp. Chi tiết: nhật ký 0008 |
