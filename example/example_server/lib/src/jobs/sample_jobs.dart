import 'package:example_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

const _sampleReportJobName = 'ExampleReportJob';
const _sampleDigestJobName = 'ExampleDigestJob';

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
