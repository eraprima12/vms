import 'package:vms/constant.dart';

bool getIsDriver() {
  return localStorage.read(driverKey) ?? false;
}

void putIsDriver({required bool value}) {
  localStorage.write(driverKey, value);
}
