/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-27 20:53:36 +0200 by sebastia

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

#import "DSAAdventureGroup.h"
#import "DSALocation.h"
#import "DSAWeather.h"

@implementation DSAAdventureGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _partyMembers = [NSMutableArray array];
        _npcMembers = [NSMutableArray array];
        _location = nil;
        _weather = nil;
    }
    return self;
}

- (instancetype)initWithPartyMembers:(NSArray<NSUUID *> *)members
                            location:(DSALocation *)location
                             weather:(DSAWeather *)weather {
    self = [super init];
    if (self) {
        _partyMembers = [members mutableCopy];
        _location = location;
        _weather = weather;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.partyMembers forKey:@"partyMembers"];
    [coder encodeObject:self.npcMembers forKey:@"npcMembers"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.weather forKey:@"weather"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _partyMembers = [coder decodeObjectForKey:@"partyMembers"];
        _npcMembers = [coder decodeObjectForKey:@"npcMembers"];
        _location = [coder decodeObjectForKey:@"location"];
        _weather = [coder decodeObjectForKey:@"weather"];
    }
    return self;
}
@end
