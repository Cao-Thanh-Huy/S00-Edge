# Bảo mật repo S00-Edge (repo PUBLIC)

## Mô hình
- Ai cũng tải được repo. Mọi nội dung chiến lược (code, preset, báo cáo, nghiên cứu, nhật ký) chỉ nằm trong file `*.age`,
  mã hóa bằng [age](https://age-encryption.org) (X25519 + ChaCha20-Poly1305) cho từng khóa công khai trong `keys/recipients.txt`.
- Không có mật khẩu chung. Mỗi người giữ khóa bí mật riêng ở `~/.s00/age_key.txt` (Windows: `C:\Users\<tên>\.s00\age_key.txt`).
- Lộ thứ gì là mất hẳn: GitHub, bản fork, bản clone, bộ nhớ đệm đều có thể còn giữ — nên chặn từ trước khi commit.

## Các lớp chặn
1. `.gitignore` dạng danh sách cho phép — chỉ `*.age`, `SHA256SUMS`, README/AGENTS/SECURITY, `scripts/s00.sh`, `keys/recipients.txt`.
2. GitHub Action `guard` — từ chối push/PR có file ngoài danh sách, file `.age` giả, sai checksum, hay chuỗi khóa bí mật.
3. `scripts/s00.sh pack` tự bỏ `.env`, `__pycache__`, `*.pkl` khi đóng gói.
4. Tài khoản GitHub bật 2FA; nhánh `main` cấm force push (Settings → Branches → Branch protection).

## Thêm người
1. Người đó cài age và chạy `age-keygen -o ~/.s00/age_key.txt`, gửi dòng `Public key: age1...` (KHÔNG gửi file khóa).
2. Thêm dòng `age1...` vào `keys/recipients.txt` (kèm dòng chú thích tên + ngày).
3. Đóng gói lại những bản muốn họ đọc (`s00.sh pack ...`, nhật ký: giải mã rồi mã hóa lại) và commit.

## Bớt người
1. Xóa khóa của họ khỏi `keys/recipients.txt`.
2. Từ bản sau họ không đọc được. Những bản họ đã tải về vẫn đọc được — không công cụ nào thu hồi được điều đó.
3. Nếu đã chia sẻ thứ gì nhạy cảm (khóa API, tài khoản sàn) cho họ: đổi ngay ở phía sàn/dịch vụ.

## Khi nghi lộ khóa bí mật
1. Tạo khóa mới, thay khóa cũ trong `keys/recipients.txt`.
2. Đóng gói lại MỌI file `.age` cho khóa mới; viết lại lịch sử git nếu cần chặn bản cũ (chủ repo quyết định).
3. Coi mọi bản đã mã hóa cho khóa cũ là đã lộ.

## Sao lưu
- Mất khóa bí mật = không ai mở lại được gói đã mã hóa. Chủ repo cất 1 bản `age_key.txt` ngoại tuyến (USB / trình quản lý mật khẩu).
- Windows: khóa quyền file `icacls "%USERPROFILE%\.s00\age_key.txt" /inheritance:r /grant:r "%USERNAME%:R"`; Mac/Linux: `chmod 600`.
