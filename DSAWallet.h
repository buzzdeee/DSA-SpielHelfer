/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-13 21:27:58 +0200 by sebastia

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

#ifndef _DSAWALLET_H_
#define _DSAWALLET_H_

#import "DSABaseObject.h"

@interface DSAWallet : DSABaseObject <NSCoding>

@property (nonatomic, assign) NSInteger dukaten;   // D
@property (nonatomic, assign) NSInteger silber;    // S
@property (nonatomic, assign) NSInteger heller;    // H
@property (nonatomic, assign) NSInteger kreuzer;   // K

// add/subtract money in Silber
- (void)addSilber:(float)silber;
- (void)subtractSilber:(float)silber;

// total in Silber
- (float)total;

// ensures to not have two digits in money values below Dukaten
- (void)normalize;

@end
#endif // _DSAWALLET_H_

