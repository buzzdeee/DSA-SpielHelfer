/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-19 22:03:00 +0200 by sebastia

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

#ifndef _DSACHARACTERVIEWMODEL_H_
#define _DSACHARACTERVIEWMODEL_H_

#import <Foundation/Foundation.h>
@class DSACharacterHero;

@interface DSACharacterViewModel : NSObject <NSCopying>

@property (nonatomic, strong) DSACharacterHero *model;

@property (nonatomic, strong) NSDictionary *money;

@property (nonatomic, strong) NSNumber *lifePoints;
@property (nonatomic, strong) NSNumber *currentLifePoints;
@property (nonatomic, strong) NSNumber *astralEnergy;
@property (nonatomic, strong) NSNumber *currentAstralEnergy;
@property (nonatomic, strong) NSNumber *karmaPoints;
@property (nonatomic, strong) NSNumber *currentKarmaPoints;

@property (nonatomic, copy) NSString *formattedMoney;
@property (nonatomic, copy) NSString *formattedLifePoints;
@property (nonatomic, copy) NSString *formattedAstralEnergy;
@property (nonatomic, copy) NSString *formattedKarmaPoints;

@end

#endif // _DSACHARACTERVIEWMODEL_H_

