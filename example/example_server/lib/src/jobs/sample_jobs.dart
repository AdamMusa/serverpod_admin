import 'package:example_server/src/generated/protocol.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';

const _sampleReportJobName = 'ExampleReportJob';
const _sampleDigestJobName = 'ExampleDigestJob';
const _sampleReportIdentifier = 'serverpod-admin-sample-report';
const _sampleDigestIdentifier = 'serverpod-admin-sample-digest';

const _samplePostTitle = 'Serverpod Admin sample post';
const _sampleCommentTitle = 'Serverpod Admin sample comment';

class ExampleReportJob extends FutureCall<Post> {
  @override
  Future<void> invoke(Session session, Post? object) async {
    session.log(
      '[SampleJob] ExampleReportJob completed for post '
      '"${object?.title ?? 'unknown'}".',
    );
  }
}

class ExampleDigestJob extends FutureCall<Comment> {
  @override
  Future<void> invoke(Session session, Comment? object) async {
    session.log(
      '[SampleJob] ExampleDigestJob completed for comment '
      '"${object?.title ?? 'unknown'}".',
    );
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
    final samplePost = await _findOrCreateSamplePost(session);
    final sampleComment = await _findOrCreateSampleComment(
      session,
      samplePost.id!,
    );

    final existingJobs = await FutureCallEntry.db.find(session);
    final now = DateTime.now().toUtc();

    await _ensureSampleJob(
      session: session,
      pod: pod,
      existingJobs: existingJobs,
      callName: _sampleReportJobName,
      payload: samplePost,
      scheduledAt: now.add(const Duration(days: 7)),
      identifier: _sampleReportIdentifier,
    );

    await _ensureSampleJob(
      session: session,
      pod: pod,
      existingJobs: existingJobs,
      callName: _sampleDigestJobName,
      payload: sampleComment,
      scheduledAt: now.add(const Duration(days: 14)),
      identifier: _sampleDigestIdentifier,
    );
  } finally {
    await session.close();
  }
}

Future<Post> _findOrCreateSamplePost(Session session) async {
  final posts = await Post.db.find(session);
  final existing = posts
      .where((post) => post.title == _samplePostTitle)
      .firstOrNull;
  if (existing != null) {
    return existing;
  }

  return Post.db.insertRow(
    session,
    Post(
      title: _samplePostTitle,
      description: 'Payload used by the Serverpod Admin sample report job.',
      date: DateTime.now().toUtc(),
      isPublished: true,
    ),
  );
}

Future<Comment> _findOrCreateSampleComment(
  Session session,
  int postId,
) async {
  final comments = await Comment.db.find(session);
  final existing = comments
      .where(
        (comment) =>
            comment.postId == postId && comment.title == _sampleCommentTitle,
      )
      .firstOrNull;
  if (existing != null) {
    return existing;
  }

  return Comment.db.insertRow(
    session,
    Comment(
      title: _sampleCommentTitle,
      description: 'Payload used by the Serverpod Admin sample digest job.',
      postId: postId,
      date: DateTime.now().toUtc(),
    ),
  );
}

Future<void> _ensureSampleJob({
  required Session session,
  required Serverpod pod,
  required List<FutureCallEntry> existingJobs,
  required String callName,
  required SerializableModel payload,
  required DateTime scheduledAt,
  required String identifier,
}) async {
  final existing = existingJobs
      .where((job) => job.identifier == identifier)
      .firstOrNull;

  if (existing != null && (existing.serializedObject?.isNotEmpty ?? false)) {
    return;
  }

  if (existing != null) {
    await FutureCallEntry.db.deleteRow(session, existing);
  }

  // ignore: deprecated_member_use
  await pod.futureCallAtTime(
    callName,
    payload,
    scheduledAt,
    identifier: identifier,
  );
}
