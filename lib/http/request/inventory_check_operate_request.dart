import 'package:jcbls_app/http/request/base_request.dart';

class InventoryCheckOperateRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return "/api/v1/task/check";
  }
}
