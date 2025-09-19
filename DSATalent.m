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
#import "DSAActionResult.h"
#import "DSATrait.h"
#import "Utils.h"
#import "NSMutableDictionary+Extras.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"
#import "DSALocations.h"
#import "DSAExecutionManager.h"

@implementation DSATalent

static NSDictionary<NSString *, Class> *typeToClassMap = nil;

+ (void)initialize
{
  if (self == [DSATalent class])
    {
      @synchronized(self)
        {
          if (!typeToClassMap)
            {
              typeToClassMap = @{

                _(@"Boxen"): [DSAFightingTalent class],
                _(@"Dolche"): [DSAFightingTalent class],
                _(@"Hruruzat"): [DSAFightingTalent class],
                _(@"Infanteriewaffen"): [DSAFightingTalent class],
                _(@"Kettenwaffen"): [DSAFightingTalent class],
                _(@"Lanzenreiten"): [DSAFightingTalent class],
                _(@"Linkshändig"): [DSAFightingTalent class],
                _(@"Peitsche"): [DSAFightingTalent class],
                _(@"Raufen"): [DSAFightingTalent class],
                _(@"Ringen"): [DSAFightingTalent class],
                _(@"Scharfe Hiebwaffen"): [DSAFightingTalent class],
                _(@"Schleuder"): [DSAFightingTalent class],
                _(@"Schußwaffen"): [DSAFightingTalent class],
                _(@"Schwerter"): [DSAFightingTalent class],
                _(@"Speere und Stäbe"): [DSAFightingTalent class],
                _(@"Stichwaffen"): [DSAFightingTalent class],
                _(@"Stumpfe Hiebwaffen"): [DSAFightingTalent class],
                _(@"Wurfwaffen"): [DSAFightingTalent class],
                _(@"Zweihänder"): [DSAFightingTalent class],
                _(@"Äxte und Beile"): [DSAFightingTalent class],

                _(@"Abrichten"): [DSAGeneralTalent class],
                _(@"Akrobatik"): [DSAGeneralTalent class],
                _(@"Alchimie"): [DSAGeneralTalent class],
                _(@"Alte Sprachen"): [DSAGeneralTalent class],
                _(@"Bekehren/Überzeugen"): [DSAGeneralTalent class],
                _(@"Betören"): [DSAGeneralTalent class],
                _(@"Boote Fahren"): [DSAGeneralTalent class],
                _(@"Etikette"): [DSAGeneralTalent class],
                _(@"Fahrzeug Lenken"): [DSAGeneralTalent class],
                _(@"Fallenstellen"): [DSAGeneralTalent class],
                _(@"Falschspiel"): [DSAGeneralTalentFalschspiel class],
                _(@"Feilschen"): [DSAGeneralTalent class],
                _(@"Fesseln/Entfesseln"): [DSAGeneralTalent class],
                _(@"Fischen/Angeln"): [DSAGeneralTalent class],
                _(@"Fliegen"): [DSAGeneralTalent class],
                _(@"Fährtensuchen"): [DSAGeneralTalent class],
                _(@"Gassenwissen"): [DSAGeneralTalent class],
                _(@"Gaukeleien"): [DSAGeneralTalent class],
                _(@"Gefahreninstinkt"): [DSAGeneralTalent class],
                _(@"Geographie"): [DSAGeneralTalent class],
                _(@"Geschichtswissen"): [DSAGeneralTalent class],
                _(@"Glücksspiel"): [DSAGeneralTalent class],
                _(@"Götter und Kulte"): [DSAGeneralTalent class],
                _(@"Heilkunde Gift"): [DSAGeneralTalent class],
                _(@"Heilkunde Krankheiten"): [DSAGeneralTalent class],
                _(@"Heilkunde Seele"): [DSAGeneralTalent class],
                _(@"Heilkunde Wunden"): [DSAGeneralTalent class],
                _(@"Holzbearbeitung"): [DSAGeneralTalent class],
                _(@"Klettern"): [DSAGeneralTalent class],
                _(@"Kochen"): [DSAGeneralTalent class],
                _(@"Kriegskunst"): [DSAGeneralTalent class],
                _(@"Körperbeherrschung"): [DSAGeneralTalent class],
                _(@"Lederarbeiten"): [DSAGeneralTalent class],
                _(@"Lehren"): [DSAGeneralTalent class],
                _(@"Lesen/Schreiben"): [DSAGeneralTalent class],
                _(@"Lügen"): [DSAGeneralTalent class],
                _(@"Magiekunde"): [DSAGeneralTalent class],
                _(@"Malen/Zeichnen"): [DSAGeneralTalent class],
                _(@"Mechanik"): [DSAGeneralTalent class],
                _(@"Menschenkenntnis"): [DSAGeneralTalent class],
                _(@"Musizieren"): [DSAGeneralTalent class],
                _(@"Orientierung"): [DSAGeneralTalent class],
                _(@"Pflanzenkunde"): [DSAGeneralTalent class],
                _(@"Prophezeien"): [DSAGeneralTalent class],
                _(@"Rechnen"): [DSAGeneralTalent class],
                _(@"Rechtskunde"): [DSAGeneralTalent class],
                _(@"Reiten"): [DSAGeneralTalent class],
                _(@"Schleichen"): [DSAGeneralTalent class],
                _(@"Schlösser Knacken"): [DSAGeneralTalent class],
                _(@"Schneidern"): [DSAGeneralTalent class],
                _(@"Schwimmen"): [DSAGeneralTalent class],
                _(@"Schätzen"): [DSAGeneralTalent class],
                _(@"Selbstbeherrschung"): [DSAGeneralTalent class],
                _(@"Sich Verkleiden"): [DSAGeneralTalent class],
                _(@"Sich Verstecken"): [DSAGeneralTalent class],
                _(@"Singen"): [DSAGeneralTalent class],
                _(@"Sinnenschärfe"): [DSAGeneralTalent class],
                _(@"Sprachen Kennen"): [DSAGeneralTalent class],
                _(@"Staatskunst"): [DSAGeneralTalent class],
                _(@"Sternkunde"): [DSAGeneralTalent class],
                _(@"Stimmen Imitieren"): [DSAGeneralTalent class],
                _(@"Tanzen"): [DSAGeneralTalent class],
                _(@"Taschendiebstahl"): [DSAGeneralTalentTaschendiebstahl class],
                _(@"Tierkunde"): [DSAGeneralTalent class],
                _(@"Töpfern"): [DSAGeneralTalent class],
                _(@"Wettervorhersage"): [DSAGeneralTalent class],
                _(@"Wildnisleben"): [DSAGeneralTalent class],
                _(@"Zechen"): [DSAGeneralTalent class],

                _(@"Anatom"): [DSAProfession class],
                _(@"Apothekarius"): [DSAProfession class],
                _(@"Armbruster"): [DSAProfession class],
                _(@"Bauer"): [DSAProfession class],
                _(@"Baumeister"): [DSAProfession class],
                _(@"Bergmann"): [DSAProfession class],
                _(@"Bettler"): [DSAProfession class],
                _(@"Bilderstecher"): [DSAProfession class],
                _(@"Bogenbauer"): [DSAProfession class],
                _(@"Brauer"): [DSAProfession class],
                _(@"Brenner"): [DSAProfession class],
                _(@"Brettspiel"): [DSAProfession class],
                _(@"Brotbäcker"): [DSAProfession class],
                _(@"Drachenjäger"): [DSAProfession class],
                _(@"Falkner"): [DSAProfession class],
                _(@"Feinmechanikus"): [DSAProfession class],
                _(@"Fischer"): [DSAProfession class],
                _(@"Fleischer"): [DSAProfession class],
                _(@"Fuhrmann"): [DSAProfession class],
                _(@"Färber"): [DSAProfession class],
                _(@"Geldwechsler"): [DSAProfession class],
                _(@"Gerber"): [DSAProfession class],
                _(@"Gesellschafter"): [DSAProfession class],
                _(@"Gesteinskundiger"): [DSAProfession class],
                _(@"Glasbläser"): [DSAProfession class],
                _(@"Goldschmied"): [DSAProfession class],
                _(@"Graveur"): [DSAProfession class],
                _(@"Grobschmied"): [DSAProfession class],
                _(@"Harnischmacher"): [DSAProfession class],
                _(@"Hausdiener"): [DSAProfession class],
                _(@"Hebamme"): [DSAProfession class],
                _(@"Heraldiker"): [DSAProfession class],
                _(@"Holzfäller"): [DSAProfession class],
                _(@"Händler"): [DSAProfession class],
                _(@"Hüttenkundiger"): [DSAProfession class],
                _(@"Instrumentenbauer"): [DSAProfession class],
                _(@"Kartograph"): [DSAProfession class],
                _(@"Kristallzüchter"): [DSAProfession class],
                _(@"Krämer"): [DSAProfession class],
                _(@"Kurtisane"): [DSAProfession class],
                _(@"Kürschner"): [DSAProfession class],
                _(@"Maurer"): [DSAProfession class],
                _(@"Müller"): [DSAProfession class],
                _(@"Pferdezüchter"): [DSAProfession class],
                _(@"Plättner"): [DSAProfession class],
                _(@"Prospektor"): [DSAProfession class],
                _(@"Richtschütze"): [DSAProfession class],
                _(@"Rinderhirte"): [DSAProfession class],
                _(@"Sattler"): [DSAProfession class],
                _(@"Schiffsbauer"): [DSAProfession class],
                _(@"Schiffszimmermann"): [DSAProfession class],
                _(@"Schlosser"): [DSAProfession class],
                _(@"Schneider"): [DSAProfession class],
                _(@"Schreiber"): [DSAProfession class],
                _(@"Schuster"): [DSAProfession class],
                _(@"Schäfer"): [DSAProfession class],
                _(@"Seefahrer"): [DSAProfession class],
                _(@"Seiler"): [DSAProfession class],
                _(@"Spengler"): [DSAProfession class],
                _(@"Steinmetz"): [DSAProfession class],
                _(@"Stellmacher"): [DSAProfession class],
                _(@"Tischler"): [DSAProfession class],
                _(@"Tätowierer"): [DSAProfession class],
                _(@"Töpfer"): [DSAProfession class],
                _(@"Uhrmacher"): [DSAProfession class],
                _(@"Waffenschmied"): [DSAProfession class],
                _(@"Wagner"): [DSAProfession class],
                _(@"Weber"): [DSAProfession class],
                _(@"Winzer"): [DSAProfession class],
                _(@"Wirt"): [DSAProfession class],
                _(@"Zimmermann"): [DSAProfession class],
                _(@"Zuckerbäcker"): [DSAProfession class],
                _(@"Zureiter"): [DSAProfession class],
                
                _(@"Schutzgeist"): [DSASpecialTalent class],
                _(@"Magisches Meisterhandwerk"): [DSASpecialTalent class],
              };
            }
        }
    }
}

+ (instancetype)talentWithName: (NSString *) talentName
                  forCharacter: (DSACharacter *) character
{
  Class subclass = [typeToClassMap objectForKey: talentName];
  NSLog(@"DSATalent talentWithName: %@ called, got subclass: %@", talentName, [subclass class]);
  if (subclass)
    {
      if ([subclass isSubclassOfClass: [DSAProfession class]])
        {
          NSLog(@"DSATalent: talentWithName: %@ going to call initTalent for a profession", talentName);
          NSDictionary *professionDict = [[[DSATalentManager sharedManager] getProfessionsDict] 
                                                     objectForKey: talentName];
          return [[subclass alloc] initTalent: talentName
                                inSubCategory: nil
                                   ofCategory: [professionDict objectForKey: @"Freizeittalent"] ? : @"Beruf"
                                      onLevel: 3
                                     withTest: [professionDict objectForKey: @"Probe"]
                       withMaxTriesPerLevelUp: 6
                            withMaxUpPerLevel: 2
                              withLevelUpCost: 0
                       influencesOtherTalents: [professionDict objectForKey: @"Bonus"]];
       }
     else if ([subclass isSubclassOfClass: [DSAFightingTalent class]])
       {
          NSLog(@"DSATalent: talentWithName: %@ going to call initTalent for a fighting talent", talentName);
          NSDictionary *talentDict = [[[DSATalentManager sharedManager] 
                      getTalentsDictForCharacter: character] 
                                             objectForKey: talentName];
          //NSLog(@"DSATalent: talentWithName: going to call initTalent for a fighting talent from dict: %@", [[DSATalentManager sharedManager] getTalentsDictForCharacter: character]);                                             
          return [[subclass alloc] initTalent: talentName
                                inSubCategory: [talentDict objectForKey: @"subCategory"]
                                   ofCategory: [talentDict objectForKey: @"category"]
                                      onLevel: [[talentDict objectForKey: @"Startwert"] integerValue]
                                     withTest: [talentDict objectForKey: @"Probe"]
                       withMaxTriesPerLevelUp: [[talentDict objectForKey: @"Versuche"] integerValue]
                            withMaxUpPerLevel: [[talentDict objectForKey: @"Steigern"] integerValue]
                              withLevelUpCost: 1
                       influencesOtherTalents: nil];
       }
     else if ([subclass isSubclassOfClass: [DSASpecialTalent class]])
       {
          NSLog(@"DSATalent: talentWithName: %@ going to call initTalent for a special talent", talentName);
          return [[subclass alloc] initTalent: talentName
                                inSubCategory: nil
                                   ofCategory: @"Spezialtalent"
                                      onLevel: 0
                                     withTest: [talentName isEqualToString: @"Magisches Meisterhandwerk"] ? @ [ @"IN" ] : nil
                       withMaxTriesPerLevelUp: 0
                            withMaxUpPerLevel: 0
                              withLevelUpCost: 0
                       influencesOtherTalents: nil];
       }
     else if ([subclass isSubclassOfClass: [DSAGeneralTalent class]])
       {
          NSLog(@"DSATalent: talentWithName: %@ going to call initTalent for a general talent", talentName);
          NSDictionary *talentDict = [[[DSATalentManager sharedManager] 
                      getTalentsDictForCharacter: character] 
                                             objectForKey: talentName];
          //NSLog(@"DSATalent: talentWithName: going to call initTalent for a fighting talent from dict: %@", talentDict);                                             
          return [[subclass alloc] initTalent: talentName
                                inSubCategory: nil
                                   ofCategory: [talentDict objectForKey: @"category"]
                                      onLevel: [[talentDict objectForKey: @"Startwert"] integerValue]
                                     withTest: [talentDict objectForKey: @"Probe"]
                       withMaxTriesPerLevelUp: [[talentDict objectForKey: @"Versuche"] integerValue]
                            withMaxUpPerLevel: [[talentDict objectForKey: @"Steigern"] integerValue]
                              withLevelUpCost: 1
                       influencesOtherTalents: nil];    
       }       
     else
       {
         NSLog(@"DSATalent talentWithName: unknown main talent class: %@  for talent: %@ aborting", [subclass class], talentName);
         abort();
       }
    }
  // handle unknown type
  NSLog(@"DSASpell: talentWithName: %@ not found returning NIL", talentName);
  return nil;
}

+ (instancetype)talentWithName: (NSString *) name
                 inSubCategory: (nullable NSString *) subCategory
                    ofCategory: (NSString *) category
                       onLevel: (NSInteger) level
                      withTest: (nullable NSArray *) test
        withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
             withMaxUpPerLevel: (NSInteger) maxUpPerLevel
               withLevelUpCost: (NSInteger) levelUpCost
        influencesOtherTalents: (nullable NSMutableDictionary *)otherInfluencedTalents
{
  Class subclass = [typeToClassMap objectForKey: name];
  if (subclass)
    {
      NSLog(@"DSATalent: talentWithName: %@ going to call initTalent...", name);
      return [[subclass alloc] initTalent: name
                            inSubCategory: subCategory
                               ofCategory: category
                                  onLevel: level
                                 withTest: test
                   withMaxTriesPerLevelUp: maxTriesPerLevelUp
                        withMaxUpPerLevel: maxUpPerLevel
                          withLevelUpCost: levelUpCost
                   influencesOtherTalents: otherInfluencedTalents];
    }
  // handle unknown type
  NSLog(@"DSATalent: talentWithName: %@ not found returning NIL", name);
  return nil;
}   

- (instancetype)initTalent: (NSString *) name
             inSubCategory: (nullable NSString *) subCategory
                ofCategory: (NSString *) category
                   onLevel: (NSInteger) level
                  withTest: (nullable NSArray *) test
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel
           withLevelUpCost: (NSInteger) levelUpCost
    influencesOtherTalents: (nullable NSMutableDictionary *)otherInfluencedTalents
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.subCategory = subCategory;
      self.category = category;
      self.level = level;
      self.test = test;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;
      self.influencesTalents = otherInfluencedTalents;
      self.isPersonalTalent = NO;      
    }
  return self;
}    

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
        self.subCategory = [coder decodeObjectForKey:@"subCategory"];
        self.category = [coder decodeObjectForKey:@"category"];
        self.level = [coder decodeIntegerForKey:@"level"];
        self.test = [coder decodeObjectForKey:@"test"];
        
        self.maxTriesPerLevelUp = [coder decodeIntegerForKey:@"maxTriesPerLevelUp"];
        self.maxUpPerLevel = [coder decodeIntegerForKey:@"maxUpPerLevel"];
        self.levelUpCost = [coder decodeIntegerForKey:@"levelUpCost"];        
        
        self.isPersonalTalent = [coder decodeBoolForKey:@"isPersonalTalent"];
        
        self.influencesTalents = [coder decodeObjectForKey:@"influencesTalents"];
        self.targetType = [coder decodeIntegerForKey:@"targetType"];
        self.talentDescription = [coder decodeObjectForKey:@"talentDescription"];
        
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.subCategory forKey:@"subCategory"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeObject:self.test forKey:@"test"];
  
  [coder encodeInteger:self.maxTriesPerLevelUp forKey:@"maxTriesPerLevelUp"];
  [coder encodeInteger:self.maxUpPerLevel forKey:@"maxUpPerLevel"];
  [coder encodeInteger:self.levelUpCost forKey:@"levelUpCost"];  
  
  [coder encodeBool:self.isPersonalTalent forKey:@"isPersonalTalent"]; 
       
  [coder encodeObject:self.influencesTalents forKey:@"influencesTalents"];
  [coder encodeInteger:self.targetType forKey:@"targetType"];
  [coder encodeObject:self.talentDescription forKey:@"talentDescription"];
  
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

- (DSAActionResult *) useWithPenalty: (NSInteger) penalty
                         byCharacter: (DSACharacter *) character
{
  NSLog(@"DSATalent useWithPenalty called");
  DSAActionResult *talentResult = [[DSAActionResult alloc] init];
  NSInteger level = self.level - penalty;
  NSInteger initialLevel = level;
  NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] init];
  NSInteger oneCounter = 0;
  NSInteger twentyCounter = 0;
  BOOL earlyFailure = NO;
  NSInteger counter = 0;
  for (NSString *trait in self.test)
    {
      NSInteger traitLevel = [[character.positiveTraits objectForKey: trait] level];
      NSInteger result = [Utils rollDice: @"1W20"];
      [resultsDict setObject: @(result) forKey: trait];
              
      if (result == 1)
        {
          oneCounter += 1;
        }
      else if (result == 20)
        {
          twentyCounter += 1;
        }
      if (initialLevel >= 0)
        {
          NSLog(@"DSATalent useWithPenalty %@ initial Level > 0 current Level: %ld", trait, (signed long) level);
          if (result <= traitLevel)  // potential failure, but we may have enough talent
            {
              NSLog(@"result was <= traitLevel");
            }
          else
            {
              NSLog(@"DSATalent useWithPenalty result was > traitLevel");
              level = level - (result - traitLevel);
              if (level < 0)
                {
                  earlyFailure = YES;
                }                      
            }
        }
       else  // initialLevel < 0
        {
           NSLog(@"DSATalent useWithPenalty %@ initial Level < 0 current Level: %ld", trait, (signed long) level);
          if (result <= traitLevel)
            {
              NSLog(@"DSATalent useWithPenalty result was <= traitLevel");
              level = level + (traitLevel - result);
              if (level < 0 && counter == 2)
                {
                   NSLog(@"setting early failure becaue counter == 2");
                   earlyFailure = YES;
                }
            }
           else
            {
              NSLog(@"DSATalent useWithPenalty result was > traitLevel");
              earlyFailure = YES;
            }
        }
      counter += 1;        
    }
  if (oneCounter >= 2)
    {
      if (oneCounter == 2)
        {
           talentResult.result = DSAActionResultAutoSuccess;
           talentResult.remainingActionPoints = level;
        }
      else
        {
           talentResult.result = DSAActionResultEpicSuccess;
           talentResult.remainingActionPoints = level;
        }
    }
  else if (twentyCounter >= 2)
    {
      if (twentyCounter == 2)
        {
           talentResult.result = DSAActionResultAutoFailure;
           talentResult.remainingActionPoints = level;
        }
      else
       {
          talentResult.result = DSAActionResultEpicFailure;
          talentResult.remainingActionPoints = level;
       }              
    }
  else
    {
      if (earlyFailure == YES)
        {
           talentResult.result = DSAActionResultFailure;
           talentResult.remainingActionPoints = level;                                    
        }
      else
        {
           talentResult.result = DSAActionResultSuccess;
           talentResult.remainingActionPoints = level;                
        }
    }
  talentResult.diceResults = resultsDict;
  
  return talentResult;
}

- (DSAActionResult *) useOnTarget: (id) target
                      byCharacter: (DSACharacter *) character
                 currentAdventure: (DSAAdventure *) adventure
{
  NSLog(@"DSATalent useOnTarget: byCharacter: currentAdventure shall be implemented in the subclass: %@", [self class]);
  return nil;
}                 
@end
// End of DSATalent

@implementation DSAFightingTalent

@end
// End of DSAFightingTalent

@implementation DSAGeneralTalent
@end

@implementation DSAGeneralTalentFalschspiel
- (DSAActionResult *) useOnTarget: (id) target
                      byCharacter: (DSACharacter *) character
                 currentAdventure: (DSAAdventure *) adventure
{
  NSLog(@"DSAGeneralTalentFalschspiel useOnTarget: byCharacter: currentAdventure called");
  DSAAdventureGroup *activeGroup = adventure.activeGroup;
  DSAPosition *currentPosition = activeGroup.position;
  DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
  
  NSInteger penalty = 0;
  if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
    {
      DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
      DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
      if ([currentTile isKindOfClass: [DSALocalMapTileBuildingInn class]] &&
          [currentPosition.context isEqualToString: DSAActionContextTavern])
        {
          DSALocalMapTileBuildingInnFillLevel fillLevel = [(DSALocalMapTileBuildingInn*)currentTile tavernFillLevel];
          switch(fillLevel)
            {
              case DSALocalMapTileBuildingInnFillLevelEmpty: penalty = -1;
              case DSALocalMapTileBuildingInnFillLevelNormal: penalty = 0;
              case DSALocalMapTileBuildingInnFillLevelBusy: penalty = 1;              
              case DSALocalMapTileBuildingInnFillLevelPacked: penalty = 2;              
            }
        }
      else
        {
          NSLog(@"no special penalty/bonus ouside Inns for Taschendiebstahl defined yet!");
        }
    }
  else
    {
      NSLog(@"DSAGeneralTalentTaschendiebstahl useOnTarget: byCharacter: currentAdventure no penalty defined when used outside DSALocalMapLocation");
    }
  
  DSAActionResult *talentResult = [self useWithPenalty: penalty
                                           byCharacter: character];
                                           
  switch (talentResult.result) {
    case DSAActionResultNone: {
        NSLog(@"DSAGeneralTalentFalschspiel useOnTarget: ... DSAActionResultNone should never happen!");
        abort();
        break;
    }

    // ✅ normale + besondere Erfolge
    case DSAActionResultSuccess:
    case DSAActionResultAutoSuccess:
    case DSAActionResultEpicSuccess: {
        NSInteger bonus = 0;
        NSString *flavorFormat = nil;
        switch (talentResult.result) {
            case DSAActionResultSuccess:
                flavorFormat = @"Mit einem listigen Lächeln schiebst du die Würfel "
                               @"so, dass niemand Verdacht schöpft. "
                               @"Am Ende des Spiels wandern %ld Silber unauffällig in deine Tasche.";            
                bonus = 0; break;
            case DSAActionResultAutoSuccess:
                flavorFormat = @"Deine Fingerfertigkeit ist meisterhaft – die Karten tanzen beinahe von selbst. "
                               @"Die Gegner schwören, so ein Pech noch nie gehabt zu haben. "
                               @"Du streichst %ld Silber Gewinn ein.";            
                bonus = 10; break;
            case DSAActionResultEpicSuccess:
                flavorFormat = @"Ein epischer Coup! Mit einer perfekten Mischung aus Bluff, "
                               @"gezinkten Karten und unschuldigem Lächeln "
                               @"räumst du den ganzen Tisch leer. "
                               @"Lachend kassierst du %ld Silber ein.";            
                bonus = 50; break;
            default: break;
        }

        NSInteger silver = [Utils rollDice:@"1W6"] + bonus;
        talentResult.resultDescription = [NSString stringWithFormat: flavorFormat, (long)silver];

        // Beispiel: Folge-Action "Geld ins Inventar"
        DSAActionDescriptor *gain = [DSAActionDescriptor new];
        gain.type = DSAActionTypeGainMoney;
        gain.parameters = @{ @"amount": @(silver) };
        gain.order = 0;

        talentResult.followUps = @[gain];
        break;
    }

    // ❌ Fehlschläge
    case DSAActionResultFailure:
    case DSAActionResultAutoFailure:
    case DSAActionResultEpicFailure: {
        NSInteger days = 0;
        NSString *flavor = nil;
        switch (talentResult.result) {
            case DSAActionResultFailure:
                days = 7;
                flavor = @"Deine Tricks mit den Würfeln fliegen auf. "
                         @"Die Mitspieler werden misstrauisch und einer packt dich am Kragen. "
                         @"Du wirst unsanft aus der Runde geworfen – Hausverbot für eine Woche.";               
                 break;
            case DSAActionResultAutoFailure:
                days = 30;
                flavor = @"Du wirst beim Falschspiel eindeutig überführt. "
                         @"Die Gäste johlen, als die gezinkten Karten auf den Tisch fallen. "
                         @"Der Wirt wirft dich hochkant hinaus – ein Monat Hausverbot.";
                break;
            case DSAActionResultEpicFailure:
                days = NSIntegerMax;
                flavor = @"Episches Scheitern! "
                         @"Du versuchst, die Karten unter dem Tisch zu tauschen, "
                         @"doch der Stapel rutscht dir aus der Hand und verteilt sich über den ganzen Raum. "
                         @"Die Menge tobt, Stühle fliegen, und der Wirt schwört dich nie wieder hineinzulassen. "
                         @"Lebenslanges Hausverbot!";
                break;
            default: break;
        }

        talentResult.resultDescription = flavor;

        // Folge-Events/Actions: rauswurf + Hausverbot
        DSAActionDescriptor *leave = [DSAActionDescriptor new];
        leave.type = DSAActionTypeLeaveLocation;
        leave.parameters = @{ @"position": [currentPosition copy] };
        leave.order = 0;

        DSAEventDescriptor *ban = [DSAEventDescriptor new];
        ban.type = DSAEventTypeLocationBan;
        ban.parameters = @{
            @"position": [currentPosition copy],
            @"durationDays": @(days)
        };
        ban.order = 1;

        talentResult.followUps = @[leave, ban];
        break;
    }
  }
                                           
  return talentResult;
}
@end

@implementation DSAGeneralTalentTaschendiebstahl
- (DSAActionResult *) useOnTarget: (id) target
                      byCharacter: (DSACharacter *) character
                 currentAdventure: (DSAAdventure *) adventure
{
  NSLog(@"DSAGeneralTalentTaschendiebstahl useOnTarget: byCharacter: currentAdventure called");
  DSAAdventureGroup *activeGroup = adventure.activeGroup;
  DSAPosition *currentPosition = activeGroup.position;
  DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
  
  NSInteger penalty = 0;
  if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
    {
      DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
      DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
      if ([currentTile isKindOfClass: [DSALocalMapTileBuildingInn class]] &&
          [currentPosition.context isEqualToString: DSAActionContextTavern])
        {
          NSLog(@"DSAGeneralTalentTaschendiebstahl useOnTarget: byCharacter: currentAdventure no special penalty defined for currentTile class: %@", [currentTile class]);
          DSALocalMapTileBuildingInnFillLevel fillLevel = [(DSALocalMapTileBuildingInn*)currentTile tavernFillLevel];
          switch(fillLevel)
            {
              case DSALocalMapTileBuildingInnFillLevelEmpty: penalty = -1;
              case DSALocalMapTileBuildingInnFillLevelNormal: penalty = 0;
              case DSALocalMapTileBuildingInnFillLevelBusy: penalty = 1;              
              case DSALocalMapTileBuildingInnFillLevelPacked: penalty = 2;              
            }
        }
      else
        {
          NSLog(@"no special penalty/bonus ouside Inns for Taschendiebstahl defined yet!");
        }
    }
  else
    {
      NSLog(@"DSAGeneralTalentTaschendiebstahl useOnTarget: byCharacter: currentAdventure no penalty defined when used outside DSALocalMapLocation");
    }
  
  DSAActionResult *talentResult = [self useWithPenalty: penalty
                                           byCharacter: character];
                                           
  switch (talentResult.result) {
    case DSAActionResultNone: {
        NSLog(@"[ERROR] DSAActionResultNone should never happen!");
        abort();
        break;
    }

    // ✅ normale + besondere Erfolge
    case DSAActionResultSuccess:
    case DSAActionResultAutoSuccess:
    case DSAActionResultEpicSuccess: {
        NSInteger bonus = 0;
        NSString *flavorFormat = nil;
        switch (talentResult.result) {
            case DSAActionResultSuccess:
                flavorFormat = @"Mit ruhiger Hand greifst du unauffällig zu. "
                               @"Das Opfer merkt nichts, während du %ld Silber "
                               @"geschickt verschwinden lässt.";            
                bonus = 0; break;
            case DSAActionResultAutoSuccess:
                flavorFormat = @"Ein perfekter Griff – fast schon elegant. "
                               @"Noch ehe jemand blinzeln kann, wandern %ld Silber "
                               @"in deine Tasche, und niemand schöpft Verdacht.";            
                bonus = 10; break;
            case DSAActionResultEpicSuccess:
                flavorFormat = @"Ein episches Meisterstück! "
                               @"Du stiehlst nicht nur mit atemberaubender Leichtigkeit, "
                               @"sondern nutzt auch die Gelegenheit, gleich mehrere Börsen zu erwischen. "
                               @"Insgesamt erbeutest du %ld Silber – "
                               @"und niemand hat die geringste Ahnung.";            
                bonus = 50; break;
            default: break;
        }

        NSInteger silver = [Utils rollDice:@"1W6"] + bonus;
        talentResult.resultDescription = [NSString stringWithFormat: flavorFormat, (long)silver];

        // Beispiel: Folge-Action "Geld ins Inventar"
        DSAActionDescriptor *gain = [DSAActionDescriptor new];
        gain.type = DSAActionTypeGainMoney;
        gain.parameters = @{ @"amount": @(silver) };
        gain.order = 0;

        talentResult.followUps = @[gain];
        break;
    }

    // ❌ Fehlschläge
    case DSAActionResultFailure:
    case DSAActionResultAutoFailure:
    case DSAActionResultEpicFailure: {
        NSInteger days = 0;
        NSString *flavor = nil;
        switch (talentResult.result) {
            case DSAActionResultFailure:
                days = 7;
                flavor = @"Du wurdest auf frischer Tat ertappt! "
                         @"Die Wirtin schreit laut, Gäste drehen sich um, "
                         @"und du wirst unsanft zur Tür hinausbefördert. "
                         @"Hausverbot für eine Woche.";                
                 break;
            case DSAActionResultAutoFailure:
                days = 30;
                flavor = @"Dein Versuch endet im völligen Desaster. "
                         @"Die Menge johlt, als dich zwei kräftige Gäste packen "
                         @"und vor die Tür setzen. "
                         @"Die Wirtin schwört, dich für mindestens einen Monat nicht wieder hereinzulassen.";
                break;
            case DSAActionResultEpicFailure:
                days = NSIntegerMax;
                flavor = @"Dein Versuch endet im völligen Desaster. "
                         @"Die Menge johlt, als dich zwei kräftige Gäste packen "
                         @"und vor die Tür setzen. "
                         @"Die Wirtin schwört, dich für mindestens einen Monat nicht wieder hereinzulassen.";
                break;
            default: break;
        }

        talentResult.resultDescription = flavor;

        // Folge-Events/Actions: rauswurf + Hausverbot
        DSAActionDescriptor *leave = [DSAActionDescriptor new];
        leave.type = DSAActionTypeLeaveLocation;
        leave.parameters = @{ @"position": [currentPosition copy] };
        leave.order = 0;

        DSAEventDescriptor *ban = [DSAEventDescriptor new];
        ban.type = DSAEventTypeLocationBan;
        ban.parameters = @{
            @"position": [currentPosition copy],
            @"durationDays": @(days)
        };
        ban.order = 1;

        talentResult.followUps = @[leave, ban];
        break;
    }
  }
                                           
  return talentResult;
}
@end
// End of DSAGeneralTalent related subclasses

@implementation DSAProfession
                       
@end
// End of DSAProfession

@implementation DSASpecialTalent

@end
// End of DSASpecialTalent

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
      _professionsByName = nil;
      
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
        
      filePath = [[NSBundle mainBundle] pathForResource:@"Berufe" ofType:@"json"];        
      _professionsByName = [NSJSONSerialization JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                                                           options: NSJSONReadingMutableContainers
                                                             error: &e];
      if (e)
        {
           NSLog(@"Error loading JSON: %@", e.localizedDescription);
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
                [talents setValue: @{@"Startwert": startwert, @"Steigern": steigern, @"Versuche": versuche, @"category": category, @"subCategory": weapontype} 
                  forKey: key];
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
                [talents setValue: @{@"Startwert": startwert, @"Probe": probe, @"Steigern": steigern, @"Versuche": versuche, @"category": category} forKey: key];
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
  for (NSString *talent in [talents allKeys])
    {
       DSATalent *t = [DSATalent talentWithName: talent
                                   forCharacter: character];
       [newTalents setObject: t forKey: talent];

    }
  //NSLog(@"THE NEW TALENTS: newTalents %@", newTalents);
  return newTalents;
}

- (NSMutableDictionary <NSString *, DSASpecialTalent*>*)getMagicalDabblerTalentsByTalentsNameArray: (NSArray *) specialTalentNames
{
  NSMutableDictionary *specialTalents = [[NSMutableDictionary alloc] init];        
  for (NSString *specialTalentName in specialTalentNames)
    {
        NSLog(@"DSATalentManager getMagicalDabblerTalentsByTalentsNameArray : Checking specialTalentName: %@", specialTalentName);
        DSATalent *talent = [DSATalent talentWithName: specialTalentName
                                         forCharacter: nil];
        NSLog(@"DSATalentManager getMagicalDabblerTalentsByTalentsNameArray: created Talent: %@", talent);
        [specialTalents setObject: talent forKey: specialTalentName];
    }
  return specialTalents;
}

// professions related methods
- (NSDictionary *) getProfessionsDict
{
  return _professionsByName;
}

// returns all relevant professions for a given Archetype in a sorted array
- (NSArray *) getProfessionsForArchetype: (nullable NSString *) archetype
{
  NSMutableArray *professions = [[NSMutableArray alloc] init];
  
  if (archetype == nil)
    {
      return professions;
    }
      
  for (NSString *profession in [_professionsByName allKeys])
    {
      if ([[_professionsByName objectForKey: profession] objectForKey: @"Typen"] != nil)
        {
          if ([[[_professionsByName objectForKey: profession] objectForKey: @"Typen"] containsObject: archetype])
            {
              [professions addObject: profession];
            }
        }
    }
  NSArray *sortedProfessions = [professions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];  
  return sortedProfessions;
}
// end of professions related methods


@end
// end of DSATalentManager