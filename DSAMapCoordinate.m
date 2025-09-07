/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-06 09:12:53 +0200 by sebastia

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

#import "DSAMapCoordinate.h"

@implementation DSAMapCoordinate

#pragma mark - Init

+ (instancetype)coordinateWithX:(NSInteger)x y:(NSInteger)y level:(NSInteger)level {
    return [[self alloc] initWithX:x y:y level:level];
}

- (instancetype)initWithX:(NSInteger)x y:(NSInteger)y level:(NSInteger)level {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _level = level;
    }
    return self;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[DSAMapCoordinate class]]) {
        return NO;
    }
    return [self isEqualToMapCoordinate:(DSAMapCoordinate *)object];
}

- (BOOL)isEqualToMapCoordinate:(DSAMapCoordinate *)other {
    if (!other) return NO;
    return self.x == other.x && self.y == other.y && self.level == other.level;
}

- (NSUInteger)hash {
    // Basic hash combining strategy
    return (NSUInteger)(self.x ^ (self.y << 8) ^ (self.level << 16));
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.x forKey:@"x"];
    [coder encodeInteger:self.y forKey:@"y"];
    [coder encodeInteger:self.level forKey:@"level"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSInteger x = [decoder decodeIntegerForKey:@"x"];
    NSInteger y = [decoder decodeIntegerForKey:@"y"];
    NSInteger level = [decoder decodeIntegerForKey:@"level"];
    return [self initWithX:x y:y level:level];
}

#pragma mark - Distances

- (NSInteger)manhattanDistanceTo:(DSAMapCoordinate *)other {
    return labs(self.x - other.x) + labs(self.y - other.y) + labs(self.level - other.level);
}

- (CGFloat)euclideanDistanceTo:(DSAMapCoordinate *)other {
    NSInteger dx = self.x - other.x;
    NSInteger dy = self.y - other.y;
    NSInteger dz = self.level - other.level;
    return sqrt(dx*dx + dy*dy + dz*dz);
}

- (NSInteger)chebyshevDistanceTo:(DSAMapCoordinate *)other {
    NSInteger dx = labs(self.x - other.x);
    NSInteger dy = labs(self.y - other.y);
    NSInteger dz = labs(self.level - other.level);
    return MAX(dx, MAX(dy, dz));
}
@end