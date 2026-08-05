// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsm_order.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFsmOrderCollection on Isar {
  IsarCollection<FsmOrder> get fsmOrders => this.collection();
}

const FsmOrderSchema = CollectionSchema(
  name: r'FsmOrder',
  id: -4877572877574585524,
  properties: {
    r'dateEnd': PropertySchema(
      id: 0,
      name: r'dateEnd',
      type: IsarType.dateTime,
    ),
    r'dateStart': PropertySchema(
      id: 1,
      name: r'dateStart',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'inventoryLocationId': PropertySchema(
      id: 3,
      name: r'inventoryLocationId',
      type: IsarType.long,
    ),
    r'isPendingSync': PropertySchema(
      id: 4,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'isRecurringInstance': PropertySchema(
      id: 5,
      name: r'isRecurringInstance',
      type: IsarType.bool,
    ),
    r'isSkipped': PropertySchema(
      id: 6,
      name: r'isSkipped',
      type: IsarType.bool,
    ),
    r'lastSyncAt': PropertySchema(
      id: 7,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'locationAddress': PropertySchema(
      id: 8,
      name: r'locationAddress',
      type: IsarType.string,
    ),
    r'locationLat': PropertySchema(
      id: 9,
      name: r'locationLat',
      type: IsarType.double,
    ),
    r'locationLng': PropertySchema(
      id: 10,
      name: r'locationLng',
      type: IsarType.double,
    ),
    r'locationName': PropertySchema(
      id: 11,
      name: r'locationName',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'odooId': PropertySchema(
      id: 13,
      name: r'odooId',
      type: IsarType.long,
    ),
    r'partnerId': PropertySchema(
      id: 14,
      name: r'partnerId',
      type: IsarType.long,
    ),
    r'partnerName': PropertySchema(
      id: 15,
      name: r'partnerName',
      type: IsarType.string,
    ),
    r'partnerPhone': PropertySchema(
      id: 16,
      name: r'partnerPhone',
      type: IsarType.string,
    ),
    r'personId': PropertySchema(
      id: 17,
      name: r'personId',
      type: IsarType.long,
    ),
    r'personName': PropertySchema(
      id: 18,
      name: r'personName',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 19,
      name: r'priority',
      type: IsarType.string,
    ),
    r'recurringId': PropertySchema(
      id: 20,
      name: r'recurringId',
      type: IsarType.long,
    ),
    r'requireSignature': PropertySchema(
      id: 21,
      name: r'requireSignature',
      type: IsarType.bool,
    ),
    r'routeId': PropertySchema(
      id: 22,
      name: r'routeId',
      type: IsarType.long,
    ),
    r'routeSequence': PropertySchema(
      id: 23,
      name: r'routeSequence',
      type: IsarType.long,
    ),
    r'routeState': PropertySchema(
      id: 24,
      name: r'routeState',
      type: IsarType.string,
    ),
    r'scheduledDateEnd': PropertySchema(
      id: 25,
      name: r'scheduledDateEnd',
      type: IsarType.dateTime,
    ),
    r'scheduledDateStart': PropertySchema(
      id: 26,
      name: r'scheduledDateStart',
      type: IsarType.dateTime,
    ),
    r'stage': PropertySchema(
      id: 27,
      name: r'stage',
      type: IsarType.string,
      enumMap: _FsmOrderstageEnumValueMap,
    ),
    r'stageId': PropertySchema(
      id: 28,
      name: r'stageId',
      type: IsarType.long,
    ),
    r'stageName': PropertySchema(
      id: 29,
      name: r'stageName',
      type: IsarType.string,
    ),
    r'warehouseId': PropertySchema(
      id: 30,
      name: r'warehouseId',
      type: IsarType.long,
    )
  },
  estimateSize: _fsmOrderEstimateSize,
  serialize: _fsmOrderSerialize,
  deserialize: _fsmOrderDeserialize,
  deserializeProp: _fsmOrderDeserializeProp,
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
  getId: _fsmOrderGetId,
  getLinks: _fsmOrderGetLinks,
  attach: _fsmOrderAttach,
  version: '3.3.2',
);

int _fsmOrderEstimateSize(
  FsmOrder object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.locationAddress;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.locationName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.partnerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.partnerPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.personName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.priority;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.routeState;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.stage.name.length * 3;
  bytesCount += 3 + object.stageName.length * 3;
  return bytesCount;
}

void _fsmOrderSerialize(
  FsmOrder object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateEnd);
  writer.writeDateTime(offsets[1], object.dateStart);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.inventoryLocationId);
  writer.writeBool(offsets[4], object.isPendingSync);
  writer.writeBool(offsets[5], object.isRecurringInstance);
  writer.writeBool(offsets[6], object.isSkipped);
  writer.writeDateTime(offsets[7], object.lastSyncAt);
  writer.writeString(offsets[8], object.locationAddress);
  writer.writeDouble(offsets[9], object.locationLat);
  writer.writeDouble(offsets[10], object.locationLng);
  writer.writeString(offsets[11], object.locationName);
  writer.writeString(offsets[12], object.name);
  writer.writeLong(offsets[13], object.odooId);
  writer.writeLong(offsets[14], object.partnerId);
  writer.writeString(offsets[15], object.partnerName);
  writer.writeString(offsets[16], object.partnerPhone);
  writer.writeLong(offsets[17], object.personId);
  writer.writeString(offsets[18], object.personName);
  writer.writeString(offsets[19], object.priority);
  writer.writeLong(offsets[20], object.recurringId);
  writer.writeBool(offsets[21], object.requireSignature);
  writer.writeLong(offsets[22], object.routeId);
  writer.writeLong(offsets[23], object.routeSequence);
  writer.writeString(offsets[24], object.routeState);
  writer.writeDateTime(offsets[25], object.scheduledDateEnd);
  writer.writeDateTime(offsets[26], object.scheduledDateStart);
  writer.writeString(offsets[27], object.stage.name);
  writer.writeLong(offsets[28], object.stageId);
  writer.writeString(offsets[29], object.stageName);
  writer.writeLong(offsets[30], object.warehouseId);
}

FsmOrder _fsmOrderDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FsmOrder();
  object.dateEnd = reader.readDateTimeOrNull(offsets[0]);
  object.dateStart = reader.readDateTimeOrNull(offsets[1]);
  object.description = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.inventoryLocationId = reader.readLongOrNull(offsets[3]);
  object.isPendingSync = reader.readBool(offsets[4]);
  object.isRecurringInstance = reader.readBool(offsets[5]);
  object.isSkipped = reader.readBool(offsets[6]);
  object.lastSyncAt = reader.readDateTime(offsets[7]);
  object.locationAddress = reader.readStringOrNull(offsets[8]);
  object.locationLat = reader.readDoubleOrNull(offsets[9]);
  object.locationLng = reader.readDoubleOrNull(offsets[10]);
  object.locationName = reader.readStringOrNull(offsets[11]);
  object.name = reader.readString(offsets[12]);
  object.odooId = reader.readLong(offsets[13]);
  object.partnerId = reader.readLongOrNull(offsets[14]);
  object.partnerName = reader.readStringOrNull(offsets[15]);
  object.partnerPhone = reader.readStringOrNull(offsets[16]);
  object.personId = reader.readLongOrNull(offsets[17]);
  object.personName = reader.readStringOrNull(offsets[18]);
  object.priority = reader.readStringOrNull(offsets[19]);
  object.recurringId = reader.readLongOrNull(offsets[20]);
  object.requireSignature = reader.readBool(offsets[21]);
  object.routeId = reader.readLongOrNull(offsets[22]);
  object.routeSequence = reader.readLongOrNull(offsets[23]);
  object.routeState = reader.readStringOrNull(offsets[24]);
  object.scheduledDateEnd = reader.readDateTimeOrNull(offsets[25]);
  object.scheduledDateStart = reader.readDateTimeOrNull(offsets[26]);
  object.stage =
      _FsmOrderstageValueEnumMap[reader.readStringOrNull(offsets[27])] ??
          FsmOrderStage.draft;
  object.stageId = reader.readLong(offsets[28]);
  object.stageName = reader.readString(offsets[29]);
  object.warehouseId = reader.readLongOrNull(offsets[30]);
  return object;
}

P _fsmOrderDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (_FsmOrderstageValueEnumMap[reader.readStringOrNull(offset)] ??
          FsmOrderStage.draft) as P;
    case 28:
      return (reader.readLong(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FsmOrderstageEnumValueMap = {
  r'draft': r'draft',
  r'inProgress': r'inProgress',
  r'done': r'done',
  r'cancelled': r'cancelled',
};
const _FsmOrderstageValueEnumMap = {
  r'draft': FsmOrderStage.draft,
  r'inProgress': FsmOrderStage.inProgress,
  r'done': FsmOrderStage.done,
  r'cancelled': FsmOrderStage.cancelled,
};

Id _fsmOrderGetId(FsmOrder object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fsmOrderGetLinks(FsmOrder object) {
  return [];
}

void _fsmOrderAttach(IsarCollection<dynamic> col, Id id, FsmOrder object) {
  object.id = id;
}

extension FsmOrderByIndex on IsarCollection<FsmOrder> {
  Future<FsmOrder?> getByOdooId(int odooId) {
    return getByIndex(r'odooId', [odooId]);
  }

  FsmOrder? getByOdooIdSync(int odooId) {
    return getByIndexSync(r'odooId', [odooId]);
  }

  Future<bool> deleteByOdooId(int odooId) {
    return deleteByIndex(r'odooId', [odooId]);
  }

  bool deleteByOdooIdSync(int odooId) {
    return deleteByIndexSync(r'odooId', [odooId]);
  }

  Future<List<FsmOrder?>> getAllByOdooId(List<int> odooIdValues) {
    final values = odooIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'odooId', values);
  }

  List<FsmOrder?> getAllByOdooIdSync(List<int> odooIdValues) {
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

  Future<Id> putByOdooId(FsmOrder object) {
    return putByIndex(r'odooId', object);
  }

  Id putByOdooIdSync(FsmOrder object, {bool saveLinks = true}) {
    return putByIndexSync(r'odooId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOdooId(List<FsmOrder> objects) {
    return putAllByIndex(r'odooId', objects);
  }

  List<Id> putAllByOdooIdSync(List<FsmOrder> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'odooId', objects, saveLinks: saveLinks);
  }
}

extension FsmOrderQueryWhereSort on QueryBuilder<FsmOrder, FsmOrder, QWhere> {
  QueryBuilder<FsmOrder, FsmOrder, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhere> anyOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'odooId'),
      );
    });
  }
}

extension FsmOrderQueryWhere on QueryBuilder<FsmOrder, FsmOrder, QWhereClause> {
  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> idBetween(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> odooIdEqualTo(
      int odooId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'odooId',
        value: [odooId],
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> odooIdNotEqualTo(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> odooIdGreaterThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> odooIdLessThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterWhereClause> odooIdBetween(
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

extension FsmOrderQueryFilter
    on QueryBuilder<FsmOrder, FsmOrder, QFilterCondition> {
  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateEnd',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateEnd',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateEndEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateStart',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateStart',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateStartEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateStart',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateStart',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateStart',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> dateStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      inventoryLocationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'inventoryLocationId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      inventoryLocationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'inventoryLocationId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      inventoryLocationIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryLocationId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      inventoryLocationIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inventoryLocationId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      inventoryLocationIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inventoryLocationId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      inventoryLocationIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inventoryLocationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> isPendingSyncEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      isRecurringInstanceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRecurringInstance',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> isSkippedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSkipped',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> lastSyncAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> lastSyncAtGreaterThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> lastSyncAtLessThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> lastSyncAtBetween(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationAddress',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationAddress',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationLat',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationLatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationLat',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLatEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationLat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationLatGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationLat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLatLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationLat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLatBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationLat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLngIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationLng',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationLngIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationLng',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLngEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationLng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationLngGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationLng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLngLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationLng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationLngBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationLng',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationName',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationName',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> locationNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      locationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameContains(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> odooIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odooId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> odooIdGreaterThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> odooIdLessThan(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> odooIdBetween(
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

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partnerId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partnerId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partnerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partnerName',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partnerName',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partnerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partnerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partnerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partnerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partnerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partnerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partnerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partnerName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partnerPhone',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partnerPhone',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partnerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partnerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partnerPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partnerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partnerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partnerPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> partnerPhoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partnerPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partnerPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      partnerPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partnerPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'personId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'personId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'personName',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      personNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'personName',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'priority',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'priority',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'priority',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> priorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'priority',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> recurringIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recurringId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      recurringIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recurringId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> recurringIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurringId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      recurringIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurringId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> recurringIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurringId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> recurringIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurringId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      requireSignatureEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requireSignature',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'routeId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'routeId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      routeSequenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'routeSequence',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      routeSequenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'routeSequence',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeSequenceEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeSequence',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      routeSequenceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeSequence',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeSequenceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeSequence',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeSequenceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeSequence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'routeState',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      routeStateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'routeState',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'routeState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'routeState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routeState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routeState',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> routeStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeState',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      routeStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routeState',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledDateEnd',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledDateEnd',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDateEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDateEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDateEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDateEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledDateStart',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledDateStart',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDateStart',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDateStart',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDateStart',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      scheduledDateStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDateStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageEqualTo(
    FsmOrderStage value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageGreaterThan(
    FsmOrderStage value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageLessThan(
    FsmOrderStage value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageBetween(
    FsmOrderStage lower,
    FsmOrderStage upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stage',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stage',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stageId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stageId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stageId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stageName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stageName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> stageNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stageName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      stageNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stageName',
        value: '',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> warehouseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'warehouseId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      warehouseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'warehouseId',
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> warehouseIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warehouseId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition>
      warehouseIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'warehouseId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> warehouseIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'warehouseId',
        value: value,
      ));
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterFilterCondition> warehouseIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'warehouseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FsmOrderQueryObject
    on QueryBuilder<FsmOrder, FsmOrder, QFilterCondition> {}

extension FsmOrderQueryLinks
    on QueryBuilder<FsmOrder, FsmOrder, QFilterCondition> {}

extension FsmOrderQuerySortBy on QueryBuilder<FsmOrder, FsmOrder, QSortBy> {
  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByDateEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnd', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByDateEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnd', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByDateStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStart', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByDateStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStart', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByInventoryLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryLocationId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy>
      sortByInventoryLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryLocationId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByIsRecurringInstance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurringInstance', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy>
      sortByIsRecurringInstanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurringInstance', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByIsSkipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSkipped', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByIsSkippedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSkipped', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationAddress', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationAddress', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPartnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPartnerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPartnerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPartnerPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerPhone', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPartnerPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerPhone', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPersonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRecurringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurringId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRecurringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurringId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRequireSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireSignature', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRequireSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireSignature', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRouteSequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeSequence', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRouteSequenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeSequence', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRouteState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeState', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByRouteStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeState', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByScheduledDateEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateEnd', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByScheduledDateEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateEnd', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByScheduledDateStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateStart', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy>
      sortByScheduledDateStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateStart', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByStageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByStageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByStageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByStageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> sortByWarehouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseId', Sort.desc);
    });
  }
}

extension FsmOrderQuerySortThenBy
    on QueryBuilder<FsmOrder, FsmOrder, QSortThenBy> {
  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByDateEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnd', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByDateEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnd', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByDateStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStart', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByDateStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStart', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByInventoryLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryLocationId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy>
      thenByInventoryLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryLocationId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByIsRecurringInstance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurringInstance', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy>
      thenByIsRecurringInstanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurringInstance', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByIsSkipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSkipped', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByIsSkippedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSkipped', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationAddress', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationAddress', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odooId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPartnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPartnerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPartnerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPartnerPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerPhone', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPartnerPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerPhone', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPersonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRecurringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurringId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRecurringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurringId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRequireSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireSignature', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRequireSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireSignature', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRouteSequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeSequence', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRouteSequenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeSequence', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRouteState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeState', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByRouteStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeState', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByScheduledDateEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateEnd', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByScheduledDateEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateEnd', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByScheduledDateStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateStart', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy>
      thenByScheduledDateStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateStart', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByStageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByStageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageId', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByStageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageName', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByStageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stageName', Sort.desc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseId', Sort.asc);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QAfterSortBy> thenByWarehouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseId', Sort.desc);
    });
  }
}

extension FsmOrderQueryWhereDistinct
    on QueryBuilder<FsmOrder, FsmOrder, QDistinct> {
  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByDateEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateEnd');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByDateStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateStart');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByInventoryLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inventoryLocationId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByIsRecurringInstance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRecurringInstance');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByIsSkipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSkipped');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByLocationAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationAddress',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByLocationLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationLat');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByLocationLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationLng');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByLocationName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odooId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partnerId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByPartnerName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partnerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByPartnerPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partnerPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByPersonName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByPriority(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByRecurringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurringId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByRequireSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requireSignature');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByRouteSequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeSequence');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByRouteState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeState', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByScheduledDateEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDateEnd');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByScheduledDateStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDateStart');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByStage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByStageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stageId');
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByStageName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stageName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FsmOrder, FsmOrder, QDistinct> distinctByWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'warehouseId');
    });
  }
}

extension FsmOrderQueryProperty
    on QueryBuilder<FsmOrder, FsmOrder, QQueryProperty> {
  QueryBuilder<FsmOrder, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FsmOrder, DateTime?, QQueryOperations> dateEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateEnd');
    });
  }

  QueryBuilder<FsmOrder, DateTime?, QQueryOperations> dateStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateStart');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> inventoryLocationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventoryLocationId');
    });
  }

  QueryBuilder<FsmOrder, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<FsmOrder, bool, QQueryOperations> isRecurringInstanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRecurringInstance');
    });
  }

  QueryBuilder<FsmOrder, bool, QQueryOperations> isSkippedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSkipped');
    });
  }

  QueryBuilder<FsmOrder, DateTime, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> locationAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationAddress');
    });
  }

  QueryBuilder<FsmOrder, double?, QQueryOperations> locationLatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationLat');
    });
  }

  QueryBuilder<FsmOrder, double?, QQueryOperations> locationLngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationLng');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> locationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationName');
    });
  }

  QueryBuilder<FsmOrder, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<FsmOrder, int, QQueryOperations> odooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odooId');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> partnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partnerId');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> partnerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partnerName');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> partnerPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partnerPhone');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> personIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personId');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personName');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> recurringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurringId');
    });
  }

  QueryBuilder<FsmOrder, bool, QQueryOperations> requireSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requireSignature');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> routeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeId');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> routeSequenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeSequence');
    });
  }

  QueryBuilder<FsmOrder, String?, QQueryOperations> routeStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeState');
    });
  }

  QueryBuilder<FsmOrder, DateTime?, QQueryOperations>
      scheduledDateEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDateEnd');
    });
  }

  QueryBuilder<FsmOrder, DateTime?, QQueryOperations>
      scheduledDateStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDateStart');
    });
  }

  QueryBuilder<FsmOrder, FsmOrderStage, QQueryOperations> stageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stage');
    });
  }

  QueryBuilder<FsmOrder, int, QQueryOperations> stageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stageId');
    });
  }

  QueryBuilder<FsmOrder, String, QQueryOperations> stageNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stageName');
    });
  }

  QueryBuilder<FsmOrder, int?, QQueryOperations> warehouseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warehouseId');
    });
  }
}
