import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adstacks Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: DashboardScreen(onToggleTheme: toggleTheme),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const DashboardScreen({super.key, required this.onToggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime focusedDay = DateTime.now();
  bool _showRightSidebar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          if (screenWidth > 1200) {
            // Desktop layout
            return _buildDesktopLayout();
          } else if (screenWidth > 768) {
            // Tablet layout
            return _buildTabletLayout();
          } else {
            // Mobile layout
            return _buildMobileLayout();
          }
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 768) {
            return FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showRightSidebar = !_showRightSidebar;
                });
              },
              backgroundColor: Colors.deepPurple,
              child: Icon(
                _showRightSidebar ? Icons.close : Icons.calendar_today,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Sidebar(),
        const Expanded(child: MainContent()),
        // Right sidebar with toggle functionality
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _showRightSidebar ? 300 : 0,
          child: _showRightSidebar
              ? RightSidebar(
                  focusedDay: focusedDay,
                  onDaySelected: (day) => setState(() => focusedDay = day),
                )
              : null,
        ),
        // Toggle button for right sidebar
        Container(
          width: 40,
          color: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: IconButton(
                  icon: Icon(
                    _showRightSidebar
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    setState(() {
                      _showRightSidebar = !_showRightSidebar;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        const Sidebar(collapsed: true),
        const Expanded(child: MainContent()),
        // Right sidebar as overlay
        if (_showRightSidebar) ...[
          Container(width: 1, color: Colors.grey.shade300),
          SizedBox(
            width: 300,
            child: RightSidebar(
              focusedDay: focusedDay,
              onDaySelected: (day) => setState(() => focusedDay = day),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        const Column(
          children: [
            MobileAppBar(),
            Expanded(child: MainContent()),
          ],
        ),
        // Right sidebar as bottom sheet on mobile
        if (_showRightSidebar)
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            top:
                MediaQuery.of(context).size.height * 0.2, // Start from 20% down
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(blurRadius: 10, color: const Color(0x33000000)),
                ],
              ),
              child: Column(
                children: [
                  // Draggable handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: RightSidebar(
                      focusedDay: focusedDay,
                      onDaySelected: (day) => setState(() => focusedDay = day),
                      compact: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class MobileAppBar extends StatelessWidget {
  const MobileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [BoxShadow(blurRadius: 4, color: const Color(0x1A000000))],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const Expanded(
              child: Text(
                'Adstacks Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatefulWidget {
  final bool collapsed;
  const Sidebar({super.key, this.collapsed = false});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late bool isCollapsed;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    isCollapsed = widget.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          isCollapsed = true;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCollapsed ? 70 : 250,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header with toggle
              GestureDetector(
                onTap: () => setState(() => isCollapsed = !isCollapsed),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: isCollapsed
                      ? const FlutterLogo(size: 40)
                      : Column(
                          children: const [
                            FlutterLogo(size: 50),
                            SizedBox(height: 8),
                            Text(
                              'Adstacks',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // User Profile Section
              _buildUserProfile(),
              const SizedBox(height: 20),

              const Divider(),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    _sidebarTile(Icons.home, 'Home', 0),
                    _sidebarTile(Icons.people, 'Employees', 1),
                    _sidebarTile(Icons.access_time, 'Attendance', 2),
                    _sidebarTile(Icons.insert_chart, 'Summary', 3),
                    _sidebarTile(Icons.info, 'Information', 4),
                    const Divider(),
                    if (!isCollapsed)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        child: Text(
                          'WORKSPACES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    _sidebarTile(Icons.work, 'Adstacks', 5),
                    _sidebarTile(Icons.monetization_on, 'Finance', 6),
                    const Divider(),
                    _sidebarTile(Icons.settings, 'Settings', 7),
                    _sidebarTile(Icons.logout, 'Logout', 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserProfile() {
    return isCollapsed
        ? const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
            ),
          )
        : Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
              ],
            ),
          );
  }

  Widget _sidebarTile(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index
            ? Colors.deepPurple
            : Colors.grey.shade700,
      ),
      title: isCollapsed
          ? null
          : Text(
              title,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.deepPurple : null,
                fontWeight: _selectedIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      hoverColor: Color.lerp(Colors.deepPurple, Colors.transparent, 0.92),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive header
          _buildResponsiveHeader(context),
          const SizedBox(height: 20),

          // Top Project Card
          SizedBox(height: 200, child: TopProjectCard()),
          const SizedBox(height: 16),

          // Middle section - Projects & Creators
          _buildMiddleSection(context),
          const SizedBox(height: 16),

          // Performance Chart
          SizedBox(height: 300, child: PerformanceCard()),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildMiddleSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SizedBox(height: 300, child: AllProjectsCard())),
              const SizedBox(width: 16),
              Expanded(child: SizedBox(height: 300, child: TopCreatorsCard())),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(height: 300, child: AllProjectsCard()),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: TopCreatorsCard()),
            ],
          );
        }
      },
    );
  }
}

class TopProjectCard extends StatelessWidget {
  const TopProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, color: const Color(0x4D6A4CBC))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Top Rating Project',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Trending project and high rating project created by team.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class AllProjectsCard extends StatelessWidget {
  const AllProjectsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      'Technology behind the Blockchain',
      'AI for Healthcare',
      'Metaverse Experience',
      'Mobile App Development',
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'All Projects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) =>
                    _ProjectRow(title: projects[index], index: index + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final String title;
  final int index;
  const _ProjectRow({required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.folder, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Project #$index • See project details',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

class TopCreatorsCard extends StatelessWidget {
  const TopCreatorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final creators = [
      {'name': '@maddison_c21', 'artworks': '9821', 'avatar': 'M'},
      {'name': '@karl.will02', 'artworks': '7032', 'avatar': 'K'},
      {'name': '@andrew', 'artworks': '6421', 'avatar': 'A'},
      {'name': '@sarah_j', 'artworks': '5210', 'avatar': 'S'},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Top Creators',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: creators.length,
                itemBuilder: (context, index) => _CreatorRow(
                  name: creators[index]['name']!,
                  count: creators[index]['artworks']!,
                  avatar: creators[index]['avatar']!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorRow extends StatelessWidget {
  final String name;
  final String count;
  final String avatar;
  const _CreatorRow({
    required this.name,
    required this.count,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.purple.shade100,
            child: Text(
              avatar,
              style: TextStyle(
                color: Colors.purple.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$count artworks',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
                          return value >= 0 && value < months.length
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(months[value.toInt()]),
                                )
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 5),
                        FlSpot(2, 4),
                        FlSpot(3, 7),
                        FlSpot(4, 6),
                      ],
                      barWidth: 3,
                      color: Colors.deepPurple,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withAlpha(25),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minX: 0,
                  maxX: 4,
                  minY: 0,
                  maxY: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightSidebar extends StatelessWidget {
  final DateTime focusedDay;
  final Function(DateTime) onDaySelected;
  final bool compact;

  const RightSidebar({
    super.key,
    required this.focusedDay,
    required this.onDaySelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: compact ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildCalendarCard(context),
          const SizedBox(height: 16),
          _buildBirthdayCard(context),
          const SizedBox(height: 16),
          _buildAnniversaryCard(context),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: compact ? const EdgeInsets.all(8) : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: compact ? 16 : 20,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 14 : 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, focusedDay),
              onDaySelected: (sel, foc) => onDaySelected(sel),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.purple.shade400,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  size: compact ? 16 : 18,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  size: compact ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.purple.shade50,
      child: Padding(
        padding: compact ? const EdgeInsets.all(8) : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎂 Today\'s Birthday',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: compact ? 14 : 16,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 8),
            _buildBirthdayItem('Pooja Mishra', 'UI Designer', context),
            _buildBirthdayItem('Amit Verma', 'Developer', context),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayItem(String name, String role, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: compact ? 16 : 20,
        backgroundColor: Colors.purple.shade100,
        child: Icon(
          Icons.person,
          size: compact ? 14 : 18,
          color: Colors.purple.shade800,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: compact ? 12 : 14,
        ),
      ),
      subtitle: Text(role, style: TextStyle(fontSize: compact ? 10 : 12)),
      trailing: compact
          ? null
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => _showSnackbar(context, 'Birthday', name),
              child: const Text('Wish'),
            ),
    );
  }

  Widget _buildAnniversaryCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.pink.shade50,
      child: Padding(
        padding: compact ? const EdgeInsets.all(8) : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💍 Anniversary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: compact ? 14 : 16,
                color: Colors.pink.shade800,
              ),
            ),
            const SizedBox(height: 8),
            _buildAnniversaryItem('Team Member 1', '5 Years', context),
            _buildAnniversaryItem('Team Member 2', '2 Years', context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnniversaryItem(
    String name,
    String years,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: compact ? 16 : 20,
        backgroundColor: Colors.pink.shade100,
        child: Icon(
          Icons.people,
          size: compact ? 14 : 18,
          color: Colors.pink.shade800,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: compact ? 12 : 14,
        ),
      ),
      subtitle: Text(years, style: TextStyle(fontSize: compact ? 10 : 12)),
      trailing: compact
          ? null
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => _showSnackbar(context, 'Anniversary', name),
              child: const Text('Wish'),
            ),
    );
  }

  void _showSnackbar(BuildContext context, String type, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 You wished $name a Happy $type!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
