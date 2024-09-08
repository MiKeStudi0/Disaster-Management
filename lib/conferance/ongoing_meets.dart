import 'dart:ui';

import 'package:flutter/material.dart';

class ongoingscreen extends StatefulWidget {
  const ongoingscreen({super.key});

  @override
  State<ongoingscreen> createState() => _ongoingscreenState();
}

class _ongoingscreenState extends State<ongoingscreen> {
  @override
  Widget build(BuildContext context) {
  int index = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Current Rescue Teams',
          style: TextStyle(color: Colors.white), // Set title color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(3, -0.2),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 32, 3, 176),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-3, -0.2),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 32, 3, 176),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -1.0),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              Positioned(
                top:
               
               MediaQuery.of(context).size.width / 25 +40,
                // Adjust position based on the size of previous widgets
                              left: 5,
                              right: 0,
                child: Text('Available Rescue Teams', style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),),  ),
                Positioned(
                    top:
               
               MediaQuery.of(context).size.width / 25 +70,
                // Adjust position based on the size of previous widgets
                              left: 5,
                              right: 0,
                  child: Divider(

                    color: Colors.white,
                    thickness: 1,
                  endIndent: 30,
                  )),
              Positioned(
                              top:
               
               MediaQuery.of(context).size.width / 25 ,
                // Adjust position based on the size of previous widgets
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 720, // Adjust height as needed
                                child: ListView(
               scrollDirection: Axis.vertical,
               children: [
                 // Horizontal list items...
                GestureDetector(
                 onTap: () {
                                                                  _showCodeInputDialog(context, index);
                                                                  setState(() {
                                                                    index = index + 1;
                                                                  });
              
                 },
                  child: InkWell(
                                    child: Card(
                   elevation: 5.0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                   ),
                   child: Container(
                       width: MediaQuery.of(context).size.width / 2.5,
                       height: 100,
                       padding: const EdgeInsets.symmetric(
                           horizontal: .0, vertical: .0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment:
                                 MainAxisAlignment.spaceEvenly,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   const Icon(
                                           Icons.call,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Container(
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4.0, vertical: 4.0),
                                 margin: const EdgeInsets.symmetric(
                                     horizontal: 3.0, vertical: 3.0),
                                 child: const Text('Rescue Team S1',
                                     style: TextStyle(
                                         fontSize: 18.0,
                                         fontWeight: FontWeight.bold,
                                         color: Color.fromARGB(
                                             255, 195, 17, 4))),
                               ),
                               
                                 ],
                               ),
                         
                               // SizedBox(height: 5.0),
                               Container(
                                 child: const Column(
                                   crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                   children: [
                                     
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         SizedBox(width: 10.0),
                                         Text(
                                           'Kozhikode  ',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),                                              SizedBox(width: 5.0),
                   
                                         Icon(
                                           Icons.track_changes_outlined,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Text(
                                           '  Koyilandy',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(width: 12.0),
                           // Container(
                           //     child: Row(
                           //   children: [
                           //     const Icon(Icons.location_on,
                           //         color: Color.fromARGB(255, 75, 77, 76)),
                           //     const SizedBox(width: 5.0),
                           //     Text('${data['district']}',
                           //         style: const TextStyle(
                           //           fontSize: 15.0,
                           //           fontWeight: FontWeight.bold,
                           //           // color: Color.fromARGB(153, 23, 1, 1),
                           //         )),
                           //   ],
                           // ))
                         ],
                       ))),
                                  ),
                ),
                              const SizedBox(
                                           height: 8,
                                         ),
              GestureDetector(
                 onTap: () {
                                                                   _showCodeInputDialog(context, index);
                                                                  setState(() {
                                                                    index = index + 1;
                                                                  });
              
                 },
                child: InkWell(
                                  child: Card(
                   elevation: 5.0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                   ),
                   child: Container(
                       width: MediaQuery.of(context).size.width / 2.5,
                       height: 100,
                       padding: const EdgeInsets.symmetric(
                           horizontal: .0, vertical: .0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment:
                                 MainAxisAlignment.spaceEvenly,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   const Icon(
                                           Icons.call,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Container(
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4.0, vertical: 4.0),
                                 margin: const EdgeInsets.symmetric(
                                     horizontal: 3.0, vertical: 3.0),
                                 child: const Text('Rescue Team S2',
                                     style: TextStyle(
                                         fontSize: 18.0,
                                         fontWeight: FontWeight.bold,
                                         color: Color.fromARGB(
                                             255, 195, 17, 4))),
                               ),
                              
                                 ],
                               ),
                         
                               // SizedBox(height: 5.0),
                               Container(
                                 child: const Column(
                                   crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                   children: [
                                     
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         SizedBox(width: 10.0),
                                         Text(
                                           'Kozhikode  ',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),                                              SizedBox(width: 5.0),
                
                                         Icon(
                                           Icons.track_changes_outlined,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Text(
                                           ' Ulliyeri',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(width: 12.0),
                           // Container(
                           //     child: Row(
                           //   children: [
                           //     const Icon(Icons.location_on,
                           //         color: Color.fromARGB(255, 75, 77, 76)),
                           //     const SizedBox(width: 5.0),
                           //     Text('${data['district']}',
                           //         style: const TextStyle(
                           //           fontSize: 15.0,
                           //           fontWeight: FontWeight.bold,
                           //           // color: Color.fromARGB(153, 23, 1, 1),
                           //         )),
                           //   ],
                           // ))
                         ],
                       ))),
                                ),
              ),const SizedBox(
                                           height: 8,
                                         ),
                               GestureDetector(
                 onTap: () {
                                                                  _showCodeInputDialog(context, index);
                                                                  setState(() {
                                                                    index = index + 1;
                                                                  });
              
                 },
              child: InkWell(
               child: Card(
                   elevation: 5.0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                   ),
                   child: Container(
                       width: MediaQuery.of(context).size.width / 2.5,
                       height: 100,
                       padding: const EdgeInsets.symmetric(
                           horizontal: .0, vertical: .0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment:
                                 MainAxisAlignment.spaceEvenly,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   const Icon(
                                           Icons.call,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Container(
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4.0, vertical: 4.0),
                                 margin: const EdgeInsets.symmetric(
                                     horizontal: 3.0, vertical: 3.0),
                                 child: const Text('Rescue Team S3',
                                     style: TextStyle(
                                         fontSize: 18.0,
                                         fontWeight: FontWeight.bold,
                                         color: Color.fromARGB(
                                             255, 195, 17, 4))),
                               ),
                              
                                 ],
                               ),
                         
                               // SizedBox(height: 5.0),
                               Container(
                                 child: const Column(
                                   crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                   children: [
                                     
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         SizedBox(width: 10.0),
                                         Text(
                                           'Kozhikode  ',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),                                              SizedBox(width: 5.0),
              
                                         Icon(
                                           Icons.track_changes_outlined,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Text(
                                           ' Balussery',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(width: 12.0),
                           // Container(
                           //     child: Row(
                           //   children: [
                           //     const Icon(Icons.location_on,
                           //         color: Color.fromARGB(255, 75, 77, 76)),
                           //     const SizedBox(width: 5.0),
                           //     Text('${data['district']}',
                           //         style: const TextStyle(
                           //           fontSize: 15.0,
                           //           fontWeight: FontWeight.bold,
                           //           // color: Color.fromARGB(153, 23, 1, 1),
                           //         )),
                           //   ],
                           // ))
                         ],
                       ))),
                              ),
                               ),
                                GestureDetector(
                 onTap: () {
                                                                _showCodeInputDialog(context, index);
                                                                  setState(() {
                                                                    index = index + 1;
                                                                  });
              
                 },
                  child: InkWell(
                                    child: Card(
                   elevation: 5.0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                   ),
                   child: Container(
                       width: MediaQuery.of(context).size.width / 2.5,
                       height: 100,
                       padding: const EdgeInsets.symmetric(
                           horizontal: .0, vertical: .0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment:
                                 MainAxisAlignment.spaceEvenly,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   const Icon(
                                           Icons.call,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Container(
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4.0, vertical: 4.0),
                                 margin: const EdgeInsets.symmetric(
                                     horizontal: 3.0, vertical: 3.0),
                                 child: const Text('Rescue Team S4',
                                     style: TextStyle(
                                         fontSize: 18.0,
                                         fontWeight: FontWeight.bold,
                                         color: Color.fromARGB(
                                             255, 195, 17, 4))),
                               ),
                               
                                 ],
                               ),
                         
                               // SizedBox(height: 5.0),
                               Container(
                                 child: const Column(
                                   crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                   children: [
                                     
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         SizedBox(width: 10.0),
                                         Text(
                                           'Kozhikode  ',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),                                              SizedBox(width: 5.0),
                   
                                         Icon(
                                           Icons.track_changes_outlined,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Text(
                                           '  Kappad',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(width: 12.0),
                           // Container(
                           //     child: Row(
                           //   children: [
                           //     const Icon(Icons.location_on,
                           //         color: Color.fromARGB(255, 75, 77, 76)),
                           //     const SizedBox(width: 5.0),
                           //     Text('${data['district']}',
                           //         style: const TextStyle(
                           //           fontSize: 15.0,
                           //           fontWeight: FontWeight.bold,
                           //           // color: Color.fromARGB(153, 23, 1, 1),
                           //         )),
                           //   ],
                           // ))
                         ],
                       ))),
                                  ),
                ),
                              const SizedBox(
                                           height: 8,
                                         ),
              GestureDetector(
                 onTap: () {
                                                                   _showCodeInputDialog(context, index);
                                                                  setState(() {
                                                                    index = index + 1;
                                                                  });
              
                 },
                child: InkWell(
                                  child: Card(
                   elevation: 5.0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                   ),
                   child: Container(
                       width: MediaQuery.of(context).size.width / 2.5,
                       height: 100,
                       padding: const EdgeInsets.symmetric(
                           horizontal: .0, vertical: .0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment:
                                 MainAxisAlignment.spaceEvenly,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   const Icon(
                                           Icons.call,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Container(
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4.0, vertical: 4.0),
                                 margin: const EdgeInsets.symmetric(
                                     horizontal: 3.0, vertical: 3.0),
                                 child: const Text('Rescue Team S5',
                                     style: TextStyle(
                                         fontSize: 18.0,
                                         fontWeight: FontWeight.bold,
                                         color: Color.fromARGB(
                                             255, 195, 17, 4))),
                               ),
                              
                                 ],
                               ),
                         
                               // SizedBox(height: 5.0),
                               Container(
                                 child: const Column(
                                   crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                   children: [
                                     
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         SizedBox(width: 10.0),
                                         Text(
                                           'Kozhikode  ',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),                                              SizedBox(width: 5.0),
                
                                         Icon(
                                           Icons.track_changes_outlined,
                                           color: Color.fromARGB(
                                               255, 75, 77, 76),
                                         ),
                                         Text(
                                           ' Atholi',
                                           style: TextStyle(
                                             fontSize: 15.0,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(width: 12.0),
                           // Container(
                           //     child: Row(
                           //   children: [
                           //     const Icon(Icons.location_on,
                           //         color: Color.fromARGB(255, 75, 77, 76)),
                           //     const SizedBox(width: 5.0),
                           //     Text('${data['district']}',
                           //         style: const TextStyle(
                           //           fontSize: 15.0,
                           //           fontWeight: FontWeight.bold,
                           //           // color: Color.fromARGB(153, 23, 1, 1),
                           //         )),
                           //   ],
                           // ))
                         ],
                       ))),
                                ),
              ),const SizedBox(
                                           height: 8,
                                         ),
                              
               ],
                                ),
                              ),
                            ),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _showCodeInputDialog(BuildContext context, int index) async {
  String enteredCode = '';
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Code to verify'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter code'),
          onChanged: (value) {
            enteredCode = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              codeconfirm(enteredCode, context, index);
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );

  // Check if the entered code is correct
}

void codeconfirm(String enteredCode, context, int index) {
  if (enteredCode == '1234') {
    // Navigate to VolunteerList page
   
  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect code')),
    );
  }
}
}
