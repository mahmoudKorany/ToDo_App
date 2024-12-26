import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final List<Map<String, dynamic>> allTasks;

  SearchCubit({required this.allTasks}) : super(SearchInitial());

  void searchTasks(String query) {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final searchResults = allTasks.where((task) {
      final title = task['title']?.toString() ?? '';
      final body = task['body']?.toString() ?? '';
      final details = task['details']?.toString() ?? '';
      final date = task['date']?.toString() ?? '';
      final time = task['time']?.toString() ?? '';
      final priority = task['priority']?.toString() ?? '';
      final status = task['status']?.toString() ?? '';

      return title.toLowerCase().contains(lowercaseQuery) ||
          body.toLowerCase().contains(lowercaseQuery) ||
          details.toLowerCase().contains(lowercaseQuery) ||
          date.toLowerCase().contains(lowercaseQuery) ||
          time.toLowerCase().contains(lowercaseQuery) ||
          priority.toLowerCase().contains(lowercaseQuery) ||
          status.toLowerCase().contains(lowercaseQuery);
    }).toList();

    if (searchResults.isEmpty) {
      emit(SearchNoResults());
    } else {
      emit(SearchLoaded(results: searchResults));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }

  void deleteTask(Map<String, dynamic> task) {
    // Remove the task from allTasks
    allTasks.removeWhere((t) => t['id'] == task['id']);

    // If we're in a search state, update the search results
    if (state is SearchLoaded) {
      final currentResults = (state as SearchLoaded).results;
      final updatedResults =
          currentResults.where((t) => t['id'] != task['id']).toList();

      if (updatedResults.isEmpty) {
        emit(SearchNoResults());
      } else {
        emit(SearchLoaded(results: updatedResults));
      }
    }
  }

  void restoreTask(Map<String, dynamic> task) {
    // Add the task back to allTasks
    allTasks.add(task);

    // If we're in a search state, update the search results
    if (state is SearchLoaded || state is SearchNoResults) {
      // Re-run the current search to update results
      searchTasks(task['title'] ?? '');
    }
  }
}
