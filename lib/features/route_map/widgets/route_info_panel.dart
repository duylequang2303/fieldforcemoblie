import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/route_stop.dart';

/// Panel thông tin lộ trình — hiển thị danh sách điểm dừng theo thứ tự.
class RouteInfoPanel extends StatelessWidget {
  const RouteInfoPanel({
    super.key,
    required this.stops,
    this.onStopTapped,
    this.onNavigateTapped,
  });

  final List<RouteStop> stops;
  final ValueChanged<RouteStop>? onStopTapped;
  final ValueChanged<RouteStop>? onNavigateTapped;

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const Center(
        child: Text(
          'Không có điểm dừng nào trong lộ trình',
          style: TextStyle(color: AppColors.onSurfaceMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: stops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) => _StopTile(
        stop: stops[i],
        isLast: i == stops.length - 1,
        onTap: () => onStopTapped?.call(stops[i]),
        onNavigate: () => onNavigateTapped?.call(stops[i]),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.stop,
    required this.isLast,
    required this.onTap,
    required this.onNavigate,
  });

  final RouteStop stop;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _StepCircle(status: stop.status, seq: stop.sequence + 1),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _lineColor,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Content
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 4),
              elevation: stop.status == StopStatus.current ? 3 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: stop.status == StopStatus.current
                    ? const BorderSide(color: AppColors.primary, width: 1.5)
                    : BorderSide.none,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stop.orderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (stop.distanceFromPrev != null)
                            Text(
                              '${stop.distanceFromPrev!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                        ],
                      ),
                      if (stop.partnerName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            stop.partnerName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ),
                      if (stop.locationName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: AppColors.onSurfaceMuted),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  stop.locationName!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Navigate button or warning message
                              if (stop.latitude != null &&
                                  stop.longitude != null)
                                GestureDetector(
                                  onTap: onNavigate,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.navigation_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              if (stop.latitude == null ||
                                  stop.longitude == null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'Chưa có tọa độ GPS',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _lineColor {
    switch (stop.status) {
      case StopStatus.completed:
        return AppColors.success;
      case StopStatus.current:
        return AppColors.primary;
      default:
        return AppColors.surfaceVariant;
    }
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.status, required this.seq});

  final StopStatus status;
  final int seq;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
        border: Border.all(color: _border, width: 2),
      ),
      child: status == StopStatus.completed
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Center(
              child: Text(
                '$seq',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: status == StopStatus.current
                      ? Colors.white
                      : AppColors.onSurfaceMuted,
                ),
              ),
            ),
    );
  }

  Color get _bg {
    switch (status) {
      case StopStatus.completed:
        return AppColors.success;
      case StopStatus.current:
        return AppColors.primary;
      default:
        return Colors.white;
    }
  }

  Color get _border {
    switch (status) {
      case StopStatus.completed:
        return AppColors.success;
      case StopStatus.current:
        return AppColors.primary;
      default:
        return AppColors.surfaceVariant;
    }
  }
}
