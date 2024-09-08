import 'package:get/get.dart';
import 'package:disaster_management/common/network_manager.dart';

class GeneralBindings extends Bindings{
  @override
  void dependencies() {
Get.put(NetworkManager());
  }
}