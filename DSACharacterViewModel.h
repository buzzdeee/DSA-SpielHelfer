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
@class DSAWallet;

@interface DSACharacterViewModel : NSObject <NSCopying>

@property (nonatomic, strong) DSACharacterHero *model;

@property (nonatomic, strong) DSAWallet *wallet;
@property (nonatomic, strong) NSDictionary *positiveTraits;
@property (nonatomic, strong) NSDictionary *currentPositiveTraits;
@property (nonatomic, strong) NSDictionary *negativeTraits;
@property (nonatomic, strong) NSDictionary *currentNegativeTraits;

@property (nonatomic, assign) NSInteger lifePoints;
@property (nonatomic, assign) NSInteger currentLifePoints;
@property (nonatomic, assign) NSInteger astralEnergy;
@property (nonatomic, assign) NSInteger currentAstralEnergy;
@property (nonatomic, assign) NSInteger karmaPoints;
@property (nonatomic, assign) NSInteger currentKarmaPoints;

@property (nonatomic, copy) NSString *formattedWallet;
@property (nonatomic, copy) NSString *formattedLifePoints;
@property (nonatomic, copy) NSString *formattedAstralEnergy;
@property (nonatomic, copy) NSString *formattedKarmaPoints;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *formattedPositiveTraits;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *formattedNegativeTraits;

@end

#endif // _DSACHARACTERVIEWMODEL_H_

