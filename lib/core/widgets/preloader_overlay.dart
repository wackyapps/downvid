import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PreloaderOverlayWidget extends StatelessWidget {
  final String preloaderMessage;
  const PreloaderOverlayWidget({super.key, required this.preloaderMessage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: 100.h, width: 100.w, color: Colors.black.withOpacity(0.5)),
        Center(
            child: Container(
                height: 12.h,
                width: 65.w,
                padding: EdgeInsets.all(1.0.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3)),
                    ]),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 5.h,
                          width: 5.h,
                          child: const CircularProgressIndicator()),
                      SizedBox(height: 1.0.h),
                      Text(preloaderMessage,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                    ])))
      ],
    );
  }
}
