import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/session_model.dart';

class SessionsPage extends StatefulWidget {

  final String token;

  const SessionsPage({
    super.key,
    required this.token,
  });

  @override
  State<SessionsPage> createState() =>
      _SessionsPageState();
}

class _SessionsPageState
    extends State<SessionsPage> {

  bool loading = true;

  List<SessionModel> sessions = [];

  List<SessionModel> filteredSessions = [];

  final TextEditingController
      searchController =
          TextEditingController();

  // =====================================
  // FETCH SESSIONS
  // =====================================

  Future fetchSessions() async {

    try {

      final response = await http.get(

        Uri.parse(
          "http://192.168.0.123:8000/api/teacher/dashboard/",
        ),

        headers: {

          "Authorization":
              "Bearer ${widget.token}",

          "Content-Type":
              "application/json",
        },
      );

      print(response.body);

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        sessions =

            (data["sessions"] as List)

                .map(

                  (session) =>

                      SessionModel.fromJson(
                          session),
                )

                .toList();

        filteredSessions = sessions;

        setState(() {

          loading = false;
        });
      }

      else {

        setState(() {

          loading = false;
        });
      }

    } catch (e) {

      print(e);

      setState(() {

        loading = false;
      });
    }
  }

  // =====================================
  // SEARCH
  // =====================================

  void searchSession(
    String value,
  ) {

    filteredSessions = sessions.where(

      (session) {

        return session.subject

            .toLowerCase()

            .contains(
              value.toLowerCase(),
            );
      },

    ).toList();

    setState(() {});
  }

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    fetchSessions();
  }

  // =====================================
  // UI
  // =====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F6FB),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            const Color(0xFF0039CB),

        title: const Text(

          "Sessions",

          style: TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: loading

          ? const Center(

              child:
                  CircularProgressIndicator(),
            )

          : Column(

              children: [

                // =================================
                // SEARCH BAR
                // =================================

                Padding(

                  padding:
                      const EdgeInsets.all(20),

                  child: Container(

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              20),

                      boxShadow: [

                        BoxShadow(

                          color: Colors.black
                              .withOpacity(0.05),

                          blurRadius: 10,

                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: TextField(

                      controller:
                          searchController,

                      onChanged:
                          searchSession,

                      decoration:
                          InputDecoration(

                        hintText:
                            "Search subject...",

                        prefixIcon:
                            const Icon(

                          Icons.search,

                          color:
                              Color(0xFF0039CB),
                        ),

                        border:
                            OutlineInputBorder(

                          borderRadius:
                              BorderRadius.circular(
                                  20),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // =================================
                // SESSIONS LIST
                // =================================

                Expanded(

                  child:
                      filteredSessions.isEmpty

                          ? const Center(

                              child: Text(

                                "No Sessions Found",

                                style: TextStyle(

                                  fontSize: 20,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            )

                          : ListView.builder(

                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 20,
                              ),

                              itemCount:
                                  filteredSessions
                                      .length,

                              itemBuilder:
                                  (context, index) {

                                final session =
                                    filteredSessions[
                                        index];

                                return Container(

                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 20,
                                  ),

                                  padding:
                                      const EdgeInsets
                                          .all(20),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        Colors.white,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                25),

                                    boxShadow: [

                                      BoxShadow(

                                        color: Colors
                                            .black
                                            .withOpacity(
                                                0.05),

                                        blurRadius: 10,

                                        offset:
                                            const Offset(
                                                0, 4),
                                      ),
                                    ],
                                  ),

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      // =================================
                                      // SUBJECT
                                      // =================================

                                      Row(

                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,

                                        children: [

                                          Expanded(

                                            child: Text(

                                              session
                                                  .subject,

                                              style:
                                                  const TextStyle(

                                                fontSize:
                                                    24,

                                                fontWeight:
                                                    FontWeight.bold,

                                                color: Color(
                                                    0xFF0039CB),
                                              ),
                                            ),
                                          ),

                                          Container(

                                            padding:
                                                const EdgeInsets.symmetric(

                                              horizontal:
                                                  15,

                                              vertical:
                                                  8,
                                            ),

                                            decoration:
                                                BoxDecoration(

                                              color:
                                                  session.isActive

                                                      ? Colors.green

                                                      : Colors.red,

                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                            ),

                                            child: Text(

                                              session.isActive

                                                  ? "ACTIVE"

                                                  : "CLOSED",

                                              style:
                                                  const TextStyle(

                                                color:
                                                    Colors.white,

                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 20),

                                      // =================================
                                      // TEACHER
                                      // =================================

                                      Row(

                                        children: [

                                          const Icon(

                                            Icons.person,

                                            color: Color(
                                                0xFF0039CB),
                                          ),

                                          const SizedBox(
                                              width:
                                                  10),

                                          Text(

                                            session
                                                .teacher,

                                            style:
                                                const TextStyle(

                                              fontSize:
                                                  16,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 12),

                                      // =================================
                                      // CLASSROOM
                                      // =================================

                                      Row(

                                        children: [

                                          const Icon(

                                            Icons.room,

                                            color: Color(
                                                0xFF0039CB),
                                          ),

                                          const SizedBox(
                                              width:
                                                  10),

                                          Text(

                                            session
                                                .classroom,

                                            style:
                                                const TextStyle(

                                              fontSize:
                                                  16,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 12),

                                      // =================================
                                      // DATE
                                      // =================================

                                      Row(

                                        children: [

                                          const Icon(

                                            Icons.calendar_today,

                                            color: Color(
                                                0xFF0039CB),
                                          ),

                                          const SizedBox(
                                              width:
                                                  10),

                                          Text(

                                            session
                                                .date,

                                            style:
                                                const TextStyle(

                                              fontSize:
                                                  16,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 12),

                                      // =================================
                                      // TIME
                                      // =================================

                                      Row(

                                        children: [

                                          const Icon(

                                            Icons.access_time,

                                            color: Color(
                                                0xFF0039CB),
                                          ),

                                          const SizedBox(
                                              width:
                                                  10),

                                          Text(

                                            "${session.startTime} → ${session.endTime}",

                                            style:
                                                const TextStyle(

                                              fontSize:
                                                  16,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 20),

                                      // =================================
                                      // COUNTS
                                      // =================================

                                      Row(

                                        children: [

                                          Expanded(

                                            child: Container(

                                              padding:
                                                  const EdgeInsets.all(
                                                      15),

                                              decoration:
                                                  BoxDecoration(

                                                color:
                                                    Colors.green
                                                        .shade50,

                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18),
                                              ),

                                              child: Column(

                                                children: [

                                                  const Icon(

                                                    Icons.check_circle,

                                                    color:
                                                        Colors.green,

                                                    size: 35,
                                                  ),

                                                  const SizedBox(
                                                      height: 10),

                                                  Text(

                                                    session.presentCount
                                                        .toString(),

                                                    style:
                                                        const TextStyle(

                                                      fontSize:
                                                          24,

                                                      fontWeight:
                                                          FontWeight.bold,

                                                      color:
                                                          Colors.green,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 5),

                                                  const Text(

                                                    "Present",

                                                    style:
                                                        TextStyle(

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                              width: 15),

                                          Expanded(

                                            child: Container(

                                              padding:
                                                  const EdgeInsets.all(
                                                      15),

                                              decoration:
                                                  BoxDecoration(

                                                color:
                                                    Colors.red
                                                        .shade50,

                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18),
                                              ),

                                              child: Column(

                                                children: [

                                                  const Icon(

                                                    Icons.cancel,

                                                    color:
                                                        Colors.red,

                                                    size: 35,
                                                  ),

                                                  const SizedBox(
                                                      height: 10),

                                                  Text(

                                                    session.absentCount
                                                        .toString(),

                                                    style:
                                                        const TextStyle(

                                                      fontSize:
                                                          24,

                                                      fontWeight:
                                                          FontWeight.bold,

                                                      color:
                                                          Colors.red,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 5),

                                                  const Text(

                                                    "Absent",

                                                    style:
                                                        TextStyle(

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 20),

                                      // =================================
                                      // ATTENDANCE LIST
                                      // =================================

                                      ExpansionTile(

                                        tilePadding:
                                            EdgeInsets.zero,

                                        childrenPadding:
                                            const EdgeInsets.only(
                                          top: 10,
                                        ),

                                        title: const Text(

                                          "Attendance List",

                                          style: TextStyle(

                                            fontSize: 18,

                                            fontWeight:
                                                FontWeight.bold,

                                            color:
                                                Color(0xFF0039CB),
                                          ),
                                        ),

                                        leading: const Icon(

                                          Icons.people,

                                          color:
                                              Color(0xFF0039CB),
                                        ),

                                        children:

                                            session.attendances.map(

                                          (attendance) {

                                            final isPresent =

                                                attendance.status
                                                        .toLowerCase() ==

                                                    "present";

                                            return Container(

                                              margin:
                                                  const EdgeInsets.only(
                                                bottom: 12,
                                              ),

                                              padding:
                                                  const EdgeInsets.all(
                                                      14),

                                              decoration:
                                                  BoxDecoration(

                                                color:

                                                    isPresent

                                                        ? Colors.green
                                                            .shade50

                                                        : Colors.red
                                                            .shade50,

                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18),
                                              ),

                                              child: Row(

                                                children: [

                                                  Icon(

                                                    isPresent

                                                        ? Icons
                                                            .check_circle

                                                        : Icons.cancel,

                                                    color:

                                                        isPresent

                                                            ? Colors.green

                                                            : Colors.red,
                                                  ),

                                                  const SizedBox(
                                                      width: 12),

                                                  Expanded(

                                                    child: Column(

                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,

                                                      children: [

                                                        Text(

                                                          attendance.student,

                                                          style:
                                                              const TextStyle(

                                                            fontSize:
                                                                16,

                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                            height: 5),

                                                        Text(

                                                          attendance.status
                                                              .toUpperCase(),

                                                          style:
                                                              TextStyle(

                                                            color:

                                                                isPresent

                                                                    ? Colors
                                                                        .green

                                                                    : Colors
                                                                        .red,

                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },

                                        ).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}