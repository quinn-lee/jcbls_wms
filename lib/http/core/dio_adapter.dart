import 'package:dio/dio.dart';
import 'package:jcbls_app/http/core/hi_error.dart';
import 'package:jcbls_app/http/core/hi_net_adapter.dart';
import 'package:jcbls_app/http/request/base_request.dart';

// Dio适配器
class DioAdapter extends HiNetAdapter {
  @override
  Future<HiNetResponse<T>> send<T>(BaseRequest request) async {
    dynamic response,
        options = Options(
            headers: request.header,
            sendTimeout: 90 * 1000,
            receiveTimeout: 90 * 1000);
    // dynamic error;
    try {
      if (request.httpMethod() == HttpMethod.POST) {
        if (request.formData != null) {
          response = await Dio()
              .post(request.url(), data: request.formData, options: options);
        } else {
          response = await Dio()
              .post(request.url(), data: request.params, options: options);
        }
      } else if (request.httpMethod() == HttpMethod.DELETE) {
        if (request.formData != null) {
          response = await Dio()
              .delete(request.url(), data: request.formData, options: options);
        } else {
          response = await Dio()
              .delete(request.url(), data: request.params, options: options);
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        return buildRes(e.response as Response, request) as HiNetResponse<T>;
      } else {
        throw HiNetError(-1, e.toString(), data: null);
      }
    }

    return buildRes(response, request) as HiNetResponse<T>;
  }

  // 构建HiNetResponse
  HiNetResponse buildRes(Response? response, BaseRequest request) {
    return HiNetResponse(
        data: response?.data,
        request: request,
        statusCode: response?.statusCode,
        statusMessage: response?.statusMessage,
        extra: response);
  }
}
