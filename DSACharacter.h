/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 00:03:31 +0200 by sebastia

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

#ifndef _DSACHARACTER_H_
#define _DSACHARACTER_H_

#import <Foundation/Foundation.h>

@interface DSACharacter : NSObject <NSCoding>

// copy properties, to prevent others fiddling with the model...
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *archetype;
@property (nonatomic, copy) NSNumber *level; 
@property (nonatomic, copy) NSNumber *adventurePoints;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSMutableArray *professions;
@property (nonatomic, copy) NSString *mageAcademy;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *hairColor;
@property (nonatomic, copy) NSString *eyeColor;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *weight;
@property (nonatomic, copy) NSDictionary *birthday;
@property (nonatomic, copy) NSString *god;
@property (nonatomic, copy) NSString *stars;
@property (nonatomic, copy) NSString *socialStatus;
@property (nonatomic, copy) NSString *parents;
@property (nonatomic, copy) NSMutableDictionary *money;
@property (nonatomic, copy) NSMutableDictionary *positiveTraits;
@property (nonatomic, copy) NSMutableDictionary *negativeTraits;
@property (nonatomic, copy) NSNumber *lifePoints;
@property (nonatomic, copy) NSNumber *astralEnergy;
@property (nonatomic, copy) NSNumber *karmaPoints;
@property (nonatomic, copy) NSNumber *mrBonus;
@property (nonatomic, strong) NSImage *portrait;

@property (readonly, copy) NSNumber *attackBaseValue;
@property (readonly, copy) NSNumber *carryingCapacity;
@property (readonly, copy) NSNumber *dodge;
@property (readonly, copy) NSNumber *encumbrance;
@property (readonly, copy) NSNumber *endurance;
@property (readonly, copy) NSNumber *magicResistance;
@property (readonly, copy) NSNumber *parryBaseValue;
@property (readonly, copy) NSNumber *rangedCombatBaseValue;



@end

#endif // _DSACHARACTER_H_

