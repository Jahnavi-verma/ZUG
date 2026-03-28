// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gig_worker_insurance/main.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('App launches and shows Onboarding screen test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GigWorkerApp());

    // Verify that the title of the first onboarding page is shown.
    expect(find.text('Gig Worker Insurance'), findsOneWidget);
    expect(find.text('Protect your income from unexpected disruptions.'), findsOneWidget);

    // Verify that the Skip and Next buttons are shown.
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap the 'Next' button and trigger a frame to animate to next page.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(); // pumpAndSettle waits for animations to finish

    // Verify that we are on the next page.
    expect(find.text('Parametric Payouts'), findsOneWidget);
  });
}
