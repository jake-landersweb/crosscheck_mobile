import 'package:crosscheck_sports/client/data_model.dart';
import 'package:crosscheck_sports/data/dynamic_fields/custom_field.dart';
import 'package:crosscheck_sports/data/dynamic_fields/stat_item.dart';
import 'package:crosscheck_sports/data/season/season.dart';
import 'package:crosscheck_sports/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/header_bar.dart';

class SeasonInfo extends StatefulWidget {
  const SeasonInfo({super.key, required this.season});
  final Season season;

  @override
  State<SeasonInfo> createState() => _SeasonInfoState();
}

class _SeasonInfoState extends State<SeasonInfo> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Season Info",
      isLarge: true,
      leading: cv.BackButton(color: dmodel.color),
      child: Column(
        children: [
          _basic(context, dmodel),
          if (widget.season.positions.isActive &&
              widget.season.positions.available.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 16),
                _teamPositions(context, dmodel),
              ],
            ),
          if (widget.season.customFields.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 16),
                _customFields(context, dmodel),
              ],
            ),
          if (widget.season.customUserFields.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 16),
                _customUserFields(context, dmodel),
              ],
            ),
          if (widget.season.stats.isActive)
            Column(
              children: [
                const SizedBox(height: 16),
                _stats(context, dmodel),
              ],
            ),
        ],
      ),
    );
  }

  Widget _basic(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Basic",
      child: Column(
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            minHeight: 50,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              cv.LabeledCell(
                label: "Status",
                value: widget.season.status(),
              ),
              cv.LabeledCell(
                label: "Timezone",
                value: widget.season.timezone,
              ),
              if (widget.season.website != "")
                cv.LabeledCell(
                  label: "Website",
                  value: widget.season.website,
                  clickable: true,
                ),
              if (widget.season.calendarUrl != "")
                cv.LabeledCell(
                  label: "Calendar",
                  value: widget.season.calendarUrl,
                  clickable: true,
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      child: cv.ListView<String>(
        minHeight: 50,
        children: widget.season.positions.available,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, position) {
          return cv.LabeledCell(
            label: position == widget.season.positions.defaultPosition
                ? position == widget.season.positions.mvp
                    ? "Mvp Default"
                    : "Default"
                : position == widget.season.positions.mvp
                    ? "Mvp"
                    : "",
            value: position.capitalize(),
          );
        },
      ),
    );
  }

  Widget _customFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      child: cv.ListView<CustomField>(
        minHeight: 50,
        children: widget.season.customFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: i.getValue(),
          );
        },
      ),
    );
  }

  Widget _customUserFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom User Fields",
      child: cv.ListView<CustomField>(
        minHeight: 50,
        children: widget.season.customUserFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: "Default: ${i.getValue()}",
          );
        },
      ),
    );
  }

  Widget _stats(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Stats",
      child: cv.ListView<StatItem>(
        minHeight: 50,
        children: widget.season.stats.stats,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: "",
            value: i.getTitle(),
          );
        },
      ),
    );
  }
}
