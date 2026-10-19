# Lab 7 – Building a Signup Form with Validation & Good UX

Ứng dụng Flutter đăng ký tài khoản, hoàn thành Lab 7.1–7.4 trong một file `lib/main.dart`. Không sử dụng package bên thứ ba; `flutter_test` là công cụ kiểm thử thuộc Flutter SDK.

## Chạy ứng dụng

Mở thư mục `Lab7` trong Android Studio hoặc VS Code, chọn thiết bị rồi chạy:

```powershell
flutter pub get
flutter run
```

Chạy trên trình duyệt:

```powershell
flutter run -d chrome
```

Để thử trên DartPad, tạo Flutter pad và dán toàn bộ nội dung `lib/main.dart`. Không cần thêm file hoặc dependency. Chưa tạo share link DartPad.

## Nội dung hoàn thành

| Phần | Triển khai |
| --- | --- |
| Lab 7.1 | `Form`, `GlobalKey<FormState>`, bốn `TextFormField`, nút Create account; gọi `validate()` và `save()` |
| Lab 7.2 | Bắt buộc nhập; email đúng định dạng; mật khẩu tối thiểu 8 ký tự và có chữ số; xác nhận trùng khớp; validator riêng; `AutovalidateMode.onUserInteraction` |
| Lab 7.3 | Bốn `FocusNode`; Next lần lượt qua các ô, Done gửi form; chạm vùng ngoài để ẩn bàn phím; `ListView` cuộn khi mở bàn phím; giải phóng controller và focus node |
| Lab 7.4 | `Future.delayed` 2 giây, email bắt đầu bằng `taken` bị từ chối, không phân biệt hoa thường; lỗi dưới ô email và SnackBar; nút bị vô hiệu hóa kèm spinner khi kiểm tra |
| Bonus | Hiện/ẩn riêng hai ô mật khẩu; chỉ báo Weak / Medium / Strong; focus vào lỗi đầu tiên; khóa sửa dữ liệu trong lúc kiểm tra; autofill |

Form sai bị chặn khi bấm Create account hoặc Done, chưa chạy kiểm tra email. Nút vẫn cho phép bấm để hiển thị lỗi cụ thể. Đổi mật khẩu sẽ kiểm tra lại ô xác nhận. Đổi email sẽ xóa lỗi email đã dùng để có thể thử lại.

Mật khẩu đạt quy tắc bắt buộc được đánh giá Medium. Strong yêu cầu thêm tối thiểu 12 ký tự, chữ hoa, chữ thường và ký tự đặc biệt. Strong chỉ là gợi ý, không phải điều kiện bắt buộc đăng ký.

Đây là mô phỏng phía giao diện, không gọi API, không tạo tài khoản thật và không lưu mật khẩu ra bộ nhớ lâu dài.

## Dữ liệu thử

| Trường hợp | Dữ liệu | Kết quả |
| --- | --- | --- |
| Bỏ trống | Không nhập gì, bấm Create account | Lỗi dưới cả bốn ô |
| Email sai | `an.example.com` | Báo nhập email hợp lệ |
| Mật khẩu ngắn | `abc123` | Yêu cầu tối thiểu 8 ký tự |
| Thiếu chữ số | `abcdefgh` | Yêu cầu ít nhất một chữ số |
| Không trùng | `Flutter123!` / `Flutter124!` | Passwords do not match |
| Thành công | `Nguyen Van An`, `an@example.com`, hai mật khẩu `Flutter123!` | Sau 2 giây hiển thị SnackBar thành công |
| Email đã dùng | `taken.an@example.com`, dữ liệu còn lại hợp lệ | Lỗi This email is already taken; sửa email để thử lại |

## Kiểm tra

```powershell
flutter analyze
flutter test
flutter build web --release
```

Đã chạy với Flutter 3.47.4 / Dart 3.13.3: analyzer không có lỗi, 8 bài kiểm thử đều đạt, build web release thành công. Kiểm thử gồm quy tắc validation, chặn form trống, async thành công/thất bại và thử lại, khóa thao tác khi chờ, Next/Done, hiện mật khẩu và kiểm tra lại xác nhận, cuộn trên màn hình 320 × 568 khi có bàn phím, rời màn hình trong lúc chờ.

Đã kiểm tra trực tiếp bản web ở kích thước 430 × 1000. Chưa chạy trên Android emulator hoặc thiết bị Android; máy hiện chưa chấp nhận đầy đủ Android SDK licenses. Chưa chạy iOS hoặc DartPad trực tiếp.

## Bài nộp

- `lib/main.dart`: toàn bộ ứng dụng, có chú thích vị trí các phần Lab 7.
- `screenshots/01_validation_errors.jpg`: lỗi khi bỏ trống form.
- `screenshots/02_signup_success.jpg`: dữ liệu hợp lệ và SnackBar thành công.
- `screenshots/03_email_taken.jpg`: email đã dùng và thông báo lỗi.
- `test/signup_test.dart`: các bài kiểm thử bằng Flutter SDK.

Các ảnh được chụp trực tiếp từ ứng dụng Flutter chạy trên web. Giải nén ZIP, mở thư mục `Lab7`, chạy `flutter pub get` rồi `flutter run`.
