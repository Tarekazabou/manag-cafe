import 'package:uuid/uuid.dart';

String generateId() => const Uuid().v4();

String generateSalesId() => 'sale_${generateId()}';

String generateSnapshotId() => 'snapshot_${generateId()}';

String generateSyncOpId() => 'sync_${generateId()}';
