// import 'package:flutter/material.dart';
// import 'package:flutter_app/provider/pole_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_app/model/pole.dart';

// class SmartPoleAppBar extends StatelessWidget implements PreferredSizeWidget {
//   // Implementing preferredSize to match AppBar's height
//   @override
//   final Size preferredSize;

//   final String title;
//   final TextStyle? titleStyle;

//   const SmartPoleAppBar({
//     super.key,
//     required this.title,
//     required this.titleStyle,
//   }) : preferredSize = const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title, // Use the title parameter here
//         style: titleStyle ??
//             const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//       ),
//       backgroundColor: Colors.deepPurpleAccent,
//       actions: [
//         choosePoleDropdownBuild(),
//       ],
//     );
//   }

//   Widget choosePoleDropdownBuild() => Consumer<PoleProvider>(
//         builder: (context, poleProvider, child) => SizedBox(
//           width: 150, // Set the width
//           height: 60, // Set the height
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: poleProvider.selectedPole,
//               dropdownColor: Colors.white,
//               alignment: Alignment.center,
//               icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   poleProvider.setSelectedPole(newValue);
//                 }
//               },
//               // This controls the color and style of the selected item shown in the button
//               selectedItemBuilder: (BuildContext context) =>
//                   poles.map<Widget>((String value) {
//                 return Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Text(
//                       value,
//                       style: const TextStyle(
//                         color: Colors.white, // Color of selected item in button
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//               focusColor: Colors.transparent, // Color
//               items: poles
//                   .map<DropdownMenuItem<String>>(
//                     (String value) => DropdownMenuItem<String>(
//                       value: value,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Text(
//                           value,
//                           style: const TextStyle(
//                             color: Colors.black, // Dropdown item text color
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ),
//       );
// }
