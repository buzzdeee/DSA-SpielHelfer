/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 20:41:26 +0200 by sebastia

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

#ifndef _DSATALENT_H_
#define _DSATALENT_H_

#import <Foundation/Foundation.h>
@class DSACharacter;

@interface DSATalent : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger maxUpPerLevel;
@property (nonatomic, assign) NSInteger maxTriesPerLevelUp;
@property (nonatomic, assign) NSInteger levelUpCost;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *talentDescription;
@property (nonatomic, strong) NSString *category;
@property (nonatomic) BOOL isPersonalTalent;              // set to YES, for i.e. Musizieren for Skald or Bard

- (BOOL) levelUp;

@end

#endif // _DSATALENT_H_

