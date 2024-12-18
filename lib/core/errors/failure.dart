import 'package:checkout/core/errors/error_message_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String errorMessage;

  const Failures(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class ServerFailure extends Failures {
  const ServerFailure(super.errorMessage);

  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('Connection timeout with the server.');
      case DioExceptionType.sendTimeout:
        return const ServerFailure('Send timeout with the server.');
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Receive timeout with the server.');
      case DioExceptionType.badCertificate:
        return const ServerFailure('Bad certificate from the server.');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response?.statusCode, dioError.response?.data);
      case DioExceptionType.cancel:
        return const ServerFailure('Request was canceled.');
      case DioExceptionType.connectionError:
        return const ServerFailure('No Internet connection.');
      case DioExceptionType.unknown:
      default:
        return const ServerFailure('An unexpected error occurred.');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == null) {
      return const ServerFailure('Received invalid status code from server.');
    }

    switch (statusCode) {
      case 400:
        return ServerFailure(
          'Bad request: ${ErrorModel.fromJson(response).error.message}',
        );
      case 401:
        return const ServerFailure('Unauthorized: Please log in.');
      case 403:
        return const ServerFailure('Forbidden: Access denied.');
      case 404:
        return const ServerFailure('Resource not found.');
      case 422:
        return ServerFailure(
          ErrorModel.fromJson(response).error.message,
        );
      case 429:
        return const ServerFailure(
            'Too many requests. Please try again later.');
      case 500:
        return const ServerFailure('Internal server error. Please try later.');
      case 503:
        return const ServerFailure('Service unavailable. Try again later.');
      default:
        return ServerFailure('Unexpected error: $statusCode');
    }
  }
}
