import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// 1. CORS Middleware to allow requests from Flutter Web
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        });
      }
      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type',
      });
    };
  };
}

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/api/status', _statusHandler); // Added for testing connection with frontend

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

// JSON endpoint for your frontend
Response _statusHandler(Request request) {
  return Response.ok(
    '{"status": "online", "project": "Seaweed Guso Quality Classification"}',
    headers: {'content-type': 'application/json'},
  );
}

void main(List<String> args) async {
  // Bind directly to loopback (localhost)
  final ip = InternetAddress.loopbackIPv4;

  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on http://localhost:${server.port}');
}