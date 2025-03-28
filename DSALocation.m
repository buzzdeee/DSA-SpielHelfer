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

/*
// Loading from JSON
NSString *path = [[NSBundle mainBundle] pathForResource:@"Orte" ofType:@"json"];
NSData *data = [NSData dataWithContentsOfFile:path];
NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

NSMutableArray<DSALocation *> *locations = [NSMutableArray array];
for (NSDictionary *dict in jsonArray) {
    DSALocation *location = [[DSALocation alloc] initWithDictionary:dict];
    [locations addObject:location];
}

// Creating a sublocation (e.g., a dungeon in Abilacht)
DSALocation *abilacht = locations[2]; // Abilacht
DSALocation *dungeon = [[DSALocation alloc] initWithDictionary:@{
    @"name": @"Ancient Ruins",
    @"x": @(abilacht.x),
    @"y": @(abilacht.y),
    @"type": @"Dungeon",
    @"region": abilacht.region
}];
dungeon.parentLocation = abilacht;
dungeon.detailX = 512; // Detailed map coordinates
dungeon.detailY = 300;
dungeon.dungeonLevel = 1;
[abilacht.sublocations addObject:dungeon];
*/

#import "DSALocation.h"

@implementation DSALocation 

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"];
        _x = [dict[@"x"] integerValue];
        _y = [dict[@"y"] integerValue];
        _type = dict[@"type"];
        _region = dict[@"region"];
        _sublocations = [NSMutableArray array]; // Start empty
        _detailX = -1; // Default: not in a sublocation
        _detailY = -1;
        _dungeonLevel = 0;
    }
    return self;
}

- (BOOL)isInDetailedLocation {
    return self.detailX >= 0 && self.detailY >= 0;
}

- (NSString *)fullDescription {
    if ([self isInDetailedLocation]) {
        return [NSString stringWithFormat:@"%@ at (%ld, %ld) - Detail (%ld, %ld), Level %ld",
                self.name ?: @"Unknown Location", (long)self.x, (long)self.y,
                (long)self.detailX, (long)self.detailY, (long)self.dungeonLevel];
    }
    return [NSString stringWithFormat:@"%@ at (%ld, %ld) - %@", 
            self.name ?: @"Unknown Location", (long)self.x, (long)self.y, self.type];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.x forKey:@"x"];
    [coder encodeInteger:self.y forKey:@"y"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.region forKey:@"region"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _x = [coder decodeIntegerForKey:@"x"];
        _y = [coder decodeIntegerForKey:@"y"];
        _type = [coder decodeObjectForKey:@"type"];
        _region = [coder decodeObjectForKey:@"region"];
    }
    return self;
}


@end
