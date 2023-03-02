import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:http/http.dart' as http;
import '../client/env.dart' as env;

class LinkPreview {
  late Uri uri;
  late String url;
  LinkMetadata? metadata;
  bool showError = false;

  LinkPreview({required String url}) {
    // clean url
    uri = Uri.parse(_validateUrl(url));
    this.url = uri.toString();
    print(this.url);
  }

  Future<void> fetchMetadata() async {
    try {
      final client = Client();

      // get normal metadata
      metadata = await _getLinkMetadata(client, uri);

      // if twitter, get extra information
      if (url.toLowerCase().contains("twitter.com")) {
        // get tweet information
        var unameExp = RegExp(
            r'(?:https?:\/\/)?(?:www\.)?twitter\.com\/(?:#!\/)?@?([^\/\?\s]*)');
        var username = unameExp.firstMatch(url)?.group(1) ?? "";
        var idExp = RegExp(r'([0-9]+)\/?$');
        var id = idExp.firstMatch(url)?.group(1) ?? "";

        String title = "";
        String description = "";

        if (username.isNotEmpty) {
          title = "@$username";
        } else {
          title = "Visit twitter.com";
        }

        if (id.isNotEmpty) {
          // use twitter api to fetch tweet metadata
          final response = await client.get(
            Uri.parse("https://api.twitter.com/2/tweets/$id"),
            headers: {"Authorization": "Bearer ${env.TWITTER_BEARER_TOKEN}"},
          );
          var body = jsonDecode(response.body)['data'];
          description = body['text'];
        } else {
          description = "Visit twitter to view this content";
        }

        metadata!.title = title;
        metadata!.description = description;
      }
    } catch (error, stacktrace) {
      print("[LINK META] there was an errorL $error\n$stacktrace");
      showError = true;
    }
  }

  Future<LinkMetadata> _getLinkMetadata(Client client, Uri u) async {
    // fetch document data from url
    final response = await client.get(u);
    final document = parse(response.body);

    String? description, title, image, appleIcon, favIcon;

    var elements = document.getElementsByTagName('meta');
    final linkElements = document.getElementsByTagName('link');

    for (var tmp in elements) {
      if (tmp.attributes['property'] == 'og:title') {
        //fetch seo title
        title = tmp.attributes['content'];
      }
      //if seo title is empty then fetch normal title
      if (title == null || title.isEmpty) {
        var vals = document.getElementsByTagName('title');
        if (vals.isNotEmpty) {
          title = document.getElementsByTagName('title')[0].text;
        }
      }

      // fetch seo description
      if (tmp.attributes['property'] == 'og:description') {
        description = tmp.attributes['content'];
      }
      //if seo description is empty then fetch normal description.
      if (description == null || description.isEmpty) {
        //fetch base title
        if (tmp.attributes['name'] == 'description') {
          description = tmp.attributes['content'];
        }
      }

      //fetch image
      if (tmp.attributes['property'] == 'og:image') {
        image = tmp.attributes['content'];
      }
    }

    for (var tmp in linkElements) {
      if (tmp.attributes['rel'] == 'apple-touch-icon') {
        appleIcon = tmp.attributes['href'];
      }
      if (tmp.attributes['rel']?.contains('icon') == true) {
        favIcon = tmp.attributes['href'];
      }
    }

    // if there was no detected favicon in metadata, assume it works here
    favIcon ??= "$url/favicon.ico";

    var m = LinkMetadata(
      title: title,
      description: description,
      image: image,
      appleIcon: appleIcon,
      favIcon: favIcon,
    );

    // if the image is empty, use the favicon or apple touch icon
    if (m.image.isEmpty()) {
      if (appleIcon.isNotEmpty()) {
        m.image = appleIcon;
      } else if (favIcon.isNotEmpty) {
        m.image = favIcon;
      }
    }

    return m;
  }

  _validateUrl(String url) {
    if (url.startsWith('http://') == true ||
        url.startsWith('https://') == true) {
      return url;
    } else {
      return 'https://$url';
    }
  }

  Widget? getImage({double? height, double? width}) {
    if (metadata == null) {
      return null;
    } else {
      if (metadata!.image == null) {
        if (metadata!.favIcon == null) {
          return null;
        } else {
          if (metadata!.favIcon!.split(".").last == "svg") {
            return SizedBox(
              height: height,
              width: width,
              child: SvgPicture.network(
                metadata!.favIcon!.startsWith("/")
                    ? "$url${metadata!.favIcon!}"
                    : metadata!.favIcon!,
              ),
            );
          }
          return CachedNetworkImage(
            imageUrl: metadata!.favIcon!.startsWith("/")
                ? "$url${metadata!.favIcon!}"
                : metadata!.favIcon!,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return Image.asset(
                "assets/launch/x.png",
                height: height,
                width: width,
              );
            },
          );
        }
      } else {
        if (metadata!.image!.split(".").last == "svg") {
          return SizedBox(
            height: height,
            width: width,
            child: SvgPicture.network(
              metadata!.image!,
            ),
          );
        } else {
          return CachedNetworkImage(
            imageUrl: metadata!.image!,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return Image.asset(
                "assets/launch/x.png",
                height: height,
                width: width,
              );
            },
          );
        }
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "metadata": metadata?.toMap(),
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class LinkMetadata {
  String? title;
  String? description;
  String? image;
  String? appleIcon;
  String? favIcon;

  LinkMetadata({
    this.title,
    this.description,
    this.image,
    this.appleIcon,
    this.favIcon,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "image": image,
      "appleIcon": appleIcon,
      "favIcon": favIcon,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
