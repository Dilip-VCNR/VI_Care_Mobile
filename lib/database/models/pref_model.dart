import 'package:vicare/dashboard/model/duration_response_model.dart';

import '../../auth/model/register_response_model.dart';
import '../../dashboard/model/offline_test_model.dart';

class PrefModel {
  UserData? userData;
  Duration? selectedDuration;
  List<OfflineTestModel>? offlineSavedTests;

  PrefModel({
    this.userData,
    this.selectedDuration,
    this.offlineSavedTests,
  });

  factory PrefModel.fromJson(Map<String, dynamic> parsedJson) {
    return PrefModel(
      userData: parsedJson["userData"] == null
          ? null
          : UserData.fromJson(parsedJson["userData"]),
      selectedDuration: parsedJson["selectedDuration"] == null
          ? null
          : Duration.fromJson(parsedJson["selectedDuration"]),
      offlineSavedTests: parsedJson["offlineSavedTests"] == null
          ? []
          : List<OfflineTestModel>.from(parsedJson["offlineSavedTests"]
              .map((x) => OfflineTestModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userData": userData?.toJson(),
      "selectedDuration": selectedDuration?.toJson(),
      "offlineSavedTests": offlineSavedTests == null
          ? null
          : List<dynamic>.from(offlineSavedTests!.map((x) => x.toJson())),
    };
  }
}
