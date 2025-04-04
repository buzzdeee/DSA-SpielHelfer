/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 22:37:59 +0200 by sebastia

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

#ifndef _DSATRAIT_H_
#define _DSATRAIT_H_

#import <Foundation/Foundation.h>

@interface DSATrait : NSObject <NSCoding, NSCopying>
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@end
// End of DSATrait

@interface DSAPositiveTrait : DSATrait
- (instancetype)initTrait: (NSString *) name
                  onLevel: (NSInteger)level;

- (BOOL) levelUp;               
@end
// End of DSAPositiveTrait

@interface DSANegativeTrait : DSATrait
- (instancetype)initTrait: (NSString *) name
                  onLevel: (NSInteger)level;

- (BOOL) levelDown;               
@end
// End of DSANegativeTrait

#endif // _DSATRAIT_H_

