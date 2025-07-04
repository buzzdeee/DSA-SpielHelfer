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

#ifndef _DSAMAPCOORDINATE_H_
#define _DSAMAPCOORDINATE_H_

#import <Foundation/Foundation.h>

@interface DSAMapCoordinate : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) NSInteger level;

+ (instancetype)coordinateWithX:(NSInteger)x y:(NSInteger)y level:(NSInteger)level;
- (instancetype)initWithX:(NSInteger)x y:(NSInteger)y level:(NSInteger)level;

- (BOOL)isEqualToMapCoordinate:(DSAMapCoordinate *)other;

- (NSInteger)manhattanDistanceTo:(DSAMapCoordinate *)other;
- (CGFloat)euclideanDistanceTo:(DSAMapCoordinate *)other;
- (NSInteger)chebyshevDistanceTo:(DSAMapCoordinate *)other;

@end

#endif // _DSAMAPCOORDINATE_H_

