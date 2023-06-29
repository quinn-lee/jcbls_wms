import 'dart:convert';

import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/inbound_file_request.dart';
import 'package:jcbls_app/http/request/inbound_mount_request.dart';
import 'package:jcbls_app/http/request/inbound_scanning_request.dart';
import 'package:jcbls_app/http/request/inbound_tasks_request.dart';
import 'package:jcbls_app/http/request/wait_to_mount_request.dart';

class InboundDao {
  // 入库任务列表
  static tasks({String? taskNum}) async {
    BaseRequest request = InboundTasksRequest();
    Map<String, dynamic> bodyJson;
    if (taskNum != null) {
      bodyJson = {'page': 1, 'per_page': 10, "q\[task_num_cont\]": taskNum};
    } else {
      bodyJson = {'page': 1, 'per_page': 30};
    }

    request.formData = bodyJson;
    // 如下方式也有效
    // request.add("q\[task_num_cont\]", "IN230410000007A");
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 入库上传图片
  static uploadPhotos(int id, List files, String category) async {
    BaseRequest request = InboundFileRequest();
    request.pathParams = "$id/app_upload_file";
    request.add("files", files);
    request.add("category", category);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 入库扫描，记录UIN/运单号
  static scanning(String num) async {
    BaseRequest request = InboundScanningRequest();
    request.add("num", num);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

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
