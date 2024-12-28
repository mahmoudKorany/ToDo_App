import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/screens/task_detail_screen.dart';
import '../cubit/search/search_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showScrollToTop = false;
  Timer? _messageTimer;
  int _currentMessageIndex = 0;
  bool _isScrolling = false;
  Timer? _scrollDebouncer;

  final List<String> _encouragingMessages = [
    "Let's try something else! Maybe...",
    "Don't worry, we can find it! Try...",
    "No luck yet, but how about...",
    "Time for a different approach! Try...",
    "Nothing here, but let's try...",
  ];

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

    _scrollController.addListener(_handleScroll);

    // Start the timer for message rotation
    _startMessageTimer();
  }

  void _handleScroll() {
    final isNowScrolling = _scrollController.position.isScrollingNotifier.value;

    setState(() {
      _showScrollToTop = _scrollController.offset > 200;
    });

    if (isNowScrolling && !_isScrolling) {
      // Started scrolling
      _isScrolling = true;
      _pauseMessageTimer();
    } else if (!isNowScrolling && _isScrolling) {
      // Stopped scrolling
      _scrollDebouncer?.cancel();
      _scrollDebouncer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isScrolling = false;
          });
          _startMessageTimer();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _messageTimer?.cancel();
    _scrollDebouncer?.cancel();
    super.dispose();
  }

  void _pauseMessageTimer() {
    _messageTimer?.cancel();
  }

  void _startMessageTimer() {
    if (_isScrolling) return;

    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && !_isScrolling) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _encouragingMessages.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String getEncouragingMessage() {
    return _encouragingMessages[_currentMessageIndex];
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
                                            : Colors.white.withOpacity(0.9),
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          context
                                              .read<SearchCubit>()
                                              .searchTasks(value);
                                        },
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search tasks...',
                                          hintStyle: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                            fontSize: 16.sp,
                                          ),
                                          prefixIcon: BlocBuilder<SearchCubit,
                                              SearchState>(
                                            builder: (context, state) {
                                              return Icon(
                                                Icons.search_rounded,
                                                color: Colors.deepOrange,
                                                size: 22.w,
                                              );
                                            },
                                          ),
                                          suffixIcon: BlocBuilder<SearchCubit,
                                              SearchState>(
                                            builder: (context, state) {
                                              return AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: state.query.isNotEmpty
                                                    ? IconButton(
                                                        icon: Icon(
                                                          Icons.clear_rounded,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.grey[300]
                                                              : Colors
                                                                  .grey[600],
                                                          size: 20.w,
                                                        ),
                                                        onPressed: () {
                                                          _searchController
                                                              .clear();
                                                          context
                                                              .read<
                                                                  SearchCubit>()
                                                              .clearSearch();
                                                        },
                                                      )
                                                    : const SizedBox.shrink(),
                                              );
                                            },
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 12.h,
                                          ),
                                        ),
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
                      } else if (state is SearchNoResults ||
                          (state is SearchLoaded && state.results.isEmpty)) {
                        return SliverFillRemaining(
                          child: _buildEmptyState(
                            context,
                            Icons.search_off_rounded,
                            'Oops! Nothing Found ',
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
              right: 16.0.w,
              bottom: 16.0.h,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Create a gradient color for dark mode
    final darkGradientColors = [
      HSLColor.fromColor(primaryColor).withLightness(0.3).toColor(),
      HSLColor.fromColor(primaryColor).withLightness(0.2).toColor(),
    ];

    // Get a random encouraging message
    String getEncouragingMessage() {
      return _encouragingMessages[_currentMessageIndex];
    }

    // Get random search suggestions
    List<String> getSearchSuggestions() {
      final suggestions = [
        ['important', 'urgent'],
        ['today', 'tomorrow'],
        ['work', 'personal'],
        ['meeting', 'call'],
        ['project', 'task'],
      ];
      return suggestions[DateTime.now().millisecond % suggestions.length];
    }

    final searchSuggestions = getSearchSuggestions();

    return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Container(
                              padding: EdgeInsets.all(28.r),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? LinearGradient(
                                        colors: darkGradientColors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isDark
                                    ? null
                                    : Colors.grey[100]!.withOpacity(0.7),
                                shape: BoxShape.circle,
                                boxShadow: isDark
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.2),
                                          blurRadius: 25,
                                          spreadRadius: 1,
                                        ),
                                        const BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (message.contains('No tasks found'))
                                    ...List.generate(3, (index) {
                                      return TweenAnimationBuilder<double>(
                                        duration: Duration(
                                            milliseconds: 1500 + (index * 200)),
                                        tween: Tween(begin: 0.4, end: 0.8),
                                        curve: Curves.easeInOut,
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: Container(
                                              width: (80 + (index * 20)).w,
                                              height: (80 + (index * 20)).h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark
                                                      ? primaryColor
                                                          .withOpacity(0.1 +
                                                              (index * 0.05))
                                                      : primaryColor
                                                          .withOpacity(0.1),
                                                  width: isDark ? 2.5 : 2,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).reversed,
                                  Icon(
                                    icon,
                                    size: 64.sp,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : primaryColor.withOpacity(0.8),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Column(
                                children: [
                                  Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      letterSpacing: 0.5,
                                      shadows: isDark
                                          ? [
                                              const Shadow(
                                                color: Colors.black38,
                                                offset: Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  if (message.contains('Nothing Found')) ...[
                                    SizedBox(height: 12.h),
                                    Text(
                                      getEncouragingMessage(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black45,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: searchSuggestions
                                          .map(
                                            (suggestion) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 10.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: isDark
                                                      ? LinearGradient(
                                                          colors: [
                                                            primaryColor
                                                                .withOpacity(
                                                                    0.2),
                                                            primaryColor
                                                                .withOpacity(
                                                                    0.15),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        )
                                                      : null,
                                                  color: isDark
                                                      ? null
                                                      : Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? primaryColor
                                                            .withOpacity(0.3)
                                                        : primaryColor
                                                            .withOpacity(0.2),
                                                    width: isDark ? 1.5 : 1,
                                                  ),
                                                  boxShadow: isDark
                                                      ? [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 8,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      suggestion ==
                                                              searchSuggestions
                                                                  .first
                                                          ? Icons
                                                              .star_outline_rounded
                                                          : Icons
                                                              .schedule_rounded,
                                                      size: 18.sp,
                                                      color: isDark
                                                          ? Colors.white
                                                              .withOpacity(0.9)
                                                          : primaryColor
                                                              .withOpacity(0.7),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      '"$suggestion"',
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color: isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.9)
                                                            : Colors.black54,
                                                        fontWeight: isDark
                                                            ? FontWeight.w500
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
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
                    TaskDetailScreen(
                        task: TaskModel(
                  id: task['id'],
                  title: task['title'],
                  time: task['time'],
                  date: task['date'],
                  status: task['status'],
                  details: task['details'],
                  priority: task['priority'],
                  category: task['category'],
                )),
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
