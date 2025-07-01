/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-22 21:04:10 +0100 by sebastia

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#ifndef _DSALOCATION_H_
#define _DSALOCATION_H_

#import <Foundation/Foundation.h>

@class DSAMapCoordinate;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DSADirection) {
    DSADirectionNorth,
    DSADirectionEast,
    DSADirectionSouth,
    DSADirectionWest,
    DSADirectionNortheast,
    DSADirectionSoutheast,
    DSADirectionSouthwest,
    DSADirectionNorthwest,
    DSADirectionInvalid
};

NS_INLINE NSString * DSADirectionToString(DSADirection direction) {
    switch (direction) {
        case DSADirectionNorth:     return @"Nord";
        case DSADirectionEast:      return @"Ost";
        case DSADirectionSouth:     return @"Süd";
        case DSADirectionWest:      return @"West";
        case DSADirectionNortheast: return @"Nordost";
        case DSADirectionSoutheast: return @"Südost";
        case DSADirectionSouthwest: return @"Südwest";
        case DSADirectionNorthwest: return @"Nordwest";
        default:                    return @"Unbekannt";
    }
}

/// Reverse mapping (string → enum)
@interface DSADirectionHelper : NSObject
+ (DSADirection)directionFromString:(NSString *)string;
@end

@interface DSALocalMapTile: NSObject <NSCoding>
@property (nonatomic, strong) DSAMapCoordinate *tileCoordinate;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL walkable;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface DSALocalMapTileWater: DSALocalMapTile <NSCoding>
@end

@interface DSALocalMapTileStreet: DSALocalMapTile <NSCoding>
@end

@interface DSALocalMapTileGreen: DSALocalMapTile <NSCoding>
@end

@interface DSALocalMapTileRoute: DSALocalMapTile <NSCoding>
@property (nonatomic, strong) NSArray *destinations;
@end

@interface DSALocalMapTileBuilding: DSALocalMapTile <NSCoding>
@property (nonatomic, assign) DSADirection door;         // NSWE
@property (nonatomic, strong) NSString *npc;             // for the time being, just the name, in the future may be DSACharacter...
@end

@interface DSALocalMapTileBuildingTemple: DSALocalMapTileBuilding <NSCoding>
@property (nonatomic, strong) NSString *god;            // Travia, Boron, etc.
@end

@interface DSALocalMapTileBuildingShop: DSALocalMapTileBuilding <NSCoding>
@end

@interface DSALocalMapTileBuildingInn: DSALocalMapTileBuilding <NSCoding>  // Taverne, Herberge, etc.
@property (nonatomic, strong) NSString *name;
@end

@interface DSALocalMapTileBuildingHealer: DSALocalMapTileBuilding <NSCoding>
@end

@interface DSALocalMapTileBuildingSmith: DSALocalMapTileBuilding <NSCoding>
@end

@interface DSALocalMapLevel: NSObject <NSCoding>
@property (nonatomic, assign) NSInteger level;          // map levels, 0 is earth level
@property (nonatomic, strong) NSArray<NSArray<DSALocalMapTile *> *> *mapTiles;
- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (DSALocalMapTile *) tileAtCoordinate: (DSAMapCoordinate *) coordinate;
@end

@interface DSALocalMap: NSObject <NSCoding>
@property (nonatomic, strong) NSArray<DSALocalMapLevel *> *mapLevels;
- (instancetype)initWithDictionary: (NSDictionary *) levelsDict;
- (instancetype)initWithMapLevels: (NSArray<DSALocalMapLevel *> *) mapLevels;
@end

@interface DSALocation : NSObject <NSCoding>
@property (nonatomic, strong, nullable) NSString *name; // Name of the location (nullable if traveling)
@property (nonatomic, strong) DSAMapCoordinate *mapCoordinate;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSString *)fullDescription;
- (DSALocalMapTile *) tileAtCoordinate: (DSAMapCoordinate *) coordinate;
@end

@interface DSAGlobalMapLocation : DSALocation <NSCoding>
@property (nonatomic, strong) NSString *type; // City, village, dungeon, etc.
@property (nonatomic, strong) NSString *region; // Region code
@property (nonatomic, strong) NSString *htmlinfo;
@property (nonatomic, strong) NSString *shortinfo;
@property (nonatomic, strong) NSString *plaininfo;
@end

@interface DSALocalMapLocation : DSALocation <NSCoding>
@property (nonatomic, strong) NSString *globalLocationName;  // every local map location is somewhere on the map, so there's a corresponding global location
@property (nonatomic, strong) NSString *localLocationType;
@property (nonatomic, strong) DSALocalMap *locationMap;


- (BOOL) hasTileOfType: (NSString *) tileType;
@end

@interface DSAPosition : NSObject <NSCopying, NSCoding>
@property (nonatomic, strong) DSAMapCoordinate *mapCoordinate;
@property (nonatomic, strong, nullable) NSString *room;          // some buildings have multiple rooms, i.e. Inns
@property (nonatomic, strong) NSString *globalLocationName;      // to refer to DSAGlobalMapLocation info
@property (nonatomic, strong) NSString *localLocationName;       // to refer to DSALocalMapLocation info

+ (instancetype)positionWithMapCoordinate:(DSAMapCoordinate *)coordinate
                       globalLocationName:(NSString *)globalLocationName
                        localLocationName:(NSString *)localLocationName
                                     room:(nullable NSString *)room;


- (instancetype)initWithMapCoordinate:(DSAMapCoordinate *)coordinate
                   globalLocationName:(NSString *)globalLocationName
                    localLocationName:(NSString *)localLocationName
                                 room:(nullable NSString *)room;

- (BOOL)isEqualToPosition:(DSAPosition *)other;

- (DSAPosition *)positionByMovingInDirection:(DSADirection)direction steps:(NSInteger)steps;

- (NSString *)roomKey;

@end

NS_ASSUME_NONNULL_END

#endif // _DSALOCATION_H_

