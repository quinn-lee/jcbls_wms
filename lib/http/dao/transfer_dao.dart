// 移库相关接口
import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/transfer_max_mount_qty_request.dart';
import 'package:jcbls_app/http/request/transfer_max_unmount_qty_request.dart';
import 'package:jcbls_app/http/request/transfer_mount_request.dart';
import 'package:jcbls_app/http/request/transfer_unmount_request.dart';

class TransferDao {
  // 库存-移库-获取最大移库下架数量
  static getMaxUnmountQty(String skuCode, String spaceNum) async {
    BaseRequest request = TransferMaxUnmountQtyRequest();
    request.add("sku_code", skuCode);
    request.add("space_num", spaceNum);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 库存-移库-开始移库并冻结库存
  static unmount(String skuCode, String spaceNum, int unmountQty) async {
    BaseRequest request = TransferUnmountRequest();
    request.add("sku_code", skuCode);
    request.add("space_num", spaceNum);
    request.add("unmount_quantity", unmountQty);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 库存-移库-获取最大移库上架数量
  static getMaxMountQty(String skuCode) async {
    BaseRequest request = TransferMaxMountQtyRequest();
    request.add("sku_code", skuCode);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 库存-移库-结束移库并解冻库存
  static mount(String skuCode, String spaceNum, int unmountQty) async {
    BaseRequest request = TransferMountRequest();
    request.add("sku_code", skuCode);
    request.add("space_num", spaceNum);
    request.add("mount_quantity", unmountQty);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
