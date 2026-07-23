// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_move.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStockMoveCollection on Isar {
  IsarCollection<StockMove> get stockMoves => this.collection();
}

const StockMoveSchema = CollectionSchema(
  name: r'StockMove',
  id: -3633861686332660392,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'demandQty': PropertySchema(
      id: 1,
      name: r'demandQty',
      type: IsarType.double,
    ),
    r'doneQty': PropertySchema(
      id: 2,
      name: r'doneQty',
      type: IsarType.double,
    ),
    r'isPendingSync': PropertySchema(
      id: 3,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'moveType': PropertySchema(
      id: 4,
      name: r'moveType',
      type: IsarType.string,
      enumMap: _StockMovemoveTypeEnumValueMap,
    ),
    r'orderOdooId': PropertySchema(
      id: 5,
      name: r'orderOdooId',
      type: IsarType.long,
    ),
    r'productBarcode': PropertySchema(
      id: 6,
      name: r'productBarcode',
      type: IsarType.string,
    ),
    r'productCode': PropertySchema(
      id: 7,
      name: r'productCode',
      type: IsarType.string,
    ),
    r'productId': PropertySchema(
      id: 8,
      name: r'productId',
      type: IsarType.long,
    ),
    r'productName': PropertySchema(
      id: 9,
      name: r'productName',
      type: IsarType.string,
    ),
    r'uomName': PropertySchema(
      id: 10,
      name: r'uomName',
      type: IsarType.string,
    )
  },
  estimateSize: _stockMoveEstimateSize,
  serialize: _stockMoveSerialize,
  deserialize: _stockMoveDeserialize,
  deserializeProp: _stockMoveDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _stockMoveGetId,
  getLinks: _stockMoveGetLinks,
  attach: _stockMoveAttach,
  version: '3.3.2',
);

int _stockMoveEstimateSize(
  StockMove object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.moveType.name.length * 3;
  {
    final value = object.productBarcode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.productCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productName.length * 3;
  {
    final value = object.uomName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _stockMoveSerialize(
  StockMove object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDouble(offsets[1], object.demandQty);
  writer.writeDouble(offsets[2], object.doneQty);
  writer.writeBool(offsets[3], object.isPendingSync);
  writer.writeString(offsets[4], object.moveType.name);
  writer.writeLong(offsets[5], object.orderOdooId);
  writer.writeString(offsets[6], object.productBarcode);
  writer.writeString(offsets[7], object.productCode);
  writer.writeLong(offsets[8], object.productId);
  writer.writeString(offsets[9], object.productName);
  writer.writeString(offsets[10], object.uomName);
}

StockMove _stockMoveDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StockMove();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.demandQty = reader.readDouble(offsets[1]);
  object.doneQty = reader.readDouble(offsets[2]);
  object.id = id;
  object.isPendingSync = reader.readBool(offsets[3]);
  object.moveType =
      _StockMovemoveTypeValueEnumMap[reader.readStringOrNull(offsets[4])] ??
          MoveType.out;
  object.orderOdooId = reader.readLong(offsets[5]);
  object.productBarcode = reader.readStringOrNull(offsets[6]);
  object.productCode = reader.readStringOrNull(offsets[7]);
  object.productId = reader.readLong(offsets[8]);
  object.productName = reader.readString(offsets[9]);
  object.uomName = reader.readStringOrNull(offsets[10]);
  return object;
}

P _stockMoveDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (_StockMovemoveTypeValueEnumMap[reader.readStringOrNull(offset)] ??
          MoveType.out) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _StockMovemoveTypeEnumValueMap = {
  r'out': r'out',
  r'in_': r'in_',
};
const _StockMovemoveTypeValueEnumMap = {
  r'out': MoveType.out,
  r'in_': MoveType.in_,
};

Id _stockMoveGetId(StockMove object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stockMoveGetLinks(StockMove object) {
  return [];
}

void _stockMoveAttach(IsarCollection<dynamic> col, Id id, StockMove object) {
  object.id = id;
}

extension StockMoveQueryWhereSort
    on QueryBuilder<StockMove, StockMove, QWhere> {
  QueryBuilder<StockMove, StockMove, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterWhere> anyOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'orderOdooId'),
      );
    });
  }
}

extension StockMoveQueryWhere
    on QueryBuilder<StockMove, StockMove, QWhereClause> {
  QueryBuilder<StockMove, StockMove, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> idBetween(
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

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> orderOdooIdEqualTo(
      int orderOdooId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'orderOdooId',
        value: [orderOdooId],
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> orderOdooIdNotEqualTo(
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

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> orderOdooIdGreaterThan(
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

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> orderOdooIdLessThan(
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

  QueryBuilder<StockMove, StockMove, QAfterWhereClause> orderOdooIdBetween(
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

extension StockMoveQueryFilter
    on QueryBuilder<StockMove, StockMove, QFilterCondition> {
  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> demandQtyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'demandQty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      demandQtyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'demandQty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> demandQtyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'demandQty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> demandQtyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'demandQty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> doneQtyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doneQty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> doneQtyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doneQty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> doneQtyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doneQty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> doneQtyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doneQty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeEqualTo(
    MoveType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeGreaterThan(
    MoveType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeLessThan(
    MoveType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeBetween(
    MoveType lower,
    MoveType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moveType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moveType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> moveTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moveType',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      moveTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moveType',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> orderOdooIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderOdooId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> orderOdooIdLessThan(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> orderOdooIdBetween(
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

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productBarcode',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productBarcode',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productBarcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productBarcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productBarcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productBarcode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productBarcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productBarcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productBarcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productBarcode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productBarcode',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productBarcodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productBarcode',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productCode',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productCode',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> productNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uomName',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uomName',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uomName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uomName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition> uomNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uomName',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterFilterCondition>
      uomNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uomName',
        value: '',
      ));
    });
  }
}

extension StockMoveQueryObject
    on QueryBuilder<StockMove, StockMove, QFilterCondition> {}

extension StockMoveQueryLinks
    on QueryBuilder<StockMove, StockMove, QFilterCondition> {}

extension StockMoveQuerySortBy on QueryBuilder<StockMove, StockMove, QSortBy> {
  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByDemandQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'demandQty', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByDemandQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'demandQty', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByDoneQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneQty', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByDoneQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneQty', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByMoveType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveType', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByMoveTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveType', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByOrderOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductBarcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productBarcode', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductBarcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productBarcode', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByUomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uomName', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> sortByUomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uomName', Sort.desc);
    });
  }
}

extension StockMoveQuerySortThenBy
    on QueryBuilder<StockMove, StockMove, QSortThenBy> {
  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByDemandQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'demandQty', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByDemandQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'demandQty', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByDoneQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneQty', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByDoneQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneQty', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByMoveType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveType', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByMoveTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveType', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByOrderOdooIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderOdooId', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductBarcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productBarcode', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductBarcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productBarcode', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByUomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uomName', Sort.asc);
    });
  }

  QueryBuilder<StockMove, StockMove, QAfterSortBy> thenByUomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uomName', Sort.desc);
    });
  }
}

extension StockMoveQueryWhereDistinct
    on QueryBuilder<StockMove, StockMove, QDistinct> {
  QueryBuilder<StockMove, StockMove, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByDemandQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'demandQty');
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByDoneQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doneQty');
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByMoveType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moveType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByOrderOdooId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderOdooId');
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByProductBarcode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productBarcode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByProductCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productId');
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByProductName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMove, StockMove, QDistinct> distinctByUomName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uomName', caseSensitive: caseSensitive);
    });
  }
}

extension StockMoveQueryProperty
    on QueryBuilder<StockMove, StockMove, QQueryProperty> {
  QueryBuilder<StockMove, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StockMove, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StockMove, double, QQueryOperations> demandQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'demandQty');
    });
  }

  QueryBuilder<StockMove, double, QQueryOperations> doneQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doneQty');
    });
  }

  QueryBuilder<StockMove, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<StockMove, MoveType, QQueryOperations> moveTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moveType');
    });
  }

  QueryBuilder<StockMove, int, QQueryOperations> orderOdooIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderOdooId');
    });
  }

  QueryBuilder<StockMove, String?, QQueryOperations> productBarcodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productBarcode');
    });
  }

  QueryBuilder<StockMove, String?, QQueryOperations> productCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productCode');
    });
  }

  QueryBuilder<StockMove, int, QQueryOperations> productIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productId');
    });
  }

  QueryBuilder<StockMove, String, QQueryOperations> productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<StockMove, String?, QQueryOperations> uomNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uomName');
    });
  }
}
