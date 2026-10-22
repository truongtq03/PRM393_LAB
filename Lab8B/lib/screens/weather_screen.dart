import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../widgets/weather_widgets.dart';

class WeatherScreen extends StatefulWidget {
  final WeatherService? service;
  const WeatherScreen({super.key, this.service});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _searchKey = GlobalKey<FormState>();
  final _query = TextEditingController();
  late final WeatherService _service;
  late Future<WeatherReport> _weatherFuture;
  Future<List<City>>? _searchFuture;
  City _city = presetCities.first;
  String _lastQuery = '';

  Future<T> _observe<T>(Future<T> request) {
    // A new search section may mount next frame. Observe fast failures now;
    // FutureBuilder still receives the original error when it subscribes.
    request.ignore();
    return request;
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WeatherService();
    _weatherFuture = _observe(_service.fetchWeather(_city));
  }

  @override
  void dispose() {
    _query.dispose();
    if (widget.service == null) _service.close();
    super.dispose();
  }

  void _search() {
    if (!_searchKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _lastQuery = _query.text.trim();
      _searchFuture = _observe(_service.searchCities(_lastQuery));
    });
  }

  void _select(City city) {
    FocusScope.of(context).unfocus();
    setState(() {
      _city = city;
      _searchFuture = null;
      _query.clear();
      _weatherFuture = _observe(_service.fetchWeather(city));
    });
  }

  Future<void> _refresh() async {
    final future = _service.fetchWeather(_city);
    setState(() {
      _weatherFuture = future;
    });
    try {
      await future;
    } catch (_) {/* FutureBuilder shows the error. */}
  }

  String _error(Object? error) => error is WeatherException
      ? error.message
      : 'Có lỗi xảy ra. Vui lòng thử lại.';

  Widget _loading(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(text)
        ]),
      );

  Widget _searchResults() => FutureBuilder<List<City>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return _loading('Đang tìm địa điểm…');
          if (snapshot.hasError)
            return StatusSection(
                icon: Icons.search_off,
                title: 'Không tìm được địa điểm',
                message: _error(snapshot.error),
                onRetry: () => setState(() {
                      _searchFuture =
                          _observe(_service.searchCities(_lastQuery));
                    }));
          final cities = snapshot.data ?? [];
          if (cities.isEmpty)
            return StatusSection(
                icon: Icons.location_off_outlined,
                title: 'Không có kết quả',
                message:
                    'Không tìm thấy “$_lastQuery”. Thử tên khác hoặc chọn thành phố bên dưới.');
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chọn địa điểm (${cities.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...cities.map((city) => Card(
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(city.name),
                            subtitle: Text(city.subtitle),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _select(city)))),
                  ]));
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Weather Companion'), actions: [
          IconButton(
              tooltip: 'Tải lại thời tiết',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh)),
        ]),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  const Text('Hôm nay nên chuẩn bị gì?',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                      'Chọn nơi bạn đến, xem dự báo và lên kế hoạch trong ngày.'),
                  const SizedBox(height: 20),
                  Form(
                      key: _searchKey,
                      child: TextFormField(
                        controller: _query,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (_) => _search(),
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                            labelText: 'Tìm thành phố',
                            hintText: 'Ví dụ: London, Tokyo, Hà Nội',
                            prefixIcon: const Icon(Icons.location_city),
                            suffixIcon: IconButton(
                                tooltip: 'Tìm địa điểm',
                                onPressed: _search,
                                icon: const Icon(Icons.search))),
                        validator: (value) =>
                            value == null || value.trim().length < 2
                                ? 'Nhập ít nhất 2 ký tự.'
                                : null,
                      )),
                  if (_searchFuture != null) _searchResults(),
                  const SizedBox(height: 12),
                  Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: presetCities
                          .map((city) => ChoiceChip(
                                label: Text(city.name),
                                selected: _city.sameLocation(city),
                                onSelected: (_) => _select(city),
                              ))
                          .toList()),
                  const SizedBox(height: 22),
                  FutureBuilder<WeatherReport>(
                      future: _weatherFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return _loading('Đang tải thời tiết ${_city.name}…');
                        }
                        if (snapshot.hasError)
                          return StatusSection(
                              icon: Icons.cloud_off_outlined,
                              title: 'Chưa tải được thời tiết',
                              message: _error(snapshot.error),
                              onRetry: _refresh);
                        final report = snapshot.data;
                        if (report == null || report.days.isEmpty)
                          return StatusSection(
                              icon: Icons.inbox_outlined,
                              title: 'Chưa có dữ liệu dự báo',
                              message: 'Thử tải lại hoặc chọn địa điểm khác.',
                              onRetry: _refresh);
                        return WeatherDashboard(city: _city, report: report);
                      }),
                  const SizedBox(height: 24),
                  const Text(
                      'Dữ liệu thời tiết: Open-Meteo • Địa danh: GeoNames',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF536275))),
                  const SizedBox(height: 6),
                  const SelectableText('open-meteo.com • geonames.org',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                ],
              )),
        ))),
      );
}
