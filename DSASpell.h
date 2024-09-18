/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 23:01:49 +0200 by sebastia

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

#ifndef _DSASPELL_H_
#define _DSASPELL_H_

#import <Foundation/Foundation.h>

@interface DSASpell : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSArray *origin;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *technique;
@property (nonatomic, strong) NSArray *test;
@property (nonatomic, strong) NSString *spellDuration;
@property (nonatomic, strong) NSString *spellingDuration;
@property (nonatomic, strong) NSString *spellRange;
@property (nonatomic, strong) NSString *cost;
@property (nonatomic, strong) NSNumber *isHealSpell;
@property (nonatomic, strong) NSNumber *isDamageSpell;
@property (nonatomic, strong) NSNumber *isAffectingCreatures;
@property (nonatomic, strong) NSNumber *isAffectingObjects;

- (instancetype)initWithLevel: (NSNumber *) level;

@end

#endif // _DSASPELL_H_

