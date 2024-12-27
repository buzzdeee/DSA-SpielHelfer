/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-13 22:09:32 +0200 by sebastia

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

#ifndef _DSAFIGHTINGTALENT_H_
#define _DSAFIGHTINGTALENT_H_

#import "DSATalent.h"

@interface DSAFightingTalent : DSATalent

@property (nonatomic, strong) NSString *subCategory;

- (instancetype)initTalent: (NSString *) name
             inSubCategory: (NSString *) subCategory
                ofCategory: (NSString *) category
                   onLevel: (NSInteger) level
    withMaxTriesPerLevelUp: (NSNumber *) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSNumber *) maxUpPerLevel
           withLevelUpCost: (NSNumber *) levelUpCost;

@end

#endif // _DSAFIGHTINGTALENT_H_

