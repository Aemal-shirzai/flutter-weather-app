import 'package:flutter/material.dart';
import 'package:flash/flash.dart';

FlashController<dynamic> currentSnackBar;

void showBasicsFlash({
    @required context,
    Duration duration,
    flashStyle = FlashBehavior.fixed,
    @required String content,
    Icon icon
  }) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        currentSnackBar = controller;
        return Flash(
          controller: controller,
          margin: EdgeInsets.only(top: 25, left: 12, right: 12),
          backgroundColor: Colors.lightBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          enableVerticalDrag: false,
          behavior: flashStyle,
          position: FlashPosition.top,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            icon: icon,
            content: Container(
              child: Text(
                content,
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }