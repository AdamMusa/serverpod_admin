import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';

const _sampleReportJobName = 'ExampleReportJob';
const _sampleDigestJobName = 'ExampleDigestJob';
const _sampleReportIdentifier = 'serverpod-admin-sample-report';
const _sampleDigestIdentifier = 'serverpod-admin-sample-digest';

class ExampleReportJob extends FutureCall<SerializableModel> {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    session.log('[SampleJob] ExampleReportJob completed.');
  }
}

class ExampleDigestJob extends FutureCall<SerializableModel> {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    session.log('[SampleJob] ExampleDigestJob completed.');
  }
}

void registerSampleJobs(Serverpod pod) {
  pod.registerFutureCall(ExampleReportJob(), _sampleReportJobName);
  pod.registerFutureCall(ExampleDigestJob(), _sampleDigestJobName);
}

Future<void> seedSampleJobs(Serverpod pod) async {
  if (pod.runMode != ServerpodRunMode.development) {
    return;
  }

  final session = await pod.createSession();
  try {
    final existingJobs = await FutureCallEntry.db.find(session);
    final existingIdentifiers = existingJobs
        .map((job) => job.identifier)
        .whereType<String>()
        .toSet();
    final now = DateTime.now().toUtc();

    if (!existingIdentifiers.contains(_sampleReportIdentifier)) {
      // ignore: deprecated_member_use
      await pod.futureCallAtTime(
        _sampleReportJobName,
        null,
        now.add(const Duration(days: 7)),
        identifier: _sampleReportIdentifier,
      );
    }

    if (!existingIdentifiers.contains(_sampleDigestIdentifier)) {
      // ignore: deprecated_member_use
      await pod.futureCallAtTime(
        _sampleDigestJobName,
        null,
        now.add(const Duration(days: 14)),
        identifier: _sampleDigestIdentifier,
      );
    }
  } finally {
    await session.close();
  }
}
