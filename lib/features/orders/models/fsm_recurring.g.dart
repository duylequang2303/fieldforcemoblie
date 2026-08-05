// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsm_recurring.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFsmRecurringCollection on Isar {
  IsarCollection<FsmRecurring> get fsmRecurrings => this.collection();
}

const FsmRecurringSchema = CollectionSchema(
  name: r'FsmRecurring',
  id: 2048914922398137943,
  properties: {
    r'companyId': PropertySchema(
      id: 0,
      name: r'companyId',
      type: IsarType.long,
    ),
    r'endDate': PropertySchema(
      id: 1,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'frequencySetId': PropertySchema(
      id: 2,
      name: r'frequencySetId',
      type: IsarType.long,
    ),
    r'generatedCount': PropertySchema(
      id: 3,
      name: r'generatedCount',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isPendingSync': PropertySchema(
      id: 5,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'lastSyncAt': PropertySchema(
      id: 6,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'nextDate': PropertySchema(
      id: 8,
      name: r'nextDate',
      type: IsarType.dateTime,
    ),
    r'odooId': PropertySchema(
      id: 9,
      name: r'odooId',
      type: IsarType.long,
    ),
    r'orderTemplateId': PropertySchema(
      id: 10,
      name: r'orderTemplateId',
      type: IsarType.long,
    ),
    r'startDate': PropertySchema(
      id: 11,
      name: r'startDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _fsmRecurringEstimateSize,
  serialize: _fsmRecurringSerialize,
  deserialize: _fsmRecurringDeserialize,
  deserializeProp: _fsmRecurringDeserializeProp,
  idName: r'id',
  indexes: {
    r'odooId': IndexSchema(
      id: -1336593894000172571,
      name: r'odooId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'odooId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _fsmRecurringGetId,
  getLinks: _fsmRecurringGetLinks,
  attach: _fsmRecurringAttach,
  version: '3.3.2',
);

int _fsmRecurringEstimateSize(
  FsmRecurring object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _fsmRecurringSerialize(
  FsmRecurring object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.companyId);
  writer.writeDateTime(offsets[1], object.endDate);
  writer.writeLong(offsets[2], object.frequencySetId);
  writer.writeLong(offsets[3], object.generatedCount);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeBool(offsets[5], object.isPendingSync);
  writer.writeDateTime(offsets[6], object.lastSyncAt);
  writer.writeString(offsets[7], object.name);
  writer.writeDateTime(offsets[8], object.nextDate);
  writer.writeLong(offsets[9], object.odooId);
  writer.writeLong(offsets[10], object.orderTemplateId);
  writer.writeDateTime(offsets[11], object.startDate);
}

FsmRecurring _fsmRecurringDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FsmRecurring();
  object.companyId = reader.readLongOrNull(offsets[0]);
  object.endDate = reader.readDateTimeOrNull(offsets[1]);
  object.frequencySetId = reader.readLong(offsets[2]);
  object.generatedCount = reader.readLong(offsets[3]);
  object.id = id;
  object.isActive = reader.readBool(offsets[4]);
  object.isPendingSync = reader.readBool(offsets[5]);
  object.lastSyncAt = reader.readDateTime(offsets[6]);
  object.name = reader.readString(offsets[7]);
  object.nextDate = reader.readDateTimeOrNull(offsets[8]);
  object.odooId = reader.readLong(offsets[9]);
  object.orderTemplateId = reader.readLongOrNull(offsets[10]);
  object.startDate = reader.readDateTime(offsets[11]);
  return object;
}

P _fsmRecurringDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fsmRecurringGetId(FsmRecurring object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fsmRecurringGetLinks(FsmRecurring object) {
  return [];
}

void _fsmRecurringAttach(
    IsarCollection<dynamic> col, Id id, FsmRecurring object) {
  object.id = id;
}

extension FsmRecurringByIndex on IsarCollection<FsmRecurring> {
  Future<FsmRecurring?> getByOdooId(int odooId) {
    return getByIndex(r'odooId', [odooId]);
  }

  FsmRecurring? getByOdooIdSync(int odooId) {
    return getByIndexSync(r'odooId', [odooId]);
  }

  Future<bool> deleteByOdooId(int odooId) {
    return deleteByIndex(r'odooId', [odooId]);
  }

  bool deleteByOdooIdSync(int odooId) {
    return deleteByIndexSync(r'odooId', [odooId]);
  }

  Future<List<FsmRecurring?>> getAllByOdooId(List<int> odooIdValues) {
    final values = odooIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'odooId', values);
  }

  List<FsmRecurring?> getAllByOdooIdSync(List<int> odooIdValues) {
    final values = odooIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'odooId', values);
  }

  Future<int> deleteAllByOdooId(List<int> odooIdValues) {
    final values = odooIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'odooId', values);
  }

  int deleteAllByOdooIdSync(List<int> odooIdValues) {
    final values = odooIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'odooId', values);
  }

  Future<Id> putByOdooId(FsmRecurring object) {
    return putByIndex(r'odooId', object);
  }

  Id putByOdooIdSync(FsmRecurring object, {bool saveLinks = true}) {
    return putByIndexSync(r'odooId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOdooId(List<FsmRecurring> objects) {
    return putAllByIndex(r'odooId', objects);
  }

  List<Id> putAllByOdooIdSync(List<FsmRecurring> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'odooId', objects, saveLinks: saveLinks);
  }
}

extension FsmRecurringQueryWhereSort
    on QueryBuilder<FsmRecurring, FsmRecurring, QWhere> {
  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhere> anyOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'odooId'),
      );
    });
  }
}

extension FsmRecurringQueryWhere
    on QueryBuilder<FsmRecurring, FsmRecurring, QWhereClause> {
  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> idBetween(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> odooIdEqualTo(
      int odooId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'odooId',
        value: [odooId],
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> odooIdNotEqualTo(
      int odooId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'odooId',
              lower: [],
              upper: [odooId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'odooId',
              lower: [odooId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'odooId',
              lower: [odooId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'odooId',
              lower: [],
              upper: [odooId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> odooIdGreaterThan(
    int odooId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'odooId',
        lower: [odooId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> odooIdLessThan(
    int odooId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'odooId',
        lower: [],
        upper: [odooId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterWhereClause> odooIdBetween(
    int lowerOdooId,
    int upperOdooId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'odooId',
        lower: [lowerOdooId],
        includeLower: includeLower,
        upper: [upperOdooId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FsmRecurringQueryFilter
    on QueryBuilder<FsmRecurring, FsmRecurring, QFilterCondition> {
  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      companyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'companyId',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      companyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'companyId',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      companyIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      companyIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      companyIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      companyIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'companyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      endDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      frequencySetIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencySetId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      frequencySetIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequencySetId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      frequencySetIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequencySetId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      frequencySetIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequencySetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      generatedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      generatedCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      generatedCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      generatedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nextDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextDate',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nextDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextDate',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nextDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nextDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nextDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      nextDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> odooIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      odooIdGreaterThan(
    int value, {
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      odooIdLessThan(
    int value, {
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition> odooIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      orderTemplateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'orderTemplateId',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      orderTemplateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'orderTemplateId',
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      orderTemplateIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderTemplateId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      orderTemplateIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderTemplateId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      orderTemplateIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderTemplateId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      orderTemplateIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderTemplateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FsmRecurringQueryObject
    on QueryBuilder<FsmRecurring, FsmRecurring, QFilterCondition> {}

extension FsmRecurringQueryLinks
    on QueryBuilder<FsmRecurring, FsmRecurring, QFilterCondition> {}

extension FsmRecurringQuerySortBy
    on QueryBuilder<FsmRecurring, FsmRecurring, QSortBy> {
  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByFrequencySetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencySetId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByFrequencySetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencySetId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByGeneratedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedCount', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByGeneratedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedCount', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByNextDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDate', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByNextDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDate', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByOrderTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderTemplateId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      sortByOrderTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderTemplateId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension FsmRecurringQuerySortThenBy
    on QueryBuilder<FsmRecurring, FsmRecurring, QSortThenBy> {
  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByFrequencySetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencySetId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByFrequencySetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencySetId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByGeneratedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedCount', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByGeneratedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedCount', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByNextDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDate', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByNextDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDate', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByOrderTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderTemplateId', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy>
      thenByOrderTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderTemplateId', Sort.desc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension FsmRecurringQueryWhereDistinct
    on QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> {
  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companyId');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct>
      distinctByFrequencySetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequencySetId');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct>
      distinctByGeneratedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedCount');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct>
      distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByNextDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDate');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odooId');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct>
      distinctByOrderTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderTemplateId');
    });
  }

  QueryBuilder<FsmRecurring, FsmRecurring, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }
}

extension FsmRecurringQueryProperty
    on QueryBuilder<FsmRecurring, FsmRecurring, QQueryProperty> {
  QueryBuilder<FsmRecurring, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FsmRecurring, int?, QQueryOperations> companyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companyId');
    });
  }

  QueryBuilder<FsmRecurring, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<FsmRecurring, int, QQueryOperations> frequencySetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequencySetId');
    });
  }

  QueryBuilder<FsmRecurring, int, QQueryOperations> generatedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedCount');
    });
  }

  QueryBuilder<FsmRecurring, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<FsmRecurring, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<FsmRecurring, DateTime, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<FsmRecurring, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<FsmRecurring, DateTime?, QQueryOperations> nextDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDate');
    });
  }

  QueryBuilder<FsmRecurring, int, QQueryOperations> odooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odooId');
    });
  }

  QueryBuilder<FsmRecurring, int?, QQueryOperations> orderTemplateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderTemplateId');
    });
  }

  QueryBuilder<FsmRecurring, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }
}
