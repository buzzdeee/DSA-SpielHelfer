/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:00:22 +0200 by sebastia

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

#ifndef _DSAHINTMANAGER_H_
#define _DSAHINTMANAGER_H_

#import <Foundation/Foundation.h>
@class DSAHint;
NS_ASSUME_NONNULL_BEGIN
@interface DSAHintManager: NSObject

@property (nonatomic, strong) NSMutableArray<DSAHint *> *mutableHints;
@property (nonatomic, strong) NSMutableSet<NSString *> *collectedHintIDs;  // Zum Tracking

@property (nonatomic, strong) NSMutableDictionary<NSString *, DSAHint *> *hintIDToHintMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DSAHint *> *hintsByID;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<DSAHint *> *> *hintsByLocation;

+ (instancetype)sharedInstance;
- (nullable NSString *)randomHintForLocation:(NSString *)location;

@end
NS_ASSUME_NONNULL_END
#endif // _DSAHINTMANAGER_H_

