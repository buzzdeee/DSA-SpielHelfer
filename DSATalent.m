/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 20:41:26 +0200 by sebastia

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

#import "DSATalent.h"
#import "Utils.h"
#import "NSMutableDictionary+Extras.h"

@implementation DSATalent
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.isPersonalTalent = NO;
    }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self)
      {
        self.name = [coder decodeObjectForKey:@"name"];
        self.level = [coder decodeIntegerForKey:@"level"];
        self.targetType = [coder decodeIntegerForKey:@"targetType"];
        self.maxTriesPerLevelUp = [coder decodeIntegerForKey:@"maxTriesPerLevelUp"];
        self.maxUpPerLevel = [coder decodeIntegerForKey:@"maxUpPerLevel"];
        self.levelUpCost = [coder decodeIntegerForKey:@"levelUpCost"];        
        self.talentDescription = [coder decodeObjectForKey:@"talentDescription"];
        self.category = [coder decodeObjectForKey:@"category"];
        self.isPersonalTalent = [coder decodeBoolForKey:@"isPersonalTalent"];
        self.test = [coder decodeObjectForKey:@"test"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeInteger:self.targetType forKey:@"targetType"];
  [coder encodeInteger:self.maxTriesPerLevelUp forKey:@"maxTriesPerLevelUp"];
  [coder encodeInteger:self.maxUpPerLevel forKey:@"maxUpPerLevel"];
  [coder encodeInteger:self.levelUpCost forKey:@"levelUpCost"];  
  [coder encodeObject:self.talentDescription forKey:@"talentDescription"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeBool:self.isPersonalTalent forKey:@"isPersonalTalent"]; 
  [coder encodeObject:self.test forKey:@"test"];     
}

- (BOOL) levelUp
{
  NSInteger result = 0;
  
  if (self.level < 10  && ! self.isPersonalTalent)
    {
      result = [Utils rollDice:@"2W6"];
    }
  else
    {
      result = [Utils rollDice:@"3W6"];
    }
  if (result > self.level)
    {
      self.level += 1;
      return YES;
    }
  else
    {
      return NO;
    }
}
@end
// End of DSATalent

@implementation DSAFightingTalent
@synthesize subCategory;
- (instancetype)initTalent: (NSString *) name
             inSubCategory: (NSString *) newSubCategory
                ofCategory: (NSString *) category
                   onLevel: (NSInteger) level
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel
           withLevelUpCost: (NSInteger) levelUpCost;
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.subCategory = newSubCategory;      
      self.level = level;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;
    }
  //NSLog(@"DSAFightingTalent: initTalent ... self: %@", self);
  return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.subCategory = [coder decodeObjectForKey:@"subCategory"];
      }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.subCategory forKey:@"subCategory"];  
}
@end
// End of DSAFightingTalent

@implementation DSAOtherTalent
- (instancetype)initTalent: (NSString *) name
                ofCategory: (NSString *) category 
                   onLevel: (NSInteger) level
                  withTest: (NSArray *) test
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel 
           withLevelUpCost: (NSInteger) levelUpCost;                          
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.test = test;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;      
      self.levelUpCost = levelUpCost;            
    }
  return self;
}
@end
// End of DSAOtherTalent

@implementation DSAProfession
- (instancetype)initProfession: (NSString *) name
                    ofCategory: (NSString *) category
                       onLevel: (NSInteger) level
                      withTest: (NSArray *) test
        withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
             withMaxUpPerLevel: (NSInteger) maxUpPerLevel
             influencesTalents: (NSMutableDictionary *)talents
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.test = test;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.influencesTalents = talents;     
    }
  return self;
}                       

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.influencesTalents = [coder decodeObjectForKey:@"influencesTalents"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.influencesTalents forKey:@"influencesTalents"];  
}
@end
// End of DSAProfession

@implementation DSASpecialTalent
- (instancetype)initTalent: (NSString *) name
                ofCategory: (NSString *) category 
                   onLevel: (NSInteger) level
                  withTest: (NSArray *) test
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel 
           withLevelUpCost: (NSInteger) levelUpCost;                          
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.test = test;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;      
      self.levelUpCost = levelUpCost;            
    }
  return self;
}
@end
// End of DSASpecialTalent

@implementation DSATalentResult
-(instancetype)init
{
  self = [super init];
  if (self)
    {
      _result = DSAActionResultNone;
      _diceResults = [[NSMutableArray alloc] init];
      _remainingTalentPoints = 0;
    }
  return self;
}

+(NSString *) resultNameForResultValue: (DSAActionResultValue) value
{
  NSArray *resultStrings = @[ _(@"Ohne Ergebnis"), _(@"Erfolg"), _(@"Automatischer Erfolg"),
                              _(@"Epischer Erfolg!"), _(@"Mißerfolg"), _(@"Automatischer Mißerfolg"),
                              _(@"Epischer Mißerfolg!") ];
  return resultStrings[value];
}
@end
// End of DSATalentResult

@implementation DSATalentManager
static DSATalentManager *sharedInstance = nil;
+ (instancetype)sharedManager {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(instancetype) init
{
  self = [super init];
  if (self)
    {
      _talentsByCategory = nil;
      
      NSError *e = nil;
      NSString *filePath;
      filePath = [[NSBundle mainBundle] pathForResource:@"Talente" ofType:@"json"];
      _talentsByCategory = [NSJSONSerialization JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                                                           options: NSJSONReadingMutableContainers
                                                             error: &e];
      if (e)
        {
           NSLog(@"DSAObjectManager init: Error loading JSON: %@", e.localizedDescription);
        }
    }
  return self;
}

- (NSDictionary *) getTalentsDict
{
  return _talentsByCategory;
}

// returns a dictionary of talents for the requested archetype
- (NSDictionary *) getTalentsDictForCharacter: (DSACharacter *)character
{
  NSString *archetype = character.archetype;
  NSMutableDictionary *talents = [[NSMutableDictionary alloc] init];
  NSString *typus;
  if ([archetype isEqualToString: _(@"Schamane")])  // We're special here, use the origins of Moha or Nivese, then apply offsets :(
    {
      typus = character.origin;
    }
  else if ([archetype isEqualToString: _(@"Steppenelf")])  // Only exists as NPC, but closely related to Auelf
    {
      typus = @"Auelf";
    }
  else if ([character isKindOfClass: [DSACharacterNpc class]])  // all other NPCs for now
    {
      typus = @"Other NPC";
    }
  else
    {
      typus = archetype;
    }
  
  NSArray *categories = [NSArray arrayWithArray: [_talentsByCategory allKeys]];
  for (NSString *category in categories)
    {
      if ([@"Kampftechniken" isEqualTo: category])
        {
          NSString *steigern = [NSString stringWithFormat: @"%@", [[_talentsByCategory objectForKey: category] objectForKey: @"Steigern"]];
          NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3];
         
          for (NSString *key in [_talentsByCategory objectForKey: category])
            {
              NSString *weapontype;
              NSString *startwert;
              if ([@"Steigern" isEqualTo: key])
                {
                  continue;
                }
              else
                {
                  weapontype = [NSString stringWithFormat: @"%@", [[[_talentsByCategory objectForKey: category] objectForKey: key] objectForKey: @"Waffentyp"]];
                  startwert = [NSString stringWithFormat: @"%@", [[[[_talentsByCategory objectForKey: category] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: typus]];
                }
                [talents setValue: @{@"Startwert": startwert, @"Steigern": steigern, @"Versuche": versuche} 
                  forKeyHierarchy: @[category, weapontype, key]];
            } 
        }
      else
        {
          NSString *steigern = [NSString stringWithFormat: @"%@", [[_talentsByCategory objectForKey: category] objectForKey: @"Steigern"]];
          NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3]; 
          for (NSString *key in [_talentsByCategory objectForKey: category])
            {
              NSArray *probe;
              NSString *startwert;
              if ([@"Steigern" isEqualTo: key])
                {
                  continue;
                }
              else
                {
                  probe = [NSArray arrayWithArray: [[[_talentsByCategory objectForKey: category] objectForKey: key] objectForKey: @"Probe"]];
                  startwert = [NSString stringWithFormat: @"%@", [[[[_talentsByCategory objectForKey: category] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: typus]];
                }
                [talents setValue: @{@"Startwert": startwert, @"Probe": probe, @"Steigern": steigern, @"Versuche": versuche} forKeyHierarchy: @[category, key]];
            }       
        }
    }
  return talents;
}

- (NSMutableDictionary <NSString *, DSATalent*>*)getTalentsForCharacter: (DSACharacter *)character
{
  // handle talents
  NSDictionary *talents = [[NSDictionary alloc] init];
  talents = [self getTalentsDictForCharacter: character];
  NSMutableDictionary *newTalents = [[NSMutableDictionary alloc] init];
  for (NSString *category in talents)
    {
      if ([category isEqualTo: @"Kampftechniken"])
        {   
          for (NSString *subCategory in [talents objectForKey: category])
            {
              for (NSString *t in [[talents objectForKey: category] objectForKey: subCategory])
                {
                   // NSLog(@"dealing with talent in if clause for loop: %@", t);
                   NSDictionary *tDict = [[[talents objectForKey: category] objectForKey: subCategory] objectForKey: t];
                   DSAFightingTalent *talent = [[DSAFightingTalent alloc] initTalent: t
                                                                       inSubCategory: subCategory
                                                                          ofCategory: category
                                                                             onLevel: [[tDict objectForKey: @"Startwert"] integerValue]
                                                              withMaxTriesPerLevelUp: [[tDict objectForKey: @"Versuche"] integerValue]
                                                                   withMaxUpPerLevel: [[tDict objectForKey: @"Steigern"] integerValue]
                                                                     withLevelUpCost: 1];
                  // NSLog(@"DSACharacterGenerationController: initialized talent: %@", talent);                                                                     
                  [newTalents setObject: talent forKey: t];
                }
            }
        }
      else
        {
          for (NSString *t in [talents objectForKey: category])
            {
              //NSLog(@"dealing with talent in else clause for loop: %@", t);
              NSDictionary *tDict = [[talents objectForKey: category] objectForKey: t];                             
              DSAOtherTalent *talent = [[DSAOtherTalent alloc] initTalent: t
                                                               ofCategory: category
                                                                  onLevel: [[tDict objectForKey: @"Startwert"] integerValue]
                                                                 withTest: [tDict objectForKey: @"Probe"]
                                                   withMaxTriesPerLevelUp: [[tDict objectForKey: @"Versuche"] integerValue]
                                                        withMaxUpPerLevel: [[tDict objectForKey: @"Steigern"] integerValue]
                                                          withLevelUpCost: 1];
              //NSLog(@"DSACharacterGenerationController: initialized talent: %@", talent);
              [newTalents setObject: talent forKey: t];
            }
        }        
    }
  //NSLog(@"THE NEW TALENTS: newTalents %@", newTalents);
  return newTalents;
}

- (NSMutableDictionary <NSString *, DSASpecialTalent*>*)getMagicalDabblerTalentsByTalentsNameArray: (NSArray *) specialTalentNames
{
  NSMutableDictionary *specialTalents = [[NSMutableDictionary alloc] init];        
  for (NSString *specialTalentName in specialTalentNames)
    {
        NSLog(@"Checking specialTalentName: %@", specialTalentName);
        DSASpecialTalent *talent = [[DSASpecialTalent alloc] initTalent: specialTalentName
                                                             ofCategory: _(@"Spezialtalent")
                                                                onLevel: 0
                                                               withTest: nil
                                                 withMaxTriesPerLevelUp: 0
                                                      withMaxUpPerLevel: 0
                                                        withLevelUpCost: 0];
        if ([specialTalentName isEqualToString: _(@"Magisches Meisterhandwerk")])                                             
          {
            [talent setTest: @[ @"IN"] ];
          }
        NSLog(@"created Talent: %@", talent);
        [specialTalents setObject: talent forKey: specialTalentName];
    }
  return specialTalents;
}

@end
// end of DSATalentManager