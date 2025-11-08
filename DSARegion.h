/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-11-08 22:02:40 +0100 by sebastia

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

#ifndef _DSAREGION_H_
#define _DSAREGION_H_

#import <Foundation/Foundation.h>

@interface DSARegion : NSObject

@property (nonatomic, strong) NSString *regionID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *polygons; // NSArray<NSArray<NSArray<NSNumber *> *> *> 
                                             // -> [[[x, y], [x, y], ...]]

- (instancetype)initWithFeature:(NSDictionary *)feature;
- (BOOL)containsPointX:(double)x Y:(double)y; // Punkt-in-Polygon-Test

@end

@interface DSARegionManager : NSObject

@property (nonatomic, strong) NSArray<DSARegion *> *regions;

+ (instancetype)sharedManager;
- (void)loadRegionsFromGeoJSON:(NSString *)path;
- (DSARegion *)regionForX:(double)x Y:(double)y;
- (DSARegion *)regionWithName: (NSString *) regionName;
- (NSArray<DSARegion *> *)allRegions;
- (NSArray<NSDictionary *> *)allFeatures;

@end

#endif // _DSAREGION_H_

