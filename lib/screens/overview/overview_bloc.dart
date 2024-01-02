import "dart:async";
import "dart:convert";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:kisgeri24/data/converter/route_route_dto_converter.dart";
import "package:kisgeri24/data/converter/sector_sector_dto_converter.dart";
import "package:kisgeri24/data/converter/year_year_dto_converter.dart";
import "package:kisgeri24/data/dto/challenge_view.dart";
import "package:kisgeri24/data/dto/sector_dto.dart";
import "package:kisgeri24/data/models/sector.dart";
import "package:kisgeri24/data/models/user.dart";
import "package:kisgeri24/data/models/year.dart";
import "package:kisgeri24/data/notification/user_notification.dart";
import "package:kisgeri24/data/repositories/challenge_repository.dart";
import "package:kisgeri24/data/repositories/sector_repository.dart";
import "package:kisgeri24/data/repositories/year_repository.dart";
import "package:kisgeri24/logging.dart";
import "package:kisgeri24/screens/overview/dto/overview_dto.dart";
import "package:kisgeri24/services/authenticator.dart";
import "package:kisgeri24/services/challenge_service.dart";
import "package:kisgeri24/services/firebase_service.dart";
import "package:kisgeri24/services/sector_service.dart";
import "package:kisgeri24/services/year_service.dart";

part "overview_event.dart";

part "overview_state.dart";

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final Converter<Sector, SectorDto> sectorToSectorDtoConverter =
      SectorToSectorDtoConverter(RouteToRouteDtoConverter());

  OverviewBloc() : super(OverviewInitial()) {
    on<LoadDataEvent>((event, emit) async {
      await _load(timerStarted: event._timer == null).then((value) {
        emit(value);
      });
    });
  }

  Future<OverviewState> _load({bool? timerStarted = false}) async {
    try {
      final List<SectorDto> routes = await fetchSectors();
      final int userPoints = await fetchTeamPoints();
      final notifications = await fetchNotifications();
      final challenges = await fetchChallenges();
      const endTime = 0;

      final overviewData = OverviewDto(
        null,
        routes,
        userPoints,
        notifications,
        challenges,
        endTime,
      );

      return LoadedState(overviewData);
    } catch (error) {
      return ErrorState("Failed to fetch data: $error");
    }
  }

  Future<List<SectorDto>> fetchSectors() async {
    final List<SectorDto> sectors = await SectorService(
      SectorRepository(
        FirebaseSingletonProvider.instance.firestoreInstance,
      ),
      SectorToSectorDtoConverter(
        RouteToRouteDtoConverter(),
      ),
    ).getSectorsWithRoutes();
    logger.d("${sectors.length} SectorDto got converted and about to return");
    return Future.value(sectors);
  }

  Future<int> fetchTeamPoints() {
    logger.d("collecting team points");
    return Future.value(1234);
  }

  Future<List<TeamNotification>> fetchNotifications() {
    logger.d("collecting notifications");
    return Future.value([]);
  }

  Future<List<ChallengeView>> fetchChallenges() {
    logger.d("collecting challenges");
    return ChallengeService(
      ChallengeRepository(
        FirebaseSingletonProvider.instance.firestoreInstance,
      ),
    ).getViewsByYear("kzU99Z2APtOBhvNFgPvv");
  }

  Future<int?> getRemainingTimeIfTimerStarted() async {
    logger.d("calculating remaining time");
    final Year yearData = await YearService(
      YearRepository(
        FirebaseSingletonProvider.instance.firestoreInstance,
      ),
      YearToYearDtoConverter(),
    ).getYearByTenantId(
      "kzU99Z2APtOBhvNFgPvv",
    ); // TODO: remove hardcoded tenantId
    final User? currentUser = await Auth(
      FirebaseSingletonProvider.instance.authInstance,
      FirebaseSingletonProvider.instance.firestoreInstance,
    ).getAuthUser();
    if (currentUser != null) {
      logger.d(
        "current user is: $currentUser who has the start time of ${currentUser.startTime}",
      );
      final int remainingTime = yearData.compEnd! - currentUser.startTime;
      logger.d("remaining time is: $remainingTime");
      return remainingTime;
    }
    return Future.value();
  }
}
