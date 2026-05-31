# AutoVSF - VideoSubFinder & OCR Pipeline

Công cụ hỗ trợ trích xuất phụ đề từ video thông qua VideoSubFinder và nhận diện chữ (OCR) bằng Google Drive API.

## Hướng dẫn cài đặt & Sử dụng

### 1. Cài đặt Python
Đảm bảo bạn đã cài đặt Python (phiên bản >= 3.10) và cài đặt các thư viện cần thiết:
```powershell
pip install watchdog google-api-python-client oauth2client httplib2 opencv-python psutil Pillow
```

### 2. Tải VideoSubFinder (VSF)
Tải công cụ VideoSubFinder phiên bản 6.10 (x64) tại đây: [Download VideoSubFinder](https://www.videohelp.com/download/VideoSubFinder_6.10_x64.zip?r=fcBBfmZrTz)
*Sau khi tải về, hãy giải nén và trỏ đường dẫn đến file `VideoSubFinderWXW_intel.exe` trong tab Settings của ứng dụng.*

### 3. Tải Aegisub (Tùy chọn)
Để chỉnh sửa và kiểm tra lại file phụ đề `.srt` sau khi trích xuất, bạn có thể sử dụng Aegisub: [Download Aegisub 3.4.2](https://github.com/TypesettingTools/Aegisub/releases/download/v3.4.2/Aegisub-3.4.2.exe)

### 4. Thiết lập Google Cloud (Bắt buộc cho OCR)
Bạn cần cấu hình Google Drive API để lấy file `credentials.json`.
Chi tiết các bước thực hiện xem tại: [Hướng dẫn thiết lập Google Cloud](docs/GOOGLE_SETUP.md)

### 3. Chạy chương trình
1. Mở Terminal tại thư mục dự án.
2. Chạy lệnh:
```powershell
python main.py
```

## Các tính năng chính
- **Tab 1 (VSF):** Chạy VideoSubFinder để tách ảnh chứa phụ đề. Hỗ trợ tạo Crop Profile nhanh.
- **Tab 2 (OCR):** Tải ảnh lên Google Drive để nhận diện chữ và ghép thành file `.srt` hoàn chỉnh. Có hiển thị ETA.
- **Tab 3 (Settings):** Cấu hình đường dẫn VSF, file xác thực, và Folder ID của Google Drive.

## Lưu ý quan trọng
- Khi chạy OCR lần đầu, trình duyệt sẽ mở trang đăng nhập Google. Hãy chọn đúng tài khoản bạn đã dùng để tạo dự án trên Google Cloud.
- Đảm bảo bạn đã **Publish** app trong mục "OAuth consent screen" trên Google Cloud để tránh lỗi xác thực.
