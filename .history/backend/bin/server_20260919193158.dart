import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        'Access-Control-Allow-Private-Network': 'true',
      };

      // Handle browser preflight checks
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}

final _router = Router()
  ..get('/', (Request req) => Response.ok('Server is running\n'))
  ..get('/api/status', (Request req) {
    return Response.ok(
      '{"status": "online", "project": "Seaweed Guso Quality Classification"}',
      headers: {'content-type': 'application/json'},
    );
  });

void main(List<String> args) async {
  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  
  // Bind explicitly to IPv4 loopback
  final server = await serve(handler, InternetAddress.loopbackIPv4, port);
  print('Server listening on http://127.0.0.1:${server.port}');
}