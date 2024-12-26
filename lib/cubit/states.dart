abstract class TodoStates {}

class TodoInitialState extends TodoStates {}

class ChangeBottomNavState extends TodoStates {}

class CreateDatabaseState extends TodoStates {}

class InsertDatabaseState extends TodoStates {}

class GetDatabaseState extends TodoStates {}

class ChangeBottomSheetState extends TodoStates {}

class UpdateDatabaseState extends TodoStates {}

class UpdateTaskLoadingState extends TodoStates {}

class UpdateTaskSuccessState extends TodoStates {}

class UpdateTaskErrorState extends TodoStates {}

class DeleteDatabaseState extends TodoStates {}

class DeleteDatabaseErrorState extends TodoStates {}

class DeleteAllTasksState extends TodoStates {}

class FilterTasksLoadingState extends TodoStates {}

class FilterTasksSuccessState extends TodoStates {}

class FilterTasksErrorState extends TodoStates {}

class ChangePriorityState extends TodoStates {}
