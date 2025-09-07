/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 20:51:44 +0200 by sebastia

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

#import "DSAHint.h"
#import "DSAMapCoordinate.h"

@implementation DSAHint

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.hintID = [coder decodeObjectForKey:@"hintID"];
        self.text = [coder decodeObjectForKey:@"text"];
        self.requiresNPC = [coder decodeObjectForKey:@"requiresNPC"];
        self.requiresRole = [coder decodeObjectForKey:@"requiresRole"];
        self.coordinate = [coder decodeObjectForKey:@"coordinate"];
        self.range = [coder decodeIntegerForKey:@"range"];
        self.locationName = [coder decodeObjectForKey:@"locationName"];
        self.questID = [coder decodeObjectForKey:@"questID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.hintID forKey:@"hintID"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.requiresNPC forKey:@"requiresNPC"];
    [coder encodeObject:self.requiresRole forKey:@"requiresRole"];
    [coder encodeObject:self.coordinate forKey:@"coordinate"];
    [coder encodeInteger:self.range forKey:@"range"];
    [coder encodeObject:self.locationName forKey:@"locationName"];
    [coder encodeObject:self.questID forKey:@"questID"];
}

+ (instancetype)hintFromDictionary:(NSDictionary *)dict {
    DSAHint *hint = [[DSAHint alloc] init];
    hint.hintID = dict[@"id"];
    hint.text = dict[@"text"];
    hint.requiresNPC = dict[@"requiresNPC"];
    hint.requiresRole = dict[@"requiresRole"];
    hint.locationName = dict[@"locationName"];
    hint.questID = dict[@"questID"];
    hint.range = dict[@"range"] ? [dict[@"range"] integerValue] : -1;

    NSDictionary *posDict = dict[@"position"];
    if (posDict) {
        NSInteger x = [posDict[@"x"] integerValue];
        NSInteger y = [posDict[@"y"] integerValue];
        NSInteger level = posDict[@"level"] ? [posDict[@"level"] integerValue] : 0;
        hint.coordinate = [[DSAMapCoordinate alloc] initWithX:x y:y level:level];
    }
    return hint;
}

@end

