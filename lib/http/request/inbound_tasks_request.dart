import 'package:jcbls_app/http/request/base_request.dart';

class InboundTasksRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.GET;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return "/api/v1/inbound/tasks";
  }
}
