import 'package:flutter/material.dart';

/// Outside the browser, documents open in a new window instead.
Widget embeddedFrame(String url) =>
    const Center(child: Text('Open the document in a new tab to view it.'));
