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
#import "DSACharacterMagic.h"
#import "DSATalent.h"
#import "DSASpell.h"
#import "DSAPositiveTrait.h"
#import "DSANegativeTrait.h"
#import "Utils.h"

@implementation DSACharacterHero

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.level = 0;
      self.adventurePoints = 0;
      self.specials = nil;    
      self.isLevelingUp = NO;  // even though we likely will level up soon, it shall be triggered by the user
      self.levelUpTalents = nil;
      self.levelUpSpells = nil;      
      self.levelUpProfessions = nil;
      self.firstLevelUpTalentTriesPenalty = 0; // this is also taken into account in the DSACharacterWindowController...
      self.maxLevelUpTalentsTries = 30;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 0;
      self.maxLevelUpTalentsTriesTmp = 0;      // this value is set in the DSACharacterWindowController, as there are characters out there, that might have variable tries
      self.maxLevelUpSpellsTriesTmp = 0;       // this value is set in the DSACharacterWindowController, as there are characters out there, that might have variable tries
      self.maxLevelUpVariableTries = 0;        // thats the value the DSACharacterWindowController checks if there ar variable tries
    }
  return self;
}

- (void) prepareLevelUp
{
  // only taking care of the basics here
  // since we'd have to ask the user how much variable tries 
  // to distribute between spells and talents, and it 
  // doesn't fit into the flow
  // it's triggered from within the upgrade flow
  self.isLevelingUp = YES;

  NSMutableDictionary *tempLevelUpTalents = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *tempLevelUpSpells = [[NSMutableDictionary alloc] init];  
  NSMutableDictionary *tempLevelUpProfessions = [[NSMutableDictionary alloc] init];
  
  if (!self.levelUpTalents)
    {
      self.levelUpTalents = [[NSMutableDictionary alloc] init];
    }  
  NSLog(@"DSACharacterHero: prepareLevelUp: Number of talents: %lu", (unsigned long)[self.talents count]); 
  for (id key in self.talents)
    {
      id value = self.talents[key];
      // Check if the value conforms to NSCopying
      if ([value conformsToProtocol:@protocol(NSCopying)])
        {
          tempLevelUpTalents[key] = [value copy];
        }
      else
        {
          tempLevelUpTalents[key] = value; // Shallow copy
        }
    }
  NSLog(@"DSACharacterHero: prepareLevelUp: Number of spells: %lu", (unsigned long)[self.spells count]);    
  if ([self isMagicalDabbler])
    {
      NSLog(@"DSACharacterHero: prepareLevelUp: IM A MAGICAL DABBLER");
      for (id key in self.spells)
        {
          id value = self.spells[key];
          NSLog(@"DSACharacterHero: prepareLevelUp: spell: %@", value);
          // Check if the value conforms to NSCopying
          if ([value conformsToProtocol:@protocol(NSCopying)])
            {
              tempLevelUpTalents[key] = [value copy];
            }
          else
            {
              tempLevelUpTalents[key] = value; // Shallow copy
            }
          NSLog(@"DSACharacterHero: prepareLevelUp: added spell to tempLevelUpTalents: %@ for Key: %@", tempLevelUpTalents[key], key);
        }
    }
    
  // Update the original dictionary after the loop
  @synchronized(self) {
    self.levelUpTalents = [tempLevelUpTalents mutableCopy];
  }
  
  if (![self isMagicalDabbler]) // magical dabblers have spells, but they're just treated like normal talents
    {
      if (!self.levelUpSpells)
        {
          self.levelUpSpells = [[NSMutableDictionary alloc] init];
        }  
      NSLog(@"Number of spells: %lu", (unsigned long)[self.spells count]); 
      for (id key in self.spells)
        {
          id value = self.spells[key];
          // Check if the value conforms to NSCopying
          if ([value conformsToProtocol:@protocol(NSCopying)])
            {
              tempLevelUpSpells[key] = [value copy];
            }
          else
            {
              tempLevelUpSpells[key] = value; // Shallow copy
            }
        }
        
      SEL levelUpSpecialsWithSpellsSelector = @selector(levelUpSpecialsWithSpells);
      if ([self respondsToSelector:levelUpSpecialsWithSpellsSelector])
        {
          // Safely invoke the selector and store the result as a BOOL
          BOOL shouldLevelUpSpecialsWithSpells = ((BOOL (*)(id, SEL))[self methodForSelector:levelUpSpecialsWithSpellsSelector])(self, levelUpSpecialsWithSpellsSelector);

          if (shouldLevelUpSpecialsWithSpells)
            {
              for (id key in self.specials)
                {
                  id value = self.specials[key];

                  // Check if the value conforms to NSCopying
                  if ([value conformsToProtocol:@protocol(NSCopying)])
                    {
                      tempLevelUpSpells[key] = [value copy];
                    }
                  else
                    {
                      tempLevelUpSpells[key] = value; // Shallow copy
                    }
                }
            }
        }
      // Update the original dictionary after the loop
      @synchronized(self) {
        self.levelUpSpells = [tempLevelUpSpells mutableCopy];
      } 
    }
NSLog(@"THE SPELLS IN LEVEL UP SPELLS: %@", self.levelUpSpells);
        
  if (!self.levelUpProfessions)
    {
      self.levelUpProfessions = [[NSMutableDictionary alloc] init];
    }  
  NSLog(@"Number of professions: %lu", (unsigned long)[self.professions count]); 
  for (id key in self.professions)
    {
      id value = _professions[key];
      // Check if the value conforms to NSCopying
      if ([value conformsToProtocol:@protocol(NSCopying)])
        {
          tempLevelUpProfessions[key] = [value copy];
        }
      else
        {
          tempLevelUpProfessions[key] = value; // Shallow copy
        }
    }

  // Update the original dictionary after the loop
  @synchronized(self) {
    self.levelUpProfessions = [tempLevelUpProfessions mutableCopy];
  }  
}

- (void) finishLevelUp
{
  self.isLevelingUp = NO;
  self.levelUpTalents = nil;
  self.levelUpSpells = nil;  
  self.levelUpProfessions = nil;
  self.maxLevelUpTalentsTriesTmp = 0;
  self.maxLevelUpSpellsTriesTmp = 0;
  self.tempDeltaLpAe = 0;
  self.level += 1;
}

// for the most characters done here
// others with special constraints, it's done in subclasses
// lifePoints level up described in "Die Helden des schwarzen Auges" Regelbuch II, S. 13

- (NSDictionary *) levelUpBaseEnergies
{
  NSInteger result;
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  result = [Utils rollDice: @"1W6"];
  NSInteger tmp = self.lifePoints;
  self.lifePoints = result + tmp;
  self.currentLifePoints = result + tmp;
  
  [resultDict setObject: @(result) forKey: @"deltaLifePoints"];
  if ([self conformsToProtocol:@protocol(DSACharacterMagic)])
    {
      result = [Utils rollDice: @"1W6"];
      NSInteger tmp = self.astralEnergy;
      self.astralEnergy = result + tmp;
      self.currentAstralEnergy = result + tmp;
      [resultDict setObject: @(result) forKey: @"deltaAstralEnergy"];
    }

  if ([self isBlessedOne])
    {        
      NSLog(@"leveling up Karma not yet implemented!!!");
      [resultDict setObject: @(result) forKey: @"deltaKarmaPoints"];
    }
  return resultDict;
}

- (BOOL) levelUpPositiveTrait: (NSString *) trait
{
  NSLog(@"DSACharacterHero: BEFORE levelUpPositiveTrait %@", [self.positiveTraits objectForKey: trait]);
  BOOL result = [(DSAPositiveTrait *)[self.positiveTraits objectForKey: trait] levelUp];
  NSLog(@"DSACharacterHero: AFTER levelUpPositiveTrait %@", [self.positiveTraits objectForKey: trait]);
  if (result == YES)  // also bump current positive trait
    {
      [[self.currentPositiveTraits objectForKey: trait] setLevel: [[self.currentPositiveTraits objectForKey: trait] level] + 1];
    }
  return result;
}

- (BOOL) levelDownNegativeTrait: (NSString *) trait
{
  BOOL result = [(DSANegativeTrait *)[self.negativeTraits objectForKey: trait] levelDown];
  if (result == YES)  // also lower current positive trait
    {
      [[self.currentNegativeTraits objectForKey: trait] setLevel: [[self.currentNegativeTraits objectForKey: trait] level] - 1];
    }  
  return result;
}


// basic leveling up of a talent is handled within the talent
- (BOOL) levelUpTalent: (DSATalent *)talent
{
  BOOL result = NO;
  DSATalent *targetTalent = nil;
  DSATalent *tmpTalent = nil;

  targetTalent = talent;
  tmpTalent = [self.levelUpTalents objectForKey: talent.name];

  if (tmpTalent.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHero: levelUpTalent: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
  
  self.maxLevelUpTalentsTriesTmp = self.maxLevelUpTalentsTriesTmp - [talent levelUpCost];

  result = [targetTalent levelUp];
  if (result)
    {
      tmpTalent.maxUpPerLevel = tmpTalent.maxUpPerLevel - 1;
      tmpTalent.maxTriesPerLevelUp = tmpTalent.maxUpPerLevel * 3;
      tmpTalent.level = targetTalent.level;
    }
  else
    {
      tmpTalent.maxTriesPerLevelUp = tmpTalent.maxTriesPerLevelUp - 1;
      if ((tmpTalent.maxTriesPerLevelUp % 3) == 0)
        {
          tmpTalent.maxUpPerLevel = tmpTalent.maxUpPerLevel- 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpTalent: (DSATalent *) talent
{
  if (talent.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
    if (self.maxLevelUpTalentsTriesTmp < [talent levelUpCost])  // spells cost
      {
        return NO;
      }
 
  // below test shouldn't really be necessary, because of just last test above, just return YES!!!
  if ([[self.levelUpTalents objectForKey: [talent name]] maxUpPerLevel] <= 0) // actually should never be < 0
    {
      return NO;
    }
  else
    {
      return YES;
    }
}

- (BOOL) canLevelUp {
    int currentLevel = self.level;
    int nextLevel = currentLevel + 1;

    // Special case for level 0 to level 1
    if (currentLevel == 0) {
        // Transition from level 0 to level 1 requires 0 points
        return YES;
    }

    // Calculate cumulative adventure points required to reach the current level
    int requiredPoints = [self adventurePointsForNextLevel:nextLevel] - [self adventurePointsForNextLevel:currentLevel];
        
    return self.adventurePoints >= requiredPoints;
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
      
  [coder encodeObject:self.professions forKey:@"professions"];  
  [coder encodeObject:self.levelUpTalents forKey:@"levelUpTalents"];
  [coder encodeObject:self.levelUpSpells forKey:@"levelUpSpells"];  
  [coder encodeObject:self.levelUpProfessions forKey:@"levelUpProfessions"];
  [coder encodeInteger:self.firstLevelUpTalentTriesPenalty forKey:@"firstLevelUpTalentTriesPenalty"];  
  [coder encodeInteger:self.maxLevelUpTalentsTries forKey:@"maxLevelUpTalentsTries"];
  [coder encodeInteger:self.maxLevelUpSpellsTries forKey:@"maxLevelUpSpellsTries"];
  [coder encodeInteger:self.maxLevelUpTalentsTriesTmp forKey:@"maxLevelUpTalentsTriesTmp"];
  [coder encodeInteger:self.maxLevelUpSpellsTriesTmp forKey:@"maxLevelUpSpellsTriesTmp"];  
  [coder encodeInteger:self.maxLevelUpVariableTries forKey:@"maxLevelUpVariableTries"];
  [coder encodeInteger:self.tempDeltaLpAe forKey:@"tempDeltaLpAe"];
  [coder encodeBool:self.isLevelingUp forKey:@"isLevelingUp"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self)
    {           
      self.professions = [coder decodeObjectForKey:@"professions"];      
      self.levelUpTalents = [coder decodeObjectForKey:@"levelUpTalents"];
      self.levelUpSpells = [coder decodeObjectForKey:@"levelUpSpells"];      
      self.levelUpProfessions = [coder decodeObjectForKey:@"levelUpProfessions"];
      self.firstLevelUpTalentTriesPenalty = [coder decodeIntegerForKey:@"firstLevelUpTalentTriesPenalty"];            
      self.maxLevelUpTalentsTries = [coder decodeIntegerForKey:@"maxLevelUpTalentsTries"];
      self.maxLevelUpSpellsTries = [coder decodeIntegerForKey:@"maxLevelUpSpellsTries"];
      self.maxLevelUpTalentsTriesTmp = [coder decodeIntegerForKey:@"maxLevelUpTalentsTriesTmp"];
      self.maxLevelUpSpellsTriesTmp = [coder decodeIntegerForKey:@"maxLevelUpSpellsTriesTmp"];      
      self.maxLevelUpVariableTries = [coder decodeIntegerForKey:@"maxLevelUpVariableTries"];
      self.tempDeltaLpAe = [coder decodeIntegerForKey:@"tempDeltaLpAe"];
      self.isLevelingUp = [coder decodeBoolForKey:@"isLevelingUp"];     
    }
  return self;
}



/* Calculate Endurance, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
- (NSInteger) endurance {
  NSInteger retVal;

  retVal = self.lifePoints + [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue];  
  return retVal;
}

/* calculate CarryingCapacity, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
- (NSInteger) carryingCapacity {
  NSInteger retVal;
  
  retVal = [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue] * 50;  
  return retVal;
}

- (NSInteger) attackBaseValue {
  NSInteger retVal;
  
  retVal = round(([[self.currentPositiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"GE.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 5);
  return retVal;
}


- (NSInteger) parryBaseValue {
  NSInteger retVal;
  
  retVal = round(([[self.currentPositiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"GE.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 5);
  return retVal;
}


- (NSInteger) rangedCombatBaseValue {
  NSInteger retVal;
  
  retVal = floor(([[self.currentPositiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"FF.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 4);
  return retVal;
}

- (NSInteger) dodge {
  NSInteger retVal;
  
  retVal = floor(([[self.currentPositiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"GE.level"] integerValue]) / 4) - 
                 roundf(self.encumbrance);
  return retVal;
}

- (NSInteger) magicResistance {
  NSInteger retVal;
  
  retVal = floor(([[self.currentPositiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"KL.level"] integerValue] +
                 self.level) / 3) - 2 * [[self.currentNegativeTraits valueForKeyPath: @"AG.level"] integerValue] +
                 self.mrBonus;
  return retVal;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
  NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
  if ([key isEqualToString:@"endurance"])
    {
      keyPaths = [NSSet setWithObjects:@"lifePoints", @"currentPositiveTraits.KK.level", nil];
    }
  else if ([key isEqualToString:@"carryingCapacity"])
    {
      keyPaths = [NSSet setWithObject:@"currentPositiveTraits.KK.level"];
    }
  else if ([key isEqualToString:@"attackBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.MU.level", 
                                         @"currentPositiveTraits.GE.level", 
                                         @"currentPositiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"parryBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.IN.level", 
                                         @"currentPositiveTraits.GE.level", 
                                         @"currentPositiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"rangedCombatBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.IN.level", 
                                         @"currentPositiveTraits.FF.level", 
                                         @"currentPositiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"dodge"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.MU.level", 
                                         @"currentPositiveTraits.IN.level", 
                                         @"currentPositiveTraits.GE.level", nil];        
    }
  else if ([key isEqualToString:@"magicResistance"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.MU.level", 
                                         @"currentPositiveTraits.KL.level",
                                         @"currentNegativeTraits.AG.level",
                                         @"mrBonus",
                                         @"level", nil];        
    }                 
  return keyPaths;
}
@end
