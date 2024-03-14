import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeaccess_qrcode/overlay/admin_password_bottom_sheet.dart';
import 'package:timeaccess_qrcode/presentation/device_info_page.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';

class AppInfo extends StatelessWidget {
  final BuildContext parent;

  const AppInfo({super.key, required this.parent});

  adminPasswordHandler() {
    FocusScope.of(parent).requestFocus(FocusNode());
    showModalBottomSheet(
      context: parent,
      elevation: 10,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black.withOpacity(0.2)),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25.w), topRight: Radius.circular(25.w)),
      ),
      builder: (_) => Padding(
        padding: MediaQuery.of(parent).viewInsets,
        child: const AdminPasswordBottomSheet(),
      ),
    ).then((value) {
      if (value != null) {
        const DeviceInfoPage().launch(parent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null,
      onLongPress: () {
        adminPasswordHandler();
      },
      child: Text(
        "Copyright \u00a9 ${DateTime.now().year} PNG Time Access",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}
