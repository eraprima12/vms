import 'package:vms/constant.dart';

bool getIsDriver() {
  return localStorage.read('isDriver') ?? false;
}

void putIsDriver({required bool value}) {
  localStorage.write(driverKey, value);
}
