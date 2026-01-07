// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_database.dart';

// ignore_for_file: type=lint
class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("pending"),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    durationSeconds,
    url,
    localPath,
    progress,
    status,
    sizeBytes,
    createdAt,
    coverUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_coverUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      )!,
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class Download extends DataClass implements Insertable<Download> {
  final int id;
  final String title;
  final String type;
  final int? durationSeconds;
  final String url;
  final String? localPath;
  final int progress;
  final String status;
  final int? sizeBytes;
  final DateTime createdAt;
  final String coverUrl;
  const Download({
    required this.id,
    required this.title,
    required this.type,
    this.durationSeconds,
    required this.url,
    this.localPath,
    required this.progress,
    required this.status,
    this.sizeBytes,
    required this.createdAt,
    required this.coverUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['progress'] = Variable<int>(progress);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cover_url'] = Variable<String>(coverUrl);
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      url: Value(url),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      progress: Value(progress),
      status: Value(status),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      createdAt: Value(createdAt),
      coverUrl: Value(coverUrl),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      url: serializer.fromJson<String>(json['url']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      progress: serializer.fromJson<int>(json['progress']),
      status: serializer.fromJson<String>(json['status']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'url': serializer.toJson<String>(url),
      'localPath': serializer.toJson<String?>(localPath),
      'progress': serializer.toJson<int>(progress),
      'status': serializer.toJson<String>(status),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'coverUrl': serializer.toJson<String>(coverUrl),
    };
  }

  Download copyWith({
    int? id,
    String? title,
    String? type,
    Value<int?> durationSeconds = const Value.absent(),
    String? url,
    Value<String?> localPath = const Value.absent(),
    int? progress,
    String? status,
    Value<int?> sizeBytes = const Value.absent(),
    DateTime? createdAt,
    String? coverUrl,
  }) => Download(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    url: url ?? this.url,
    localPath: localPath.present ? localPath.value : this.localPath,
    progress: progress ?? this.progress,
    status: status ?? this.status,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    coverUrl: coverUrl ?? this.coverUrl,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      url: data.url.present ? data.url.value : this.url,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      progress: data.progress.present ? data.progress.value : this.progress,
      status: data.status.present ? data.status.value : this.status,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('progress: $progress, ')
          ..write('status: $status, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('coverUrl: $coverUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    durationSeconds,
    url,
    localPath,
    progress,
    status,
    sizeBytes,
    createdAt,
    coverUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.durationSeconds == this.durationSeconds &&
          other.url == this.url &&
          other.localPath == this.localPath &&
          other.progress == this.progress &&
          other.status == this.status &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.coverUrl == this.coverUrl);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> type;
  final Value<int?> durationSeconds;
  final Value<String> url;
  final Value<String?> localPath;
  final Value<int> progress;
  final Value<String> status;
  final Value<int?> sizeBytes;
  final Value<DateTime> createdAt;
  final Value<String> coverUrl;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.progress = const Value.absent(),
    this.status = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.coverUrl = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String type,
    this.durationSeconds = const Value.absent(),
    required String url,
    this.localPath = const Value.absent(),
    this.progress = const Value.absent(),
    this.status = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String coverUrl,
  }) : title = Value(title),
       type = Value(type),
       url = Value(url),
       coverUrl = Value(coverUrl);
  static Insertable<Download> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<int>? durationSeconds,
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? progress,
    Expression<String>? status,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
    Expression<String>? coverUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (progress != null) 'progress': progress,
      if (status != null) 'status': status,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (coverUrl != null) 'cover_url': coverUrl,
    });
  }

  DownloadsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? type,
    Value<int?>? durationSeconds,
    Value<String>? url,
    Value<String?>? localPath,
    Value<int>? progress,
    Value<String>? status,
    Value<int?>? sizeBytes,
    Value<DateTime>? createdAt,
    Value<String>? coverUrl,
  }) {
    return DownloadsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('progress: $progress, ')
          ..write('status: $status, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('coverUrl: $coverUrl')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabaseDownload extends GeneratedDatabase {
  _$AppDatabaseDownload(QueryExecutor e) : super(e);
  $AppDatabaseDownloadManager get managers => $AppDatabaseDownloadManager(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [downloads];
}

typedef $$DownloadsTableCreateCompanionBuilder =
    DownloadsCompanion Function({
      Value<int> id,
      required String title,
      required String type,
      Value<int?> durationSeconds,
      required String url,
      Value<String?> localPath,
      Value<int> progress,
      Value<String> status,
      Value<int?> sizeBytes,
      Value<DateTime> createdAt,
      required String coverUrl,
    });
typedef $$DownloadsTableUpdateCompanionBuilder =
    DownloadsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> type,
      Value<int?> durationSeconds,
      Value<String> url,
      Value<String?> localPath,
      Value<int> progress,
      Value<String> status,
      Value<int?> sizeBytes,
      Value<DateTime> createdAt,
      Value<String> coverUrl,
    });

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabaseDownload, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabaseDownload, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabaseDownload, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabaseDownload,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (
            Download,
            BaseReferences<_$AppDatabaseDownload, $DownloadsTable, Download>,
          ),
          Download,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableManager(_$AppDatabaseDownload db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
              }) => DownloadsCompanion(
                id: id,
                title: title,
                type: type,
                durationSeconds: durationSeconds,
                url: url,
                localPath: localPath,
                progress: progress,
                status: status,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                coverUrl: coverUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String type,
                Value<int?> durationSeconds = const Value.absent(),
                required String url,
                Value<String?> localPath = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String coverUrl,
              }) => DownloadsCompanion.insert(
                id: id,
                title: title,
                type: type,
                durationSeconds: durationSeconds,
                url: url,
                localPath: localPath,
                progress: progress,
                status: status,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                coverUrl: coverUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabaseDownload,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (
        Download,
        BaseReferences<_$AppDatabaseDownload, $DownloadsTable, Download>,
      ),
      Download,
      PrefetchHooks Function()
    >;

class $AppDatabaseDownloadManager {
  final _$AppDatabaseDownload _db;
  $AppDatabaseDownloadManager(this._db);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
}
