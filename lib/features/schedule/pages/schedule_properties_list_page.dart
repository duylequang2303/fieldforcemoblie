import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../models/schedule_property.dart';
import '../services/properties_service.dart';

class SchedulePropertiesListPage extends StatefulWidget {
  const SchedulePropertiesListPage({super.key});

  @override
  State<SchedulePropertiesListPage> createState() =>
      _SchedulePropertiesListPageState();
}

class _SchedulePropertiesListPageState
    extends State<SchedulePropertiesListPage> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ScheduleProperty> _all = [];
  List<ScheduleProperty> _filtered = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  bool _isAuthError = false;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _isAuthError = false;
      _currentPage = 0;
      _hasMore = true;
    });
    try {
      final list = await PropertiesService.instance.fetchProperties();
      if (!mounted) return;
      setState(() {
        _all = list;
        _filtered = list;
        _loading = false;
        _hasMore = list.length >= PropertiesService.defaultPageSize;
      });
    } on OdooAuthException catch (e) {
      logger.w('PropertiesListPage: session expired', error: e);
      if (!mounted) return;
      setState(() {
        _error = 'Session expired — please log in again';
        _isAuthError = true;
        _loading = false;
      });
    } on OdooConnectionException catch (e) {
      logger.w('PropertiesListPage: connection error', error: e);
      if (!mounted) return;
      setState(() {
        _error = 'No connection — ${e.message}';
        _isAuthError = false;
        _loading = false;
      });
    } catch (e) {
      logger.e('PropertiesListPage: unexpected error', error: e);
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isAuthError = false;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    
    setState(() => _loadingMore = true);
    
    try {
      _currentPage++;
      final nextPage = await PropertiesService.instance
          .fetchPropertiesPaginated(page: _currentPage);
      
      if (!mounted) return;
      
      setState(() {
        if (nextPage.isEmpty) {
          _hasMore = false;
        } else {
          _all.addAll(nextPage);
          _filtered = _search.text.isEmpty 
              ? _all 
              : _all.where((p) => _matchesSearch(p)).toList();
          _hasMore = nextPage.length >= PropertiesService.defaultPageSize;
        }
        _loadingMore = false;
      });
    } catch (e) {
      logger.e('PropertiesListPage: failed to load more', error: e);
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  bool _matchesSearch(ScheduleProperty p) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return p.address.toLowerCase().contains(q) ||
        p.ownerName.toLowerCase().contains(q) ||
        p.suburb.toLowerCase().contains(q);
  }

void _onSearch(String q) {
    setState(() {
      if (q.trim().isEmpty) {
        _filtered = _all;
      } else {
        final s = q.trim().toLowerCase();
        _filtered = _all.where((p) =>
            p.address.toLowerCase().contains(s) ||
            p.ownerName.toLowerCase().contains(s) ||
            p.suburb.toLowerCase().contains(s)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final weak = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Properties',
          style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            color: theme.colorScheme.primary,
            child: TextField(
              controller: _search,
              onChanged: _onSearch,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search properties',
                hintStyle: TextStyle(color: weak),
                prefixIcon: Icon(Icons.search, color: weak),
                suffixIcon: IconButton(
                  onPressed: () {
                    _search.clear();
                    _onSearch('');
                  },
                  icon: Icon(Icons.close, color: weak),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(theme, muted, weak),
    );
  }

  Widget _buildBody(ThemeData theme, Color muted, Color weak) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAuthError ? Icons.lock_outline : Icons.cloud_off_outlined,
                size: 48,
                color: weak,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_isAuthError)
                FilledButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Log In'),
                )
              else
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
          child: Text('No properties found', style: TextStyle(color: muted)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filtered.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
            height: 1, color: theme.dividerColor, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          if (index == _filtered.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final p = _filtered[index];
          return ListTile(
            title: Text(
              p.address,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.suburb.isNotEmpty)
                    Text(p.suburb,
                        style: TextStyle(fontSize: 14, color: muted)),
                  if (p.ownerName.isNotEmpty)
                    Text(p.ownerName,
                        style: TextStyle(fontSize: 14, color: muted)),
                ],
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: weak),
            onTap: () => context.push('/schedule-properties/${p.odooId}', extra: p),
          );
        },
      ),
    );
  }
}