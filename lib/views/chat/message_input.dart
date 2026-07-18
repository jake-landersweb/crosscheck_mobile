import 'dart:io';

import 'package:crosscheck_sports/components/core/container.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart'
    show LiquidGlassContainer, LiquidGlassConfig, CNGlassEffectShape;
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../data/root.dart';
import '../../client/root.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/loading_indicator.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.team,
    required this.season,
  });
  final Team team;
  final Season season;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late TextEditingController _controller;
  bool _sending = false;
  File? _videoPreview;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ChatModel cmodel = Provider.of<ChatModel>(context);
    final content = _buildContent(context, dmodel, cmodel);
    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: content,
    );
    if (Platform.isIOS) {
      return LiquidGlassContainer(
        config: const LiquidGlassConfig(
          shape: CNGlassEffectShape.rect,
          cornerRadius: 20,
        ),
        child: padded,
      );
    }
    return XCContainer.custom(
      customRadius: 20,
      innerPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: content,
    );
  }

  Widget _buildContent(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Sprung.overDamped,
            height: cmodel.selectedImage == null && _videoPreview == null
                ? 0
                : 200,
            child: cmodel.selectedImage == null && _videoPreview == null
                ? Container()
                : Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _videoPreview != null
                                ? _videoPreview!
                                : File(cmodel.selectedImage!.path),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Clickable(
                          onTap: () {
                            setState(() {
                              cmodel.selectedImage = null;
                              _videoPreview = null;
                              cmodel.selectedVideo = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.black.withValues(alpha: 0.5),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Clickable(
                onTap: () {
                  showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
                      return AssetSheet(
                        onImageSelect: ((asset) {
                          setState(() {
                            cmodel.selectedVideo = null;
                            _videoPreview = null;
                            cmodel.selectedImage = asset;
                          });
                        }),
                        onVideoSelect: (asset) {
                          setState(() {
                            cmodel.selectedImage = null;
                            cmodel.selectedVideo = asset;
                          });
                          _loadVideoPreview(context, asset.path);
                        },
                      );
                    }),
    );
                },
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: dmodel.color,
                    ),
                  ),
                ),
              ),
              // text field
              Expanded(
                child: XCField(
              autocorrect: true,
              controller: _controller,
              labelText: "Type here ...",
              isLabeled: false,
              maxLines: 3,
              onChanged: (value) {
                    setState(() {});
                  },
            ),
              ),
              Opacity(
                opacity: (_controller.text.isEmpty && !cmodel.hasAsset())
                    ? 0.5
                    : 1,
                child: Clickable(
                  onTap: () {
                    if (_controller.text.isEmpty && !cmodel.hasAsset()) {
                      print("text input was empty");
                    } else {
                      _sendMessage(context, dmodel, cmodel);
                    }
                  },
                  child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: _sending
                            ? XCLoadingIndicator(color: dmodel.color)
                            : Icon(Icons.send, color: dmodel.color),
                      )),
                ),
              ),
            ],
          ),
        ],
    );
  }

  void _loadVideoPreview(BuildContext context, String filePath) async {
    var path = await VideoThumbnail.thumbnailFile(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 100,
    );
    if (path.isNotEmpty()) {
      setState(() {
        _videoPreview = File(path!);
      });
    } else {
      print("There was an issue getting the preview");
    }
  }

  Future<void> _sendMessage(
      BuildContext context, DataModel dmodel, ChatModel cmodel) async {
    setState(() {
      _sending = true;
    });
    Message? sentMessage =
        await cmodel.sendMessage(cmodel.room!.roomId, _controller.text);
    if (sentMessage != null) {
      // send notification
      Map<String, dynamic> body = {
        "body": _controller.text,
        "sender": cmodel.name,
        "email": cmodel.email,
      };
      if (sentMessage.img.isNotEmpty()) {
        body['image'] = sentMessage.img;
      }
      print("[CHAT] body = $body");
      dmodel.sendChatNotification(
        widget.team.teamId,
        widget.season.seasonId,
        body,
        () {},
      );
    } else {
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue sending your message"),
      );
    }
    setState(() {
      _controller.clear();
      _sending = false;
      _videoPreview = null;
    });
  }
}
