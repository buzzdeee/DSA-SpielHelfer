/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 23:21:02 +0200 by sebastia

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

#import "DSASpellAntiMagicDisruptMovement.h"

@implementation DSASpellAntiMagicDisruptMovement 
- (instancetype)initWithLevel:(NSNumber *)level {
    self = [super init];
    if (self) {
        self.level = level;
        self.name = _(@"Bewegung stören");
        self.longName = _(@"Bewegung stören");
        self.origin = @[ @"Gildenmagie" ];
        self.test = @[ @"KL", @"IN", @"FF" ];
        self.spellRange = @"49 Schritt";
        self.spellingDuration = @"2 seconds";
        self.spellDuration = @"permanent";
        self.technique = @"Der Magier deutet mit der rechten Hand, oder dem Stab, auf das Ziel des Zaubers und beschreibt mit der linken einen kleine Kreis in der Luft";
        self.cost = @"6+";
        self.isHealSpell = [NSNumber numberWithBool: NO];
        self.isDamageSpell = [NSNumber numberWithBool: YES];
    }
    return self;  
}

- (DSASpellResult *)castSpellOnObject: (DSAObject *)object
{
  return [[DSASpellResult alloc] init];
}

- (DSASpellResult *)castSpellOnCreature: (DSAObject *)creature
{
  return [[DSASpellResult alloc] init];
}


@end
