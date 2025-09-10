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
                _(@"Falschspiel"): [DSAGeneralTalent class],
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
                _(@"Taschendiebstahl"): [DSAGeneralTalent class],
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
              };
            }
        }
    }
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
  NSLog(@"DSASpell: spellWithName: %@ not found returning NIL", name);
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
@end
// End of DSATalent

@implementation DSAFightingTalent
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
@end
// End of DSAFightingTalent

@implementation DSAGeneralTalent
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
// End of DSAGeneralTalent

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
              DSAGeneralTalent *talent = [[DSAGeneralTalent alloc] initTalent: t
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