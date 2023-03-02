import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';

class AssetSheet extends StatefulWidget {
  const AssetSheet({
    super.key,
    required this.onImageSelect,
    required this.onVideoSelect,
  });

  final void Function(XFile asset) onImageSelect;
  final void Function(XFile asset) onVideoSelect;

  @override
  State<AssetSheet> createState() => _AssetSheetState();
}

class _AssetSheetState extends State<AssetSheet> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Select Type",
      color: dmodel.color,
      child: cv.ListView<Tuple<String, Widget>>(
        backgroundColor: CustomColors.sheetCell(context),
        childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        horizontalPadding: 0,
        onChildTap: (context, child) async {
          switch (child.v1()) {
            case "image":
              _handleImage(context, dmodel);
              break;
            case "video":
              _handleVideo(context, dmodel);
              break;
            default:
              return;
          }
        },
        childBuilder: ((context, item) {
          return item.v2();
        }),
        children: [
          Tuple<String, Widget>(
            "image",
            _assetRow(
              context,
              dmodel,
              title: "Image",
              icon: Icons.photo_camera_outlined,
              onTap: () {},
            ),
          ),
          Tuple<String, Widget>(
            "video",
            _assetRow(
              context,
              dmodel,
              title: "Video",
              icon: Icons.videocam_outlined,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetRow(
    BuildContext context,
    DataModel dmodel, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: CustomColors.textColor(context),
            ),
          ),
        ),
        Icon(icon, color: dmodel.color),
      ],
    );
  }

  Future<void> _handleImage(BuildContext context, DataModel dmodel) async {
    try {
      // dismiss keyboard
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

      final ImagePicker picker = ImagePicker();
      XFile? selectedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        widget.onImageSelect(selectedImage);
      }

      if (selectedImage != null) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      print("error = $error");
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue uploading your image"),
      );
    }
  }

  Future<void> _handleVideo(BuildContext context, DataModel dmodel) async {
    try {
      // dismiss keyboard
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

      final ImagePicker picker = ImagePicker();
      XFile? selectedVideo =
          await picker.pickVideo(source: ImageSource.gallery);

      if (selectedVideo != null) {
        widget.onVideoSelect(selectedVideo);
      }

      if (selectedVideo != null) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      print("error = $error");
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue uploading your image"),
      );
    }
  }
}
