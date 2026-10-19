# Lab 6 – Building a Responsive Movie Genre Browsing Screen

Ứng dụng Flutter duyệt phim theo thể loại, hoàn thành Lab 6.1–6.3. Toàn bộ mã ứng dụng nằm trong `lib/main.dart`, có thể dán vào DartPad ở chế độ Flutter. Không dùng package bên thứ ba; bộ kiểm thử chỉ dùng `flutter_test` của Flutter SDK.

## Chạy ứng dụng

Mở thư mục `Lab6` trong Android Studio hoặc VS Code:

```powershell
flutter pub get
flutter run
```

Chạy trên trình duyệt:

```powershell
flutter run -d chrome
```

DartPad: tạo Flutter pad và dán toàn bộ `lib/main.dart`. Chưa tạo share link hoặc kiểm tra trực tiếp trên DartPad.

## Yêu cầu đã hoàn thành

| Phần | Nội dung |
| --- | --- |
| Lab 6.1 | Tiêu đề Find a Movie, phần giới thiệu, SafeArea và khoảng cách thích ứng theo chiều rộng |
| Lab 6.2 | Tìm theo tên không phân biệt hoa thường; Wrap chứa các FilterChip; chọn nhiều thể loại; dropdown A-Z, Z-A, Year, Rating |
| Lab 6.3 | LayoutBuilder chọn danh sách một cột khi chiều rộng khả dụng dưới 800 px; lưới hai cột từ 800 px; LayoutBuilder bên trong card thay đổi kích thước ảnh |
| Bonus | Badge số thể loại đã chọn; hiển thị năm, rating và thể loại; Clear filters; đếm kết quả; trạng thái không có kết quả; ảnh dự phòng khi tải thất bại |

Dữ liệu gồm 6 Movie cố định với title, year, genres, posterUrl và rating. Ảnh mạng là ảnh minh họa từ Unsplash, không phải poster chính thức. Rating và dữ liệu phim chỉ dùng để minh họa tính năng, không lấy từ API.

Tìm kiếm và thể loại kết hợp bằng AND. Khi chọn nhiều thể loại, phim chỉ cần khớp ít nhất một thể loại (OR). Year xếp năm mới nhất trước; Rating xếp điểm cao nhất trước. Các trường hợp bằng nhau được xếp tiếp theo tên A-Z. Hàm `filterMovies` tạo danh sách mới, không sắp xếp trực tiếp trên dữ liệu gốc.

Clear filters xóa cả nội dung TextField, các thể loại đã chọn và đưa sort về A-Z. Nút Clear search chỉ xóa nội dung tìm kiếm.

## Responsive và bàn phím

Dùng một `CustomScrollView` chứa cả bộ lọc và kết quả, với `SliverList` cho một cột và `SliverGrid` cho hai cột. Đây là các thành phần danh sách/lưới bên trong cùng một vùng cuộn, giúp phần bộ lọc không gây tràn khi mở bàn phím hoặc xoay ngang màn hình.

Mốc 800 px được tính trước khi trừ padding, nhất quán cho cả trang. `Expanded` dành không gian còn lại trong card cho thông tin phim. Các hàng điều khiển dùng Wrap, thông tin năm/rating cũng có thể xuống dòng. Chiều cao card trong lưới tăng theo cỡ chữ từ MediaQuery. Controller được dispose khi rời màn hình.

Android release có quyền INTERNET để tải ảnh. Cần kết nối Internet để xem ảnh mạng; khi mất mạng ứng dụng vẫn hiển thị thông tin và biểu tượng ảnh dự phòng.

## Kiểm tra

```powershell
flutter analyze
flutter test
flutter build web --release
```

Đã chạy bằng Flutter 3.47.4 / Dart 3.13.3:

- Analyzer không báo lỗi.
- 15 bài kiểm thử đều đạt: tìm kiếm, OR/AND thể loại, bốn thứ tự sắp xếp, Clear filters, tương tác chip và dropdown, trạng thái rỗng, breakpoint 320/430/799/800/1024 px, xoay ngang với bàn phím, cỡ chữ 200% trên tablet và ảnh dự phòng.
- Build web release thành công.
- Kiểm tra trực tiếp bản web ở 430 × 932 và 1024 × 900, bao gồm thao tác chọn/xóa thể loại.

Chưa chạy Android emulator hoặc thiết bị thật; máy hiện chưa chấp nhận đầy đủ Android SDK licenses. Chưa kiểm tra iOS hoặc desktop.

## Bài nộp

- `lib/main.dart`: toàn bộ mã ứng dụng, có chú thích các phần Lab 6.
- `test/widget_test.dart`: kiểm thử logic và giao diện.
- `screenshots/01_phone.jpg`: bố cục một cột trên điện thoại.
- `screenshots/02_genre_filter.jpg`: chọn Action, hiển thị hai phim phù hợp.
- `screenshots/03_tablet_grid.jpg`: bố cục hai cột trên tablet/web.
