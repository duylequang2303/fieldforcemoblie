// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_report.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkReportCollection on Isar {
  IsarCollection<WorkReport> get workReports => this.collection();
}

const WorkReportSchema = CollectionSchema(
  name: r'WorkReport',
  id: 6631193665313486159,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customerName': PropertySchema(
      id: 1,
      name: r'customerName',
      type: IsarType.string,
    ),
    r'customerSignaturePath': PropertySchema(
      id: 2,
      name: r'customerSignaturePath',
      type: IsarType.string,
    ),
    r'isPendingSync': PropertySchema(
      id: 3,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'odooId': PropertySchema(
      id: 4,
      name: r'odooId',
      type: IsarType.long,
    ),
    r'orderOdooId': PropertySchema(
      id: 5,
      name: r'orderOdooId',
      type: IsarType.long,
    ),
    r'photoPaths': PropertySchema(
      id: 6,
      name: r'photoPaths',
      type: IsarType.stringList,
    ),
    r'problemsFound': PropertySchema(
      id: 7,
      name: r'problemsFound',
      type: IsarType.string,
    ),
    r'recommendation': PropertySchema(
      id: 8,
      name: r'recommendation',
      type: IsarType.string,
    ),
    r'signedAt': PropertySchema(
      id: 9,
      name: r'signedAt',
      type: IsarType.dateTime,
    ),
    r'workDone': PropertySchema(
      id: 10,
      name: r'workDone',
      type: IsarType.string,
    )
  },
  estimateSize: _workReportEstimateSize,
  serialize: _workReportSerialize,
  deserialize: _workReportDeserialize,
  deserializeProp: _workReportDeserializeProp,
  idName: r'id',
  indexes: {
    r'orderOdooId': IndexSchema(
      id: -73562086872608232,
      name: r'orderOdooId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'orderOdooId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _workReportGetId,
  getLinks: _workReportGetLinks,
  attach: _workReportAttach,
  version: '3.3.2',
);

int _workReportEstimateSize(
  WorkReport object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.customerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customerSignaturePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.photoPaths.length * 3;
  {
    for (var i = 0; i < object.photoPaths.length; i++) {
      final value = object.photoPaths[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.problemsFound;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.recommendation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.workDone.length * 3;
  return bytesCount;
}

void _workReportSerialize(
  WorkReport object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.customerName);
  writer.writeString(offsets[2], object.customerSignaturePath);
  writer.writeBool(offsets[3], object.isPendingSync);
  writer.writeLong(offsets[4], object.odooId);
  writer.writeLong(offsets[5], object.orderOdooId);
  writer.writeStringList(offsets[6], object.photoPaths);
  writer.writeString(offsets[7], object.problemsFound);
  writer.writeString(offsets[8], object.recommendation);
  writer.writeDateTime(offsets[9], object.signedAt);
  writer.writeString(offsets[10], object.workDone);
}

WorkReport _workReportDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkReport();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.customerName = reader.readStringOrNull(offsets[1]);
  object.customerSignaturePath = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isPendingSync = reader.readBool(offsets[3]);
  object.odooId = reader.readLongOrNull(offsets[4]);
  object.orderOdooId = reader.readLong(offsets[5]);
  object.photoPaths = reader.readStringList(offsets[6]) ?? [];
  object.problemsFound = reader.readStringOrNull(offsets[7]);
  object.recommendation = reader.readStringOrNull(offsets[8]);
  object.signedAt = reader.readDateTimeOrNull(offsets[9]);
  object.workDone = reader.readString(offsets[10]);
  return object;
}

P _workReportDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workReportGetId(WorkReport object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workReportGetLinks(WorkReport object) {
  return [];
}

void _workReportAttach(IsarCollection<dynamic> col, Id id, WorkReport object) {
  object.id = id;
}

extension WorkReportByIndex on IsarCollection<WorkReport> {
  Future<WorkReport?> getByOrderOdooId(int orderOdooId) {
    return getByIndex(r'orderOdooId', [orderOdooId]);
  }

  WorkReport? getByOrderOdooIdSync(int orderOdooId) {
    return getByIndexSync(r'orderOdooId', [orderOdooId]);
  }

  Future<bool> deleteByOrderOdooId(int orderOdooId) {
    return deleteByIndex(r'orderOdooId', [orderOdooId]);
  }

  bool deleteByOrderOdooIdSync(int orderOdooId) {
    return deleteByIndexSync(r'orderOdooId', [orderOdooId]);
  }

  Future<List<WorkReport?>> getAllByOrderOdooId(List<int> orderOdooIdValues) {
    final values = orderOdooIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'orderOdooId', values);
  }

  List<WorkReport?> getAllByOrderOdooIdSync(List<int> orderOdooIdValues) {
    final values = orderOdooIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'orderOdooId', values);
  }

  Future<int> deleteAllByOrderOdooId(List<int> orderOdooIdValues) {
    final values = orderOdooIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'orderOdooId', values);
  }

  int deleteAllByOrderOdooIdSync(List<int> orderOdooIdValues) {
    final values = orderOdooIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'orderOdooId', values);
  }

  Future<Id> putByOrderOdooId(WorkReport object) {
    return putByIndex(r'orderOdooId', object);
  }

  Id putByOrderOdooIdSync(WorkReport object, {bool saveLinks = true}) {
    return putByIndexSync(r'orderOdooId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOrderOdooId(List<WorkReport> objects) {
    return putAllByIndex(r'orderOdooId', objects);
  }

  List<Id> putAllByOrderOdooIdSync(List<WorkReport> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'orderOdooId', objects, saveLinks: saveLinks);
  }
}

extension WorkReportQueryWhereSort
    on QueryBuilder<WorkReport, WorkReport, QWhere> {
  QueryBuilder<WorkReport, WorkReport, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhere> anyOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'orderOdooId'),
      );
    });
  }
}

extension WorkReportQueryWhere
    on QueryBuilder<WorkReport, WorkReport, QWhereClause> {
  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> orderOdooIdEqualTo(
      int orderOdooId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'orderOdooId',
        value: [orderOdooId],
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> orderOdooIdNotEqualTo(
      int orderOdooId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderOdooId',
              lower: [],
              upper: [orderOdooId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderOdooId',
              lower: [orderOdooId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderOdooId',
              lower: [orderOdooId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderOdooId',
              lower: [],
              upper: [orderOdooId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause>
      orderOdooIdGreaterThan(
    int orderOdooId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'orderOdooId',
        lower: [orderOdooId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> orderOdooIdLessThan(
    int orderOdooId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'orderOdooId',
        lower: [],
        upper: [orderOdooId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterWhereClause> orderOdooIdBetween(
    int lowerOrderOdooId,
    int upperOrderOdooId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'orderOdooId',
        lower: [lowerOrderOdooId],
        includeLower: includeLower,
        upper: [upperOrderOdooId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkReportQueryFilter
    on QueryBuilder<WorkReport, WorkReport, QFilterCondition> {
  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customerName',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customerName',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customerName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customerSignaturePath',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customerSignaturePath',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerSignaturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customerSignaturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customerSignaturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customerSignaturePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customerSignaturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customerSignaturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customerSignaturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customerSignaturePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerSignaturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      customerSignaturePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customerSignaturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> odooIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'odooId',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      odooIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'odooId',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> odooIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> odooIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> odooIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> odooIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'odooId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      orderOdooIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderOdooId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      orderOdooIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderOdooId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      orderOdooIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderOdooId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      orderOdooIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderOdooId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      photoPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'problemsFound',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'problemsFound',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemsFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'problemsFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'problemsFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'problemsFound',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'problemsFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'problemsFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'problemsFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'problemsFound',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemsFound',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      problemsFoundIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'problemsFound',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recommendation',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recommendation',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommendation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommendation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendation',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      recommendationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommendation',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> signedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signedAt',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      signedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signedAt',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> signedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      signedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> signedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> signedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> workDoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workDone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      workDoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workDone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> workDoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workDone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> workDoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workDone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      workDoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'workDone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> workDoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'workDone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> workDoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'workDone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition> workDoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'workDone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      workDoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workDone',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterFilterCondition>
      workDoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'workDone',
        value: '',
      ));
    });
  }
}

extension WorkReportQueryObject
    on QueryBuilder<WorkReport, WorkReport, QFilterCondition> {}

extension WorkReportQueryLinks
    on QueryBuilder<WorkReport, WorkReport, QFilterCondition> {}

extension WorkReportQuerySortBy
    on QueryBuilder<WorkReport, WorkReport, QSortBy> {
  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy>
      sortByCustomerSignaturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerSignaturePath', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy>
      sortByCustomerSignaturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerSignaturePath', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByOrderOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByProblemsFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemsFound', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByProblemsFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemsFound', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByRecommendation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy>
      sortByRecommendationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortBySignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortBySignedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByWorkDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDone', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> sortByWorkDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDone', Sort.desc);
    });
  }
}

extension WorkReportQuerySortThenBy
    on QueryBuilder<WorkReport, WorkReport, QSortThenBy> {
  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy>
      thenByCustomerSignaturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerSignaturePath', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy>
      thenByCustomerSignaturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerSignaturePath', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByOrderOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByProblemsFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemsFound', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByProblemsFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemsFound', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByRecommendation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy>
      thenByRecommendationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenBySignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenBySignedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByWorkDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDone', Sort.asc);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QAfterSortBy> thenByWorkDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDone', Sort.desc);
    });
  }
}

extension WorkReportQueryWhereDistinct
    on QueryBuilder<WorkReport, WorkReport, QDistinct> {
  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByCustomerName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct>
      distinctByCustomerSignaturePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerSignaturePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odooId');
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderOdooId');
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByPhotoPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPaths');
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByProblemsFound(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'problemsFound',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByRecommendation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommendation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctBySignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signedAt');
    });
  }

  QueryBuilder<WorkReport, WorkReport, QDistinct> distinctByWorkDone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workDone', caseSensitive: caseSensitive);
    });
  }
}

extension WorkReportQueryProperty
    on QueryBuilder<WorkReport, WorkReport, QQueryProperty> {
  QueryBuilder<WorkReport, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkReport, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WorkReport, String?, QQueryOperations> customerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerName');
    });
  }

  QueryBuilder<WorkReport, String?, QQueryOperations>
      customerSignaturePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerSignaturePath');
    });
  }

  QueryBuilder<WorkReport, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<WorkReport, int?, QQueryOperations> odooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odooId');
    });
  }

  QueryBuilder<WorkReport, int, QQueryOperations> orderOdooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderOdooId');
    });
  }

  QueryBuilder<WorkReport, List<String>, QQueryOperations>
      photoPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPaths');
    });
  }

  QueryBuilder<WorkReport, String?, QQueryOperations> problemsFoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'problemsFound');
    });
  }

  QueryBuilder<WorkReport, String?, QQueryOperations> recommendationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommendation');
    });
  }

  QueryBuilder<WorkReport, DateTime?, QQueryOperations> signedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signedAt');
    });
  }

  QueryBuilder<WorkReport, String, QQueryOperations> workDoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workDone');
    });
  }
}
