import 'dart:convert';

import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/inbound_mount_request.dart';
import 'package:jcbls_app/http/request/wait_to_mount_request.dart';

class InboundDao {
  // 入库-待安放收货信息列表
  static waitToMount({String? skuCode}) async {
    BaseRequest request = WaitToMountRequest();
    String bodyJson;
    if (skuCode != null) {
      bodyJson = json.encode({
        'page': 1,
        'per_page': 10,
        'q': {
          'inbound_sku': {'sku_code': skuCode}
        }
      });
    } else {
      bodyJson = json.encode({'page': 1, 'per_page': 20});
    }
    request.formData = bodyJson;
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 入库-安置库位号
  static mountOperate(int id, String spaceNum) async {
    BaseRequest request = InboundMountRequest();
    request.pathParams = "$id/mount";
    request.add("space_num", spaceNum);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
