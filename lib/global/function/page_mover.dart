import 'package:flutter/material.dart';
import 'package:vms/constant.dart';

abstract class MovePageContract {
  push({required Widget widget});
  pushAndRemove({required Widget widget});
  pushAndReplace({required Widget widget});
  pop();
}

class MovePageHandler implements MovePageContract {
  @override
  pop() {
    Navigator.pop(navigatorKey.currentContext!);
    throw UnimplementedError();
  }

  @override
  push({required Widget widget}) {
    Navigator.push(navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => widget));
    throw UnimplementedError();
  }

  @override
  pushAndRemove({required Widget widget}) {
    Navigator.pushAndRemoveUntil(navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => widget), (route) => false);
  }

  @override
  pushAndReplace({required Widget widget}) {
    Navigator.pushReplacement(navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => widget));
    throw UnimplementedError();
  }
}
