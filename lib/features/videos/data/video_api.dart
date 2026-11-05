
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../model/video_item.dart';


class VideoApi {
  final Dio _dio;

  VideoApi({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<VideoItem>> fetchVideos() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/videos',
      );

      final data = response.data;

      if (data == null) {
        throw const FormatException(
          'The server returned an empty response',
        );
      }

      return data
          .map(
            (item) => VideoItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    } on DioException catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The request timed out. Please try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to the backend. Check the server and network.';

      case DioExceptionType.badResponse:
        return 'The server returned an error (${error.response?.statusCode}).';

      default:
        return 'Unable to load videos. Please try again.';
    }
  }
}
