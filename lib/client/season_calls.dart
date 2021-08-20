import 'root.dart';

import '../data/root.dart';

extension SeasonCalls on DataModel {
  void seasonUserGet(String teamId, String seasonId, String email,
      Function(SeasonUser) completion,
      {bool? showMessages}) async {
    var response =
        await client.fetch("/teams/$teamId/seasons/$seasonId/users/$email");

    if (response == null) {
      if (showMessages ?? false) {
        setError("There was an issue getting the user record", true);
      }
    } else if (response['status'] == 200) {
      setSuccess("Successfully found season user", false);
      completion(SeasonUser.fromJson(response['body']));
    } else {
      if (showMessages ?? false) {
        setError("There was an issue getting the user record", true);
      }
      print(response['message']);
    }
  }

  Future<void> getSeasonRoster(String teamId, String seasonId,
      Function(List<SeasonUser>) completion) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/users")
        .then((response) {
      if (response == null) {
        setError("There was an issue getting the season roster", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully got season roster", false);
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        setError("There was an issue getting the season roster", true);
        print(response['message']);
      }
    });
  }
}
