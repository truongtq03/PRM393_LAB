# Lab 9 – Working With Local JSON Storage

Ứng dụng Flutter gồm ba tab theo đề LAB 9_Working With Local JSON Storage.docx.

## Chạy ứng dụng

```powershell
cd D:\PRM393\work\PRM393_LAB\Lab9
flutter pub get
flutter run -d windows
# Hoặc chọn thiết bị Android:
flutter devices
flutter run -d <device-id>
# Bản thử trình duyệt:
flutter run -d chrome
```

Máy hiện tại dùng Flutter 3.47.4 / Dart 3.13.3. Windows cần bật Developer Mode để Flutter tạo symlink cho plugin và có bộ công cụ C++ của Visual Studio. Android cần SDK, emulator/thiết bị và giấy phép SDK đã được người dùng chấp nhận.

## Đối chiếu yêu cầu

| Phần | Cách thực hiện | Code minh chứng |
|---|---|---|
| 9.1: JSON nhúng | Đăng ký assets, rootBundle.loadString, jsonDecode → List<LocalItem>; ListView hiển thị ID, tên và mô tả | pubspec.yaml, assets/data/items.json, lib/services/json_repository.dart, lib/screens/asset_screen.dart |
| 9.2: Save & Load | initState tải dữ liệu; tạo file nếu chưa có; FAB mở form; thêm vào RAM, nhấn Lưu JSON để ghi; Tải lại khôi phục dữ liệu đã lưu | lib/screens/storage_screen.dart, lib/services/platform_backend_io.dart |
| 9.3: Mini database | Thêm/sửa/xóa có xác nhận, tìm tên/ghi chú/ID; tự động lưu; ID tăng dần và không tái sử dụng sau xóa | lib/models/local_item.dart, lib/screens/storage_screen.dart |
| Widget | StatefulWidget, setState, ListView, FloatingActionButton, TextField/TextFormField; tên bắt buộc | lib/screens/ |
| UX và lỗi | Loading, thử lại, snackbar, trạng thái chưa lưu, hỏi trước khi bỏ thay đổi; giữ JSON hỏng nguyên trạng; CRUD chỉ cập nhật UI sau khi ghi thành công | lib/services/json_repository.dart, lib/screens/storage_screen.dart |

## JSON và vị trí lưu

assets/data/items.json là danh sách nhúng chỉ đọc. Backend Android/iOS/Windows dùng path_provider, dart:io File và dart:convert. Dữ liệu người dùng lưu riêng:

```text
getApplicationDocumentsDirectory()/PRM393_Lab9/
  manual_saved.json    # Tab 9.2
  crud_database.json   # Tab 9.3
```

Ghi UTF-8 vào tệp .tmp, flush rồi đổi tên thay thế tệp đích. Giao diện hiển thị đường dẫn thực tế. Không ghi ngược vào assets. Cấu trúc database:

```json
{
  "version": 1,
  "nextId": 2,
  "items": [
    {"id": 1, "name": "Học Flutter", "description": "Thực hành JSON"}
  ]
}
```

Hai file trong examples/ là mẫu rỗng hợp lệ, không phải nơi lưu dữ liệu chạy thật. App tự tạo file rỗng ở lần chạy đầu.

**Bản web:** conditional export chọn localStorage riêng, với các key prm393_lab9_manual_saved.json và prm393_lab9_crud_database.json. Web không dùng File/path_provider và không chứng minh việc ghi file vào application documents directory. Dữ liệu thuộc từng origin; xóa site data hoặc đổi cổng chạy sẽ không còn thấy dữ liệu ở origin trước.

Chạy project bằng Android Studio hoặc VS Code để có assets và plugin đầy đủ. DartPad chỉ phù hợp thử riêng logic model/CRUD trong bộ nhớ; toàn bộ project với custom assets và File không thể dán trực tiếp thành một file DartPad.

## Kiểm tra thủ công

1. Mở 9.1 Assets: thấy 4 mục có tên và mô tả.
2. Mở 9.2 Save/Load, thêm mục: thấy Có thay đổi chưa lưu. Nhấn Lưu JSON, đóng hẳn và mở lại app: mục vẫn còn. Thêm mục chưa lưu, Tải lại và đồng ý bỏ thay đổi: chỉ còn nội dung đã lưu.
3. Mở 9.3 CRUD, thêm hai mục; sửa mục đầu và kiểm tra ID giữ nguyên. Tìm FLUTTER để kiểm tra không phân biệt hoa thường. Xóa qua xác nhận, mở lại app để kiểm tra. Thêm tiếp: ID không trùng mục đã xóa.
4. Xem JSON đã lưu để đối chiếu. Nếu sửa file thành JSON hỏng khi app đã đóng, lần mở sau phải báo lỗi và giữ nguyên file; sửa file hợp lệ rồi Thử lại.

## Kết quả kiểm chứng

- flutter analyze: không có lỗi/cảnh báo analyzer.
- flutter test: **16/16 đạt**. Bao gồm assets thật, schema, ID, tìm kiếm, hai file độc lập, JSON hỏng, lỗi ghi, CRUD/UI, tạo lại app và bố cục 320×568 có bàn phím.
- test/storage_test.dart dùng **File thật trong thư mục tạm Windows**: ghi tiếng Việt, tạo backend/repository mới để đọc lại, ghi đè, xóa và kiểm tra ID tiếp theo. Test tiêm thư mục tạm; không kiểm chứng plugin path_provider chạy trên thiết bị.
- flutter build web --release: thành công. Đã thao tác trình duyệt để thêm/lưu, reload toàn trang, xác nhận dữ liệu còn, sửa và tìm kiếm.
- flutter build windows --release: bị môi trường chặn với thông báo “Building with plugins requires symlink support” và yêu cầu bật Developer Mode. Không tự thay đổi thiết lập máy. **Chưa xác nhận UI native chạy trên Android/Windows.**

## Ảnh minh chứng

Các ảnh dưới đây chụp từ **bản web dùng localStorage**, không phải file storage native.

| Ảnh | Nội dung |
|---|---|
| [01_assets.jpg](screenshots/01_assets.jpg) | JSON assets thành danh sách |
| [02_saved_after_reload.jpg](screenshots/02_saved_after_reload.jpg) | Dữ liệu còn sau reload toàn trang |
| [03_crud_search.jpg](screenshots/03_crud_search.jpg) | Sửa giữ ID, lọc 1 trong 2 mục |
| [04_saved_json.jpg](screenshots/04_saved_json.jpg) | JSON đã lưu, nextId = 3 |
| [05_delete_confirmation.jpg](screenshots/05_delete_confirmation.jpg) | Xác nhận trước khi xóa |

Không tạo ZIP theo lựa chọn nộp bài đã thống nhất. Source, JSON mẫu và ảnh có thể dùng làm minh chứng từng phần trong báo cáo.

## Tài liệu

- [Flutter: Read and write files](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)
- [path_provider](https://pub.dev/packages/path_provider)
