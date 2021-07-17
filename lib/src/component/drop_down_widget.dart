import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropdownWidget extends StatelessWidget {
  //const DropdownWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Text('기본메뉴'),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class DropdownList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  color: Colors.transparent,
                ),
              ),),
            Positioned(
              left: 0,
              top: 150,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.white
                  ),
                  child: Text('기본메뉴'),
                ),
            ),
          ],
        ),
      ),
    );
  }
}