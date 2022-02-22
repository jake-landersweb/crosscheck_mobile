import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';

import 'root.dart';

import '../data/root.dart';
import 'package:http/http.dart' as http;

extension TeamCalls on DataModel {
  Future<void> teamUserSeasonsGet(
      String teamId, String email, Function(TeamUserSeasons) completion,
      {VoidCallback? onError}) async {
    var response = await client.fetch("/teams/$teamId/users/$email/tusRaw");

    if (response == null) {
      addIndicator(IndicatorItem.error(
          "There was an issue fetching your team information"));
      if (onError != null) {
        onError();
      }
    } else if (response['status'] == 200) {
      print("Successfully got tus");
      completion(TeamUserSeasons.fromJson(response['body']));
    } else {
      addIndicator(IndicatorItem.error(
          "There was an issue fetching your team information"));
      print(response['message']);
      prefs.remove("teamId");
      if (onError != null) {
        onError();
      }
    }
  }

  Future<void> getTeamRoster(
      String teamId, Function(List<SeasonUser>) completion) async {
    await client.fetch("/teams/$teamId/users").then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the schedule"));
      } else if (response['status'] == 200) {
        print("Successfully fetched schedule");
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the schedule"));
        print(response['message']);
      }
    });
  }

  Future<void> teamUserUpdate(String teamId, String email,
      Map<String, dynamic> body, VoidCallback completion,
      {bool? showMessages}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/users/$email/update", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an issue updating your user record"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully updated user record"));
        completion();
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue updating your user record"));
        print(response['message']);
      }
    });
  }

  Future<void> createTeam(
      Map<String, dynamic> body, Function(Team) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/createTeam", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue creating the team"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully created your team!"));
        completion(Team.fromJson(response['body']));
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue creating the team"));
        print(response['message']);
      }
    });
  }

  Future<void> updateTeam(
      String teamId, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/update", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue updating the team"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully updated your team"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue updating the team"));
        print(response['message']);
      }
    });
  }

  Future<void> createTeamUser(String teamId, Map<String, dynamic> body,
      Function(SeasonUser) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/createUser", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error("There was an issue adding the user"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully added user"));
        completion(SeasonUser.fromJson(response['body']));
      } else {
        addIndicator(IndicatorItem.error("There was an issue adding the user"));
        print(response['message']);
      }
    });
  }

  Future<void> validateUser(String email, Map<String, dynamic> body,
      Future<void> Function(String) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/users/$email/validate", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue joining the team"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully joined team"));
        completion(response['body']);
      } else {
        print(response.toString());
        if (response['status'] < 400) {
          addIndicator(IndicatorItem.error(response['message']));
        } else {
          addIndicator(
              IndicatorItem.error("There was an issue joining the team"));
        }
      }
    });
  }

  Future<void> uploadTeamLogo(
      String teamId, File image, Function(String) completion,
      {VoidCallback? onError}) async {
    Map<String, String> presignedUrlHeaders = {
      'Content-Type': 'application/json'
    };

    // compress the file
    // final extension = p.extension(image.path);
    // print('attempting to compress file ...');
    // // compress the image
    // File? compressedImage = await FlutterImageCompress.compressAndGetFile(
    //   image.absolute.path,
    //   image.absolute.path + 'compressed' + extension,
    //   quality: 50,
    //   format: extension == '.png' ? CompressFormat.png : CompressFormat.jpeg,
    // );
    // // get the byte information
    // File processedFile;
    // if (compressedImage == null) {
    //   print('compress failed, using original file');
    //   processedFile = image;
    // } else {
    //   print('compress was successful, using compressed file');
    //   processedFile = compressedImage;
    // }

    // convert the image to a png
    // img.Image? i = img.decodeImage(image.readAsBytesSync());
    // if (i == null) {
    //   addIndicator(
    //       IndicatorItem.error("There was an issue uploading your logo."));
    //   onError != null ? onError() : null;
    //   return;
    // }
    // img.Image? smaller = img.copyResize(i,
    //     width: i.width > i.height ? 1000 : null,
    //     height: i.width > i.height ? null : 1000);

    // convert the image into a compressed png

    // write in an isolate to not block main thread
    void decodeIsolate(_DecodeParam param) {
      var image = img.decodeImage(param.file.readAsBytesSync())!;
      var smaller = img.copyResize(image,
          width: image.width > image.height ? 1000 : null,
          height: image.width > image.height ? null : 1000);
      param.sendPort.send(smaller);
    }

    var receivePort = ReceivePort();

    await Isolate.spawn(
      decodeIsolate,
      _DecodeParam(image, receivePort.sendPort),
    );

    img.Image smaller = await receivePort.first as img.Image;

    image = image..writeAsBytesSync(img.encodePng(smaller, level: 4));

    // compose the body
    String filename = "$teamId.png";

    Map<String, dynamic> presignedUrlBody = {"filename": filename};

    // get the presigned url to upload the file to
    var presignedUrlResponse = await client.post("/teams/$teamId/uploadLogo",
        presignedUrlHeaders, jsonEncode(presignedUrlBody));

    // check response
    if (presignedUrlResponse == null) {
      onError != null ? onError() : null;
      return;
    }

    if (presignedUrlResponse['status'] != 200) {
      onError != null ? onError() : null;
      return;
    }

    // compose the upload request
    var postUri = Uri.parse(presignedUrlResponse['body']['url']);
    // set request type
    http.MultipartRequest request = http.MultipartRequest("POST", postUri);
    // add the compressed file
    http.MultipartFile multipartFile =
        await http.MultipartFile.fromPath('file', image.path);
    request.files.add(multipartFile);

    // add all fields returned by presigned url request
    request.fields['AWSAccessKeyId'] =
        presignedUrlResponse['body']['fields']['AWSAccessKeyId'];
    request.fields['x-amz-security-token'] =
        presignedUrlResponse['body']['fields']['x-amz-security-token'];
    request.fields['policy'] = presignedUrlResponse['body']['fields']['policy'];
    request.fields['signature'] =
        presignedUrlResponse['body']['fields']['signature'];
    request.fields['key'] = filename;

    // send the request
    http.StreamedResponse uploadResponse = await request.send();

    if (uploadResponse.statusCode != 204) {
      addIndicator(
          IndicatorItem.error("There was an issue uploading your logo."));
      onError != null ? onError() : null;
      return;
    }

    // get the new presinged url
    var urlResponse = await client.fetch("/teams/$teamId/getLogo");
    if (urlResponse == null) {
      addIndicator(
          IndicatorItem.error("There was an issue uploading your logo."));
      onError != null ? onError() : null;
      return;
    }
    if (urlResponse['status'] == 200) {
      addIndicator(IndicatorItem.success("Successfully uploaded image"));
      completion(urlResponse['body']);
      return;
    } else {
      addIndicator(
          IndicatorItem.error("There was an issue uploading your logo."));
      onError != null ? onError() : null;
      return;
    }
  }
}

class _DecodeParam {
  final File file;
  final SendPort sendPort;
  _DecodeParam(this.file, this.sendPort);
}
