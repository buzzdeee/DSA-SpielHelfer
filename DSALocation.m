/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-22 21:04:11 +0100 by sebastia

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

#import "DSALocation.h"
#import "DSAMapCoordinate.h"

NSString * const DSALocalMapTileBuildingInnTypeHerberge = @"Herberge";
NSString * const DSALocalMapTileBuildingInnTypeHerbergeMitTaverne = @"Herberge mit Taverne";
NSString * const DSALocalMapTileBuildingInnTypeTaverne = @"Taverne";


@implementation DSADirectionHelper
+ (DSADirection)directionFromString:(NSString *)directionString {
    NSString *input = [directionString uppercaseString];

    if ([input isEqualToString:@"N"] || [input isEqualToString:@"NORTH"]) {
        return DSADirectionNorth;
    } else if ([input isEqualToString:@"E"] || [input isEqualToString:@"EAST"]) {
        return DSADirectionEast;
    } else if ([input isEqualToString:@"S"] || [input isEqualToString:@"SOUTH"]) {
        return DSADirectionSouth;
    } else if ([input isEqualToString:@"W"] || [input isEqualToString:@"WEST"]) {
        return DSADirectionWest;
    } else if ([input isEqualToString:@"NE"] || [input isEqualToString:@"NORTHEAST"]) {
        return DSADirectionNortheast;
    } else if ([input isEqualToString:@"SE"] || [input isEqualToString:@"SOUTHEAST"]) {
        return DSADirectionSoutheast;
    } else if ([input isEqualToString:@"SW"] || [input isEqualToString:@"SOUTHWEST"]) {
        return DSADirectionSouthwest;
    } else if ([input isEqualToString:@"NW"] || [input isEqualToString:@"NORTHWEST"]) {
        return DSADirectionNorthwest;
    } else {
        NSLog(@"Unknown direction string: %@", directionString);
        return DSADirectionNorth; // or some default/fallback
    }
}
@end

@implementation DSALocalMapTile: NSObject
static NSDictionary<NSString *, Class> *tileTypeToClassMap = nil;
+ (void)initialize {
    if (self == [DSALocalMapTile class]) {
        @synchronized(self) {
            if (! tileTypeToClassMap) {
                tileTypeToClassMap = @{
                    _(@"Gras"): [DSALocalMapTileGreen class],
                    _(@"Wasser"): [DSALocalMapTileWater class],
                    _(@"Weg"): [DSALocalMapTileStreet class],
                    _(@"Hafen"): [DSALocalMapTileRoute class],
                    _(@"Wegweiser"): [DSALocalMapTileRoute class],
                    _(@"Haus"): [DSALocalMapTileBuilding class],
                    _(@"Krämer"): [DSALocalMapTileBuildingShop class],
                    _(@"Waffenhändler"): [DSALocalMapTileBuildingShop class],
                    _(@"Kräuterhändler"): [DSALocalMapTileBuildingShop class],
                    _(@"Heiler"): [DSALocalMapTileBuildingHealer class],
                    _(@"Schmied"): [DSALocalMapTileBuildingSmith class],
                    _(@"Tempel"): [DSALocalMapTileBuildingTemple class],
                    _(DSALocalMapTileBuildingInnTypeTaverne): [DSALocalMapTileBuildingInn class],
                    _(DSALocalMapTileBuildingInnTypeHerberge): [DSALocalMapTileBuildingInn class],
                    _(DSALocalMapTileBuildingInnTypeHerbergeMitTaverne): [DSALocalMapTileBuildingInn class],
                };
            }
        }
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    Class subclass = [tileTypeToClassMap objectForKey: [dict objectForKey: @"type"]];
    if (subclass)
      {
        return [[subclass alloc] initWithDictionary: dict];
      }
    return nil;
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSALocalMapTile *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.tileCoordinate forKey:@"tileCoordinate"];
    [coder encodeBool:self.walkable forKey:@"walkable"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _type = [coder decodeObjectForKey:@"type"];
        _tileCoordinate = [coder decodeObjectForKey:@"tileCoordinate"];
        _walkable = [coder decodeBoolForKey:@"walkable"];
    }
    return self;
}
@end

@implementation DSALocalMapTileWater: DSALocalMapTile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.walkable = NO;
    }
    return self;
}
@end

@implementation DSALocalMapTileStreet: DSALocalMapTile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.walkable = YES;
    }
    return self;
}
@end

@implementation DSALocalMapTileGreen: DSALocalMapTile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.walkable = YES;
    }
    return self;
}
@end

@implementation DSALocalMapTileRoute: DSALocalMapTile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.destinations = dict[@"destinations"];
        self.walkable = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder: coder];
    [coder encodeObject:self.destinations forKey:@"destinations"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self) {
        _destinations = [coder decodeObjectForKey: @"destinations"];
    }
    return self;
}

@end

@implementation DSALocalMapTileBuilding: DSALocalMapTile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.walkable = YES;
        _door = [DSADirectionHelper directionFromString: dict[@"door"]];
        _npc = dict[@"npc"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder: coder];
    [coder encodeInteger:self.door forKey:@"door"];
    [coder encodeObject:self.npc forKey:@"npc"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self) {
        _door = [coder decodeIntegerForKey: @"door"];
        _npc = [coder decodeObjectForKey:@"npc"];
    }
    return self;
}
@end

@implementation DSALocalMapTileBuildingTemple: DSALocalMapTileBuilding
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.walkable = YES;
        self.door = [DSADirectionHelper directionFromString: dict[@"door"]];
        self.npc = dict[@"npc"];
        _god = dict[@"Gott"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder: coder];
    [coder encodeObject:self.god forKey:@"god"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self) {
        _god = [coder decodeObjectForKey: @"god"];
    }
    return self;
}
@end

@implementation DSALocalMapTileBuildingShop: DSALocalMapTileBuilding
@end

@implementation DSALocalMapTileBuildingInn: DSALocalMapTileBuilding
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.tileCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                              y: [dict[@"y"] integerValue]
                                                          level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        self.walkable = YES;
        self.door = [DSADirectionHelper directionFromString: dict[@"door"]];
        self.npc = dict[@"npc"];
        _name = dict[@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder: coder];
    [coder encodeObject:self.name forKey:@"name"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self) {
        _name = [coder decodeObjectForKey: @"name"];
    }
    return self;
}
@end

@implementation DSALocalMapTileBuildingHealer: DSALocalMapTileBuilding
@end

@implementation DSALocalMapTileBuildingSmith: DSALocalMapTileBuilding
@end


@implementation DSALocalMapLevel: NSObject
- (instancetype)init {
    self = [super init];
    if (self) {
      _mapTiles = [[NSArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary: (NSDictionary *) dict {
    NSLog(@"DSALocalMapLevel initWithDictionary called!");
    self = [super init];
    if (self) {
      _level = [dict[@"level"] integerValue];
      _mapTiles = [[NSArray alloc] init];
      NSMutableArray *mapArray = [[NSMutableArray alloc] init];
      NSInteger rowCounter = 0;
      for (NSArray *row in dict[@"levelMap"])
        {
          NSMutableArray *mutableRow = [[NSMutableArray alloc] init];
          NSInteger columnCounter = 0;
          //NSLog(@"DSALocalMapLevel initWithDictionary: row: %@", [NSNumber numberWithInteger: rowCounter]);
          for (NSDictionary *tileDict in row)
            {
              DSALocalMapTile *tile = [[DSALocalMapTile alloc]initWithDictionary: tileDict];
              tile.tileCoordinate = [DSAMapCoordinate coordinateWithX: columnCounter
                                                                    y: rowCounter
                                                                level: _level];              
              //NSLog(@"DSALocalMapLevel initWithDictionary: got tile: %@", tile);
              [mutableRow addObject: tile];
              columnCounter++;
            }
          [mapArray addObject: mutableRow];
          rowCounter++;
        }
      _mapTiles = [mapArray copy];
      //NSLog(@"DSALocalMapLevel initWithDictionary: returning self: %@", self);
    }
    return self;
}

- (DSALocalMapTile *) tileAtCoordinate: (DSAMapCoordinate *) coordinate
{
  if (coordinate.level != self.level)
    {
      return nil;  // we're wrong here...
    }
  
  return [[_mapTiles objectAtIndex: coordinate.y]
                     objectAtIndex: coordinate.x];   
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSALocation *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mapTiles forKey:@"mapTiles"];
    [coder encodeInteger:self.level forKey:@"level"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _mapTiles = [coder decodeObjectForKey:@"mapTiles"];
        _level = [coder decodeIntegerForKey:@"level"];
    }
    return self;
}

@end
// End of DSALocalMapLevel

@implementation DSALocalMap: NSObject
- (instancetype)init {
    self = [super init];
    if (self) {
      _mapLevels = [[NSArray alloc] init];
    }
    return self;
}

- (instancetype)initWithMapLevels: (NSArray<DSALocalMapLevel *> *) mapLevels {
    self = [super init];
    if (self) {
      _mapLevels = [mapLevels copy];
    }
    return self;
}

- (instancetype)initWithDictionary: (NSDictionary *) levelsDict {
    self = [super init];
    if (self) {
      //NSLog(@"DSALocalMap: initWithDictionary levelsDict: %@", levelsDict);
      NSMutableArray *levelArray = [[NSMutableArray alloc] init];
      for (NSString *level in [levelsDict allKeys])
        {
          //NSLog(@"DSALocalMap: initWithDictionary level: %@", level);
          NSArray *levelMatrix = [levelsDict objectForKey: level];
          NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
          [levelDict setObject: level forKey: @"level"];
          [levelDict setObject: levelMatrix forKey: @"levelMap"];
          //NSLog(@"DSALocalMap: initWithDictionary levelMatrix: %@", levelMatrix);
          DSALocalMapLevel *mapLevel = [[DSALocalMapLevel alloc] initWithDictionary: levelDict];
          //mapLevel.level = [level integerValue];
          [levelArray addObject: mapLevel];
        }
      _mapLevels = [levelArray copy];
      //NSLog(@"DSALocalMap: initWithDictionary _mapLevels: %@", _mapLevels);
    }
    return self;
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSALocalMap *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mapLevels forKey:@"mapLevels"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _mapLevels = [coder decodeObjectForKey:@"mapLevels"];
    }
    return self;
}
@end
// End of DSALocalMap

@implementation DSALocation
static NSDictionary<NSString *, Class> *locationTypeToClassMap = nil;
+ (void)initialize {
    if (self == [DSALocation class]) {
        @synchronized(self) {
            // also update DSALocations in case of updates here...
            if (! locationTypeToClassMap) {
                locationTypeToClassMap = @{
                    _(@"global"): [DSAGlobalMapLocation class],
                    _(@"local"): [DSALocalMapLocation class],
                };
            }
        }
    }
}


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    Class subclass = [locationTypeToClassMap objectForKey: [dict objectForKey: @"locationType"]];
    if (subclass)
      {
        return [[subclass alloc] initWithDictionary: dict];
      }
    return nil;
}

- (NSString *)fullDescription
{
  NSLog(@"DSALocation subclasses should override fullDescription!");
  return nil;
}

- (DSALocalMapTile *) tileAtCoordinate: (DSAMapCoordinate *) coordinate
{
  NSLog(@"DSALocation subclasses should override tileAtCoordinate!");
  return nil;
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSALocation *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.mapCoordinate forKey:@"mapCoordinate"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _mapCoordinate = [coder decodeObjectForKey:@"mapCoordinate"];
    }
    return self;
}
@end
// End of DSALocation

@implementation DSAGlobalMapLocation 

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.mapCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                             y: [dict[@"y"] integerValue]
                                                         level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];                                        
        _type = dict[@"type"];
        _region = dict[@"region"];
        _htmlinfo = dict[@"htmlinfo"];
        _shortinfo = dict[@"shortinfo"];
        _plaininfo = dict[@"plaininfo"];
    }
    return self;
}

- (NSString *)fullDescription {
    return [NSString stringWithFormat:@"%@ at %@ - %@", 
            self.name ?: @"Unknown Location", self.mapCoordinate, self.type];
}

- (DSALocalMapTile *) tileAtCoordinate: (DSAMapCoordinate *) coordinate
{
  return nil;  // we don't have map tiles at global level...
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder: coder];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.region forKey:@"region"];
    [coder encodeObject:self.shortinfo forKey:@"shortinfo"];
    [coder encodeObject:self.plaininfo forKey:@"plaininfo"];
    [coder encodeObject:self.htmlinfo forKey:@"htmlinfo"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _type = [coder decodeObjectForKey:@"type"];
        _region = [coder decodeObjectForKey:@"region"];
        _shortinfo = [coder decodeObjectForKey:@"shortinfo"];
        _plaininfo = [coder decodeObjectForKey:@"plaininfo"];
        _htmlinfo = [coder decodeObjectForKey:@"htmlinfo"];
    }
    return self;
}
@end
// End of DSAGlobalMapLocation

@implementation DSALocalMapLocation 

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSLog(@"DSALocalMapLocation initWithDictionary called!");
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.mapCoordinate = [DSAMapCoordinate coordinateWithX: [dict[@"x"] integerValue]
                                                             y: [dict[@"y"] integerValue]
                                                         level: dict[@"level"] ? [dict[@"level"] integerValue] : 0];
        _globalLocationName = dict[@"globalLocation"];
        _localLocationType = dict[@"localLocationType"];
        _locationMap = [[DSALocalMap alloc] initWithDictionary: dict[@"LevelDetails"]]; 
    }
    return self;
}

- (NSString *)fullDescription {
    return [NSString stringWithFormat:@"%@ at %@", 
            self.name ?: @"Unknown Location", self.mapCoordinate];
}

- (BOOL) hasTileOfType: (NSString *) tileType
{
  //NSLog(@"DSALocalMapLocation hasTileOfType: %@", tileType);
  //NSLog(@"DSALocalMapLocation hasTileOfType: looking at all levels in self.locationMap: %@", self.locationMap);
  for (DSALocalMapLevel *level in self.locationMap.mapLevels)
    {
      //NSLog(@"DSALocation hasTileOfType checking level: %@", level);
      NSArray *mapArray = level.mapTiles;
      for (NSArray *mapRow in mapArray)
        {
          for (DSALocalMapTile *tile in mapRow)
            {
              if ([tile.type isEqualToString: @"Tempel"])
                {
                  return YES;
                }
            }
        }
    }
  return NO;  
}

- (DSALocalMapTile *) tileAtCoordinate: (DSAMapCoordinate *) coordinate
{
  for (DSALocalMapLevel *level in self.locationMap.mapLevels)
    {
      //NSLog(@"DSALocation tileAtCoordinate checking level: %@", level);
      if (level.level == coordinate.level)
        {
          return [level tileAtCoordinate: coordinate];
        }
    }
  return nil;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder: coder];
    [coder encodeObject:self.globalLocationName forKey:@"globalLocationName"];
    [coder encodeObject:self.localLocationType forKey:@"localLocationType"];
    [coder encodeObject:self.locationMap forKey:@"locationMap"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self) {
        _globalLocationName = [coder decodeObjectForKey: @"globalLocationName"];
        _localLocationType = [coder decodeObjectForKey: @"localLocationType"];
        _locationMap = [coder decodeObjectForKey:@"locationMap"];
    }
    return self;
}
@end
// End of DSALocalMapLocation

@implementation DSAPosition

#pragma mark - Init

+ (instancetype)positionWithMapCoordinate:(DSAMapCoordinate *)coordinate
                       globalLocationName:(NSString *)globalLocationName
                        localLocationName:(NSString *)localLocationName
                                     room:(NSString *)room
{
    return [[self alloc] initWithMapCoordinate:coordinate
                             globalLocationName:globalLocationName
                              localLocationName:localLocationName
                                           room:room];
}

- (instancetype)initWithMapCoordinate:(DSAMapCoordinate *)coordinate
                   globalLocationName:(NSString *)globalLocationName
                    localLocationName:(NSString *)localLocationName
                                 room:(NSString *)room
{
    self = [super init];
    if (self) {
        _mapCoordinate = coordinate;
        _globalLocationName = [globalLocationName copy];
        _localLocationName = [localLocationName copy];
        _room = [room copy];
    }
    return self;
}

- (DSAPosition *)positionByMovingInDirection:(DSADirection)direction steps:(NSInteger)steps {
    NSInteger dx = 0;
    NSInteger dy = 0;

    switch (direction) {
        case DSADirectionNorth:
            dy = -steps;
            break;
        case DSADirectionSouth:
            dy = steps;
            break;
        case DSADirectionEast:
            dx = steps;
            break;
        case DSADirectionWest:
            dx = -steps;
            break;
        default:
            NSLog(@"DSAPosition: Invalid direction %ld", (long)direction);
            return nil;
    }

    DSAMapCoordinate *newCoord = [[DSAMapCoordinate alloc] initWithX:self.mapCoordinate.x + dx
                                                                  y:self.mapCoordinate.y + dy
                                                              level:self.mapCoordinate.level];
    
    return [DSAPosition positionWithMapCoordinate:newCoord
                               globalLocationName:self.globalLocationName
                                localLocationName:self.localLocationName
                                             room:self.room];
}


#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[DSAPosition class]]) return NO;
    return [self isEqualToPosition:(DSAPosition *)object];
}

- (BOOL)isEqualToPosition:(DSAPosition *)other {
    if (!other) return NO;

    BOOL coordinatesEqual = (!self.mapCoordinate && !other.mapCoordinate) ||
                            [self.mapCoordinate isEqual:other.mapCoordinate];

    BOOL globalEqual = (!self.globalLocationName && !other.globalLocationName) ||
                       [self.globalLocationName isEqualToString:other.globalLocationName];

    BOOL localEqual = (!self.localLocationName && !other.localLocationName) ||
                      [self.localLocationName isEqualToString:other.localLocationName];

    return coordinatesEqual && globalEqual && localEqual;
}

- (NSUInteger)hash {
    return self.mapCoordinate.hash ^
           self.globalLocationName.hash ^
           self.localLocationName.hash ^
           self.room.hash;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[DSAPosition allocWithZone:zone] initWithMapCoordinate:[self.mapCoordinate copy]
                                                globalLocationName:[self.globalLocationName copy]
                                                 localLocationName:[self.localLocationName copy]
                                                              room:[self.room copy]];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mapCoordinate forKey:@"mapCoordinate"];
    [coder encodeObject:self.globalLocationName forKey:@"globalLocationName"];
    [coder encodeObject:self.localLocationName forKey:@"localLocationName"];
    [coder encodeObject:self.room forKey:@"room"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    DSAMapCoordinate *coord = [decoder decodeObjectOfClass:[DSAMapCoordinate class] forKey:@"mapCoordinate"];
    NSString *globalName = [decoder decodeObjectOfClass:[NSString class] forKey:@"globalLocationName"];
    NSString *localName = [decoder decodeObjectOfClass:[NSString class] forKey:@"localLocationName"];
    NSString *room = [decoder decodeObjectOfClass:[NSString class] forKey:@"room"];
    return [self initWithMapCoordinate:coord globalLocationName:globalName localLocationName:localName room: room];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<DSAPosition coordinate:%@ global:%@ local:%@ room:%@>",
            self.mapCoordinate, self.globalLocationName, self.localLocationName, self.room];
}

- (NSString *)roomKey
{
    DSAMapCoordinate *coord = self.mapCoordinate;
    NSString *locationName = self.localLocationName ?: @"UnknownLocation";

    NSString *roomKey = [NSString stringWithFormat:@"INN:%@:%ld:%ld:%ld",
                         locationName,
                         coord.x,
                         coord.y,
                         coord.level];
    return roomKey;
}
@end
