import 'package:jcbls_app/http/request/base_request.dart';

class TransferMaxMountQtyRequest extends BaseRequest {
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
    return "/api/v1/inventories/transfer/get_max_mount_quantity";
  }
}
