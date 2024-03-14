import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';
import 'package:timeaccess_qrcode/utils/helper.dart';

class AdminPasswordBottomSheet extends StatefulWidget {
  const AdminPasswordBottomSheet({super.key});

  @override
  State<AdminPasswordBottomSheet> createState() => _AdminPasswordBottomSheetState();
}

class _AdminPasswordBottomSheetState extends State<AdminPasswordBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          40.height,
          PinCodeTextField(
            autoFocus: true,
            appContext: context,
            length: 6,
            animationCurve: Curves.easeIn,
            obscureText: true,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              fieldHeight: 70.h,
              fieldWidth: 40.w,
              borderWidth: 1.w,
              activeFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              selectedFillColor: Colors.white,
              inactiveColor: const Color(0xFFC9D0D8),
              activeColor: const Color(0xFFC9D0D8),
              selectedColor: const Color(0xFF01ADCF),
            ),
            showCursor: false,
            enableActiveFill: true,
            keyboardType: TextInputType.number,
            onCompleted: (code) {
              if (code == Constants.adminPassword) {
                Helper.finish(context, true);

              } else {
                Helper.finish(context);
                Helper.showToast("Invalid Password", false);
              }
            },
          ),
          40.height,
        ],
      ),
    );
  }
}
