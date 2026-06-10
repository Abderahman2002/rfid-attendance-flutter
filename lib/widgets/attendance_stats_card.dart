import 'package:flutter/material.dart';

class StudentStatsCard extends StatelessWidget {

  final String number;
  final String title;
  final IconData icon;
  final Color color;

  const StudentStatsCard({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color:
            color.withOpacity(0.08),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(

          color:
              color.withOpacity(0.12),
        ),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withOpacity(
              0.03,
            ),

            blurRadius: 8,

            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // =====================================
          // TOP SECTION
          // =====================================

          Row(

            children: [

              // ICON

              Container(

                width: 48,
                height: 48,

                decoration: BoxDecoration(

                  color:
                      color.withOpacity(
                    0.15,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(

                  icon,

                  color: color,

                  size: 26,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // BADGE

              Expanded(

                child: Align(

                  alignment:
                      Alignment.centerRight,

                  child: Container(

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(

                      color:
                          color.withOpacity(
                        0.15,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: Text(

                      title.toUpperCase(),

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(

                        color: color,

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          // =====================================
          // NUMBER
          // =====================================

          Text(

            number,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(

              color: color,

              fontSize: 40,

              fontWeight:
                  FontWeight.bold,

              height: 1,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // =====================================
          // TITLE
          // =====================================

          Text(

            title,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(

              color:
                  Colors.grey.shade900,

              fontSize: 18,

              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}