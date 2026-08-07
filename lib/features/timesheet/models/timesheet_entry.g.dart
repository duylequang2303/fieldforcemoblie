// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timesheet_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimesheetEntryCollection on Isar {
  IsarCollection<TimesheetEntry> get timesheetEntrys => this.collection();
}

const TimesheetEntrySchema = CollectionSchema(
  name: r'TimesheetEntry',
  id: -433889819656722495,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'employeeName': PropertySchema(
      id: 2,
      name: r'employeeName',
      type: IsarType.string,
    ),
    r'hours': PropertySchema(
      id: 3,
      name: r'hours',
      type: IsarType.double,
    ),
    r'isPendingSync': PropertySchema(
      id: 4,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'isSyncFailed': PropertySchema(
      id: 5,
      name: r'isSyncFailed',
      type: IsarType.bool,
    ),
    r'lastSyncAt': PropertySchema(
      id: 6,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'localOwnerId': PropertySchema(
      id: 7,
      name: r'localOwnerId',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'nextRetryAt': PropertySchema(
      id: 9,
      name: r'nextRetryAt',
      type: IsarType.dateTime,
    ),
    r'odooId': PropertySchema(
      id: 10,
      name: r'odooId',
      type: IsarType.long,
    ),
    r'orderOdooId': PropertySchema(
      id: 11,
      name: r'orderOdooId',
      type: IsarType.long,
    ),
    r'syncRetryCount': PropertySchema(
      id: 12,
      name: r'syncRetryCount',
      type: IsarType.long,
    )
  },
  estimateSize: _timesheetEntryEstimateSize,
  serialize: _timesheetEntrySerialize,
  deserialize: _timesheetEntryDeserialize,
  deserializeProp: _timesheetEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'orderOdooId': IndexSchema(
      id: -73562086872608232,
      name: r'orderOdooId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'orderOdooId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'localOwnerId': IndexSchema(
      id: 8066245324207909689,
      name: r'localOwnerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localOwnerId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _timesheetEntryGetId,
  getLinks: _timesheetEntryGetLinks,
  attach: _timesheetEntryAttach,
  version: '3.3.2',
);

int _timesheetEntryEstimateSize(
  TimesheetEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.employeeName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _timesheetEntrySerialize(
  TimesheetEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.employeeName);
  writer.writeDouble(offsets[3], object.hours);
  writer.writeBool(offsets[4], object.isPendingSync);
  writer.writeBool(offsets[5], object.isSyncFailed);
  writer.writeDateTime(offsets[6], object.lastSyncAt);
  writer.writeLong(offsets[7], object.localOwnerId);
  writer.writeString(offsets[8], object.name);
  writer.writeDateTime(offsets[9], object.nextRetryAt);
  writer.writeLong(offsets[10], object.odooId);
  writer.writeLong(offsets[11], object.orderOdooId);
  writer.writeLong(offsets[12], object.syncRetryCount);
}

TimesheetEntry _timesheetEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimesheetEntry();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.employeeName = reader.readStringOrNull(offsets[2]);
  object.hours = reader.readDouble(offsets[3]);
  object.id = id;
  object.isPendingSync = reader.readBool(offsets[4]);
  object.isSyncFailed = reader.readBool(offsets[5]);
  object.lastSyncAt = reader.readDateTime(offsets[6]);
  object.localOwnerId = reader.readLongOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.nextRetryAt = reader.readDateTimeOrNull(offsets[9]);
  object.odooId = reader.readLongOrNull(offsets[10]);
  object.orderOdooId = reader.readLong(offsets[11]);
  object.syncRetryCount = reader.readLong(offsets[12]);
  return object;
}

P _timesheetEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timesheetEntryGetId(TimesheetEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timesheetEntryGetLinks(TimesheetEntry object) {
  return [];
}

void _timesheetEntryAttach(
    IsarCollection<dynamic> col, Id id, TimesheetEntry object) {
  object.id = id;
}

extension TimesheetEntryQueryWhereSort
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QWhere> {
  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhere> anyOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'orderOdooId'),
      );
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhere> anyLocalOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'localOwnerId'),
      );
    });
  }
}

extension TimesheetEntryQueryWhere
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QWhereClause> {
  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      orderOdooIdEqualTo(int orderOdooId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'orderOdooId',
        value: [orderOdooId],
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      orderOdooIdNotEqualTo(int orderOdooId) {
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      orderOdooIdLessThan(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      orderOdooIdBetween(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localOwnerId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOwnerId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdEqualTo(int? localOwnerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localOwnerId',
        value: [localOwnerId],
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdNotEqualTo(int? localOwnerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOwnerId',
              lower: [],
              upper: [localOwnerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOwnerId',
              lower: [localOwnerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOwnerId',
              lower: [localOwnerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOwnerId',
              lower: [],
              upper: [localOwnerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdGreaterThan(
    int? localOwnerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOwnerId',
        lower: [localOwnerId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdLessThan(
    int? localOwnerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOwnerId',
        lower: [],
        upper: [localOwnerId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterWhereClause>
      localOwnerIdBetween(
    int? lowerLocalOwnerId,
    int? upperLocalOwnerId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOwnerId',
        lower: [lowerLocalOwnerId],
        includeLower: includeLower,
        upper: [upperLocalOwnerId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimesheetEntryQueryFilter
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QFilterCondition> {
  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'employeeName',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'employeeName',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'employeeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'employeeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'employeeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'employeeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'employeeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeName',
        value: '',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      employeeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeName',
        value: '',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      hoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      hoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      hoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      hoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      isSyncFailedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSyncFailed',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      localOwnerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localOwnerId',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      localOwnerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localOwnerId',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      localOwnerIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localOwnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      localOwnerIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localOwnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      localOwnerIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localOwnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      localOwnerIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localOwnerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nextRetryAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextRetryAt',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nextRetryAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextRetryAt',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nextRetryAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nextRetryAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nextRetryAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      nextRetryAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextRetryAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      odooIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'odooId',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      odooIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'odooId',
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      odooIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      odooIdGreaterThan(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      odooIdLessThan(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      odooIdBetween(
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      orderOdooIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderOdooId',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
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

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      syncRetryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncRetryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      syncRetryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncRetryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      syncRetryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncRetryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterFilterCondition>
      syncRetryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncRetryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimesheetEntryQueryObject
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QFilterCondition> {}

extension TimesheetEntryQueryLinks
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QFilterCondition> {}

extension TimesheetEntryQuerySortBy
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QSortBy> {
  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByEmployeeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeName', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByEmployeeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeName', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hours', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hours', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByIsSyncFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSyncFailed', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByIsSyncFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSyncFailed', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByLocalOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOwnerId', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByLocalOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOwnerId', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> sortByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortByOrderOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortBySyncRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      sortBySyncRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.desc);
    });
  }
}

extension TimesheetEntryQuerySortThenBy
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QSortThenBy> {
  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByEmployeeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeName', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByEmployeeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeName', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hours', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hours', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByIsSyncFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSyncFailed', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByIsSyncFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSyncFailed', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByLocalOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOwnerId', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByLocalOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOwnerId', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy> thenByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenByOrderOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.desc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenBySyncRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.asc);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QAfterSortBy>
      thenBySyncRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.desc);
    });
  }
}

extension TimesheetEntryQueryWhereDistinct
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct> {
  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByEmployeeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct> distinctByHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hours');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByIsSyncFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSyncFailed');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByLocalOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localOwnerId');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextRetryAt');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct> distinctByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odooId');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderOdooId');
    });
  }

  QueryBuilder<TimesheetEntry, TimesheetEntry, QDistinct>
      distinctBySyncRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncRetryCount');
    });
  }
}

extension TimesheetEntryQueryProperty
    on QueryBuilder<TimesheetEntry, TimesheetEntry, QQueryProperty> {
  QueryBuilder<TimesheetEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimesheetEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TimesheetEntry, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<TimesheetEntry, String?, QQueryOperations>
      employeeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeName');
    });
  }

  QueryBuilder<TimesheetEntry, double, QQueryOperations> hoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hours');
    });
  }

  QueryBuilder<TimesheetEntry, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<TimesheetEntry, bool, QQueryOperations> isSyncFailedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSyncFailed');
    });
  }

  QueryBuilder<TimesheetEntry, DateTime, QQueryOperations>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<TimesheetEntry, int?, QQueryOperations> localOwnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localOwnerId');
    });
  }

  QueryBuilder<TimesheetEntry, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TimesheetEntry, DateTime?, QQueryOperations>
      nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextRetryAt');
    });
  }

  QueryBuilder<TimesheetEntry, int?, QQueryOperations> odooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odooId');
    });
  }

  QueryBuilder<TimesheetEntry, int, QQueryOperations> orderOdooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderOdooId');
    });
  }

  QueryBuilder<TimesheetEntry, int, QQueryOperations> syncRetryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncRetryCount');
    });
  }
}
