import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ScanPage extends StatefulWidget {

  final String token;

  const ScanPage({
    super.key,
    required this.token,
  });

  @override
  State<ScanPage> createState() =>
      _ScanPageState();
}

class _ScanPageState
    extends State<ScanPage> {

  // =====================================
  // CONTROLLER
  // =====================================

  final TextEditingController
      rfidController =
          TextEditingController();

  final FocusNode focusNode =
      FocusNode();

  // =====================================
  // VARIABLES
  // =====================================

  bool loading = false;

  String? error;

  Map<String, dynamic>? lastAttendance;

  List<Map<String, dynamic>>
      recentScans = [];

  // =====================================
  // SCAN RFID
  // =====================================

  Future<void> scanCard() async {

    final uid =
        rfidController.text.trim();

    if (uid.isEmpty) {

      return;
    }

    setState(() {

      loading = true;

      error = null;
    });

    try {

      final data =
          await ApiService
              .scanAttendance(

        widget.token,
        uid,
      );

      // =====================================
      // ERROR
      // =====================================

      if (data["error"] != null) {

        setState(() {

          error = data["error"];

          lastAttendance = null;
        });
      }

      // =====================================
      // SUCCESS
      // =====================================

      else {

        final attendance =
            data["attendance"];

        setState(() {

          lastAttendance =
              attendance;

          error = null;

          recentScans.insert(
            0,
            {

              ...attendance,

              "time":
                  DateTime.now()
                      .toString(),
            },
          );
        });

        ScaffoldMessenger.of(context)

            .showSnackBar(

          SnackBar(

            backgroundColor:
                Colors.green,

            content: Text(

              "${attendance["student"]} scanned successfully",
            ),
          ),
        );
      }

      rfidController.clear();

      focusNode.requestFocus();
    }

    catch (e) {

      setState(() {

        error = e.toString();
      });
    }

    finally {

      setState(() {

        loading = false;
      });
    }
  }

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    Future.delayed(

      const Duration(
        milliseconds: 500,
      ),

      () {

        focusNode.requestFocus();
      },
    );
  }

  // =====================================
  // DISPOSE
  // =====================================

  @override
  void dispose() {

    rfidController.dispose();

    focusNode.dispose();

    super.dispose();
  }

  // =====================================
  // UI
  // =====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F7FC),

      appBar: AppBar(

        backgroundColor:
            const Color(0xFF0047FF),

        foregroundColor:
            Colors.white,

        title: const Text(
          "RFID Scanner",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =====================================
            // HEADER CARD
            // =====================================

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                      25),

              decoration: BoxDecoration(

                gradient:
                    const LinearGradient(

                  colors: [

                    Color(0xFF0047FF),

                    Color(0xFF2979FF),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                        25),
              ),

              child: const Column(

                children: [

                  Icon(

                    Icons.nfc,

                    color: Colors.white,

                    size: 70,
                  ),

                  SizedBox(height: 15),

                  Text(

                    "RFID Attendance",

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize: 28,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(

                    "Real-time attendance system",

                    style: TextStyle(

                      color:
                          Colors.white70,

                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================
            // INPUT
            // =====================================

            TextField(

              controller:
                  rfidController,

              focusNode:
                  focusNode,

              onSubmitted:
                  (_) => scanCard(),

              decoration: InputDecoration(

                hintText:
                    "Scan RFID card...",

                filled: true,

                fillColor:
                    Colors.white,

                prefixIcon:
                    const Icon(

                  Icons.credit_card,

                  color:
                      Color(0xFF0047FF),
                ),

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                          18),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================
            // BUTTON
            // =====================================

            SizedBox(

              width: double.infinity,

              height: 60,

              child: ElevatedButton(

                onPressed:
                    loading

                        ? null

                        : scanCard,

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                          0xFF0047FF),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                ),

                child: loading

                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )

                    : const Text(

                        "SCAN RFID",

                        style: TextStyle(

                          color:
                              Colors.white,

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            // =====================================
            // SUCCESS CARD
            // =====================================

            if (lastAttendance != null)

              Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.all(
                        20),

                decoration: BoxDecoration(

                  color:
                      Colors.green.shade50,

                  borderRadius:
                      BorderRadius.circular(
                          20),

                  border: Border.all(

                    color:
                        Colors.green,
                  ),
                ),

                child: Column(

                  children: [

                    const Icon(

                      Icons.check_circle,

                      color:
                          Colors.green,

                      size: 70,
                    ),

                    const SizedBox(
                        height: 15),

                    const Text(

                      "ACCESS GRANTED",

                      style: TextStyle(

                        color:
                            Colors.green,

                        fontSize: 22,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 15),

                    Text(

                      lastAttendance![
                          "student"],

                      style:
                          const TextStyle(

                        fontSize: 26,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Text(

                      lastAttendance![
                          "subject"],
                    ),

                    Text(

                      lastAttendance![
                          "classroom"],
                    ),
                  ],
                ),
              ),

            // =====================================
            // ERROR CARD
            // =====================================

            if (error != null)

              Container(

                width: double.infinity,

                margin:
                    const EdgeInsets.only(
                        top: 20),

                padding:
                    const EdgeInsets.all(
                        18),

                decoration: BoxDecoration(

                  color:
                      Colors.red.shade50,

                  borderRadius:
                      BorderRadius.circular(
                          18),

                  border: Border.all(

                    color: Colors.red,
                  ),
                ),

                child: Row(

                  children: [

                    const Icon(

                      Icons.error,

                      color: Colors.red,
                    ),

                    const SizedBox(
                        width: 10),

                    Expanded(

                      child: Text(

                        error!,

                        style: const TextStyle(

                          color: Colors.red,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // =====================================
            // RECENT SCANS
            // =====================================

            if (recentScans.isNotEmpty)

              const Text(

                "Recent Scans",

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            ...recentScans.map(

              (attendance) {

                return Container(

                  margin:
                      const EdgeInsets.only(
                          bottom: 15),

                  padding:
                      const EdgeInsets.all(
                          18),

                  decoration:
                      BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                            20),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black
                            .withOpacity(
                                0.05),

                        blurRadius: 10,

                        offset:
                            const Offset(
                                0, 4),
                      ),
                    ],
                  ),

                  child: Row(

                    children: [

                      Container(

                        padding:
                            const EdgeInsets
                                .all(12),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.green
                                  .shade100,

                          shape:
                              BoxShape.circle,
                        ),

                        child: const Icon(

                          Icons.check,

                          color:
                              Colors.green,
                        ),
                      ),

                      const SizedBox(
                          width: 15),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              attendance[
                                  "student"],

                              style:
                                  const TextStyle(

                                fontSize:
                                    18,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            Text(

                              attendance[
                                  "subject"],
                            ),

                            Text(

                              attendance[
                                  "classroom"],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}