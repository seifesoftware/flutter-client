import 'package:invoiceninja_flutter/data/models/task_status_model.dart';
import 'package:invoiceninja_flutter/redux/static/static_state.dart';
import 'package:memoize/memoize.dart';
import 'package:built_collection/built_collection.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/ui/list_ui_state.dart';

var memoizedDropdownTaskStatusList = memo5(
    (BuiltMap<String, TaskStatusEntity> taskStatusMap,
            BuiltList<String> taskStatusList,
            StaticState staticState,
            BuiltMap<String, UserEntity> userMap,
            String clientId) =>
        dropdownTaskStatusesSelector(
            taskStatusMap, taskStatusList, staticState, userMap, clientId));

List<String> dropdownTaskStatusesSelector(
    BuiltMap<String, TaskStatusEntity> taskStatusMap,
    BuiltList<String> taskStatusList,
    StaticState staticState,
    BuiltMap<String, UserEntity> userMap,
    String clientId) {
  final list = taskStatusList.where((taskStatusId) {
    final taskStatus = taskStatusMap[taskStatusId];
    /*
    if (clientId != null && clientId > 0 && taskStatus.clientId != clientId) {
      return false;
    }
    */
    return taskStatus.isActive;
  }).toList();

  list.sort((taskStatusAId, taskStatusBId) {
    final taskStatusA = taskStatusMap[taskStatusAId];
    final taskStatusB = taskStatusMap[taskStatusBId];
    return taskStatusA.compareTo(
      sortAscending: true,
      sortField: TaskStatusFields.name,
      taskStatus: taskStatusB,
    );
  });

  return list;
}

var memoizedFilteredTaskStatusList = memo3(
    (BuiltMap<String, TaskStatusEntity> taskStatusMap,
            BuiltList<String> taskStatusList,
            ListUIState taskStatusListState) =>
        filteredTaskStatusesSelector(
            taskStatusMap, taskStatusList, taskStatusListState));

List<String> filteredTaskStatusesSelector(
    BuiltMap<String, TaskStatusEntity> taskStatusMap,
    BuiltList<String> taskStatusList,
    ListUIState taskStatusListState) {
  final list = taskStatusList.where((taskStatusId) {
    final taskStatus = taskStatusMap[taskStatusId];

    if (!taskStatus.matchesStates(taskStatusListState.stateFilters)) {
      return false;
    }
    return taskStatus.matchesFilter(taskStatusListState.filter);
  }).toList();

  list.sort((taskStatusAId, taskStatusBId) {
    return taskStatusMap[taskStatusAId].compareTo(
      taskStatus: taskStatusMap[taskStatusBId],
      sortField: taskStatusListState.sortField,
      sortAscending: taskStatusListState.sortAscending,
    );
  });

  return list;
}

bool hasTaskStatusChanges(TaskStatusEntity taskStatus,
        BuiltMap<String, TaskStatusEntity> taskStatusMap) =>
    taskStatus.isNew
        ? taskStatus.isChanged
        : taskStatus != taskStatusMap[taskStatus.id];
