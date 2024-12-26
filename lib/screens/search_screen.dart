import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/screens/task_detail_screen.dart';
import '../cubit/search/search_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Hero(
                      tag: 'searchBar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2)
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1)
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]!.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                        size: 20.w,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  SizedBox(width: 15.w),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]!.withOpacity(0.5)
                                            : Colors.white.withOpacity(0.8),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search_rounded,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                            size: 20.w,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (query) {
                                                context
                                                    .read<SearchCubit>()
                                                    .searchTasks(query);
                                              },
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Search tasks...',
                                                hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  fontSize: 16.sp,
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      if (state is SearchInitial) {
                        return SliverFillRemaining(
                          child: _buildEmptyState(
                            context,
                            Icons.search_rounded,
                            'Search for tasks...',
                          ),
                        );
                      } else if (state is SearchLoading) {
                        return SliverFillRemaining(
                          child: _buildLoadingState(),
                        );
                      } else if (state is SearchError) {
                        return SliverFillRemaining(
                          child: _buildEmptyState(
                            context,
                            Icons.error_outline_rounded,
                            'An error occurred',
                          ),
                        );
                      } else if (state is SearchLoaded &&
                          state.results.isEmpty) {
                        return SliverFillRemaining(
                          child: _buildEmptyState(
                            context,
                            Icons.search_off_rounded,
                            'No tasks found',
                          ),
                        );
                      } else if (state is SearchLoaded) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final task = state.results[index];
                              return TweenAnimationBuilder<double>(
                                duration:
                                    Duration(milliseconds: 300 + (index * 50)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: value,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 6.h,
                                        ),
                                        child: _buildTaskItem(context, task),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: state.results.length,
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_showScrollToTop)
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showScrollToTop ? 1.0 : 0.0,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.9),
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: const Icon(Icons.arrow_upward_rounded),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTaskDeletion(BuildContext context, Map<String, dynamic> task) {
    // Store the task for potential undo
    final deletedTask = Map<String, dynamic>.from(task);
    final searchCubit = context.read<SearchCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show snackbar with undo option
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task deleted',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.white,
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.black87,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.deepOrange,
          onPressed: () {
            searchCubit.restoreTask(deletedTask);
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
        ),
        duration: const Duration(seconds: 3),
        elevation: isDark ? 4 : 2,
      ),
    );

    // Delete the task
    searchCubit.deleteTask(deletedTask);
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 80.sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black12,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white38
                          : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) {
    return Dismissible(
      key: Key(task['id'].toString()),
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _handleTaskDeletion(context, task);
        return true;
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TaskDetailScreen(task: task),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color:
                    _getStatusColor(task['status'] ?? 'new').withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task['priority'] ?? 'medium')
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            color:
                                _getPriorityColor(task['priority'] ?? 'medium'),
                            size: 14.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            (task['priority'] ?? 'medium').toUpperCase(),
                            style: TextStyle(
                              color: _getPriorityColor(
                                  task['priority'] ?? 'medium'),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task['status'] ?? 'new')
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(task['status'] ?? 'new'),
                            color: _getStatusColor(task['status'] ?? 'new'),
                            size: 14.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _getStatusText(task['status'] ?? 'new'),
                            style: TextStyle(
                              color: _getStatusColor(task['status'] ?? 'new'),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  task['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                if (task['details']?.toString().isNotEmpty ?? false) ...[
                  SizedBox(height: 8.h),
                  Text(
                    task['details'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      task['time'] ?? 'No Time',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.grey,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      task['date'] ?? 'No Date',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.green;
      case 'archived':
        return Colors.blue;
      case 'new':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Icons.check_circle_rounded;
      case 'archived':
        return Icons.archive_rounded;
      case 'new':
        return Icons.pending_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return 'COMPLETED';
      case 'archived':
        return 'ARCHIVED';
      case 'new':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }
}
