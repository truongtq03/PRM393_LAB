// Compile the correct implementation without importing browser APIs on native.
export 'platform_backend_io.dart'
    if (dart.library.js_interop) 'platform_backend_web.dart';
