/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-07 21:57:19 +0100 by sebastia

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

#ifndef _DSACHARACTERHEROHUMANSHARISAD_H_
#define _DSACHARACTERHEROHUMANSHARISAD_H_

#import <Foundation/Foundation.h>

#import "DSACharacterHeroHuman.h"
#import "DSACharacterMagic.h"
@class DSASpellResult;
@class DSASpell;

@interface DSACharacterHeroHumanSharisad : DSACharacterHeroHuman <DSACharacterMagic>

- (DSASpellResult *) castSpell: (DSASpell *) spell;
- (DSASpellResult *) castSpell: (DSASpell *) spell on: (id) target;
- (DSASpellResult *) castSpell: (DSASpell *) spell withSource: (id) source onTarget: (id) target;
- (BOOL) levelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUpSpell: (DSASpell *)spell;


@end

#endif // _DSACHARACTERHEROHUMANSHARISAD_H_

