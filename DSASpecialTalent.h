/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-10-09 19:48:53 +0200 by sebastia

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

#ifndef _DSASPECIALTALENT_H_
#define _DSASPECIALTALENT_H_

#import "DSATalent.h"

@interface DSASpecialTalent : DSATalent

@property (nonatomic, strong) NSArray *test;

- (instancetype)initTalent: (NSString *) name
                ofCategory: (NSString *) category 
                   onLevel: (NSInteger) level
                  withTest: (NSArray *) test
    withMaxTriesPerLevelUp: (NSNumber *) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSNumber *) maxUpPerLevel
           withLevelUpCost: (NSNumber *) levelUpCost;                          

@end

#endif // _DSASPECIALTALENT_H_

