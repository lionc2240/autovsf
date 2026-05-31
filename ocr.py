"""ocr.py — OCR engine: upload ảnh lên Drive, lấy text, ghép SRT.
Không phụ thuộc UI — giao tiếp qua callbacks.
"""
import io, re, time, shutil, threading, concurrent.futures, httplib2
from pathlib import Path
from typing import Callable

from apiclient import discovery
from apiclient.http import MediaFileUpload, MediaIoBaseDownload
from oauth2client import client, tools
from oauth2client.file import Storage

import config as C

# ── Auth ──────────────────────────────────────────────────────────────────────
def get_credentials():
    cred_file  = C.credentials_file()
    tok_file   = C.token_file()
    store = Storage(tok_file)
    creds = store.get()
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets(cred_file, C.SCOPES)
        flow.user_agent = C.APP_NAME
        try:
            import argparse
            from oauth2client import tools as _t
            flags = argparse.ArgumentParser(parents=[_t.argparser]).parse_args([])
            creds = tools.run_flow(flow, store, flags)
        except Exception:
            creds = tools.run(flow, store)
    return creds

# ── Thread-local Drive service ─────────────────────────────────────────────────
_local = threading.local()

def _service(creds):
    if not hasattr(_local, "svc"):
        _local.svc = discovery.build("drive", "v3", http=creds.authorize(httplib2.Http()))
    return _local.svc

# ── Validate folder (1 lần/session) ───────────────────────────────────────────
_folder_validated = False

def _validate_folder(svc, folder_id: str):
    """Kiểm tra folder_id tồn tại và có quyền truy cập."""
    if not folder_id:
        return
    try:
        svc.files().get(fileId=folder_id, fields="id,name,mimeType").execute()
    except Exception as e:
        raise RuntimeError(
            f"Drive Folder ID không hợp lệ hoặc không có quyền: {folder_id}\n"
            f"→ Kiểm tra ID và share folder cho tài khoản Google đang dùng.\n"
            f"Chi tiết: {e}"
        )

# ── Drive OCR ─────────────────────────────────────────────────────────────────
def _drive_ocr(svc, imgfile: str, imgname: str, folder_id: str) -> str:
    """Upload ảnh → Google Docs OCR → export text → xóa file."""
    mime = "application/vnd.google-apps.document"
    body = {"name": imgname, "mimeType": mime}
    if folder_id:
        body["parents"] = [folder_id]

    # resumable=False: create() trả về file id ngay lập tức
    f = svc.files().create(
        body=body,
        media_body=MediaFileUpload(imgfile, mimetype=mime, resumable=False),
    ).execute()

    file_id = f.get("id")
    if not file_id:
        raise RuntimeError(f"Drive create() không trả về id. Response: {f}")

    try:
        # Retry export: Drive cần thời gian index sau upload
        for attempt in range(5):
            try:
                time.sleep(1 + attempt)   # 1s, 2s, 3s, 4s, 5s
                buf = io.BytesIO()
                dl  = MediaIoBaseDownload(
                    buf, svc.files().export_media(fileId=file_id, mimeType="text/plain")
                )
                done = False
                while not done:
                    _, done = dl.next_chunk()
                break
            except Exception:
                if attempt == 4:
                    raise
        return "".join(buf.getvalue().decode("utf-8").split("\n")[2:])
    finally:
        try:
            svc.files().delete(fileId=file_id).execute()
        except Exception:
            pass

# ── Parse timestamps từ tên file ──────────────────────────────────────────────
def _timestamps(name: str):
    """'HH_MM_SS_mmm__HH_MM_SS_mmm.bmp' → ('HH:MM:SS,mmm', 'HH:MM:SS,mmm')"""
    parts = name.split("__")
    if len(parts) < 2:
        raise ValueError(f"Tên file sai định dạng: {name}")
    def fmt(seg):
        t = seg.split("_")
        return f"{t[0][:2]}:{t[1][:2]}:{t[2][:2]},{t[3][:3]}"
    return fmt(parts[0]), fmt(parts[1])

# ── OCR một ảnh ───────────────────────────────────────────────────────────────
def _ocr_one(image: Path, idx: int, creds, workdir: Path,
             folder_id: str, log: Callable, on_done: Callable):
    global _folder_validated
    st = C.state
    if st.stop_event.is_set():
        return

    svc = _service(creds)

    # Validate folder một lần duy nhất
    if not _folder_validated:
        try:
            _validate_folder(svc, folder_id)
            _folder_validated = True
        except RuntimeError as e:
            log(f"❌ {e}")
            st.stop_event.set()
            return

    name = image.name
    for attempt in range(1, C.MAX_RETRIES + 1):
        if st.stop_event.is_set():
            return
        try:
            text = _drive_ocr(svc, str(image), name, folder_id)
            stem = image.stem   # dùng Path.stem thay vì name[:-5]

            (workdir / "raw_texts" / f"{stem}.txt").write_text(text, encoding="utf-8")
            (workdir / "texts"     / f"{stem}.txt").write_text(text, encoding="utf-8")

            t0, t1 = _timestamps(name)
            with st.srt_lock:
                st.srt_entries[idx] = [f"{idx}\n", f"{t0} --> {t1}\n", f"{text}\n\n", ""]

            log(f"✅ {text[:60]}{'...' if len(text) > 60 else ''}")
            on_done()
            return
        except Exception as e:
            log(f"⚠️ Lần {attempt}/{C.MAX_RETRIES}: {e}")
            if attempt == C.MAX_RETRIES:
                raise
            time.sleep(C.RETRY_DELAY)

# ── Entry point ───────────────────────────────────────────────────────────────
def run(images_dir: str, srt_out: str,
        delete_raw: bool, delete_texts: bool,
        log: Callable, on_progress: Callable, on_finish: Callable):
    """Chạy toàn bộ pipeline OCR trong background thread."""
    cfg       = C.load()
    threads   = cfg["threads"]
    folder_id = C.state.folder_id or cfg["folder_id"]

    global _folder_validated
    _folder_validated = False
    C.state.reset()
    C.state.t0 = time.time()

    def _run():
        creds    = get_credentials()
        workdir  = Path.cwd()
        imgdir   = Path(images_dir)
        raw_dir  = workdir / "raw_texts"
        txt_dir  = workdir / "texts"
        srt_path = Path(srt_out).with_suffix(".srt")

        if not imgdir.exists():
            log(f"❌ Không tìm thấy thư mục: {imgdir}")
            on_finish(None); return

        raw_dir.mkdir(exist_ok=True)
        txt_dir.mkdir(exist_ok=True)

        images = [p for ext in C.IMAGE_EXTS for p in imgdir.rglob(ext)]
        C.state.total = len(images)
        log(f"📂 {C.state.total} ảnh | {threads} luồng")

        if not images:
            log("❌ Không có ảnh hợp lệ."); on_finish(None); return

        def _done():
            C.state.done += 1
            on_progress(C.state.done, C.state.total)

        with concurrent.futures.ThreadPoolExecutor(max_workers=threads) as ex:
            futs = {
                ex.submit(_ocr_one, img, i + 1, creds, workdir, folder_id, log, _done): img
                for i, img in enumerate(images)
            }
            for fut in concurrent.futures.as_completed(futs):
                if C.state.stop_event.is_set():
                    ex.shutdown(wait=False, cancel_futures=True)
                    break
                try:
                    fut.result()
                except Exception as e:
                    log(f"❌ {futs[fut].name}: {e}")

        if C.state.stop_event.is_set():
            on_finish(None); return

        # Ghép SRT theo thứ tự index
        srt = "".join("".join(C.state.srt_entries[i])
                      for i in sorted(C.state.srt_entries))
        srt_path.write_text(srt, encoding="utf-8")

        # Dọn dẹp thư mục tạm
        for flag, d in ((delete_raw, raw_dir), (delete_texts, txt_dir)):
            if flag and d.exists():
                shutil.rmtree(d)

        elapsed = time.time() - C.state.t0
        log(f"✅ Xong trong {elapsed:.1f}s → {srt_path}")
        on_finish(str(srt_path))

    threading.Thread(target=_run, daemon=True).start()
