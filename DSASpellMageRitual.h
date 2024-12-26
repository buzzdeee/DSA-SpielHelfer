/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-26 12:09:29 +0100 by sebastia

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

#ifndef _DSASPELLMAGERITUAL_H_
#define _DSASPELLMAGERITUAL_H_

#import "DSASpell.h"

@interface DSASpellMageRitual : DSASpell

@property (nonatomic, assign) NSInteger aspCost;
@property (nonatomic, assign) NSInteger permanentASPCost;
@property (nonatomic, strong) NSString *lpCost;
@property (nonatomic, assign) NSInteger permanentLPCost;

- (instancetype)initSpell: (NSString *) name
               ofCategory: (NSString *) category
                 withTest: (NSArray *) test
              withASPCost: (NSInteger) aspCost
     withPermanentASPCost: (NSInteger) permanentASPCost
               withLPCost: (NSString *) lpCost
      withPermanentLPCost: (NSInteger) permanentLPCost;

@end

#endif // _DSASPELLMAGERITUAL_H_

