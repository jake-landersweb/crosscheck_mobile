import 'root.dart';

import '../data/root.dart';

extension TeamCalls on DataModel {
  void teamUserSeasonsGet(
      String teamId, String email, Function(TeamUserSeasons) completion) async {
    loadingStatus = LoadingStatus.loading;

    var response = await client.fetch("/teams/$teamId/users/$email/dashboard");

    if (response == null) {
      setError("There was an issue fetching your team information", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got tus", false);
      completion(TeamUserSeasons.fromJson(response['body']));
    } else {
      setError("There was an issue fetching your team information", true);
      print(response['message']);
    }
  }
}
