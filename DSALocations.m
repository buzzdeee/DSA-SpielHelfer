/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-22 21:25:01 +0100 by sebastia

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

#import <Foundation/Foundation.h>
#import "DSALocations.h"

@implementation DSALocations
static NSDictionary<NSString *, Class> *locationTypeToClassMap = nil;

+ (instancetype)sharedInstance {
    static DSALocations *sharedInstance = nil;
    static NSObject *lock = nil;

    // also update DSALocation in case of updates here...
    @synchronized(self) {
        if (! locationTypeToClassMap) {
            locationTypeToClassMap = @{
                _(@"global"): [DSAGlobalMapLocation class],
                _(@"local"): [DSALocalMapLocation class],
            };
        }
    }
    
    if (!lock) {
        lock = [[NSObject alloc] init];
    }

    @synchronized (lock) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
            [sharedInstance loadLocationsFromJSON];
        }
    }

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadLocationsFromJSON {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Orte" ofType:@"json"];
    if (!path) {
        NSLog(@"Error: Orte.json not found!");
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSArray *locationsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"Error parsing Orte.json: %@", error.localizedDescription);
        return;
    }

    @synchronized (self) {
        for (NSDictionary *locationDict in locationsArray) {
            NSMutableDictionary *dict = [locationDict mutableCopy];
            [dict setObject: @"global" forKey: @"locationType"];
            
            DSALocation *location = [[DSALocation alloc] initWithDictionary:dict];
            [self.locations addObject:location];
        }
    }

//    NSDictionary *mapsDict = [Utils getMapsDict];
    NSLog(@"DSALocations: loadLocationsFromJSON : Adding local location maps to locations now");

    path = [[NSBundle mainBundle] pathForResource:@"Karten" ofType:@"json"];                         
    NSDictionary *mapsDict = [NSJSONSerialization 
      JSONObjectWithData: [NSData dataWithContentsOfFile: path]
            options: NSJSONReadingMutableContainers
              error: &error];   
    if (error)
      {
         NSLog(@"Error loading JSON: %@", error.localizedDescription);
      }
          
    @synchronized (self) {
        for (NSString *mapCategory in [mapsDict allKeys]) {
            //NSLog(@"DSALocations: loadLocationsFromJSON : going through map category: %@", mapCategory);
            for (NSString *mapName in [[mapsDict objectForKey: mapCategory] allKeys])
              {
                //NSLog(@"DSALocations: loadLocationsFromJSON : checking map name: %@", mapName);
                NSMutableDictionary *dict = [[[mapsDict objectForKey: mapCategory] objectForKey: mapName] mutableCopy];
                //NSLog(@"DSALocations: loadLocationsFromJSON dict is of class: %@", [dict class]);
                //NSLog(@"DSALocations: loadLocationsFromJSON dict before adding locationType: %@", dict);
                [dict setObject: @"local" forKey: @"locationType"];
                [dict setObject: mapName forKey: @"name"];
                [dict setObject: mapCategory forKey: @"localLocationType"];
                NSLog(@"DSALocations: loadLocationsFromJSON : before creating location");
                DSALocation *location = [[DSALocation alloc] initWithDictionary:dict];
                //NSLog(@"DSALocations: loadLocationsFromJSON the LOCATION: %@", location);
                [self.locations addObject:location];
              }
        }
    }    
}

- (void)addLocation:(DSALocation *)location {
    @synchronized (self) {
        if (![self.locations containsObject:location]) {
            [self.locations addObject:location];
        }
    }
}

- (void)removeLocationWithName:(NSString *)name ofType: (NSString *) type{
    @synchronized (self) {
        DSALocation *locationToRemove = [self locationWithName:name ofType: type];
        if (locationToRemove) {
            [self.locations removeObject:locationToRemove];
        }
    }
}

- (NSArray<NSString *> *)locationNames {
    NSMutableArray *names = [NSMutableArray array];
    for (DSALocation *location in self.locations) {
        [names addObject:location.name];
    }
    return [names copy];
}

- (NSArray<NSString *> *)locationNamesWithTemples {
    NSMutableArray *names = [NSMutableArray array];
    NSLog(@"DSALocations locationNamesWithTemples called:");
    for (DSALocation *location in self.locations)
      {
        if ([location isKindOfClass: [DSALocalMapLocation class]])
          {
             NSLog(@"DSALocations locationNamesWithTemples checking: %@", location.name);
             if ([(DSALocalMapLocation *)location hasTileOfType: @"Tempel"])
               {
                  [names addObject:location.name];
               }
          }
      }
    return [names copy];
}

- (DSALocation *)locationWithName:(NSString *)name ofType: (NSString *) type {
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass: [locationTypeToClassMap objectForKey: type]] && [location.name isEqualToString:name]) {
                return location;
            }
        }
    }
    return nil; // Not found
}

- (DSALocalMapLocation *)locationWithName:(NSString *)name ofLocalLocationType: (NSString *) type
{
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass: [DSALocalMapLocation class]] &&
                [location.name isEqualToString: name] && 
                [[(DSALocalMapLocation *)location localLocationType] isEqualToString:type])
                  {
                    return (DSALocalMapLocation *)location;
                  }
        }
    }
    return nil; // Not found  
}


- (DSAPosition *)arrivalTileInLocalLocationWithDestinationName:(NSString *)destinationName
                                                fromOriginName:(NSString *)originName
{
    DSALocation *destinationLocation = [self locationWithName:destinationName ofType:@"local"];
    if (!destinationLocation) {
        NSLog(@"Destination location '%@' not found", destinationName);
        return nil;
    }

    if (![destinationLocation isKindOfClass:[DSALocalMapLocation class]]) {
        NSLog(@"Destination '%@' is not a DSALocalMapLocation", destinationName);
        return nil;
    }

    DSALocalMapLocation *localMapLocation = (DSALocalMapLocation *)destinationLocation;
    DSALocalMap *localMap = localMapLocation.locationMap;

    if (!localMap || localMap.mapLevels.count == 0) {
        NSLog(@"Local map for '%@' is missing or has no levels", destinationName);
        return nil;
    }

    DSALocalMapLevel *groundLevel = nil;
    for (DSALocalMapLevel *level in localMap.mapLevels) {
        if (level.level == 0) {
            groundLevel = level;
            break;
        }
    }

    if (!groundLevel) {
        NSLog(@"No level 0 found in local map for '%@'", destinationName);
        return nil;
    }

    NSInteger rows = groundLevel.mapTiles.count;
    if (rows == 0) return nil;
    NSInteger cols = ((NSArray *)groundLevel.mapTiles.firstObject).count;

    // 4. Über alle Tiles iterieren (2D-Array)
    for (NSInteger y = 0; y < rows; y++) {
        NSArray<DSALocalMapTile *> *row = groundLevel.mapTiles[y];
        for (NSInteger x = 0; x < cols; x++) {
            DSALocalMapTile *tile = row[x];

            if (![tile isKindOfClass:[DSALocalMapTileRoute class]]) continue;
            DSALocalMapTileRoute *routeTile = (DSALocalMapTileRoute *)tile;

            if (!([routeTile.type isEqualToString:@"Wegweiser"] ||
                  [routeTile.type isEqualToString:@"Hafen"])) continue;

            if (![routeTile.destinations containsObject:originName]) continue;

            // 👉 Hier: Nachbar-Tiles prüfen
            NSArray<NSValue *> *neighborOffsets = @[
                [NSValue valueWithPoint:NSMakePoint(-1,  0)],
                [NSValue valueWithPoint:NSMakePoint( 1,  0)],
                [NSValue valueWithPoint:NSMakePoint( 0, -1)],
                [NSValue valueWithPoint:NSMakePoint( 0,  1)]
            ];

            for (NSValue *offsetValue in neighborOffsets) {
                NSPoint offset = [offsetValue pointValue];
                NSInteger nx = x + offset.x;
                NSInteger ny = y + offset.y;

                if (nx < 0 || ny < 0 || ny >= rows) continue;
                NSArray *neighborRow = groundLevel.mapTiles[ny];
                if (nx >= neighborRow.count) continue;

                DSALocalMapTile *neighborTile = neighborRow[nx];

                if ([neighborTile isKindOfClass:[DSALocalMapTileGreen class]] ||
                    [neighborTile isKindOfClass:[DSALocalMapTileStreet class]]) {

                    DSAPosition *position = [[DSAPosition alloc] init];
                    position.mapCoordinate = neighborTile.tileCoordinate;
                    position.localLocationName = destinationName;
                    position.globalLocationName = destinationName;
                    position.context = nil;

                    NSLog(@"✅ Found arrival neighbor tile for '%@' from '%@' at coordinate %@",
                          destinationName, originName, neighborTile.tileCoordinate);
                    return position;
                }
            }
/*
            // Falls keine begehbare Nachbarschaft, nimm Wegweiser selbst (fallback)
            DSAPosition *fallback = [[DSAPosition alloc] init];
            fallback.mapCoordinate = routeTile.tileCoordinate;
            fallback.localLocationName = destinationName;
            fallback.globalLocationName = destinationName;
            fallback.context = nil;

            NSLog(@"⚠️ No walkable neighbor found, fallback to waypoint for '%@' from '%@'",
                  destinationName, originName);
            return fallback; */
        }
    }

    NSLog(@"DSALocations arrivalTileInLocalLocationWithDestinationName: No arrival tile found in '%@' from '%@' aborting()", destinationName, originName);
    abort();
    return nil;
}

- (NSArray<NSString *> *)getLocalLocationCategories
{
    NSMutableArray *locationTypes = [[NSMutableArray alloc] init];
    NSMutableSet *seenTypes = [[NSMutableSet alloc] init];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            NSLog(@"DSALocations getLocalLocationCategories : iterating through location: %@", location.name);
            if ([location isKindOfClass:[DSALocalMapLocation class]]) {
                NSLog(@"DSALocations getLocalLocationCategories : iterating through location: %@ is DSALocalMapLocation", location.name);
                NSString *type = [(DSALocalMapLocation *)location localLocationType];
                if (![seenTypes containsObject:type]) {
                    [seenTypes addObject:type];
                    [locationTypes addObject:type];
                }
            }
        }
    }

    return locationTypes;
}

- (NSArray<NSString *> *)getLocalLocationNamesOfCategory: (NSString *) category
{
    NSMutableArray *localLocationNames = [[NSMutableArray alloc] init];
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass:[DSALocalMapLocation class]] && [[(DSALocalMapLocation *)location localLocationType] isEqualToString: category]) {
                [localLocationNames addObject:location.name];
            }
        }
    }
    return localLocationNames;  
}

- (NSArray<NSString *> *)getLocalLocationMapLevelsOfMap: (NSString *) mapName
{
    NSMutableArray *mapLevels = [[NSMutableArray alloc] init];
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass:[DSALocalMapLocation class]] && [location.name isEqualToString: mapName]) {
                for (DSALocalMapLevel *level in [[(DSALocalMapLocation *) location locationMap] mapLevels])
                  {
                    [mapLevels addObject: [NSString stringWithFormat: @"%lu", (unsigned long)level.level]];
                  }
            }
        }
    }
    return mapLevels;
}

- (DSALocalMapLevel *)getLocalLocationMapWithName: (NSString *) mapName ofLevel: (NSInteger) level
{
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass:[DSALocalMapLocation class]] && [location.name isEqualToString: mapName]) {
                for (DSALocalMapLevel *mapLevel in [[(DSALocalMapLocation *) location locationMap] mapLevels])
                  {
                    if (mapLevel.level == level)
                      {
                        return mapLevel;
                      }
                  }
            }
        }
    }
  return nil;
}

- (NSString *)htmlInfoForLocationWithName:(NSString *)name {
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass: [DSAGlobalMapLocation class]] && [location.name isEqualToString:name]) {
                return [(DSAGlobalMapLocation *)location htmlinfo];
            }
        }
    }
    return nil; // Not found
}

- (NSString *)plainInfoForLocationWithName:(NSString *)name {
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass: [DSAGlobalMapLocation class]] && [location.name isEqualToString:name]) {
                return [(DSAGlobalMapLocation *)location plaininfo];
            }
        }
    }
    return nil; // Not found
}

- (NSArray<NSString *> *)locationNamesOfType:(NSString *)type {
    NSMutableArray *results = [NSMutableArray array];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass: [DSAGlobalMapLocation class]] &&  [[(DSAGlobalMapLocation *)location type] isEqualToString:type]) {
                [results addObject:[(DSAGlobalMapLocation *)location name]];
            }
        }
    }

    return [results copy];
}

- (NSArray<NSString *> *)locationNamesOfTypes:(NSArray<NSString *> *)types {
    NSMutableArray *results = [NSMutableArray array];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location isKindOfClass: [DSAGlobalMapLocation class]] &&  [types containsObject:[(DSAGlobalMapLocation *)location type]]) {
                [results addObject:[(DSAGlobalMapLocation *)location name]];
            }
        }
    }

    return [results copy];
}

- (NSArray<NSString *> *)locationNamesOfTypes:(NSArray<NSString *> *)types matching:(NSString *)match {
    NSMutableArray *results = [NSMutableArray array];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([types containsObject:[(DSAGlobalMapLocation *)location type]] && [[(DSAGlobalMapLocation *)location name] containsString:match]) {
                [results addObject:location.name];
            }
        }
    }

    return [results copy];
}

@end
