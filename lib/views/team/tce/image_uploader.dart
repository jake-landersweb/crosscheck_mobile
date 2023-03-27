import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:image_picker/image_picker.dart';
import '../../components/root.dart' as comp;

class ImageUploader extends StatefulWidget {
  const ImageUploader({
    Key? key,
    required this.team,
    required this.onImageChange,
    required this.imgIsUrl,
  }) : super(key: key);
  final Team team;
  final Function(String) onImageChange;
  final bool imgIsUrl;

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final ImagePicker _picker = ImagePicker();

  XFile? _currentImage;

  bool _isLoading = false;

  String _imageURL = "";
  String? _tempImageUrl;
  late bool imgIsUrl;

  @override
  void initState() {
    if (!widget.team.image
        .contains("https://crosscheck-sports.s3.amazonaws.com")) {
      _imageURL = widget.team.image;
    }
    imgIsUrl = widget.imgIsUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Upload Image",
      color: dmodel.color,
      child: cv.ListView<Widget>(
        showStyling: false,
        hasDividers: false,
        childPadding: EdgeInsets.zero,
        horizontalPadding: 0,
        children: [
          const SizedBox(height: 16),
          cv.SegmentedPicker(
            selection: imgIsUrl ? "From URL" : "Image Uploader",
            titles: const ["Image Uploader", "From URL"],
            onSelection: (val) {
              setState(() {
                imgIsUrl = val == "Image Uploader" ? false : true;
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 700),
            curve: Sprung.overDamped,
            child: imgIsUrl
                ? _urlImage(context, dmodel)
                : _imageUploader(context, dmodel),
          ),
        ],
      ),
    );
  }

  Widget _imageUploader(BuildContext context, DataModel dmodel) {
    return cv.ListView<Widget>(
      showStyling: false,
      hasDividers: false,
      childPadding: EdgeInsets.zero,
      horizontalPadding: 0,
      children: [
        const SizedBox(height: 16),
        if (_currentImage == null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TeamLogo(url: widget.team.image, size: 150),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.file(
                    File(_currentImage!.path),
                    width: 150,
                    height: 150,
                    errorBuilder: (context, obj, tmp) {
                      return Image.asset(
                        "assets/launch/x.png",
                        color: dmodel.color,
                        width: 150,
                        height: 150,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  cv.BasicButton(
                    onTap: () {
                      setState(() {
                        _currentImage = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: CustomColors.sheetCell(context),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Remove Image",
                          style: TextStyle(
                            color: CustomColors.textColor(context)
                                .withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 16),
        comp.SubActionButton(
          title: "Select New Image",
          backgroundColor: CustomColors.sheetCell(context),
          onTap: () {
            _selectImage(context, dmodel);
          },
        ),
        if (_currentImage != null)
          for (var i in _afterUpload(context, dmodel)) i,
      ],
    );
  }

  Widget _urlImage(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        const SizedBox(height: 16),
        cv.TextField2(
          labelText: "Image Url",
          value: _imageURL,
          backgroundColor: CustomColors.sheetCell(context),
          onChanged: (val) {
            setState(() {
              _imageURL = val;
            });
          },
        ),
        const SizedBox(height: 8),
        cv.BasicButton(
          onTap: () {
            if (_linkIsValid) {
              setState(() {
                _tempImageUrl = _imageURL;
              });
            }
          },
          child: Text(
            "Load Image Preview",
            style: TextStyle(
              color: _linkIsValid
                  ? dmodel.color
                  : CustomColors.textColor(context).withOpacity(0.5),
              fontSize: 18,
            ),
          ),
        ),
        if (_tempImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Image.network(
              _tempImageUrl!,
              width: 150,
              height: 150,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 150,
                  width: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: dmodel.color,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Opacity(
            opacity: _linkIsValid ? 1 : 0.5,
            child: comp.ActionButton(
              title: "Save Image URL",
              color: dmodel.color,
              isLoading: _isLoading,
              onTap: () {
                if (_linkIsValid) {
                  _uploadImageURL(context, dmodel);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _afterUpload(BuildContext context, DataModel dmodel) {
    return [
      const SizedBox(height: 16),
      cv.RoundedLabel(
        "Confirm Upload",
        color: dmodel.color,
        textColor: Colors.white,
        isLoading: _isLoading,
        onTap: () {
          if (!_isLoading && _currentImage != null) {
            setState(() {
              _isLoading = true;
            });
            _uploadImage(context, dmodel);
          }
        },
      ),
    ];
  }

  Future<void> _selectImage(BuildContext context, DataModel dmodel) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _currentImage = image;
        });
      } else {
        dmodel.addIndicator(
          IndicatorItem.error("There was an issue uploading this image"),
        );
      }
    } catch (error) {
      print("error = $error");
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue uploading this image"),
      );
    }
  }

  Future<void> _uploadImage(BuildContext context, DataModel dmodel) async {
    // create file representation of this picked file
    try {
      File file = File(_currentImage!.path);
      await dmodel.uploadTeamLogo(widget.team.teamId, file, (newImg) {
        // successfully uploaded
        // update the team image to the new presigned url
        setState(() {
          dmodel.tus!.team.setImage(newImg);
          widget.onImageChange(newImg);
        });
        Navigator.of(context).pop();
      }, onError: () {
        //
      });
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print("error = $error");
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue with your chosen file"));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImageURL(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.addImageURL(widget.team.teamId, _imageURL, () {
      widget.onImageChange(_imageURL);
      Navigator.of(context).pop();
    });
    setState(() {
      _isLoading = false;
    });
  }

  bool get _linkIsValid => Uri.parse(_imageURL).isAbsolute;
}
