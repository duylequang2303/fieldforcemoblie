// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsm_frequency_set.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFsmFrequencySetCollection on Isar {
  IsarCollection<FsmFrequencySet> get fsmFrequencySets => this.collection();
}

const FsmFrequencySetSchema = CollectionSchema(
  name: r'FsmFrequencySet',
  id: 945145306367413749,
  properties: {
    r'duration': PropertySchema(
      id: 0,
      name: r'duration',
      type: IsarType.long,
    ),
    r'interval': PropertySchema(
      id: 1,
      name: r'interval',
      type: IsarType.long,
    ),
    r'intervalType': PropertySchema(
      id: 2,
      name: r'intervalType',
      type: IsarType.string,
      enumMap: _FsmFrequencySetintervalTypeEnumValueMap,
    ),
    r'isPendingSync': PropertySchema(
      id: 3,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'lastSyncAt': PropertySchema(
      id: 4,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'odooId': PropertySchema(
      id: 6,
      name: r'odooId',
      type: IsarType.long,
    )
  },
  estimateSize: _fsmFrequencySetEstimateSize,
  serialize: _fsmFrequencySetSerialize,
  deserialize: _fsmFrequencySetDeserialize,
  deserializeProp: _fsmFrequencySetDeserializeProp,
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
  getId: _fsmFrequencySetGetId,
  getLinks: _fsmFrequencySetGetLinks,
  attach: _fsmFrequencySetAttach,
  version: '3.3.2',
);

int _fsmFrequencySetEstimateSize(
  FsmFrequencySet object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.intervalType.name.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _fsmFrequencySetSerialize(
  FsmFrequencySet object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duration);
  writer.writeLong(offsets[1], object.interval);
  writer.writeString(offsets[2], object.intervalType.name);
  writer.writeBool(offsets[3], object.isPendingSync);
  writer.writeDateTime(offsets[4], object.lastSyncAt);
  writer.writeString(offsets[5], object.name);
  writer.writeLong(offsets[6], object.odooId);
}

FsmFrequencySet _fsmFrequencySetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FsmFrequencySet();
  object.duration = reader.readLongOrNull(offsets[0]);
  object.id = id;
  object.interval = reader.readLong(offsets[1]);
  object.intervalType = _FsmFrequencySetintervalTypeValueEnumMap[
          reader.readStringOrNull(offsets[2])] ??
      FrequencyIntervalType.daily;
  object.isPendingSync = reader.readBool(offsets[3]);
  object.lastSyncAt = reader.readDateTime(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.odooId = reader.readLong(offsets[6]);
  return object;
}

P _fsmFrequencySetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_FsmFrequencySetintervalTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          FrequencyIntervalType.daily) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FsmFrequencySetintervalTypeEnumValueMap = {
  r'daily': r'daily',
  r'weekly': r'weekly',
  r'monthly': r'monthly',
  r'yearly': r'yearly',
};
const _FsmFrequencySetintervalTypeValueEnumMap = {
  r'daily': FrequencyIntervalType.daily,
  r'weekly': FrequencyIntervalType.weekly,
  r'monthly': FrequencyIntervalType.monthly,
  r'yearly': FrequencyIntervalType.yearly,
};

Id _fsmFrequencySetGetId(FsmFrequencySet object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fsmFrequencySetGetLinks(FsmFrequencySet object) {
  return [];
}

void _fsmFrequencySetAttach(
    IsarCollection<dynamic> col, Id id, FsmFrequencySet object) {
  object.id = id;
}

extension FsmFrequencySetByIndex on IsarCollection<FsmFrequencySet> {
  Future<FsmFrequencySet?> getByOdooId(int odooId) {
    return getByIndex(r'odooId', [odooId]);
  }

  FsmFrequencySet? getByOdooIdSync(int odooId) {
    return getByIndexSync(r'odooId', [odooId]);
  }

  Future<bool> deleteByOdooId(int odooId) {
    return deleteByIndex(r'odooId', [odooId]);
  }

  bool deleteByOdooIdSync(int odooId) {
    return deleteByIndexSync(r'odooId', [odooId]);
  }

  Future<List<FsmFrequencySet?>> getAllByOdooId(List<int> odooIdValues) {
    final values = odooIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'odooId', values);
  }

  List<FsmFrequencySet?> getAllByOdooIdSync(List<int> odooIdValues) {
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

  Future<Id> putByOdooId(FsmFrequencySet object) {
    return putByIndex(r'odooId', object);
  }

  Id putByOdooIdSync(FsmFrequencySet object, {bool saveLinks = true}) {
    return putByIndexSync(r'odooId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOdooId(List<FsmFrequencySet> objects) {
    return putAllByIndex(r'odooId', objects);
  }

  List<Id> putAllByOdooIdSync(List<FsmFrequencySet> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'odooId', objects, saveLinks: saveLinks);
  }
}

extension FsmFrequencySetQueryWhereSort
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QWhere> {
  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhere> anyOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'odooId'),
      );
    });
  }
}

extension FsmFrequencySetQueryWhere
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QWhereClause> {
  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause> idBetween(
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      odooIdEqualTo(int odooId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'odooId',
        value: [odooId],
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      odooIdNotEqualTo(int odooId) {
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      odooIdGreaterThan(
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      odooIdLessThan(
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterWhereClause>
      odooIdBetween(
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

extension FsmFrequencySetQueryFilter
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QFilterCondition> {
  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeEqualTo(
    FrequencyIntervalType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeGreaterThan(
    FrequencyIntervalType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeLessThan(
    FrequencyIntervalType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeBetween(
    FrequencyIntervalType lower,
    FrequencyIntervalType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'intervalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'intervalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'intervalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'intervalType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalType',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      intervalTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'intervalType',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      odooIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
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

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterFilterCondition>
      odooIdBetween(
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
}

extension FsmFrequencySetQueryObject
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QFilterCondition> {}

extension FsmFrequencySetQueryLinks
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QFilterCondition> {}

extension FsmFrequencySetQuerySortBy
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QSortBy> {
  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByIntervalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalType', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByIntervalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalType', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy> sortByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      sortByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }
}

extension FsmFrequencySetQuerySortThenBy
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QSortThenBy> {
  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByIntervalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalType', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByIntervalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalType', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy> thenByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QAfterSortBy>
      thenByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }
}

extension FsmFrequencySetQueryWhereDistinct
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct> {
  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct>
      distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct>
      distinctByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interval');
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct>
      distinctByIntervalType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct>
      distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct>
      distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmFrequencySet, FsmFrequencySet, QDistinct> distinctByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odooId');
    });
  }
}

extension FsmFrequencySetQueryProperty
    on QueryBuilder<FsmFrequencySet, FsmFrequencySet, QQueryProperty> {
  QueryBuilder<FsmFrequencySet, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FsmFrequencySet, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<FsmFrequencySet, int, QQueryOperations> intervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interval');
    });
  }

  QueryBuilder<FsmFrequencySet, FrequencyIntervalType, QQueryOperations>
      intervalTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalType');
    });
  }

  QueryBuilder<FsmFrequencySet, bool, QQueryOperations>
      isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<FsmFrequencySet, DateTime, QQueryOperations>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<FsmFrequencySet, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<FsmFrequencySet, int, QQueryOperations> odooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odooId');
    });
  }
}
