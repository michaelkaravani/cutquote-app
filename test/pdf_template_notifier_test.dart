import 'dart:async';

import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('restores a saved account template after restart', () async {
    final remote = <String, String>{};
    final first = PdfTemplateNotifier(
      loadRemoteTemplate: (uid) async => remote[uid],
      saveRemoteTemplate: (uid, template) async {
        remote[uid] = template;
      },
    );

    await first.initialize('user-1');
    await first.setTemplate('clean_corporate');

    final restarted = PdfTemplateNotifier(
      loadRemoteTemplate: (uid) async => remote[uid],
      saveRemoteTemplate: (uid, template) async {
        remote[uid] = template;
      },
    );
    await restarted.initialize('user-1');

    expect(restarted.currentTemplate, 'clean_corporate');
  });

  test('remote account value overrides a stale local cache', () async {
    SharedPreferences.setMockInitialValues({
      'pdf_template_style_user-1': 'natural_craft',
    });
    final notifier = PdfTemplateNotifier(
      loadRemoteTemplate: (_) async => 'minimal_stone',
      saveRemoteTemplate: (_, _) async {},
    );

    await notifier.initialize('user-1');

    expect(notifier.currentTemplate, 'minimal_stone');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('pdf_template_style_user-1'), 'minimal_stone');
  });

  test('migrates the legacy device preference to the account', () async {
    SharedPreferences.setMockInitialValues({
      'pdf_template_style': 'modern_bordeaux',
    });
    String? savedUid;
    String? savedTemplate;
    final notifier = PdfTemplateNotifier(
      loadRemoteTemplate: (_) async => null,
      saveRemoteTemplate: (uid, template) async {
        savedUid = uid;
        savedTemplate = template;
      },
    );

    await notifier.initialize('user-1');

    expect(notifier.currentTemplate, 'modern_bordeaux');
    expect(savedUid, 'user-1');
    expect(savedTemplate, 'modern_bordeaux');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('pdf_template_style'), isNull);
    expect(
      preferences.getString('pdf_template_style_user-1'),
      'modern_bordeaux',
    );
  });

  test('does not confirm a template when the remote save fails', () async {
    final notifier = PdfTemplateNotifier(
      loadRemoteTemplate: (_) async => 'premium_dark',
      saveRemoteTemplate: (_, _) async => throw StateError('offline'),
    );
    await notifier.initialize('user-1');

    await expectLater(
      notifier.setTemplate('clean_corporate'),
      throwsStateError,
    );

    expect(notifier.currentTemplate, 'premium_dark');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('pdf_template_style_user-1'), 'premium_dark');
  });

  test('rejects unsupported template identifiers', () async {
    final notifier = PdfTemplateNotifier(
      loadRemoteTemplate: (_) async => null,
      saveRemoteTemplate: (_, _) async {},
    );
    await notifier.initialize('user-1');

    await expectLater(
      notifier.setTemplate('removed_template'),
      throwsArgumentError,
    );
    expect(notifier.currentTemplate, defaultPdfTemplate);
  });

  test('keeps account caches isolated', () async {
    final remote = <String, String>{
      'user-1': 'clean_corporate',
      'user-2': 'natural_craft',
    };
    final notifier = PdfTemplateNotifier(
      loadRemoteTemplate: (uid) async => remote[uid],
      saveRemoteTemplate: (uid, template) async {
        remote[uid] = template;
      },
    );

    await notifier.initialize('user-1');
    expect(notifier.currentTemplate, 'clean_corporate');

    await notifier.initialize('user-2');
    expect(notifier.currentTemplate, 'natural_craft');

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('pdf_template_style_user-1'),
      'clean_corporate',
    );
    expect(preferences.getString('pdf_template_style_user-2'), 'natural_craft');
  });

  test('discards a delayed load from a previous account', () async {
    final userOneLoad = Completer<String?>();
    final notifier = PdfTemplateNotifier(
      loadRemoteTemplate: (uid) async {
        if (uid == 'user-1') return userOneLoad.future;
        return 'natural_craft';
      },
      saveRemoteTemplate: (_, _) async {},
    );

    final firstInitialization = notifier.initialize('user-1');
    await Future<void>.delayed(Duration.zero);
    await notifier.initialize('user-2');
    userOneLoad.complete('clean_corporate');
    await firstInitialization;

    expect(notifier.currentTemplate, 'natural_craft');
  });
}
