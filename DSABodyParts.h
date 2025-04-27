/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-28 22:43:54 +0100 by sebastia

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

#ifndef _DSABODYPARTS_H_
#define _DSABODYPARTS_H_

#import <Foundation/Foundation.h>
#import "DSAInventory.h"
#import "DSAEquipResult.h"

@interface DSABodyParts : NSObject <NSCoding, NSCopying>
@property (nonatomic, strong) DSAInventory *head;
@property (nonatomic, strong) DSAInventory *neck;
@property (nonatomic, strong) DSAInventory *eyes;
@property (nonatomic, strong) DSAInventory *leftEar;
@property (nonatomic, strong) DSAInventory *rightEar;
@property (nonatomic, strong) DSAInventory *nose;
@property (nonatomic, strong) DSAInventory *face;
@property (nonatomic, strong) DSAInventory *back;
@property (nonatomic, strong) DSAInventory *shoulder;
@property (nonatomic, strong) DSAInventory *leftArm;
@property (nonatomic, strong) DSAInventory *rightArm;
@property (nonatomic, strong) DSAInventory *leftHand;
@property (nonatomic, strong) DSAInventory *rightHand;
@property (nonatomic, strong) DSAInventory *hip;
@property (nonatomic, strong) DSAInventory *upperBody;
@property (nonatomic, strong) DSAInventory *lowerBody;
@property (nonatomic, strong) DSAInventory *leftLeg;
@property (nonatomic, strong) DSAInventory *rightLeg;
@property (nonatomic, strong) DSAInventory *leftFoot;
@property (nonatomic, strong) DSAInventory *rightFoot;

- (instancetype)init;
- (DSAEquipResult *)equipObject:(DSAObject *)object;
- (DSAInventory *)inventoryForBodyPart:(NSString *)bodyPart;
- (NSInteger)countInventories;
- (NSArray<NSString *> *)inventoryPropertyNames;

@end

#endif // _DSABODYPARTS_H_

