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
      self.level = @0;
      self.adventurePoints = @0;
      self.specials = nil;    
      self.isLevelingUp = NO;  // even though we likely will level up soon, it shall be triggered by the user
      self.levelUpTalents = nil;
      self.levelUpSpells = nil;      
      self.levelUpProfessions = nil;
      self.firstLevelUpTalentTriesPenalty = @0; // this is also taken into account in the DSACharacterWindowController...
      self.maxLevelUpTalentsTries = @30;        // most have this as their starting value
      self.maxLevelUpSpellsTries = @0;
      self.maxLevelUpTalentsTriesTmp = @0;      // this value is set in the DSACharacterWindowController, as there are characters out there, that might have variable tries
      self.maxLevelUpSpellsTriesTmp = @0;       // this value is set in the DSACharacterWindowController, as there are characters out there, that might have variable tries
      self.maxLevelUpVariableTries = @0;        // thats the value the DSACharacterWindowController checks if there ar variable tries
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
      id value = _talents[key];
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
          id value = _spells[key];
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
          id value = _spells[key];
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
      // Update the original dictionary after the loop
      @synchronized(self) {
        self.levelUpSpells = [tempLevelUpSpells mutableCopy];
      } 
    }
    
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
  self.maxLevelUpTalentsTriesTmp = @0;
  self.maxLevelUpSpellsTriesTmp = @0;
  self.tempDeltaLpAe = @0;
  self.level = [NSNumber numberWithInteger: [self.level integerValue] + 1];
}

// for the most characters done here
// others with special constraints, it's done in subclasses
// lifePoints level up described in "Die Helden des schwarzen Auges" Regelbuch II, S. 13

- (NSDictionary *) levelUpBaseEnergies
{
  NSNumber *result;
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  result = [Utils rollDice: @"1W6"];
  NSNumber *tmp = self.lifePoints;
  self.lifePoints = [NSNumber numberWithInteger: [result integerValue] + [tmp integerValue]];
  self.currentLifePoints = [NSNumber numberWithInteger: [result integerValue] + [tmp integerValue]];
  
  [resultDict setObject: result forKey: @"deltaLifePoints"];
  if ([self conformsToProtocol:@protocol(DSACharacterMagic)])
    {
      result = [Utils rollDice: @"1W6"];
      NSNumber *tmp = self.astralEnergy;
      self.astralEnergy = [NSNumber numberWithInteger: [result integerValue] + [tmp integerValue]];
      self.currentAstralEnergy = [NSNumber numberWithInteger: [result integerValue] + [tmp integerValue]];
      [resultDict setObject: result forKey: @"deltaAstralEnergy"];
    }

  if ([self isBlessedOne])
    {        
      NSLog(@"leveling up Karma not yet implemented!!!");
      [resultDict setObject: result forKey: @"deltaKarmaPoints"];
    }
  return resultDict;
}

- (BOOL) levelUpPositiveTrait: (NSString *) trait
{
  BOOL result = [(DSAPositiveTrait *)[self.positiveTraits objectForKey: trait] levelUp];
  return result;
}

- (BOOL) levelDownNegativeTrait: (NSString *) trait
{
  BOOL result = [(DSANegativeTrait *)[self.negativeTraits objectForKey: trait] levelDown];
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

  if ([tmpTalent.maxUpPerLevel integerValue] == 0)
    {
      NSLog(@"DSACharacterHero: levelUpTalent: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
  
  self.maxLevelUpTalentsTriesTmp = [NSNumber numberWithInteger: [self.maxLevelUpTalentsTriesTmp integerValue] - [[talent levelUpCost] integerValue]];

  result = [targetTalent levelUp];
  if (result)
    {
      tmpTalent.maxUpPerLevel = [NSNumber numberWithInteger: [tmpTalent.maxUpPerLevel integerValue] - 1];
      tmpTalent.maxTriesPerLevelUp = [NSNumber numberWithInteger: [tmpTalent.maxUpPerLevel integerValue] * 3];
      tmpTalent.level = targetTalent.level;
    }
  else
    {
      tmpTalent.maxTriesPerLevelUp = [NSNumber numberWithInteger: [tmpTalent.maxTriesPerLevelUp integerValue] - 1];
      if ([tmpTalent.maxTriesPerLevelUp integerValue] % 3 == 0)
        {
          tmpTalent.maxUpPerLevel = [NSNumber numberWithInteger: [tmpTalent.maxUpPerLevel integerValue] - 1];
        }
    }
  return result;
}

- (BOOL) canLevelUpTalent: (DSATalent *) talent
{
  if ([talent.level integerValue] == 18)
    {
      // we're already at the general maximum
      return NO;
    }
//  if ([talent isMemberOfClass: [DSASpell class]]) // special case magical dabbler
//    {
      if ([self.maxLevelUpTalentsTriesTmp integerValue] < [[talent levelUpCost] integerValue])  // spells cost
        {
          return NO;
        }
//    }
  NSLog(@"DSACharacterHero: canLevelUpTalent: testing %@ %@", [talent name], [[self.levelUpTalents objectForKey: [talent name]] maxUpPerLevel]);
  
  // below test shouldn't really be necessary, because of just last test above, just return YES!!!
  if ([[[self.levelUpTalents objectForKey: [talent name]] maxUpPerLevel] integerValue] <= 0) // actually should never be < 0
    {
      return NO;
    }
  else
    {
      return YES;
    }
}

- (BOOL) canLevelUp {
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
  [coder encodeObject:self.spells forKey:@"spells"];
  [coder encodeObject:self.specials forKey:@"specials"];    
  [coder encodeObject:self.professions forKey:@"professions"];  
  [coder encodeObject:self.levelUpTalents forKey:@"levelUpTalents"];
  [coder encodeObject:self.levelUpSpells forKey:@"levelUpSpells"];  
  [coder encodeObject:self.levelUpProfessions forKey:@"levelUpProfessions"];
  [coder encodeObject:self.firstLevelUpTalentTriesPenalty forKey:@"firstLevelUpTalentTriesPenalty"];  
  [coder encodeObject:self.maxLevelUpTalentsTries forKey:@"maxLevelUpTalentsTries"];
  [coder encodeObject:self.maxLevelUpSpellsTries forKey:@"maxLevelUpSpellsTries"];
  [coder encodeObject:self.maxLevelUpTalentsTriesTmp forKey:@"maxLevelUpTalentsTriesTmp"];
  [coder encodeObject:self.maxLevelUpSpellsTriesTmp forKey:@"maxLevelUpSpellsTriesTmp"];  
  [coder encodeObject:self.maxLevelUpVariableTries forKey:@"maxLevelUpVariableTries"];
  [coder encodeObject:self.tempDeltaLpAe forKey:@"tempDeltaLpAe"];
  [coder encodeBool:self.isLevelingUp forKey:@"isLevelingUp"];
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
      self.spells = [coder decodeObjectOfClass:[NSString class] forKey:@"spells"];
      self.specials = [coder decodeObjectOfClass:[NSString class] forKey:@"specials"];           
      self.professions = [coder decodeObjectOfClass:[NSString class] forKey:@"professions"];      
      self.levelUpTalents = [coder decodeObjectOfClass:[NSString class] forKey:@"levelUpTalents"];
      self.levelUpSpells = [coder decodeObjectOfClass:[NSString class] forKey:@"levelUpSpells"];      
      self.levelUpProfessions = [coder decodeObjectOfClass:[NSString class] forKey:@"levelUpProfessions"];
      self.firstLevelUpTalentTriesPenalty = [coder decodeObjectOfClass:[NSString class] forKey:@"firstLevelUpTalentTriesPenalty"];            
      self.maxLevelUpTalentsTries = [coder decodeObjectOfClass:[NSString class] forKey:@"maxLevelUpTalentsTries"];
      self.maxLevelUpSpellsTries = [coder decodeObjectOfClass:[NSString class] forKey:@"maxLevelUpSpellsTries"];
      self.maxLevelUpTalentsTriesTmp = [coder decodeObjectOfClass:[NSString class] forKey:@"maxLevelUpTalentsTriesTmp"];
      self.maxLevelUpSpellsTriesTmp = [coder decodeObjectOfClass:[NSString class] forKey:@"maxLevelUpSpellsTriesTmp"];      
      self.maxLevelUpVariableTries = [coder decodeObjectOfClass:[NSString class] forKey:@"maxLevelUpVariableTries"];
      self.tempDeltaLpAe = [coder decodeObjectOfClass:[NSString class] forKey:@"tempDeltaLpAe"];
      self.isLevelingUp = [coder decodeBoolForKey:@"isLevelingUp"];     
    }  
  return self;
}



/* Calculate Endurance, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
- (NSNumber *) endurance {
  NSInteger retVal;

  retVal = [[self lifePoints] integerValue] + [[self.positiveTraits valueForKeyPath: @"KK.level"] integerValue];  
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
  NSLog(@"DSACharacterHero: Calculation for encumbrance missing!!!");
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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
  NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
  
  NSLog(@"DSACharacterHero keyPathsForValuesAffectingValueForKey: %@", key);
  
  if ([key isEqualToString:@"endurance"])
    {
      keyPaths = [NSSet setWithObjects:@"lifePoints", @"positiveTraits.KK.level", nil];
    }
  else if ([key isEqualToString:@"carryingCapacity"])
    {
      keyPaths = [NSSet setWithObject:@"positiveTraits.KK.level"];
    }
  else if ([key isEqualToString:@"attackBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"positiveTraits.MU.level", 
                                         @"positiveTraits.GE.level", 
                                         @"positiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"parryBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"positiveTraits.IN.level", 
                                         @"positiveTraits.GE.level", 
                                         @"positiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"rangedCombatBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"positiveTraits.IN.level", 
                                         @"positiveTraits.FF.level", 
                                         @"positiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"dodge"])
    {
        keyPaths = [NSSet setWithObjects:@"positiveTraits.MU.level", 
                                         @"positiveTraits.IN.level", 
                                         @"positiveTraits.GE.level", nil];        
    }
  else if ([key isEqualToString:@"magicResistance"])
    {
        keyPaths = [NSSet setWithObjects:@"positiveTraits.MU.level", 
                                         @"positiveTraits.KL.level",
                                         @"negativeTraits.AG.level",
                                         @"mrBonus",
                                         @"level", nil];        
    }                 
  return keyPaths;
}
@end
