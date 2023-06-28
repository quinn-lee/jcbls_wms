// 登录
import 'package:jcbls_app/db/hi_cache.dart';
import 'package:jcbls_app/http/core/hi_net.dart';
import 'package:jcbls_app/http/request/base_request.dart';
import 'package:jcbls_app/http/request/token_request.dart';

class LoginDao {
  static const TOKEN = "Token";
  static Future<Map> getToken(String username, String password) async {
    BaseRequest request = TokenRequest();
    request.isLoginApi = true;
    request.add("username", username).add("password", password);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    if (result['code'] == 0) {
      //保存登录令牌
      HiCache.getInstance().setString(TOKEN, result['data']['user']['token']);
      //保存登录邮箱
      HiCache.getInstance()
          .setString("login_email", result['data']['user']['username']);
    } else {
      //登录失败
      HiCache.getInstance().setString(TOKEN, "");
    }
    return result;
  }

  static getCacheToken() {
    return HiCache.getInstance().get(TOKEN);
  }
}
