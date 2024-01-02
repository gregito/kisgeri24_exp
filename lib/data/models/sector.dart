import 'package:flutter/foundation.dart';
import 'package:kisgeri24/data/models/entity.dart';
import 'package:kisgeri24/data/models/route.dart';
import 'package:kisgeri24/data/models/wall.dart';

class Sector extends Entity {
  String name;
  int ordinal;
  List<Wall>? walls;
  List<Route>? routes;

  Sector(this.name, this.ordinal, this.walls, this.routes);

  static Sector fromSnapshot(String name, value) {
    Map placeMap = value as Map<dynamic, dynamic>;
    String placeName = name;
    List<Wall> wallList = [];
    List<Route> routeList = [];

    final int ordinal = placeMap["ordinal"] ?? 0;
    if (_sectorHasSubWall(value)) {
      placeMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final Wall wall = Wall.fromSnapshot(key, value);
          wallList.add(wall);
        }
      });
    } else {
      placeMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final Route route = Route.fromSnapshot(value);
          routeList.add(route);
        }
      });
    }

    return Sector(placeName, ordinal, wallList, routeList);
  }

  static bool _sectorHasSubWall(dynamic value) {
    bool hasSubWall = true;
    value.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final Map<String, dynamic> element = value;
        if (element.containsKey("points")) {
          hasSubWall = false;
          return;
        }
      }
    });
    return hasSubWall;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sector &&
        other.name == name &&
        listEquals(other.routes, routes);
  }

  @override
  int get hashCode => Object.hash(name, routes);

  @override
  String toString() {
    return 'Sector{name: $name, walls: $walls, routes: $routes}';
  }
}
