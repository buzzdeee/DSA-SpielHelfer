/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-24 22:03:27 +0200 by sebastia

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

#import "DSACharacterHeroHumanMage.h"
#import "DSASpell.h"
#import "DSASpellResult.h"

@implementation DSACharacterHeroHumanMage

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = @25;
      self.astralEnergy = @30;
      self.currentLifePoints = @25;
      self.currentAstralEnergy = @30; 
      self.maxLevelUpTalentsTries = @15;        // Talent und ZF Steigerungen lt. Compendium Salamandris S. 28      
      self.maxLevelUpSpellsTries = @40;
      self.maxLevelUpTalentsTriesTmp = @15;
      self.maxLevelUpSpellsTriesTmp = @40;      
      self.maxLevelUpVariableTries = @10;
      self.mrBonus = @3;           
    }
  return self;
}

- (DSASpellResult *) castSpell: (DSASpell *) spell
{
  return [[DSASpellResult alloc] init];
}
- (DSASpellResult *) castSpell: (DSASpell *) spell on: (id) target
{
  return [[DSASpellResult alloc] init];
}

- (DSASpellResult *) castSpell: (DSASpell *) spell withSource: (id) source onTarget: (id) target
{
  return [[DSASpellResult alloc] init];
}

- (BOOL) levelUpSpell: (DSASpell *)spell
{
  return YES;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  return YES;
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}

- (DSASpellResult *) meditate
{
  return [[DSASpellResult alloc] init];
}

- (DSASpellResult *) enchantStaff: (id) staff
{
  return [[DSASpellResult alloc] init];
}

@end
