import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/outbound_review_request.dart';

class OutboundDao {
  // 出库 - 复核扫描
  static review(String shpmtNum, String skuCode) async {
    BaseRequest request = OutboundReviewRequest();
    request.add("shpmt_num", shpmtNum);
    request.add("sku_code", skuCode);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
