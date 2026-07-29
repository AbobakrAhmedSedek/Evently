
import 'package:flutter/material.dart';
 
class LocationItem extends StatelessWidget {
 final  Widget child;
  const LocationItem({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
     return Row(

       children: [
                SizedBox( width: 20,),

         child,
       ],
     );
      // Column(
    //   children: [
    //     SizedBox(height: height * 0.01),
    //     // ✅ عرض الموقع مع حالة التحميل
    //     child,
    //   ],
    // );
  }
}
