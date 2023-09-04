import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/inventory_check_operate_request.dart';
import 'package:jcbls_app/http/request/inventory_check_tasks_request.dart';

class InventoryDao {
  // 盘点任务-待操作列表
  static checkTasks({String? taskNum}) async {
    BaseRequest request = InventoryCheckTasksRequest();
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

  // 盘点任务-添加盘点信息
  static checkOperate(int id, String skuCode, int quantity) async {
    BaseRequest request = InventoryCheckOperateRequest();
    request.pathParams = "$id/operate";
    request.add("sku_code", skuCode);
    request.add("quantity_increment", quantity);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
