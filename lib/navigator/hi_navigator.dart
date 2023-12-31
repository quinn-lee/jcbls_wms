import 'package:flutter/material.dart';
import 'package:jcbls_app/page/blue_thermal_print_page.dart';
import 'package:jcbls_app/page/home_page.dart';
import 'package:jcbls_app/page/inbound_mount_list_page.dart';
import 'package:jcbls_app/page/inbound_mount_page.dart';
import 'package:jcbls_app/page/inbound_page.dart';
import 'package:jcbls_app/page/inbound_scanning_page.dart';
import 'package:jcbls_app/page/inbound_tasks_page.dart';
import 'package:jcbls_app/page/inbound_upload_photos_page.dart';
import 'package:jcbls_app/page/inventory_check_operate_page.dart';
import 'package:jcbls_app/page/inventory_check_tasks_page.dart';
import 'package:jcbls_app/page/inventory_page.dart';

import 'package:jcbls_app/page/login_page.dart';
import 'package:jcbls_app/page/outbound_page.dart';
import 'package:jcbls_app/page/outbound_review_page.dart';
import 'package:jcbls_app/page/outbound_scanning_page.dart';
import 'package:jcbls_app/page/outbound_wave_detail_page.dart';
import 'package:jcbls_app/page/outbound_wave_single_page.dart';
import 'package:jcbls_app/page/returned_page.dart';
import 'package:jcbls_app/page/transfer_mount_page.dart';
import 'package:jcbls_app/page/transfer_mount_scan_space_page.dart';
import 'package:jcbls_app/page/transfer_unmount_page.dart';
import 'package:jcbls_app/page/transfer_unmount_scan_space_page.dart';

typedef RouteChangeListener(RouteStatusInfo current, RouteStatusInfo? pre);

pageWrap(Widget child) {
  return MaterialPage(key: ValueKey(child.hashCode), child: child);
}

// 获取routeStatus在页面栈中的位置
int getPageIndex(List<MaterialPage> pages, RouteStatus routeStatus) {
  for (int i = 0; i < pages.length; i++) {
    MaterialPage page = pages[i];
    if (getStatus(page) == routeStatus) {
      return i;
    }
  }
  return -1;
}

// 自定义路由封装，路由状态
enum RouteStatus {
  login,
  home,
  unknown,
  returnedPage,
  inboundPage,
  outboundPage,
  inventoryPage,
  inboundMountListPage,
  inboundMountPage,
  inboundScanningPage,
  inboundTasksPage,
  inboundUploadPhotosPage,
  transferUnmountScanSpacePage,
  transferUnmountPage,
  transferMountScanSpacePage,
  transferMountPage,
  blueThermalPrintPage,
  outboundReviewPage,
  outboundScanningPage,
  outboundWaveSinglePage,
  outboundWaveDetailPage,
  inventoryCheckTasksPage,
  inventoryCheckOperatePage
}

// 获取page 对应的RouteStatus
RouteStatus getStatus(MaterialPage page) {
  if (page.child is LoginPage) {
    return RouteStatus.login;
  } else if (page.child is HomePage) {
    return RouteStatus.home;
  } else if (page.child is ReturnedPage) {
    return RouteStatus.returnedPage;
  } else if (page.child is InventoryPage) {
    return RouteStatus.inventoryPage;
  } else if (page.child is InboundPage) {
    return RouteStatus.inboundPage;
  } else if (page.child is OutboundPage) {
    return RouteStatus.outboundPage;
  } else if (page.child is InboundMountListPage) {
    return RouteStatus.inboundMountListPage;
  } else if (page.child is InboundScanningPage) {
    return RouteStatus.inboundScanningPage;
  } else if (page.child is InboundTasksPage) {
    return RouteStatus.inboundTasksPage;
  } else if (page.child is InboundUploadPhotosPage) {
    return RouteStatus.inboundUploadPhotosPage;
  } else if (page.child is InboundMountPage) {
    return RouteStatus.inboundMountPage;
  } else if (page.child is TransferUnmountScanSpacePage) {
    return RouteStatus.transferUnmountScanSpacePage;
  } else if (page.child is TransferUnmountPage) {
    return RouteStatus.transferUnmountPage;
  } else if (page.child is TransferMountScanSpacePage) {
    return RouteStatus.transferMountScanSpacePage;
  } else if (page.child is TransferMountPage) {
    return RouteStatus.transferMountPage;
  } else if (page.child is BlueThermalPrintPage) {
    return RouteStatus.blueThermalPrintPage;
  } else if (page.child is OutboundReviewPage) {
    return RouteStatus.outboundReviewPage;
  } else if (page.child is OutboundScanningPage) {
    return RouteStatus.outboundScanningPage;
  } else if (page.child is OutboundWaveSinglePage) {
    return RouteStatus.outboundWaveSinglePage;
  } else if (page.child is OutboundWaveDetailPage) {
    return RouteStatus.outboundWaveDetailPage;
  } else if (page.child is InventoryCheckTasksPage) {
    return RouteStatus.inventoryCheckTasksPage;
  } else if (page.child is InventoryCheckOperatePage) {
    return RouteStatus.inventoryCheckOperatePage;
  } else {
    return RouteStatus.unknown;
  }
}

// 路由信息
class RouteStatusInfo {
  final RouteStatus routeStatus;
  final Widget page;

  RouteStatusInfo(this.routeStatus, this.page);
}

///监听路由页面跳转
///感知当前页面是否压后台
class HiNavigator extends _RouteJumpListener {
  static HiNavigator? _instance;

  RouteJumpListener? _routeJump;
  List<RouteChangeListener> _listeners = [];
  RouteStatusInfo? _current;

  //首页底部tab
  RouteStatusInfo? _bottomTab;

  HiNavigator._();

  static HiNavigator getInstance() {
    return _instance ??= HiNavigator._();
  }

  // 首页底部tab切换监听
  void onBottomTabChange(int index, Widget page) {
    _bottomTab = RouteStatusInfo(RouteStatus.home, page);
    _notify(_bottomTab!);
  }

  ///注册路由跳转逻辑
  void registerRouteJump(RouteJumpListener routeJumpListener) {
    _routeJump = routeJumpListener;
  }

  ///监听路由页面跳转
  void addListener(RouteChangeListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  ///移除监听
  void removeListener(RouteChangeListener listener) {
    _listeners.remove(listener);
  }

  @override
  void onJumpTo(RouteStatus routeStatus, {Map? args}) {
    _routeJump?.onJumpTo(routeStatus, args: args);
  }

  ///通知路由页面变化
  void notify(List<MaterialPage> currentPages, List<MaterialPage> prePages) {
    if (currentPages == prePages) return;
    var current =
        RouteStatusInfo(getStatus(currentPages.last), currentPages.last.child);
    _notify(current);
  }

  void _notify(RouteStatusInfo current) {
    // if (current.page is BottomNavigator && _bottomTab != null) {
    //   //如果打开的是首页，则明确到首页具体的tab
    //   current = _bottomTab!;
    // }
    print('hi_navigator:current:${current.page}');
    print('hi_navigator:pre:${_current?.page}');
    _listeners.forEach((listener) {
      listener(current, _current!);
    });
    _current = current;
  }
}

///抽象类供HiNavigator实现
abstract class _RouteJumpListener {
  void onJumpTo(RouteStatus routeStatus, {Map args});
}

typedef OnJumpTo = void Function(RouteStatus routeStatus, {Map? args});

///定义路由跳转逻辑要实现的功能
class RouteJumpListener {
  final OnJumpTo onJumpTo;

  RouteJumpListener({required this.onJumpTo});
}
