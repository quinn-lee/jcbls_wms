import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/outbound_scanning_request.dart';
import 'package:jcbls_app/http/request/outbound_review_request.dart';
import 'package:jcbls_app/http/request/outbound_wave_request.dart';

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

  // 出库 - 出库扫描
  static scanning(String num) async {
    BaseRequest request = OutboundScanningRequest();
    request.add("num", num);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 出库-波次列表（待取件,一票一件）
  static waitToPick() async {
    BaseRequest request = OutboundWaveRequest();
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
