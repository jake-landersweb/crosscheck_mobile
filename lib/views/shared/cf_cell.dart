import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../components/root.dart' as comp;

class CustomFieldField extends StatefulWidget {
  const CustomFieldField({
    Key? key,
    required this.item,
    this.color = Colors.blue,
    this.isCreate = true,
    this.valueLabelText = "Value",
  }) : super(key: key);
  final CustomField item;
  final Color color;
  final bool isCreate;
  final String valueLabelText;

  @override
  _CustomFieldFieldState createState() => _CustomFieldFieldState();
}

class _CustomFieldFieldState extends State<CustomFieldField> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        if (widget.isCreate)
          cv.LabeledWidget(
            "Type",
            isExpanded: false,
            child: cv.BasicButton(
              onTap: () {
                cv.showFloatingSheet(
                  context: context,
                  builder: (context) {
                    return cv.Sheet(
                      title: "Select Type",
                      color: dmodel.color,
                      child: cv.DynamicSelector<String>(
                        selectorStyle: cv.DynamicSelectorStyle.list,
                        selections: const ["S", "I", "B"],
                        color: dmodel.color,
                        titleBuilder: ((context, item) {
                          return CustomField.getTypeTitle(item);
                        }),
                        selectedLogic: (context, item) {
                          return item == widget.item.getType();
                        },
                        onSelect: (context, item) {
                          setState(() {
                            widget.item.setType(item);
                          });
                          switch (item) {
                            case "S":
                            case "SS":
                              setState(() {
                                widget.item.setValue("");
                              });
                              break;
                            case "I":
                              setState(() {
                                widget.item.setValue("0");
                              });
                              break;
                            default:
                              setState(() {
                                widget.item.setValue("false");
                              });
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: dmodel.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Text(
                    widget.item.typeTitle(),
                    style: TextStyle(
                      color: dmodel.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // cv.SegmentedPicker(
        //   selection: widget.item.getType(),
        //   titles: const ["Word", "Number", "True/False"],
        //   selections: const ["S", "I", "B"],
        //   style: cv.SegmentedPickerStyle(
        //     sliderColor: dmodel.color.withOpacity(0.3),
        //     selectedTextColor: dmodel.color,
        //     backgroundColor: CustomColors.sheetCell(context),
        //     shape:
        //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //     height: 40,
        //   ),
        //   onSelection: (value) {
        //     // change the type
        //     setState(() {
        //       widget.item.setType(value);
        //     });
        //     // change the value
        // switch (value) {
        //   case "S":
        //     setState(() {
        //       widget.item.setValue("");
        //     });
        //     break;
        //   case "I":
        //     setState(() {
        //       widget.item.setValue("0");
        //     });
        //     break;
        //   default:
        //     setState(() {
        //       widget.item.setValue("false");
        //     });
        // }
        //   },
        // ),
        if (widget.isCreate)
          cv.TextField2(
            fieldPadding: const EdgeInsets.all(0),
            showBackground: false,
            value: widget.item.getTitle(),
            isLabeled: true,
            maxLines: 1,
            labelText: "Title",
            onChanged: (value) {
              widget.item.setTitle(value);
            },
          ),
        // else
        //   cv.LabeledWidget("Title", child: Text(widget.item.getTitle())),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Center(
            child: _valField(context),
          ),
        ),
      ],
    );
  }

  Widget _valField(BuildContext context) {
    switch (widget.item.getType()) {
      case "S":
        return cv.TextField2(
          fieldPadding: const EdgeInsets.all(0),
          showBackground: false,
          isLabeled: true,
          maxLines: 1,
          value: widget.item.getValue(),
          labelText:
              widget.isCreate ? widget.valueLabelText : widget.item.getTitle(),
          onChanged: (value) {
            widget.item.setValue(value);
          },
        );
      case "I":
        return cv.LabeledWidget(
          widget.isCreate ? widget.valueLabelText : widget.item.getTitle(),
          child: cv.NumberTextField(
            label: "",
            initValue: int.parse(widget.item.getValue()),
            color: widget.color,
            onChange: (val) {
              setState(() {
                widget.item.setValue(val);
              });
            },
          ),
        );
      case "SS":
        // add model selector for all values in value field
        return Text("CREATE ME PLEASE FOR THE LOVE OF GOD");
      default:
        return cv.LabeledWidget(
          widget.isCreate ? widget.valueLabelText : widget.item.getTitle(),
          child: Row(
            children: [
              FlutterSwitch(
                value: widget.item.getValue() == "true" ? true : false,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: widget.color,
                onToggle: (value) {
                  setState(() {
                    widget.item.setValue(value);
                  });
                },
              ),
              const Spacer(),
            ],
          ),
        );
    }
  }
}
