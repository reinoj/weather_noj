class CityInfo {
  final int id;
  final String cityName;
  final String stateName;
  final String gridId;
  final int gridX;
  final int gridY;
  final int time;
  // final int current;
  // final List<List<int>> forecast;
  // final List<int> hourly;
  // final int infoTime;
  // final int weatherTime;

  CityInfo({
    required this.id,
    required this.cityName,
    required this.stateName,
    required this.gridId,
    required this.gridX,
    required this.gridY,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'CityName': cityName,
      'StateName': stateName,
      'GridId': gridId,
      'GridX': gridX,
      'GridY': gridY,
      'Time': time,
    };
  }

  CityInfo.fromMap(Map<String, dynamic> res)
      : id = res["Id"],
        cityName = res["CityName"],
        stateName = res["StateName"],
        gridId = res["GridId"],
        gridX = res["GridX"],
        gridY = res["GridY"],
        time = res["Time"];
}
