import 'package:flutter/material.dart';

typedef void OnChanged(String string);
typedef void OnSubmitted(String string);
typedef void OnTap(String sufTextToClear);

class InputSuggestions extends StatefulWidget {
  InputSuggestions({
    this.fontSize = 14,
    this.lowerCase = false,
    this.style,
    this.suggestions,
    this.controller,
    this.autocorrect,
    this.autofocus,
    this.keyboardType,
    this.maxLength,
    this.inputDecoration,
    this.onSubmitted,
    this.focusNode,
    this.onChanged,
    this.onSuffixTapped,
    Key key
  })
      :assert(fontSize != null),
        super(key: key);

  final TextStyle style;
  final TextEditingController controller;
  final InputDecoration inputDecoration;
  final double fontSize;
  final bool autocorrect;
  final List<String> suggestions;
  final bool lowerCase;
  final bool autofocus;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final int maxLength;
  final OnSubmitted onSubmitted;
  final OnChanged onChanged;
  final OnTap onSuffixTapped;


  @override
  _InputSuggestionsState createState() => _InputSuggestionsState();
}

class _InputSuggestionsState extends State<InputSuggestions> {
  TextEditingController _controller;

  List<String> _matches = List();
  String _helperText = "";
  String _suffixText = "no matches";
  bool _helperCheck = true;


  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: _matches.isNotEmpty
          ? AlignmentDirectional.topStart
          : AlignmentDirectional.centerStart,
      children: <Widget>[
        Container(
          padding: widget.inputDecoration != null ? widget.inputDecoration
              .contentPadding :
          EdgeInsets.symmetric(
              vertical: 10 + (widget.fontSize.toDouble() / 14), horizontal: 0)
          ,
          child: Text(
            _matches.isNotEmpty ? (
                _matches.first
            ) : "",
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: widget.fontSize ?? null,
              color: Colors.grey[400],
            ),
          ),
        ),
        Container(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus ?? true,
            keyboardType: widget.keyboardType ?? null,
            maxLength: widget.maxLength ?? null,
            maxLines: 1,
            autocorrect: widget.autocorrect ?? false,
            focusNode: widget.focusNode ?? null,
            style: widget.style != null ?
            widget.style.copyWith(
                fontSize: widget.fontSize
            ) :
            null,
            decoration:
            widget.inputDecoration != null ?
            widget.suggestions != null ?
            widget.inputDecoration.copyWith(
                labelText: _helperCheck ? null : _helperText)
                :
            widget.inputDecoration.copyWith(contentPadding: EdgeInsets.all(8))
                : null,
            onChanged: (str) => _checkOnChanged(str),
            onSubmitted: (str) => _onSubmitted(str)
            ,
          ),
        ),
        !_helperCheck ?
        Positioned(right: 2.0, child: GestureDetector(child: Text(
            _suffixText,
            style: widget.style ??
                TextStyle(color: Colors.grey, fontSize: widget.fontSize)),
            onTap: (){
              widget.onSuffixTapped(_suffixText);
            })) : Container()
      ],
    );
  }

  ///OnSubmitted
  void _onSubmitted(String str) {
    if (widget.suggestions != null)
      str = _matches.first;

    if (widget.lowerCase)
      str = str.toLowerCase();

    str = str.trim();

    if (widget.suggestions != null) {
      if (_matches.isNotEmpty) {
        if (widget.onSubmitted != null)
          widget.onSubmitted(str);
        setState(() {
          _matches = [];
        });
        _controller.clear();
      }
    }
    else if (str != '') {
      if (widget.onSubmitted != null)
        widget.onSubmitted(str);
      _controller.clear();
    }
  }

  ///Check onChanged
  void _checkOnChanged(String str) {
    _suffixText = "no matches";
    if (widget.suggestions != null) {
      var suggestions = widget.suggestions;
      // Check if exact match and if so add it first
      _matches = suggestions.where(
              (sgt) => sgt.toLowerCase() == str.toLowerCase()
      ).toList();
      // If no exact matches then search for the closest one
      if (_matches.isEmpty) {
        _matches = suggestions.where(
                (sgt) =>
                sgt.toLowerCase().startsWith(str.toLowerCase())).toList();
      }

      if (str.isEmpty)
        _matches = [];

      if (_matches.length > 1)
        _matches.removeWhere(
                (mtc) => mtc == str
        );


      setState(() {
        _helperCheck = _matches.isNotEmpty || str.isEmpty ? true : false;
        _matches.sort((a, b) => a.compareTo(b));
      });

      if (widget.onChanged != null)
        widget.onChanged(str);
    }
  }

}
