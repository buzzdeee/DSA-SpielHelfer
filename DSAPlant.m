/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-24 21:06:09 +0200 by sebastia

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

#import "DSAPlant.h"

@implementation DSAPlant
- (instancetype)initWithName:(NSString *)name fromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = name;
        self.recognition = [dict[@"Bekanntheit"] integerValue];
        self.shelfLife = dict[@"Haltbarkeit"];
        self.price = [dict[@"Preis"] floatValue];
        self.weight = [dict[@"Gewicht"] floatValue];
        self.icon = dict[@"Icon"] ? [dict[@"Icon"] objectAtIndex: arc4random_uniform([dict[@"Icon"] count])]: nil;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder]; // falls DSAObject ebenfalls NSCoding unterstützt

    [coder encodeInteger:self.recognition forKey:@"recognition"];
    [coder encodeObject:self.shelfLife forKey:@"shelfLife"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder]; // falls DSAObject ebenfalls NSCoding unterstützt
    if (self) {
        _recognition = [coder decodeIntegerForKey:@"recognition"];
        _shelfLife = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"shelfLife"];
    }
    return self;
}

+ (NSSet<Class> *)supportsSecureCodingClassesForKeys {
    return [NSSet setWithObjects:
        [NSArray class], [NSDictionary class], [NSNumber class], [NSString class], nil];
}
@end

@interface DSAPlantRegistry ()
@property (nonatomic, strong) NSArray<DSAPlant *> *plants;
@end

@implementation DSAPlantRegistry

+ (instancetype)sharedRegistry {
    static DSAPlantRegistry *sharedInstance = nil;
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[DSAPlantRegistry alloc] init];
            [sharedInstance loadPlantsFromJSON];
        }
    }
    
    return sharedInstance;
}

- (void)loadPlantsFromJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Pflanzen" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"DSAPlantManager: Could not read Pflanzen.json");
        self.plants = @[];
        return;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSDictionary class]]) {
        NSLog(@"DSAPlantManager: Error parsing JSON: %@", error.localizedDescription);
        self.plants = @[];
        return;
    }

    NSMutableArray *loadedPlants = [NSMutableArray array];

    for (NSString *name in json) {
        NSDictionary *dict = json[name];
        DSAPlant *plant = [[DSAPlant alloc] initWithName:name fromDictionary:dict];
        if (plant) {
            plant.validSlotTypes = @[@(DSASlotTypeGeneral)];
            plant.canShareSlot = YES;
            [loadedPlants addObject:plant];
        } else {
            NSLog(@"DSAPlantManager: Unknown plant class for name %@", name);
        }
    }

    self.plants = [loadedPlants copy];
}

- (NSArray<DSAPlant *> *)allPlants {
    return self.plants ?: @[];
}

- (NSArray<DSAPlant *> *)sortedPlantsByName {
    return [[self allPlants] sortedArrayUsingComparator:^NSComparisonResult(DSAPlant *a, DSAPlant *b) {
        return [a.name compare:b.name];
    }];
}

- (nullable DSAPlant *)plantWithName:(NSString *)name {
    for (DSAPlant *plant in self.plants) {
        if ([plant.name isEqualToString:name]) {
            return plant;
        }
    }
    return nil;
}

- (nullable DSAPlant *)plantWithUniqueID:(NSString *)uniqueID
{
    if (![uniqueID hasPrefix:@"Plant_"]) {
        NSLog(@"DSAPlantRegistry plantWithUniqueID: unexpected format %@", uniqueID);
        return nil;
    }

    NSString *name = [uniqueID substringFromIndex:[@"Plant_" length]];
    return [self plantWithName:name];
}

- (NSArray<NSString *> *)allPlantNames {
    NSMutableArray *plantNames = [[NSMutableArray alloc] init]; 
    for (DSAPlant *plant in _plants)
      {
        [plantNames addObject: plant.name];
      }
    return [plantNames copy];
}
@end