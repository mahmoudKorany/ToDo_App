part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  final String query;
  
  const SearchState({this.query = ''});

  @override
  List<Object> get props => [query];
}

class SearchInitial extends SearchState {
  const SearchInitial() : super(query: '');
}

class SearchLoading extends SearchState {
  const SearchLoading({required String query}) : super(query: query);
}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> results;

  const SearchLoaded({required this.results, required String query}) : super(query: query);

  @override
  List<Object> get props => [results, query];
}

class SearchNoResults extends SearchState {
  const SearchNoResults({required String query}) : super(query: query);
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message, required String query}) : super(query: query);

  @override
  List<Object> get props => [message, query];
}
