/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-19 22:19:06 +0100 by sebastia

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

#ifndef _DSAROUTEPLANNER_H_
#define _DSAROUTEPLANNER_H_

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DSARoutePlanner : NSObject

@property (nonatomic, strong) NSDictionary *locations; // Named locations
@property (nonatomic, strong) NSMutableDictionary *roadGraph; // Graph of roads

// Load data from App Bundle
- (instancetype)initWithBundleFiles;

// Find shortest path between two named locations
- (NSArray<NSValue *> *)findShortestPathFrom:(NSString *)startName to:(NSString *)destinationName;

@end

#endif // _DSAROUTEPLANNER_H_

