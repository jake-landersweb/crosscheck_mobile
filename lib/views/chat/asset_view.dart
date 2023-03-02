import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

class AssetView extends StatefulWidget {
  const AssetView({
    super.key,
    required this.message,
  });
  final Message message;

  @override
  State<AssetView> createState() => _AssetViewState();
}

class _AssetViewState extends State<AssetView> with TickerProviderStateMixin {
  VideoPlayerController? _videoController;

  final _animationLength = 400;

  double _dx = 0;
  double _dy = 0;
  double _factor = 1;
  Duration _duration = const Duration(milliseconds: 0);

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    super.dispose();
  }

  void init() async {
    // check video exists, if it does, then check if file is saved in cache.
    // if the file is in cache then load the video playback controller.
    // if video is not in cache, get the presigned url, save the video in
    // cache, then load the video into the controller
    if (widget.message.video != null) {
      var cacheManager = DefaultCacheManager();
      // await cacheManager.removeFile(widget.message.video!);
      var fileInfo = await cacheManager.getFileFromCache(widget.message.video!);
      if (fileInfo == null) {
        // fetch the presinged url
        print("video does not exist in cache");
        var success = await widget.message
            .getPresignedVideoUrl(context.read<DataModel>());
        if (success) {
          // save the video in cache
          var fileInfo2 = await cacheManager.downloadFile(
            widget.message.presignedVideoUrl!,
            key: widget.message.video!,
          );
          // have to edit filename in order to properly load as mp4
          var newFile = await fileInfo2.file
              .rename("${fileInfo2.file.path.split(".")[0]}.mp4");
          await cacheManager.putFile(
            "",
            newFile.readAsBytesSync(),
            key: widget.message.video!,
            maxAge: const Duration(days: 7),
            fileExtension: 'mp4',
            eTag: widget.message.video!,
          );
          // load playback controller
          _videoController = VideoPlayerController.file(newFile)
            ..initialize().then((_) => setState(() {}));
          _videoController!.addListener(() => _checkVideo());
        } else {
          print("failed to get presigned video url");
        }
      } else {
        // load the playback controller with the file
        print("video exists in cache");
        // var newFile = await fileInfo.file
        //     .rename("${fileInfo.file.path.split(".")[0]}.mp4");
        _videoController = VideoPlayerController.file(fileInfo.file)
          ..initialize().then((_) => setState(() {}));
        _videoController!.addListener(() => _checkVideo());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return GestureDetector(
      onPanUpdate: ((details) {
        // update values when dragging
        setState(() {
          _dx += details.delta.dx;
          _dy += details.delta.dy;
          var temp = 1 - ((_dx + _dy) / 1000);
          _factor = temp > 1 ? 1 : temp;
        });
      }),
      onPanEnd: ((details) {
        // check to close
        if (_factor < 0.9) {
          Navigator.of(context).pop();
          return;
        }
        // trick to animate back to default position
        setState(() {
          _duration = Duration(milliseconds: _animationLength);
        });
        setState(() {
          _dx = 0;
          _dy = 0;
          _factor = 1;
        });
        Future.delayed(Duration(milliseconds: _animationLength), () {
          setState(() {
            _duration = const Duration(milliseconds: 0);
          });
        });
      }),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.black.withOpacity(_factor),
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
            top: true,
            right: false,
            left: false,
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // sender and date
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message.sender,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message.getDynamicDate(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // actions
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: cv.BasicButton(
                          onTap: () {
                            cv.showFloatingSheet(
                              context: context,
                              builder: (context) => _sheet(context),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(
                                Icons.more_vert_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      cv.BasicButton(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: _duration,
                        curve: Sprung.overDamped,
                        top: _dy,
                        left: _dx,
                        child: AnimatedScale(
                          duration: Duration(milliseconds: _animationLength),
                          curve: Sprung.overDamped,
                          scale: _factor,
                          child: Column(
                            children: [
                              if (widget.message.img != null)
                                _imageView(context),
                              if (_videoController != null) _videoView(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.message.img == null && _videoController == null)
                  Expanded(
                    child: Center(
                      child: cv.LoadingIndicator(color: dmodel.color),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageView(BuildContext context) {
    return Center(
      child: ClipRRect(
        child: Hero(
          tag: widget.message.img!,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: "",
                  cacheKey: widget.message.img,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoView(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Hero(
          tag: widget.message.video!,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                        child: VideoPlayer(_videoController!),
                      ),
                      IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _videoController!.value.isPlaying ? 0 : 1,
                          duration: const Duration(milliseconds: 250),
                          curve: Sprung.overDamped,
                          child: Container(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheet(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "",
      color: dmodel.color,
      child: cv.BasicButton(
        onTap: () async {
          // get the file from the cache key
          if (widget.message.img != null) {
            var file = await DefaultCacheManager()
                .getFileFromCache(widget.message.img!);
            if (file != null) {
              try {
                var image = await convertFileToIntList(file.file);
                final appDir = await syspaths.getTemporaryDirectory();
                File f = File('${appDir.path}/${widget.message.img!}');
                f.writeAsBytes(image);
                print(f);
                await GallerySaver.saveImage(f.path);
                dmodel.addIndicator(
                  IndicatorItem.success("Successfully saved image"),
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } catch (error) {
                print(error);
                dmodel.addIndicator(
                    IndicatorItem.error('There was an issue saving this file'));
              }
            } else {
              dmodel.addIndicator(
                  IndicatorItem.error('There was an issue saving this file'));
            }
          } else if (_videoController != null) {
            var file = await DefaultCacheManager()
                .getFileFromCache(widget.message.video!);
            if (file != null) {
              try {
                var video = await convertFileToIntList(file.file);
                final appDir = await syspaths.getTemporaryDirectory();
                File f = File('${appDir.path}/${widget.message.video!}');
                f.writeAsBytes(video);
                print(f);
                await GallerySaver.saveVideo(f.path);
                dmodel.addIndicator(
                  IndicatorItem.success("Successfully saved video"),
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } catch (error) {
                print(error);
                dmodel.addIndicator(
                    IndicatorItem.error('There was an issue saving this file'));
              }
            } else {
              dmodel.addIndicator(
                  IndicatorItem.error('There was an issue saving this file'));
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CustomColors.sheetCell(context),
          ),
          height: 50,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Save to Camera Roll",
                    style: TextStyle(
                      color: CustomColors.textColor(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
                Icon(
                  Icons.file_download_outlined,
                  color: dmodel.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkVideo() {
    if (_videoController!.value.position == _videoController!.value.duration) {
      setState(() {});
    }
  }
}
