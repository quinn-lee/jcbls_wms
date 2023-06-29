class InboundTask {
  late int id;
  String? category;
  String? taskNum;
  Map? org;

  InboundTask(this.id, this.category, this.taskNum, this.org);

  InboundTask.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    taskNum = json['task_num'];
    org = json['org'];
  }
}
