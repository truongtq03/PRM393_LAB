# Lab 8 – Building an API-powered List Screen

Ứng dụng Flutter lấy bài viết từ REST API JSONPlaceholder, chuyển JSON thành model và hiển thị bằng FutureBuilder + ListView.builder. Đã hoàn thành Lab 8.1–8.4 và phần POST tùy chọn. Toàn bộ ứng dụng nằm trong `lib/main.dart`; chỉ dùng Flutter SDK và package `http` theo đề.

## Chạy

Mở thư mục `Lab8` trong Android Studio hoặc VS Code:

```powershell
flutter pub get
flutter run
```

Trên web:

```powershell
flutter run -d chrome
```

Android đã khai báo quyền INTERNET trong manifest chính, áp dụng cả bản release. Cần kết nối Internet để gọi API.

DartPad: tạo pad Flutter và dán toàn bộ `lib/main.dart`, với package `http` được hỗ trợ. File không phụ thuộc vào ảnh, asset hoặc mã nguồn nội bộ khác. Chưa kiểm tra trực tiếp trên DartPad và chưa tạo share link.

## Đối chiếu đề

| Phần | Minh chứng trong main.dart |
| --- | --- |
| Lab 8.1 | `ApiService.fetchPosts()` gọi GET bằng `http.Client` đến `https://jsonplaceholder.typicode.com/posts` |
| Lab 8.2 | `Post` có id, userId, title, body; `factory Post.fromJson()` kiểm tra kiểu; `json.decode(utf8.decode(response.bodyBytes))`; chuyển JSON array thành `List<Post>` |
| Lab 8.2 | `PostListScreen` dùng `ListView.builder`, hiển thị ID, title và phần xem trước body |
| Lab 8.3 | Spinner khi waiting, thông báo thân thiện cho lỗi kết nối / HTTP / timeout / JSON sai; nút Retry và trạng thái danh sách rỗng |
| Lab 8.4 | Lớp `ApiService` riêng; inject `http.Client` qua constructor để kiểm thử; Future được tạo trong initState và lưu lại, không GET lại mỗi lần build |
| Bonus | Kéo để refresh, nút refresh, màn hình chi tiết và form POST có validation, loading, báo lỗi và thử lại |

API service quản lý đóng client bằng `close()`. Khi màn hình tự tạo service, nó đóng service trong dispose; khi service được truyền từ ngoài vào, bên gọi chịu trách nhiệm đóng. Request có timeout mặc định 15 giây. Callback setState chỉ cập nhật state đồng bộ.

## POST và dữ liệu mô phỏng

Nhấn biểu tượng dấu cộng để mở form, nhập Title và Body rồi bấm Create post. Form chặn ô trống và khóa gửi lặp khi đang chờ. POST gửi JSON gồm title, body và userId = 1; chấp nhận HTTP 201 và parse model trả về.

JSONPlaceholder là API giả lập: POST phản hồi thành công nhưng không lưu bản ghi thật trên máy chủ. Bài mới được thêm đầu danh sách trong phiên hiện tại, có dòng `Created locally`; đóng hoặc tải lại ứng dụng sẽ mất dữ liệu này. Refresh GET vẫn giữ các mục vừa tạo trong bộ nhớ của màn hình. Rate limit, mất mạng hoặc lỗi máy chủ được hiển thị ở giao diện; không tự động gửi lại POST để tránh gửi lặp.

## Kiểm thử

```powershell
flutter analyze
flutter test
flutter build web --release
```

Đã thực hiện với Flutter 3.47.4 / Dart 3.13.3:

- Analyzer không báo lỗi.
- 20 bài kiểm thử đạt: model, UTF-8, GET, danh sách rỗng, HTTP lỗi, JSON sai, mất kết nối, timeout, payload/status POST, loading, Future không bị gọi lặp, Retry phục hồi, navigation, refresh thất bại, POST validation/success/failure và màn hình nhỏ khi có bàn phím.
- Build web release thành công.
- Trên trình duyệt thực tế: GET tải 100 bài, mở chi tiết đúng nội dung, POST thử nghiệm thành công trả ID 101 và hiển thị mục vừa tạo tại đầu danh sách.
- Chưa chạy trực tiếp trên Android/iOS hoặc DartPad.

Test service dùng `MockClient` từ `package:http/testing.dart`, không cần mockito hoặc thư viện mạng bổ sung. Test không phụ thuộc vào tình trạng API công khai.

## Ảnh minh chứng

| File | Nội dung |
| --- | --- |
| `screenshots/01_loading.jpg` | Spinner và Loading posts |
| `screenshots/02_error.jpg` | Lỗi HTTP 503 với nút Retry |
| `screenshots/03_loaded.jpg` | 100 bài lấy từ API thật |
| `screenshots/04_detail.jpg` | Nội dung đầy đủ của Post #1 |
| `screenshots/05_post_created.jpg` | POST thật thành công; mục ID 101 nằm đầu danh sách |

Hai ảnh loading/error được chụp từ cùng giao diện sản phẩm với client giả lập, giúp tái hiện ổn định các trạng thái khó chụp bằng mạng thật. Ba ảnh còn lại dùng API thật. Client giả lập chỉ nằm trong entrypoint hỗ trợ chụp ảnh `tool/state_preview.dart`; ứng dụng chính không dùng dữ liệu giả khi GET.

Để tái hiện:

```powershell
flutter run -d chrome -t tool/state_preview.dart
```

Thêm `?scenario=loading` hoặc `?scenario=error` vào URL preview. Loading được giữ hai phút; error trả HTTP 503 ở mỗi lần thử. Không có query trên entrypoint này thì ứng dụng dùng API thật như `lib/main.dart`. Muốn chụp lỗi mạng thật, ngắt mạng rồi nhấn refresh ở ứng dụng chính.

## Tài liệu API

- JSONPlaceholder: https://jsonplaceholder.typicode.com/
- http: https://pub.dev/packages/http
