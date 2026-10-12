// Halaman Home - Morning Ralph + daftar tugas
import 'package:flutter/material.dart';

// StatelessWidget karena tampilannya statis saja
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // warna langsung di sini biar gampang dipahami pemula
    var navy = Color(0xFF101E33);
    var abuBorder = Color(0xFFE9E4DC);
    var abuHint = Color(0xFFB9B3A8);
    var hijauTua = Color(0xFF5ED67E);
    var dotMerah = Color(0xFFE26D5A);
    var dotBiru = Color(0xFF3E8BFF);
    var dotHijau = Color(0xFF4CC38A);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header atas: lingkaran FR + tombol lonceng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: abuBorder),
                  color: Colors.white,
                ),
                child: Text(
                  'FR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: abuBorder),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Icon(Icons.notifications_outlined, size: 20),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 16,
                      width: 1,
                      color: abuBorder,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Icon(Icons.more_horiz, size: 20),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // judul sapaan tengah
          Center(
            child: Text(
              'Morning, Ralph',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Apryl 27, 2026',
              style: TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(height: 14),
          // kotak search bentuk pil
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 13, color: abuHint),
              prefixIcon: Icon(Icons.search, size: 20, color: navy),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: abuBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: hijauTua),
              ),
            ),
          ),
          SizedBox(height: 16),
          // judul section Today
          Row(
            children: [
              Text(
                'Today (3)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
          SizedBox(height: 10),
          // kartu tugas: Design Wireframe
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: abuBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: dotMerah, width: 2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design Wireframe',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 12,
                            color: navy,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Friday 08:00 AM - 09:00 AM',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: abuHint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // kartu tugas: Meet with client
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: abuBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: dotBiru, width: 2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meet with client',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 12,
                            color: navy,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Friday 10:00 AM - 11:00 AM',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: abuHint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // kartu tugas: April content
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: abuBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: dotBiru, width: 2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "April's content selection",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 12,
                            color: navy,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Friday 01:00 PM - 02:00 PM',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: abuHint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // judul section 30 Apr
          Row(
            children: [
              Text(
                '30 Apr (1)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
          SizedBox(height: 10),
          // kartu tugas: Brainstorming
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: abuBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: dotHijau, width: 2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brainstorming session - ideas',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 12,
                            color: navy,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Saturday 08:00 AM - 17:00 PM',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: abuHint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
