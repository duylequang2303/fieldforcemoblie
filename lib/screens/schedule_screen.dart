import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

/// Màn hình mẫu ScheduleScreen tuân thủ cấu trúc Scaffold mới.
/// Background #F5F5F5 và AppBar Primary Green đã được quản lý bởi AppTheme.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Ghi chú: Nếu dùng go_router (như trong AGENTS.md), 
    // hàm này sẽ gọi context.go() thay vì chỉ set state.
    // Ví dụ:
    // switch (index) {
    //   case 0: context.go('/schedule'); break;
    //   case 1: context.go('/properties'); break;
    //   case 2: context.go('/settings'); break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: 4,
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
                    Icons.event_available,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Job #${1000 + index}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('42 Garden Street, Sydney NSW\n09:00 AM - 11:00 AM'),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Mở chi tiết công việc
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
