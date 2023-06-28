// 获取Token请求
import 'package:jcbls_app/http/request/base_request.dart';

class TokenRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
  }

  @override
  bool needLogin() {
    return false;
  }

  @override
  String path() {
    return "/api/v1/sessions";
  }
}
