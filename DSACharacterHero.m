/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 21:31:33 +0200 by sebastia

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

#import "DSACharacterHero.h"
#import "DSATalent.h"

@implementation DSACharacterHero

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.level = [NSNumber numberWithInteger: 0];
      self.adventurePoints = [NSNumber numberWithInteger: 0];
    }
  return self;
}

- (void) levelUpTalent: (DSATalent *)talent
{
  NSLog(@"DSACharacterHero: levelUpTalent: NOT IMPLEMENTED YET");
}


- (BOOL)canLevelUp {
    int currentLevel = [self.level integerValue];
    int nextLevel = currentLevel + 1;

    // Special case for level 0 to level 1
    if (currentLevel == 0) {
        // Transition from level 0 to level 1 requires 0 points
        return YES;
    }

    // Calculate cumulative adventure points required to reach the current level
    int requiredPoints = [self adventurePointsForNextLevel:nextLevel] - [self adventurePointsForNextLevel:currentLevel];
    
    NSLog(@"DSACharacterHero: canLevelUp was called: %i", [self.adventurePoints integerValue] >= requiredPoints);
    
    return [self.adventurePoints integerValue] >= requiredPoints;
}

- (int)adventurePointsForNextLevel:(int)level {
    // Calculate total adventure points required to reach the given level
    // Points required to reach each level increases by 100 more than the previous level
    int totalPoints = 0;
    for (int i = 1; i < level; i++) {
        totalPoints += 100 * i;
    }
    return totalPoints;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  
  [coder encodeObject:self.talents forKey:@"talents"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self)
    {
      self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
      self.title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
      self.archetype = [coder decodeObjectOfClass:[NSString class] forKey:@"archetype"];
      self.level = [coder decodeObjectOfClass:[NSString class] forKey:@"level"];
      self.adventurePoints = [coder decodeObjectOfClass:[NSString class] forKey:@"adventurePoints"];
      self.origin = [coder decodeObjectOfClass:[NSString class] forKey:@"origin"];
      self.professions = [coder decodeObjectOfClass:[NSString class] forKey:@"professions"];
      self.mageAcademy = [coder decodeObjectOfClass:[NSString class] forKey:@"mageAcademy"];
      self.sex = [coder decodeObjectOfClass:[NSString class] forKey:@"sex"];
      self.hairColor = [coder decodeObjectOfClass:[NSString class] forKey:@"hairColor"];
      self.eyeColor = [coder decodeObjectOfClass:[NSString class] forKey:@"eyeColor"];
      self.height = [coder decodeObjectOfClass:[NSString class] forKey:@"height"];
      self.weight = [coder decodeObjectOfClass:[NSString class] forKey:@"weight"];
      self.birthday = [coder decodeObjectOfClass:[NSString class] forKey:@"birthday"];
      self.god = [coder decodeObjectOfClass:[NSString class] forKey:@"god"];
      self.stars = [coder decodeObjectOfClass:[NSString class] forKey:@"stars"];
      self.socialStatus = [coder decodeObjectOfClass:[NSString class] forKey:@"socialStatus"];
      self.parents = [coder decodeObjectOfClass:[NSString class] forKey:@"parents"];
      self.money = [coder decodeObjectOfClass:[NSString class] forKey:@"money"];
      self.positiveTraits = [coder decodeObjectOfClass:[NSString class] forKey:@"positiveTraits"];
      self.negativeTraits = [coder decodeObjectOfClass:[NSString class] forKey:@"negativeTraits"];
      self.talents = [coder decodeObjectOfClass:[NSString class] forKey:@"talents"];
    }  
  return self;
}



/* Calculate Endurance, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
- (NSNumber *) endurance {
  NSInteger retVal;

  retVal = [[self lifePoints] integerValue] * [[self.positiveTraits valueForKeyPath: @"KK.level"] integerValue];
  
  return [NSNumber numberWithInteger: retVal];
}

/* calculate CarryingCapacity, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
- (NSNumber *) carryingCapacity {
  NSInteger retVal;
  
  retVal = [[self.positiveTraits valueForKeyPath: @"KK.level"] integerValue] * 50;
  
  return [NSNumber numberWithInteger: retVal];
}

- (NSNumber *) attackBaseValue {
  NSInteger retVal;
  
  retVal = round(([[self.positiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                  [[self.positiveTraits valueForKeyPath: @"GE.level"] integerValue] + 
                  [[self.positiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 5);
  return [NSNumber numberWithInteger: retVal];
}


- (NSNumber *) parryBaseValue {
  NSInteger retVal;
  
  retVal = round(([[self.positiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                  [[self.positiveTraits valueForKeyPath: @"GE.level"] integerValue] + 
                  [[self.positiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 5);
  return [NSNumber numberWithInteger: retVal];
}


- (NSNumber *) rangedCombatBaseValue {
  NSInteger retVal;
  
  retVal = floor(([[self.positiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                 [[self.positiveTraits valueForKeyPath: @"FF.level"] integerValue] + 
                 [[self.positiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 4);
  return [NSNumber numberWithInteger: retVal];
}

- (NSNumber *) dodge {
  NSInteger retVal;
  
  retVal = floor(([[self.positiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                 [[self.positiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                 [[self.positiveTraits valueForKeyPath: @"GE.level"] integerValue]) / 4) - 
                 [[self encumbrance] integerValue];
  return [NSNumber numberWithInteger: retVal];
}


- (NSNumber *) encumbrance {
  NSLog(@"Calculation for encumbrance missing!!!");
  return [NSNumber numberWithInteger: 0];
}

- (NSNumber *) magicResistance {
  NSInteger retVal;
  
  retVal = floor(([[self.positiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                 [[self.positiveTraits valueForKeyPath: @"KL.level"] integerValue] +
                 [self.level integerValue]) / 3) - 2 * [[self.negativeTraits valueForKeyPath: @"AG.level"] integerValue] +
                 [self.mrBonus integerValue];
  return [NSNumber numberWithInteger: retVal];
}

@end
