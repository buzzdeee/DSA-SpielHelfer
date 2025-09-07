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