import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/empty_state_widget.dart';

/// Màn hình mẫu ScheduleScreen tuân thủ cấu trúc Scaffold mới.
/// Có Loading state, Empty state và Date Navigation Bar theo chuẩn Sortscape.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 0;
  
  // Biến state mô phỏng dữ liệu
  bool _isLoading = false;
  
  // Đổi thành list rỗng [] để test Empty State
  final List<int> _jobs = [1000, 1001, 1002, 1003]; 

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Date Navigation Bar Component
  Widget _buildDateNavigationBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              // TODO: Logic lùi ngày
            },
          ),
          Column(
            children: [
              Text(
                'Hôm nay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '25 Thg 7, 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // TODO: Logic tiến ngày
            },
          ),
        ],
      ),
    );
  }

  /// Main List Component
  Widget _buildJobList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_jobs.isEmpty) {
      return const EmptyStateWidget(
        message: 'Không có công việc nào trong ngày này.',
        icon: Icons.event_available,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.work_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              'Job #${_jobs[index]}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('42 Garden Street, Sydney NSW\n09:00 AM - 11:00 AM'),
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Mở chi tiết công việc
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: Chuyển sang dùng AppLocalizations khi dự án setup xong i18n
        // title: Text(AppLocalizations.of(context)!.schedule),
        title: const Text('Lịch trình'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDateNavigationBar(),
            // Thêm divider nhẹ giữa Date bar và list
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: _buildJobList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
