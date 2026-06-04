# AutoVSF - VideoSubFinder & OCR Pipeline

Công cụ hỗ trợ trích xuất phụ đề cứng từ video thông qua VideoSubFinder và nhận diện chữ (OCR) bằng Google Drive API.

---

## Cài đặt nhanh (One-Click Install)

Chỉ cần mở **PowerShell** (với quyền Admin) và dán lệnh sau để tự động cài đặt mọi thứ (Python, Git, thư viện và VideoSubFinder):

```powershell
irm https://raw.githubusercontent.com/lionc2240/autovsf/main/install.ps1 | iex
```

Sau khi cài đặt, gõ `autovsf` trong **bất kỳ** cửa sổ PowerShell nào để mở tool. Trình cài đặt tự động đăng ký hàm PowerShell toàn cục để truy cập nhanh.

---

## 📸 Ảnh chụp màn hình

<p align="center">
  <img src="../images/autovsf_running.jpg" width="55%" alt="AutoVSF Running">
</p>

<p align="center">
  <img src="../images/autovsf_ocr.jpg" width="55%" alt="AutoVSF OCR">
</p>

---

## Hướng dẫn thủ công (Nếu không dùng One-Click)

### 1. Yêu cầu hệ thống
- Python ≥ 3.10: `pip install watchdog google-api-python-client oauth2client httplib2 opencv-python psutil Pillow`
- VideoSubFinder 6.10 (x64): Giải nén vào thư mục `program/` của dự án sao cho đường dẫn chạy là:
  `program/VideoSubFinder_6.10_x64/Release_x64/VideoSubFinderWXW_intel.exe`

### 2. Thiết lập Google Cloud (Bắt buộc cho OCR)
Bạn cần cấu hình Google Drive API để lấy file xác thực `credentials.json` bỏ vào thư mục dự án.
> Xem chi tiết tại: [Hướng dẫn thiết lập Google Cloud](VIE_GOOGLE_SETUP.md)

### 3. Chạy chương trình

Bạn có thể chọn một trong các cách sau:

- **PowerShell (mọi nơi):** Sau khi cài bằng one-click, chỉ cần gõ:
  ```powershell
  autovsf
  ```

- **Trên Windows:** Chạy tệp tin `run.bat`:
  ```batch
  run.bat
  ```

- **Sử dụng Python trực tiếp:**
  ```powershell
  python main.py
  ```

---

## 🌟 Các tính năng chính
- **Tab 1 (VSF):** Chạy VideoSubFinder tự động tách ảnh phụ đề. Hỗ trợ tạo Crop Profile trực quan bằng cách kéo thả chuột.
- **Tab 2 (OCR):** Tự động tải ảnh lên Google Drive OCR và ghép thành file `.srt` hoàn chỉnh, hiển thị ETA thời gian thực.
- **Tab 3 (Settings):** Cấu hình linh hoạt, quản lý thông minh trạng thái và đường dẫn của `credentials.json` (tự động copy vào dự án).

---

## ⚠️ Lưu ý quan trọng
- Lần đầu OCR chạy, trình duyệt sẽ mở trang đăng nhập Google. Hãy chọn đúng tài khoản Google Cloud bạn đã cấu hình.
- Đảm bảo đã chuyển trạng thái dự án Google sang **Publish App** (Production) trong mục "Audience" trên Google Cloud để tránh lỗi xác thực.
