/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-08 23:06:31 +0100 by sebastia

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

#ifndef _DSASPELLWITCHCURSE_H_
#define _DSASPELLWITCHCURSE_H_

#import "DSASpell.h"

@interface DSASpellWitchCurse : DSASpell
@property (nonatomic) BOOL isLearned;

- (instancetype)initSpell: (NSString *) name 
                 withTest: (NSArray *) test
                isLearned: (BOOL) learned;

@end

#endif // _DSASPELLWITCHCURSE_H_
