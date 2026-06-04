# AutoVSF - VideoSubFinder & OCR 流水线

> 📖 **中文版 README** — 默认英文版: [README.md](../README.md) | **[Tiếng Việt](VIE_README.md)**

通过 VideoSubFinder 和 Google Drive API OCR 从视频中提取硬字幕。

---

## 快速安装 (一键)

以**管理员**身份打开 **PowerShell** 并粘贴：

```powershell
irm https://raw.githubusercontent.com/lionc2240/autovsf/main/install.ps1 | iex
```

安装后，在**任何** PowerShell 窗口中输入 `autovsf` 即可启动工具。安装程序会自动注册全局 PowerShell 函数以便快速访问。

---

## 📸 截图

<p align="center">
  <img src="../images/autovsf_running.jpg" width="55%" alt="AutoVSF Running">
</p>

<p align="center">
  <img src="../images/autovsf_ocr.jpg" width="55%" alt="AutoVSF OCR">
</p>

---

## 手动设置

### 1. 环境要求
- Python ≥ 3.10：`pip install watchdog google-api-python-client oauth2client httplib2 opencv-python psutil Pillow`
- VideoSubFinder 6.10 (x64)：解压到 `program/`，确保可执行文件位于：
  `program/VideoSubFinder_6.10_x64/Release_x64/VideoSubFinderWXW_intel.exe`

### 2. Google Cloud 设置 (OCR 必需)
配置 Google Drive API 并将 `credentials.json` 放在项目根目录。
> 详见 [Google Cloud 设置指南](CN_GOOGLE_SETUP.md)

### 3. 运行

- **PowerShell（任意位置）：** 使用一键安装后，只需输入：
  ```powershell
  autovsf
  ```

- **Windows：** 双击 `run.bat` 或运行：
  ```batch
  run.bat
  ```

- **直接使用 Python：**
  ```powershell
  python main.py
  ```

---

## 🌟 功能特点
- **标签 1 (VSF)：** 运行 VideoSubFinder 提取字幕图像。支持拖放的裁剪配置文件生成器。
- **标签 2 (OCR)：** 自动上传图像到 Google Drive OCR，实时估算剩余时间，生成完整 `.srt` 文件。
- **标签 3 (设置)：** 灵活配置，智能管理 `credentials.json`。

---

## ⚠️ 重要提示
- 首次运行 OCR 时，浏览器将打开进行 Google 登录。请使用您配置的 Google Cloud 账户。
- 确保在 Google Cloud Console 的"受众"部分将应用**发布 (Production)**，以避免认证错误。
