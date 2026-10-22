# Lab 8B – Weather Companion

## Mô tả ứng dụng

Chọn Scenario A – Weather Companion App. Ứng dụng giúp người dùng xem thời tiết nơi sắp đến và quyết định có nên mang ô, chuẩn bị trang phục gì, hoặc chọn hoạt động ngoài trời/trong nhà. Người dùng có thể chọn TP.HCM, Hà Nội, Đà Nẵng hoặc tìm thành phố khác trên thế giới.

Dữ liệu lấy trực tiếp từ Open-Meteo Forecast API và Geocoding API bằng package `http`. Giao diện hiển thị nhiệt độ, cảm giác như, độ ẩm, gió, xác suất mưa cao nhất ngày, dự báo ba ngày và các gợi ý có giải thích ngắn. Không yêu cầu API key cho cách sử dụng học tập này.

## Chạy ứng dụng

Mở thư mục `Lab8B` trong Android Studio hoặc VS Code:

```powershell
flutter pub get
flutter run
```

Chạy trên trình duyệt:

```powershell
flutter run -d chrome
```

Android đã khai báo quyền INTERNET trong manifest chính để gọi API cả ở bản release. Ứng dụng không truy cập GPS: thành phố được chọn thủ công hoặc qua tìm kiếm. Dự án được tổ chức thành nhiều file, không thể dán riêng `main.dart` vào DartPad để chạy toàn bộ.

## Cách sử dụng

1. Khi mở ứng dụng, thời tiết TP.HCM được tải từ API thật.
2. Chọn chip Hà Nội/Đà Nẵng để tải dữ liệu của thành phố đó; hoặc nhập ít nhất hai ký tự và nhấn biểu tượng tìm kiếm/phím Search.
3. Chọn một địa điểm trong danh sách kết quả. Thông tin tỉnh/thành và quốc gia giúp phân biệt các nơi trùng tên.
4. Đọc phần **Chuẩn bị cho hôm nay** và kéo xuống xem dự báo ba ngày.
5. Nhấn nút tải lại hoặc kéo trang xuống để refresh. Nếu lỗi, nhấn **Thử lại**. Tìm kiếm không có kết quả vẫn giữ thông tin thời tiết đang xem.

## Đối chiếu yêu cầu

| Yêu cầu | Triển khai |
| --- | --- |
| REST API thật, dùng http | Hai GET endpoint Open-Meteo; URL/query được xây bằng Uri.https |
| Model + fromJson | City, CurrentWeather, ForecastDay, WeatherReport; kiểm tra kiểu, số hữu hạn, miền giá trị và chiều dài các mảng dự báo |
| UI có mục đích | Ba gợi ý về ô/áo mưa, trang phục và hoạt động trong ngày, kèm lý do dựa trên model |
| Loading | Spinner riêng cho tải thời tiết và tìm địa điểm |
| Lỗi + Retry | Thông báo thân thiện cho HTTP, timeout, kết nối, JSON hoặc dữ liệu sai; nút Thử lại |
| Dữ liệu rỗng | Không có thành phố trùng tên và không có dự báo được xử lý riêng |
| Service Layer | WeatherService chứa toàn bộ HTTP và JSON parsing; UI không gọi http trực tiếp |
| FutureBuilder | Future tải thời tiết được cache trong state; FutureBuilder riêng cho kết quả tìm kiếm |
| Form / ListView | Form tìm kiếm, ListView chính cuộn toàn bộ nội dung và ListView.builder cho dự báo |
| UX bổ sung | Refresh, ba địa điểm chọn nhanh, bố cục một/hai cột theo LayoutBuilder, đơn vị và múi giờ rõ ràng |

## Cấu trúc mã nguồn

```text
lib/
  main.dart                       WeatherApp và theme
  models/weather.dart             Model, mô tả mã WMO và WeatherAdvice
  services/weather_service.dart   WeatherService, WeatherException
  screens/weather_screen.dart     Search, FutureBuilder, chọn nơi, Retry
  widgets/weather_widgets.dart    Dashboard, forecast và status sections
test/
  fixtures.dart                   JSON mẫu chỉ dùng trong test
  model_and_service_test.dart     Kiểm thử model/service/quy tắc gợi ý
  weather_screen_test.dart        Kiểm thử các luồng giao diện
tool/state_preview.dart          Entry point hỗ trợ chụp loading/error
screenshots/                     Ảnh minh chứng
```

Service hỗ trợ inject `http.Client` để test bằng MockClient có sẵn trong package http. Khi màn hình tự tạo service, dispose sẽ đóng client; nếu service được truyền từ bên ngoài, bên gọi chịu trách nhiệm đóng. Có timeout mặc định 15 giây. Mỗi Future được lưu lại; phản hồi muộn của thành phố cũ không được hiển thị đè lên thành phố vừa chọn. Lỗi tìm kiếm đến ngay trước khi FutureBuilder mới được gắn vào cây widget cũng được xử lý.

## API đã tích hợp

**Geocoding**

```text
GET https://geocoding-api.open-meteo.com/v1/search
name=<city>&count=8&language=vi&format=json
```

Đọc `results` thành List<City>. Không có trường results nghĩa là không có kết quả. Tên ngắn hơn hai ký tự không được gửi đi.

**Forecast**

```text
GET https://api.open-meteo.com/v1/forecast
latitude=<lat>&longitude=<lon>&timezone=auto&forecast_days=3
current=temperature_2m,relative_humidity_2m,apparent_temperature,
        precipitation,weather_code,wind_speed_10m
daily=weather_code,temperature_2m_max,temperature_2m_min,
      precipitation_probability_max
temperature_unit=celsius&wind_speed_unit=kmh&precipitation_unit=mm
```

Thông tin thời gian hiển thị theo trường `current.time` và `timezone` của API. Nhiệt độ dùng °C, gió km/h. Xác suất mưa là giá trị cao nhất trong ngày, không phải tỷ lệ thời gian trong ngày có mưa. Không có xác suất sẽ hiển thị **Chưa có dữ liệu**, không tự đổi thành 0%.

## Quy tắc gợi ý

Đây là các quy tắc minh họa của ứng dụng, không phải API trả sẵn lời khuyên:

- Ô/áo mưa: lượng giáng thủy hiện tại > 0, mã WMO báo mưa/tuyết/dông hiện tại hoặc trong ngày, hoặc xác suất mưa cao nhất ngày từ 40%. Lý do hiển thị điều kiện dẫn tới gợi ý.
- Trang phục: cảm giác như từ 32°C thì chọn đồ thoáng nhẹ; dưới 20°C thì mang áo khoác; còn lại là trang phục nhẹ, dễ điều chỉnh.
- Hoạt động: ưu tiên trong nhà nếu có dông; tránh vận động giữa trưa nếu nhiệt độ cảm nhận hoặc mức cao nhất ngày từ 35°C; chọn nơi kín gió nếu gió hiện tại từ 35 km/h; chuẩn bị phương án trong nhà nếu có mưa/tuyết. Nếu có sương mù/mã chưa hỗ trợ thì kiểm tra điều kiện trước khi đi. Còn lại có thể cân nhắc đi bộ.

Nguồn dữ liệu được ghi ở cuối giao diện: Open-Meteo và GeoNames. Các chip chọn nhanh chỉ chứa tên/tọa độ; thời tiết của chúng luôn được gọi từ API thật.

## Kiểm tra

```powershell
flutter analyze
flutter test
flutter build web --release
```

Đã chạy bằng Flutter 3.47.4 / Dart 3.13.3: analyzer không báo lỗi, 25 bài kiểm thử đều đạt và build web release thành công. Kiểm thử gồm model, parse UTF-8, lỗi HTTP/JSON, timeout, tìm kiếm rỗng/sai, Retry, đổi thành phố, phản hồi cũ đến muộn, các quy tắc gợi ý và khả năng cuộn ở 320 × 568 / 1024 × 1000 px.

Đã thử trên trình duyệt với API thật: tải thời tiết TP.HCM, tìm London, chọn Luân Đôn và nhận dữ liệu/múi giờ tương ứng, thử chuỗi không có kết quả. Đã kiểm tra trực tiếp bố cục 1024 × 1100 và 430 × 1100 px. Chưa chạy trực tiếp trên Android hoặc iOS.

## Ảnh minh chứng

- `01_loading.jpg`: trạng thái chờ tải thời tiết.
- `02_error.jpg`: lỗi HTTP 503 và nút Thử lại.
- `03_weather_and_advice.jpg`: dữ liệu API thật, dự báo và gợi ý thực tế cho TP.HCM.
- `04_city_search.jpg`: tìm thành phố bằng Geocoding API thật.
- `05_empty_search.jpg`: tìm kiếm thực tế không có kết quả.
- `06_phone.jpg`: bố cục điện thoại.
- `07_selected_city.jpg`: thời tiết và gợi ý thay đổi sau khi chọn Luân Đôn từ API thật.

Hai ảnh loading/error dùng cùng UI với client giả lập riêng để tái hiện ổn định. Các ảnh thành công, tìm kiếm và bố cục dùng API thật. Ứng dụng chính không trộn dữ liệu fixture của test vào dữ liệu sản phẩm.

Để chụp lại hai trạng thái chờ/lỗi:

```powershell
flutter run -d chrome -t tool/state_preview.dart
```

Thêm `?scenario=loading` hoặc `?scenario=error` vào URL. Loading được giữ hai phút; error trả 503 mỗi lần thử. Không có query thì entrypoint hỗ trợ này cũng gọi API thật. Bản chạy mặc định `lib/main.dart` luôn dùng API thật.

## Tài liệu nguồn

- Forecast, đơn vị, mã WMO: https://open-meteo.com/en/docs
- Tìm địa điểm và cấu trúc results: https://open-meteo.com/en/docs/geocoding-api
- HTTP client / MockClient: https://pub.dev/packages/http
