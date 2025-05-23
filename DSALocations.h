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

#ifndef _DSALOCATIONS_H_
#define _DSALOCATIONS_H_

#import "Foundation/Foundation.h"
#import "DSALocation.h"

@interface DSALocations : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<DSALocation *> *locations; // Mutable array for dynamic updates

+ (instancetype)sharedInstance;

- (void)loadLocationsFromJSON;
- (void)addLocation:(DSALocation *)location;
- (void)removeLocationWithName:(NSString *)name;

- (NSArray<NSString *> *)locationNames;                  // list of all location names
- (NSArray<NSString *> *)locationNamesWithTemples;       // list of all locations that have temples

- (DSALocation *)locationWithName:(NSString *)name;
- (NSString *) htmlInfoForLocationWithName: (NSString *) name;
- (NSString *) plainInfoForLocationWithName: (NSString *) name;
- (NSArray<NSString *> *)locationNamesOfType:(NSString *)type;
- (NSArray<NSString *> *)locationNamesOfTypes:(NSArray<NSString *> *)types;
- (NSArray<NSString *> *)locationNamesOfTypes:(NSArray<NSString *> *)types matching:(NSString *)match;

@end
#endif // _DSALOCATIONS_H_

