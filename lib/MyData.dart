
class MyData {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  MyData({this.userId, this.id, this.title, this.completed});

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}

