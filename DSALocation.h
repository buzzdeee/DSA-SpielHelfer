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

NS_ASSUME_NONNULL_BEGIN

@interface DSALocation : NSObject <NSCoding>

@property (nonatomic, strong, nullable) NSString *name; // Name of the location (nullable if traveling)
@property (nonatomic, assign) NSInteger x; // X coordinate on the main map
@property (nonatomic, assign) NSInteger y; // Y coordinate on the main map
@property (nonatomic, strong) NSString *type; // City, village, dungeon, etc.
@property (nonatomic, strong) NSString *region; // Region code
@property (nonatomic, strong) NSString *htmlinfo;
@property (nonatomic, strong) NSString *shortinfo;
@property (nonatomic, strong) NSString *plaininfo;
@property (nonatomic, strong, nullable) DSALocation *parentLocation; // Parent (if inside a detailed location)
@property (nonatomic, strong, nullable) NSMutableArray<DSALocation *> *sublocations; // Detailed sublocations
@property (nonatomic, assign) NSInteger detailX; // X coord within the detailed map
@property (nonatomic, assign) NSInteger detailY; // Y coord within the detailed map
@property (nonatomic, assign) NSInteger dungeonLevel; // If inside a dungeon, track depth
// below information taken from Karten.json
@property (nonatomic, strong) NSDictionary *locationMap;


- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isInDetailedLocation;
- (NSString *)fullDescription;

@end

NS_ASSUME_NONNULL_END

#endif // _DSALOCATION_H_

