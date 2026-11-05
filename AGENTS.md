# Quy tắc cho NGƯỜI và AI (Claude, Gemini, Codex…) làm việc với repo S00-Edge

Đây là bộ quy tắc DUY NHẤT. `CLAUDE.md`, `GEMINI.md` và các file `.agents/rules/` bên trong gói đều phải tuân theo file này;
chỗ nào mâu thuẫn thì file này thắng.

## 1. Repo PUBLIC — bảo mật trước tiên
- Chỉ commit: `*.age`, `SHA256SUMS`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `SECURITY.md`, `QUY_TRINH_KIEM_DINH.md`, `scripts/s00.sh`,
  `keys/recipients.txt`, `.github/workflows/guard.yml`, `.gitignore`, `.gitattributes`. `.gitignore` và CI `guard` đã chặn sẵn.
- KHÔNG ghi tên chân, tham số, số liệu chiến lược vào README hay commit message. Nội dung thật chỉ nằm trong file `.age`.
- KHÔNG đưa `.env`, khóa API, tài khoản sàn, khóa bí mật age vào bất kỳ gói nào.
- KHÔNG push / force push / tạo Release khi chủ repo chưa cho phép rõ ràng cho lần đó.
- Quản lý khóa: xem `SECURITY.md`.

## 2. Trước khi thử bất kỳ ý tưởng nào: ĐỌC NHẬT KÝ
- `sh scripts/s00.sh unpack-all` → đọc `_giai_ma/nhat_ky/0001.md` (tổng hợp mọi giả thuyết từ v4.4) và các file sau đó.
- Ý tưởng đã có trong nhật ký thì KHÔNG chạy lại, trừ khi có lý do mới (dữ liệu mới, sàn mới, luật khác) — ghi rõ lý do.

## 3. Sau MỌI lần thử (kể cả thất bại): GHI NHẬT KÝ
1. Viết 1 file markdown theo mẫu ở cuối file này.
2. `sh scripts/s00.sh log-new <file.md> <ĐẠT|BÁC|GHI CHÚ> <người>` → tạo `nhat_ky/NNNN.age` + thêm 1 dòng vào bảng README.
3. Commit cả `nhat_ky/` và `README.md`. Mỗi thử nghiệm 1 file riêng → nhiều người ghi cùng lúc không đè nhau.
4. Script/kết quả: đóng gói lại `research/` bằng `s00.sh pack`. Gói trong git chỉ chứa script, tài liệu và kết quả NHỎ (vài MB).
   Kết quả nặng và không còn thay đổi (log/báo cáo MT5, CSV trung gian, ảnh) → gói lưu trữ riêng, đưa lên GitHub Release
   `research-luutru-<ngày>` (cần chủ repo cho phép). Không đưa lại vào gói trong git. Gói lưu trữ hiện có: `research-luutru-20261105`.
   Lấy về: `gh release download research-luutru-20261105 -D _giai_ma/` rồi `sh scripts/s00.sh unpack _giai_ma/s00_research_luutru_20261105.tar.age`.

## 4. Chuẩn ĐẠT (để đổi bản chuẩn) — chi tiết & cách chạy: `QUY_TRINH_KIEM_DINH.md`
- Làm theo luồng trong `QUY_TRINH_KIEM_DINH.md` (chuẩn bị → đọc nhật ký → giả thuyết → công tắc + parity → `kiem_dinh.py` →
  xác minh MT5 → ghi nhật ký). Luật là MẶC ĐỊNH, không cứng 100%: làm khác thì ghi rõ chỗ khác và lý do; đề xuất luật mới theo
  mục "Bổ sung / thay đổi luật" của file đó.
- Mặc định: Bộ A (bộ nghiên cứu) **10/10 ô** — 3 giai đoạn 2014-17 / 2017-21 / 2022-26 + 2 nửa sau COVID × phí XM / STRESS;
  Bộ B (bộ chuẩn XM, $100k) ≥ 6/8 và 2022-26 thắng cả 2 phí; Bộ C ($1k XM Micro) ≥ 7/10; MaxDD không tăng quá 2 điểm.
- Kết quả chỉ trên 2022-26 hoặc 2025-26 là TRONG MẪU — không được gọi là OOS, không đủ để đổi bản chuẩn.
  Đã có nhiều thay đổi đẹp ở 2022-26 nhưng thua ở 2014-21 (xem nhật ký).
- MT5 Strategy Tester dùng để kiểm EA khớp Python và chi phí thật, KHÔNG dùng để chọn tham số trên cùng giai đoạn rồi báo là OOS.

## 5. Cạm bẫy đã gặp
- `backtest.py` bỏ qua IM LẶNG chân nào thiếu dữ liệu. Thiếu `intraday_eth` / `xasset_h1` / `intraday_fx` là chạy thiếu chân ETH /
  S&P / Nasdaq / USDJPY mà không báo lỗi. Dùng gói dữ liệu đầy đủ ở Release `data-20261101`.
- Bảng lãi theo chân bằng tiền ($) trong lãi kép bị chi phối bởi lệnh ở cuối kỳ (vốn lớn) → dùng đóng góp log %/năm.
- Ghép deal out ↔ in trong báo cáo MT5: deal out không ghi tên chân; ghép theo (symbol, volume) chỉ gần đúng.

## Mẫu nhật ký
```markdown
# NNNN — <tên ngắn> (<ngày>, <người/máy>)
- Giả thuyết:
- Thay đổi (file, tham số):
- Cách kiểm (engine, giai đoạn, phí, vốn):
- Kết quả (từng ô; CAGR, MaxDD, PF, lệnh/năm):
- Kết luận: ĐẠT / BÁC + lý do
- Script & file kết quả (trong gói research):
```
