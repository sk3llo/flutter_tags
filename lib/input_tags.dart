import 'package:flutter/material.dart';
import 'package:flutter_tags/src/suggestions.dart';
import 'package:flutter_tags/src/text_util.dart';

/// Callback
typedef void OnDelete(String tags);
typedef void OnInsert(String tags);

/// PopupMenuBuilder
typedef List<PopupMenuEntry> PopupMenuBuilder(String tag);
typedef void PopupMenuOnSelected(int id, String tag);


class InputTags extends StatefulWidget {

  InputTags({
    @required this.tags,
    this.columns = 4,
    this.autofocus,
    this.inputDecoration,
    this.maxLength,
    this.keyboardType,
    this.height,
    this.borderRadius,
    this.boxShadow,
    this.placeholder,
    this.symmetry = false,
    this.textFieldHidden = false,
    this.margin,
    this.padding,
    this.alignment,
    this.offset,
    this.duplicate = false,
    this.fontSize = 14,
    this.textOverflow,
    this.lowerCase = false,
    this.textStyle,
    this.autocorrect,
    this.focusNode,
    this.icon,
    this.iconSize,
    this.iconPadding,
    this.iconMargin,
    this.iconColor,
    this.iconBackground,
    this.iconBorderRadius,
    this.color,
    this.backgroundContainer,
    this.highlightColor,
    this.suggestionsList,
    this.onDelete,
    this.onInsert,
    this.popupMenuBuilder,
    this.popupMenuOnSelected,
    Key key
  })
      : assert(tags != null),
        super(key: key);

  ///List of [Tag] object
  final List<String> tags;

  ///specific number of columns
  final int columns;

  ///autofocus InputField
  final bool autofocus;

  ///decoration InputField
  final InputDecoration inputDecoration;

  ///max-length InputField
  final int maxLength;

  ///keyboard InputField
  final TextInputType keyboardType;

  ///customize the height of the tag. Default auto-resize
  final double height;

  ///creates Focus Node
  final FocusNode focusNode;

  /// border-radius of tag
  final BorderRadius borderRadius;

  /// box-shadow of tag
  final List<BoxShadow> boxShadow;

  ///placeholder InputField
  final String placeholder;

  /// imposes the same width and the same number of columns for each row
  final bool symmetry;

  /// Sometimes you need to hide the textField
  final bool textFieldHidden;

  /// margin between the tag
  final EdgeInsets margin;

  /// padding of the tag
  final EdgeInsets padding;

  /// type of row alignment
  final MainAxisAlignment alignment;

  /// offset of width (default 0)
  final int offset;

  /// possibility to insert duplicates in the list
  final bool duplicate;

  /// TextStyle of the tag
  final TextStyle textStyle;

  /// TextStyle of the tag
  final bool autocorrect;

  /// font size, the height of the tag is proportional to the font size
  final double fontSize;

  /// custom Icon close
  final Icon icon;

  /// icon size of Icon close
  final double iconSize;

  /// padding of Icon close
  final EdgeInsets iconPadding;

  /// margin of Icon close
  final EdgeInsets iconMargin;

  /// color of Icon close
  final Color iconColor;

  /// background of Icon close
  final Color iconBackground;

  /// border-radius of Icon Size
  final BorderRadius iconBorderRadius;

  /// type of text overflow within the tag
  final TextOverflow textOverflow;

  /// lower-case text tag
  final bool lowerCase;

  /// background color tag
  final Color color;

  /// background color container
  final Color backgroundContainer;

  ///highlight-color. it is activated when trying to insert a duplicate
  final Color highlightColor;

  /// callback
  final OnDelete onDelete;

  /// callback
  final OnInsert onInsert;

  /// Suggestions List
  final List<String> suggestionsList;

  /// Popup Menu Items
  /// (String Tag)
  final PopupMenuBuilder popupMenuBuilder;

  /// On Selected Item
  /// (int id, String tag)
  final PopupMenuOnSelected popupMenuOnSelected;


  @override
  _InputTagsState createState() => _InputTagsState();
}

class _InputTagsState extends State<InputTags> {
  final GlobalKey _containerKey = GlobalKey();
  Orientation _orientation = Orientation.portrait;

  //duplicate highlighting
  int _check = -1;

  // Position for popupMenu
  Offset _tapPosition;

  List<String> _tags = [];

  double _width = 0;
  double _initFontSize = 14;
  double _initMargin = 3;
  double _initPadding = 10;
  double _initBorderRadius = 8;

  double _initPaddingIcon = 3;
  double _initMarginIcon = 8;


  @override
  void initState() {
    super.initState();

    _tags = widget.tags;
  }


  @override
  void dispose() {
    super.dispose();
  }


  //get the current width of the container
  void _getwidthContainer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _containerKey.currentContext;
      if (keyContext != null) {
        final RenderBox box = keyContext.findRenderObject();
        final size = box.size;
        setState(() {
          _width = size.width;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // essential to avoid infinite loop of addPostFrameCallback
    if (MediaQuery
        .of(context)
        .orientation != _orientation || _width == 0)
      _getwidthContainer();
    _orientation = MediaQuery
        .of(context)
        .orientation;

    return Container(
      key: _containerKey,
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      color: widget.backgroundContainer ?? Colors.white,
      child: Column(children: _buildRows(),),
    );
  }

  List<Widget> _buildRows() {
    List<Widget> rows = [];

    int columns = widget.columns;

    //margin of the tag
    double margin = (widget.margin != null)
        ? widget.margin.horizontal
        : _initMargin * 2;

    //padding of the tag
    double padding = widget.padding != null
        ? widget.padding.horizontal
        : _initPadding;
    padding = padding * (widget.fontSize.clamp(8, 20) / 14);

    int tagsLength = _tags.length + 1;
    int rowsLength = (tagsLength / columns).ceil();
    double fontSize = widget.fontSize ?? _initFontSize;

    //initial width tag
    double widthTag = 1;

    int start = 0;
    bool overflow;

    for (int i = 0; i < rowsLength; i++) {
      // Single Row
      List<Widget> row = [];

      //break row
      overflow = false;

      //width of the Tag
      double tmpWidth = 0;

      // final index of the current row
      int end = start + columns;

      // makes sure that 'end' does not exceed 'tagsLength'
      if (end >= tagsLength) end -= end - tagsLength;

      for (int j = start; j < end; j++) {
        if (!widget.symmetry && _tags.isNotEmpty) {
          String tag = _tags[j % (tagsLength - 1)];

          TextSize txtSize = TextSize(
              txt: tag,
              fontSize: fontSize * (tag.length < 2 ? 1.2 : 1)
          );

          // Total width of the tag
          double txtWidth = txtSize
              .get()
              .width + _widthIcon() + padding + margin;

          //sum of the width of each tag
          //widget.offset it is optional but in special cases allows you to improve the width of the tags
          tmpWidth += txtWidth + (widget.offset ?? 0);

//          if (j > start && tmpWidth > _width) {
          if (j > start && tmpWidth > _width) {
            start = j;
            overflow = true;
            rowsLength += 1;
            break;
          }

          widthTag = txtWidth;
        }

        row.add(_buildField(
            index: _tags.isNotEmpty ? j % (tagsLength - 1) : null,
            width: widthTag,
            last: (j + 1 == tagsLength)));
      }

      // Check overflow width
      if (!overflow) start = end;

      rows.add(
          Row(
            mainAxisAlignment: widget.alignment ??
                ((widget.symmetry) ? MainAxisAlignment.start : MainAxisAlignment
                    .center),
            children: row,
          )
      );
    }

    return rows;
  }

  /// Build single Tag
  Widget _buildField({int index, double width, bool last = false}) {
    String tag = (index != null) ? _tags[index] : '';

    print(width);

    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject();

    Widget textField = Visibility(
      visible: !widget.textFieldHidden,
      child: Expanded(
          flex: (widget.symmetry) ? 1 : width.ceil(),
          child: Container(
              margin: widget.margin ??
                  EdgeInsets.symmetric(horizontal: _initMargin, vertical: 6),
              child: _textField()
          )
      ),
    );

    if (last || tag == null)
      return textField;
    else {
      Widget container = Container(
        margin: widget.margin ??
            EdgeInsets.symmetric(horizontal: _initMargin, vertical: 6),
        width: (widget.symmetry) ? _widthCalc() : width,
        height: widget.height ?? 29 * (widget.fontSize / 14),
        decoration: BoxDecoration(
          boxShadow: widget.boxShadow ?? [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 4,
                offset: Offset(0, 1)
            )
          ],
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(_initBorderRadius),
          color: _check == index
              ? ((widget.highlightColor ?? widget.color?.withRed(700)) ??
              Colors.green.withRed(450))
              : (widget.color ?? Colors.green[400]),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              flex: 1,
              child: Padding(
                padding: widget.padding ?? EdgeInsets.only(
                    left: (_initPadding) * (widget.fontSize.clamp(8, 20) / 14)),
                child: Text(
                  tag,
                  overflow: widget.textOverflow ?? TextOverflow.fade,
                  softWrap: false,
                  style: _textStyle,
                ),
              ),
            ),
            FittedBox(
                fit: BoxFit.cover,
                child: GestureDetector(
                  child: Container(
                    padding: widget.iconPadding ??
                        EdgeInsets.all(_initPaddingIcon),
                    margin: widget.iconMargin ??
                        EdgeInsets.only(
                            right: _initMarginIcon *
                                (widget.fontSize != null ? (widget.fontSize
                                    .clamp(8, 22) / 26) : 1)
                        ),
                    decoration: BoxDecoration(
                      color: widget.iconBackground ?? Colors.transparent,
                      borderRadius: widget.iconBorderRadius ??
                          BorderRadius.circular(_initBorderRadius),
                    ),
                    child: Icon(
                        widget.icon ?? Icons.clear,
                        color: widget.iconColor ?? Colors.white,
                        size: ((widget.fontSize != null)
                            ? 15 +
                            (widget.fontSize.clamp(6, 25).toDouble() - 18)
                            : 14)),
                  ),
                  onTap: () {
                    _check = -1;
                    if (widget.onDelete != null)
                      widget.onDelete(tag);
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )
            )
          ],
        ),
      );

      return Flexible(
          flex: (widget.symmetry) ? 1 : width.ceil(),
          child: GestureDetector(
            onTapDown: (details) {
              _tapPosition = details.globalPosition;
            },
            onLongPress: () {
              showMenu(
                  semanticLabel: tag,
                  items: widget.popupMenuBuilder(tag) ?? [],
                  context: context,
                  position: RelativeRect.fromRect(_tapPosition & Size(40, 40),
                      Offset.zero & overlay
                          .size) // & RelativeRect.fromLTRB(65.0, 40.0, 0.0, 0.0),
              ).then((value) {
                if (widget.popupMenuOnSelected != null)
                  widget.popupMenuOnSelected(value, tag);
              });
            },
            child: widget.popupMenuBuilder == null ?
            Tooltip(
              message: tag,
              child: container,
            )
                :
            container,
          )
      );
    }
  }

  /// TextFiled or CustomTextField
  Widget _textField() {
    return InputSuggestions(
      fontSize: widget.fontSize ?? null,
      suggestions: widget.suggestionsList ?? null,
      autofocus: widget.autofocus ?? true,
      keyboardType: widget.keyboardType ?? null,
      focusNode: widget.focusNode ?? null,
      maxLength: widget.maxLength ?? null,
      lowerCase: widget.lowerCase ?? null,

      autocorrect: widget.autocorrect ?? false,
      onSubmitted: (str) {
        setState(() {
          _check = -1;
          if (_tags.contains(str) && !widget.duplicate)
            _check = _tags.indexWhere((st) => st == str);
          else {
            if (widget.onInsert != null)
              widget.onInsert(str);
            _tags.add(str);
          }
        });
      },
      style: TextStyle(color: Colors.black),
      inputDecoration: InputDecoration(
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              vertical: 7 + (widget.fontSize.clamp(10, 24).toDouble() - 14),
              horizontal: 10 + (widget.fontSize.clamp(10, 24).toDouble() - 14)),
          labelText: 'Tags',
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(_initBorderRadius,),
            borderSide: BorderSide(color: widget.color ?? Color.fromRGBO(54, 209, 220, 1.0), width: 2),
          ),
//          enabledBorder: UnderlineInputBorder(
//            borderRadius: BorderRadius.circular(_initBorderRadius,),
//            borderSide: BorderSide(color: Colors.grey),
//          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(_initBorderRadius,),
            borderSide: BorderSide(color: Colors.grey, width: 2),
          )
      ),
    );
  }

  ///TextStyle
  TextStyle get _textStyle {
    if (widget.textStyle != null)
      return widget.textStyle.apply(
        color: widget.textStyle.color ?? Colors.white,
      );

    return TextStyle(
        fontSize: widget.fontSize ?? null,
        color: Colors.white,
        fontWeight: FontWeight.normal
    );
  }

  ///Total width of the close icon
  double _widthIcon() {
    double margin = widget.iconMargin != null
        ? widget.iconMargin.horizontal
        : _initMarginIcon;
    double padding = widget.iconPadding != null ? widget.iconPadding
        .horizontal / 2 : _initPaddingIcon;
    double size = (widget.fontSize != null) ? 15 +
        (widget.fontSize.clamp(6, 25).toDouble() - 18) : 14;

    return margin + padding + size;
  }

  ///Container width divided by the number of columns when symmetry is active
  double _widthCalc() {
    int columns = widget.columns;

    int margin = (widget.margin != null)
        ? widget.margin.horizontal.round()
        : _initMargin.round() * 2;

    int subtraction = columns * (margin);
    double width = (_width > 1) ? (_width - subtraction) / columns : _width;

    return width;
  }

}
