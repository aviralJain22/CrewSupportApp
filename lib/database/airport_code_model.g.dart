// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_code_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAirportLocalCollection on Isar {
  IsarCollection<AirportLocal> get airportLocals => this.collection();
}

const AirportLocalSchema = CollectionSchema(
  name: r'AirportLocal',
  id: 3723505444696510470,
  properties: {
    r'country': PropertySchema(
      id: 0,
      name: r'country',
      type: IsarType.string,
    ),
    r'ident': PropertySchema(
      id: 1,
      name: r'ident',
      type: IsarType.string,
    ),
    r'identUpper': PropertySchema(
      id: 2,
      name: r'identUpper',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 4,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 5,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'municipality': PropertySchema(
      id: 6,
      name: r'municipality',
      type: IsarType.string,
    ),
    r'municipalityUpper': PropertySchema(
      id: 7,
      name: r'municipalityUpper',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'nameUpper': PropertySchema(
      id: 9,
      name: r'nameUpper',
      type: IsarType.string,
    ),
    r'region': PropertySchema(
      id: 10,
      name: r'region',
      type: IsarType.string,
    ),
    r'regionUpper': PropertySchema(
      id: 11,
      name: r'regionUpper',
      type: IsarType.string,
    ),
    r'rowHash': PropertySchema(
      id: 12,
      name: r'rowHash',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 13,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAtMs': PropertySchema(
      id: 14,
      name: r'updatedAtMs',
      type: IsarType.long,
    )
  },
  estimateSize: _airportLocalEstimateSize,
  serialize: _airportLocalSerialize,
  deserialize: _airportLocalDeserialize,
  deserializeProp: _airportLocalDeserializeProp,
  idName: r'sourceId',
  indexes: {
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'ident': IndexSchema(
      id: 6661924287940095643,
      name: r'ident',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ident',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'identUpper': IndexSchema(
      id: -3015867946591477925,
      name: r'identUpper',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'identUpper',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'nameUpper': IndexSchema(
      id: -4212347565132636086,
      name: r'nameUpper',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameUpper',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'municipalityUpper': IndexSchema(
      id: -8750783139392428588,
      name: r'municipalityUpper',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'municipalityUpper',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'regionUpper': IndexSchema(
      id: 2775027475879832386,
      name: r'regionUpper',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'regionUpper',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'rowHash': IndexSchema(
      id: -3291533421221111215,
      name: r'rowHash',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'rowHash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updatedAtMs': IndexSchema(
      id: 2203618382568911480,
      name: r'updatedAtMs',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAtMs',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _airportLocalGetId,
  getLinks: _airportLocalGetLinks,
  attach: _airportLocalAttach,
  version: '3.1.0+1',
);

int _airportLocalEstimateSize(
  AirportLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.country.length * 3;
  bytesCount += 3 + object.ident.length * 3;
  bytesCount += 3 + object.identUpper.length * 3;
  bytesCount += 3 + object.municipality.length * 3;
  bytesCount += 3 + object.municipalityUpper.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.nameUpper.length * 3;
  bytesCount += 3 + object.region.length * 3;
  bytesCount += 3 + object.regionUpper.length * 3;
  bytesCount += 3 + object.rowHash.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _airportLocalSerialize(
  AirportLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.country);
  writer.writeString(offsets[1], object.ident);
  writer.writeString(offsets[2], object.identUpper);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeDouble(offsets[4], object.latitude);
  writer.writeDouble(offsets[5], object.longitude);
  writer.writeString(offsets[6], object.municipality);
  writer.writeString(offsets[7], object.municipalityUpper);
  writer.writeString(offsets[8], object.name);
  writer.writeString(offsets[9], object.nameUpper);
  writer.writeString(offsets[10], object.region);
  writer.writeString(offsets[11], object.regionUpper);
  writer.writeString(offsets[12], object.rowHash);
  writer.writeString(offsets[13], object.type);
  writer.writeLong(offsets[14], object.updatedAtMs);
}

AirportLocal _airportLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AirportLocal(
    country: reader.readString(offsets[0]),
    ident: reader.readString(offsets[1]),
    identUpper: reader.readString(offsets[2]),
    isActive: reader.readBool(offsets[3]),
    latitude: reader.readDouble(offsets[4]),
    longitude: reader.readDouble(offsets[5]),
    municipality: reader.readString(offsets[6]),
    municipalityUpper: reader.readString(offsets[7]),
    name: reader.readString(offsets[8]),
    nameUpper: reader.readString(offsets[9]),
    region: reader.readString(offsets[10]),
    regionUpper: reader.readString(offsets[11]),
    rowHash: reader.readString(offsets[12]),
    sourceId: id,
    type: reader.readString(offsets[13]),
    updatedAtMs: reader.readLong(offsets[14]),
  );
  return object;
}

P _airportLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _airportLocalGetId(AirportLocal object) {
  return object.sourceId;
}

List<IsarLinkBase<dynamic>> _airportLocalGetLinks(AirportLocal object) {
  return [];
}

void _airportLocalAttach(
    IsarCollection<dynamic> col, Id id, AirportLocal object) {
  object.sourceId = id;
}

extension AirportLocalQueryWhereSort
    on QueryBuilder<AirportLocal, AirportLocal, QWhere> {
  QueryBuilder<AirportLocal, AirportLocal, QAfterWhere> anySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhere> anyUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAtMs'),
      );
    });
  }
}

extension AirportLocalQueryWhere
    on QueryBuilder<AirportLocal, AirportLocal, QWhereClause> {
  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> sourceIdEqualTo(
      Id sourceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: sourceId,
        upper: sourceId,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      sourceIdNotEqualTo(Id sourceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: sourceId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: sourceId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: sourceId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: sourceId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      sourceIdGreaterThan(Id sourceId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: sourceId, includeLower: include),
      );
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> sourceIdLessThan(
      Id sourceId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: sourceId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> sourceIdBetween(
    Id lowerSourceId,
    Id upperSourceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerSourceId,
        includeLower: includeLower,
        upper: upperSourceId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> typeEqualTo(
      String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'type',
        value: [type],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> typeNotEqualTo(
      String type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> identEqualTo(
      String ident) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ident',
        value: [ident],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> identNotEqualTo(
      String ident) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ident',
              lower: [],
              upper: [ident],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ident',
              lower: [ident],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ident',
              lower: [ident],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ident',
              lower: [],
              upper: [ident],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> identUpperEqualTo(
      String identUpper) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'identUpper',
        value: [identUpper],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      identUpperNotEqualTo(String identUpper) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identUpper',
              lower: [],
              upper: [identUpper],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identUpper',
              lower: [identUpper],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identUpper',
              lower: [identUpper],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identUpper',
              lower: [],
              upper: [identUpper],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> nameUpperEqualTo(
      String nameUpper) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nameUpper',
        value: [nameUpper],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      nameUpperNotEqualTo(String nameUpper) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameUpper',
              lower: [],
              upper: [nameUpper],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameUpper',
              lower: [nameUpper],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameUpper',
              lower: [nameUpper],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameUpper',
              lower: [],
              upper: [nameUpper],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      municipalityUpperEqualTo(String municipalityUpper) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'municipalityUpper',
        value: [municipalityUpper],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      municipalityUpperNotEqualTo(String municipalityUpper) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'municipalityUpper',
              lower: [],
              upper: [municipalityUpper],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'municipalityUpper',
              lower: [municipalityUpper],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'municipalityUpper',
              lower: [municipalityUpper],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'municipalityUpper',
              lower: [],
              upper: [municipalityUpper],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      regionUpperEqualTo(String regionUpper) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'regionUpper',
        value: [regionUpper],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      regionUpperNotEqualTo(String regionUpper) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'regionUpper',
              lower: [],
              upper: [regionUpper],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'regionUpper',
              lower: [regionUpper],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'regionUpper',
              lower: [regionUpper],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'regionUpper',
              lower: [],
              upper: [regionUpper],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> rowHashEqualTo(
      String rowHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'rowHash',
        value: [rowHash],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> rowHashNotEqualTo(
      String rowHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rowHash',
              lower: [],
              upper: [rowHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rowHash',
              lower: [rowHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rowHash',
              lower: [rowHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rowHash',
              lower: [],
              upper: [rowHash],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause> isActiveEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isActive',
        value: [isActive],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      isActiveNotEqualTo(bool isActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      updatedAtMsEqualTo(int updatedAtMs) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAtMs',
        value: [updatedAtMs],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      updatedAtMsNotEqualTo(int updatedAtMs) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAtMs',
              lower: [],
              upper: [updatedAtMs],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAtMs',
              lower: [updatedAtMs],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAtMs',
              lower: [updatedAtMs],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAtMs',
              lower: [],
              upper: [updatedAtMs],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      updatedAtMsGreaterThan(
    int updatedAtMs, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAtMs',
        lower: [updatedAtMs],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      updatedAtMsLessThan(
    int updatedAtMs, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAtMs',
        lower: [],
        upper: [updatedAtMs],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterWhereClause>
      updatedAtMsBetween(
    int lowerUpdatedAtMs,
    int upperUpdatedAtMs, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAtMs',
        lower: [lowerUpdatedAtMs],
        includeLower: includeLower,
        upper: [upperUpdatedAtMs],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AirportLocalQueryFilter
    on QueryBuilder<AirportLocal, AirportLocal, QFilterCondition> {
  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'country',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'country',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      countryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> identEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ident',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ident',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> identLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ident',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> identBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ident',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ident',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> identEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ident',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> identContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ident',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> identMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ident',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ident',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ident',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'identUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'identUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'identUpper',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'identUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'identUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'identUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'identUpper',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      identUpperIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'identUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'municipality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'municipality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'municipality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'municipality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'municipality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'municipality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'municipality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'municipality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'municipality',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'municipality',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'municipalityUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'municipalityUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'municipalityUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'municipalityUpper',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'municipalityUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'municipalityUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'municipalityUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'municipalityUpper',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'municipalityUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      municipalityUpperIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'municipalityUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> nameContains(
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameUpper',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameUpper',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      nameUpperIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> regionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> regionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'region',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> regionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'region',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'region',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'region',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'regionUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'regionUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'regionUpper',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'regionUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'regionUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'regionUpper',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'regionUpper',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      regionUpperIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'regionUpper',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rowHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rowHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rowHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rowHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rowHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rowHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rowHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rowHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rowHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      rowHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rowHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      sourceIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      sourceIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      sourceIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      sourceIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      updatedAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      updatedAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      updatedAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterFilterCondition>
      updatedAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AirportLocalQueryObject
    on QueryBuilder<AirportLocal, AirportLocal, QFilterCondition> {}

extension AirportLocalQueryLinks
    on QueryBuilder<AirportLocal, AirportLocal, QFilterCondition> {}

extension AirportLocalQuerySortBy
    on QueryBuilder<AirportLocal, AirportLocal, QSortBy> {
  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByIdent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ident', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByIdentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ident', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByIdentUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      sortByIdentUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByMunicipality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipality', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      sortByMunicipalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipality', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      sortByMunicipalityUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipalityUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      sortByMunicipalityUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipalityUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByNameUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByNameUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByRegion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByRegionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByRegionUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      sortByRegionUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByRowHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowHash', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByRowHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowHash', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> sortByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      sortByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }
}

extension AirportLocalQuerySortThenBy
    on QueryBuilder<AirportLocal, AirportLocal, QSortThenBy> {
  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByIdent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ident', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByIdentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ident', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByIdentUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      thenByIdentUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByMunicipality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipality', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      thenByMunicipalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipality', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      thenByMunicipalityUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipalityUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      thenByMunicipalityUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'municipalityUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByNameUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByNameUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByRegion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByRegionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByRegionUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionUpper', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      thenByRegionUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionUpper', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByRowHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowHash', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByRowHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowHash', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy> thenByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.asc);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QAfterSortBy>
      thenByUpdatedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAtMs', Sort.desc);
    });
  }
}

extension AirportLocalQueryWhereDistinct
    on QueryBuilder<AirportLocal, AirportLocal, QDistinct> {
  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByCountry(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'country', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByIdent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ident', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByIdentUpper(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identUpper', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByMunicipality(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'municipality', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct>
      distinctByMunicipalityUpper({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'municipalityUpper',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByNameUpper(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameUpper', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByRegion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'region', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByRegionUpper(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regionUpper', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByRowHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rowHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AirportLocal, AirportLocal, QDistinct> distinctByUpdatedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAtMs');
    });
  }
}

extension AirportLocalQueryProperty
    on QueryBuilder<AirportLocal, AirportLocal, QQueryProperty> {
  QueryBuilder<AirportLocal, int, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> countryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'country');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> identProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ident');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> identUpperProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identUpper');
    });
  }

  QueryBuilder<AirportLocal, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<AirportLocal, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<AirportLocal, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> municipalityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'municipality');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations>
      municipalityUpperProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'municipalityUpper');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> nameUpperProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameUpper');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> regionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'region');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> regionUpperProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regionUpper');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> rowHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rowHash');
    });
  }

  QueryBuilder<AirportLocal, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<AirportLocal, int, QQueryOperations> updatedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAtMs');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAirportSyncMetaCollection on Isar {
  IsarCollection<AirportSyncMeta> get airportSyncMetas => this.collection();
}

const AirportSyncMetaSchema = CollectionSchema(
  name: r'AirportSyncMeta',
  id: -4705716300018777969,
  properties: {
    r'lastSyncAtMs': PropertySchema(
      id: 0,
      name: r'lastSyncAtMs',
      type: IsarType.long,
    )
  },
  estimateSize: _airportSyncMetaEstimateSize,
  serialize: _airportSyncMetaSerialize,
  deserialize: _airportSyncMetaDeserialize,
  deserializeProp: _airportSyncMetaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _airportSyncMetaGetId,
  getLinks: _airportSyncMetaGetLinks,
  attach: _airportSyncMetaAttach,
  version: '3.1.0+1',
);

int _airportSyncMetaEstimateSize(
  AirportSyncMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _airportSyncMetaSerialize(
  AirportSyncMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.lastSyncAtMs);
}

AirportSyncMeta _airportSyncMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AirportSyncMeta(
    lastSyncAtMs: reader.readLongOrNull(offsets[0]) ?? 0,
  );
  object.id = id;
  return object;
}

P _airportSyncMetaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _airportSyncMetaGetId(AirportSyncMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _airportSyncMetaGetLinks(AirportSyncMeta object) {
  return [];
}

void _airportSyncMetaAttach(
    IsarCollection<dynamic> col, Id id, AirportSyncMeta object) {
  object.id = id;
}

extension AirportSyncMetaQueryWhereSort
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QWhere> {
  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AirportSyncMetaQueryWhere
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QWhereClause> {
  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterWhereClause>
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

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterWhereClause> idBetween(
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
}

extension AirportSyncMetaQueryFilter
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QFilterCondition> {
  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
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

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
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

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
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

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
      lastSyncAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
      lastSyncAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
      lastSyncAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterFilterCondition>
      lastSyncAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AirportSyncMetaQueryObject
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QFilterCondition> {}

extension AirportSyncMetaQueryLinks
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QFilterCondition> {}

extension AirportSyncMetaQuerySortBy
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QSortBy> {
  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterSortBy>
      sortByLastSyncAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAtMs', Sort.asc);
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterSortBy>
      sortByLastSyncAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAtMs', Sort.desc);
    });
  }
}

extension AirportSyncMetaQuerySortThenBy
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QSortThenBy> {
  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterSortBy>
      thenByLastSyncAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAtMs', Sort.asc);
    });
  }

  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QAfterSortBy>
      thenByLastSyncAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAtMs', Sort.desc);
    });
  }
}

extension AirportSyncMetaQueryWhereDistinct
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QDistinct> {
  QueryBuilder<AirportSyncMeta, AirportSyncMeta, QDistinct>
      distinctByLastSyncAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAtMs');
    });
  }
}

extension AirportSyncMetaQueryProperty
    on QueryBuilder<AirportSyncMeta, AirportSyncMeta, QQueryProperty> {
  QueryBuilder<AirportSyncMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AirportSyncMeta, int, QQueryOperations> lastSyncAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAtMs');
    });
  }
}
