import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {

  final VoidCallback onScan;

  final VoidCallback onSessions;

  const QuickActions({
    super.key,
    required this.onScan,
    required this.onSessions,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        Expanded(

          child: GestureDetector(

            onTap: onScan,

            child: Container(

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(

                gradient:
                    const LinearGradient(

                  colors: [

                    Color(0xFF0039CB),
                    Color(0xFF2979FF),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: const Column(

                children: [

                  Icon(

                    Icons.nfc,

                    color: Colors.white,

                    size: 38,
                  ),

                  SizedBox(height: 12),

                  Text(

                    "Scan RFID",

                    style: TextStyle(

                      color: Colors.white,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(

          child: GestureDetector(

            onTap: onSessions,

            child: Container(

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(24),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black
                        .withOpacity(0.05),

                    blurRadius: 10,
                  ),
                ],
              ),

              child: const Column(

                children: [

                  Icon(

                    Icons.calendar_month,

                    color: Color(0xFF0039CB),

                    size: 38,
                  ),

                  SizedBox(height: 12),

                  Text(

                    "Sessions",

                    style: TextStyle(

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}