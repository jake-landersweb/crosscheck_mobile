import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:image_picker/image_picker.dart';

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
          if (imgIsUrl)
            _urlImage(context, dmodel)
          else
            _imageUploader(context, dmodel),
        ],
      ),
    );
  }

  Widget _imageUploader(BuildContext context, DataModel dmodel) {
    return cv.ListView<Widget>(
      showStyling: false,
      hasDividers: false,
      childPadding: EdgeInsets.zero,
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
        cv.RoundedLabel(
          "Select New Image",
          color: CustomColors.sheetCell(context),
          textColor: CustomColors.textColor(context),
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
        cv.Section(
          "Image URL",
          child: cv.TextField2(
            labelText: "Image Url",
            fieldPadding: EdgeInsets.zero,
            value: _imageURL,
            onChanged: (val) {
              setState(() {
                _imageURL = val;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: cv.RoundedLabel(
            "Add Image URL",
            color: dmodel.color,
            textColor: Colors.white,
            isLoading: _isLoading,
            onTap: () {
              if (_imageURL.isNotEmpty) {
                _uploadImageURL(context, dmodel);
              }
            },
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
}
