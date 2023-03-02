import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crosscheck_sports/data/link_preview.dart';
import 'package:crosscheck_sports/views/chat/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';

class MessageCell extends StatefulWidget {
  const MessageCell({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<MessageCell> createState() => _MessageCellState();
}

class _MessageCellState extends State<MessageCell>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive =>
      widget.message.img.isNotEmpty() ||
      widget.message.video.isNotEmpty() ||
      _url != null;

  File? _videoThumbnail;

  String? _url;
  LinkPreview? linkPreview;
  late String _message;

  @override
  void initState() {
    _handleAssets();
    var urlResults = _getUrl();
    _url = urlResults.v1();
    _message = urlResults.v2();
    super.initState();
  }

  void _handleAssets() async {
    var cacheManager = DefaultCacheManager();

    // handle images
    if (widget.message.img.isNotEmpty()) {
      var file = await cacheManager.getFileFromCache(widget.message.img!);

      if (file != null) {
        setState(() {
          // set as empty because it will not be used
          widget.message.presignedImgUrl = "";
        });
      } else {
        var success =
            await widget.message.getPresignedImgUrl(context.read<DataModel>());
        if (success) {
          setState(() {});
        }
      }
      file = null;
      return;
    }

    // handle videos
    if (widget.message.video.isNotEmpty()) {
      // await cacheManager.removeFile(widget.message.videoImageName());
      // check if a thumbnail for this video exists in cache
      var fileInfo =
          await cacheManager.getFileFromCache(widget.message.videoImageName());
      if (fileInfo == null) {
        // create a thumbnail
        var success = await widget.message
            .getPresignedVideoUrl(context.read<DataModel>());
        if (success) {
          final uint8list = await VideoThumbnail.thumbnailData(
            video: widget.message.presignedVideoUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 300,
            quality: 100,
          );
          if (uint8list != null) {
            // write thumbnail to cache
            var file = await cacheManager.putFile(
              "",
              uint8list,
              key: widget.message.videoImageName(),
            );
            setState(() {
              _videoThumbnail = file;
            });
            print(
                "successfully saved video screenshot in cache named: ${widget.message.videoImageName()}");
          } else {
            print("FAILED TO GET THUMBNAIL");
          }
        } else {
          print("FAILED TO GET PRESIGNED URL");
        }
      } else {
        print("video thumbnail exists in cache");
        // thumbnail exists in cache
        print("SIZE = ${fileInfo.file.lengthSync()}");
        setState(() {
          _videoThumbnail = fileInfo.file;
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ChatModel cmodel = Provider.of<ChatModel>(context);
    return _body(context, dmodel, cmodel);
  }

  Widget _body(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Column(
      key: ValueKey(widget.message.messageId),
      crossAxisAlignment: widget.message.email == cmodel.email
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // header
        Row(
          textDirection: cmodel.email == widget.message.email
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            Text(
              widget.message.sender,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: CustomColors.random(widget.message.email),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.message.getDynamicDate(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: CustomColors.textColor(context).withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // content
        Row(
          textDirection: cmodel.email == widget.message.email
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            _messageView(context, dmodel, cmodel),
          ],
        ),
      ],
    );
  }

  Widget _messageView(
      BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Column(
      crossAxisAlignment: widget.message.email == cmodel.email
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (widget.message.img != null) _imageView(context, dmodel, cmodel),
        if (widget.message.video != null) _videoView(context, dmodel, cmodel),
        if (_message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: cmodel.email == widget.message.email
                    ? const Radius.circular(10)
                    : const Radius.circular(5),
                topRight: cmodel.email == widget.message.email
                    ? const Radius.circular(5)
                    : const Radius.circular(10),
                bottomLeft: cmodel.email == widget.message.email
                    ? const Radius.circular(10)
                    : const Radius.circular(5),
                bottomRight: cmodel.email == widget.message.email
                    ? const Radius.circular(5)
                    : const Radius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.5),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    textDirection: cmodel.email == widget.message.email
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    children: [
                      Container(
                        // height: double.infinity,
                        width: 7,
                        color: CustomColors.random(widget.message.email),
                      ),
                      Flexible(
                        child: Container(
                          color: CustomColors.cellColor(context),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              widget.message.email == cmodel.email ? 16 : 8,
                              10,
                              widget.message.email == cmodel.email ? 8 : 16,
                              10,
                            ),
                            child: SelectableText(
                              _message,
                              style: TextStyle(
                                color: CustomColors.textColor(context),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_url != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: _linkPreview(context, dmodel),
          ),
        _time(context),
      ],
    );
  }

  Widget _imageView(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.5,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Sprung.overDamped,
          child: widget.message.presignedImgUrl != null
              ? cv.BasicButton(
                  onTap: () => _openAssetView(context),
                  child: Hero(
                    tag: widget.message.img!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.presignedImgUrl!,
                        cacheKey: widget.message.img,
                      ),
                    ),
                  ),
                )
              : const SizedBox(height: 0, width: 0),
        ),
      ),
    );
  }

  Widget _videoView(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Sprung.overDamped,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.5,
          ),
          child: cv.BasicButton(
            onTap: () => _openAssetView(context),
            child: Hero(
              tag: widget.message.video!,
              child: _videoThumbnail != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(_videoThumbnail!),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white.withOpacity(0.8),
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 0, width: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkPreview(BuildContext context, DataModel dmodel) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 1.2,
      ),
      child: cv.BasicButton(
        onTap: () => _launchUrl(dmodel),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 700),
          curve: Sprung.overDamped,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.2,
                maxHeight: linkPreview!.showError ? 75 : 100,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: CustomColors.cellColor(context),
                child: _linkPreviewContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkPreviewContent(BuildContext context) {
    if (linkPreview?.showError ?? false) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CustomColors.textColor(context).withOpacity(0.5),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.priority_high,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "There was an issue loading the link preview",
                  style: TextStyle(
                    fontSize: 14,
                    color: CustomColors.textColor(context).withOpacity(0.5),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: 75,
            child: Row(
              children: [
                linkPreview?.getImage(height: 75, width: 125) ?? Container(),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          linkPreview?.metadata?.title ?? "",
                          maxLines:
                              linkPreview?.metadata?.description.isEmpty() ??
                                      false
                                  ? 2
                                  : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          linkPreview?.metadata?.description ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color:
                CustomColors.invertedBackgroundColor(context).withOpacity(0.1),
            height: 25,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        linkPreview?.uri.host ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _time(BuildContext context) {
    return Text(
      widget.message.getTime(),
      style: TextStyle(
        fontWeight: FontWeight.w400,
        color: CustomColors.textColor(context).withOpacity(0.3),
        fontSize: 12,
      ),
    );
  }

  void _openAssetView(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return AssetView(message: widget.message);
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        fullscreenDialog: true,
        opaque: false,
      ),
    );
  }

  Tuple<String?, String> _getUrl() {
    RegExp exp = RegExp(
        r'((http|ftp|https):\/\/)?([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])');
    RegExpMatch? match = exp.firstMatch(widget.message.message.toLowerCase());

    if (match != null) {
      // clean url
      var msg = widget.message.message;
      var split = widget.message.message.split(":");
      if (split.length > 1) {
        msg = "${split[0].toLowerCase()}:${split[1]}";
      }
      String url = widget.message.message.substring(match.start, match.end);

      url = url;
      // remove the url from the message
      msg = msg.replaceFirst(match.pattern, '');
      // get the metadata
      _setLinkData(url);
      return Tuple<String?, String>(url, msg);
    } else {
      return Tuple<String?, String>(null, widget.message.message);
    }
  }

  void _setLinkData(String url) async {
    linkPreview = LinkPreview(url: url);
    await linkPreview!.fetchMetadata();
    setState(() {});
  }

  Future<void> _launchUrl(DataModel dmodel) async {
    if (!await launchUrl(Uri.parse(linkPreview!.url))) {
      dmodel.addIndicator(IndicatorItem.error("Could not load url"));
    }
  }
}
