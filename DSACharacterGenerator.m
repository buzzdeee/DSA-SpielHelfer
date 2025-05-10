/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-04 22:20:40 +0200 by sebastia

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

#import "DSACharacterGenerator.h"
#import "DSACharacter.h"
#import "Utils.h"
#import "DSAAventurianCalendar.h"
#import "DSATrait.h"
#import "DSASpellWitchCurse.h"
#import "DSASpellDruidRitual.h"
#import "DSASpellMischievousPrank.h"
#import "DSASpellGeodeRitual.h"
#import "DSASpellMageRitual.h"
#import "DSASpellShamanRitual.h"
#import "DSASpellSharisadDance.h"
#import "DSASpellElvenSong.h"
#import "DSALiturgy.h"

@implementation DSACharacterGenerator

- (DSACharacter *)generateCharacterWithParameters:(NSDictionary *)parameters
{
  NSString *archetype = [self resolveArchetypeFromParameters:parameters];
  
  
  // Order below is important
  self.character = [DSACharacter characterWithType: archetype];
  self.character.isNPC = [self shouldMarkAsNPCFromParameters: parameters];
  self.character.isMagicalDabbler = [self shouldMarkAsMagicalDabblerFromParameters: parameters];
  self.character.archetype = archetype;
  self.character.sex = [self resolveSexFromParameters: parameters];
  self.character.name = [self resolveNameFromParameters: parameters];
  self.character.title = [self resolveTitleFromParameters: parameters];
  self.character.origin = [self resolveOriginFromParameters: parameters];
  self.character.professions = [self resolveProfessionFromParameters: parameters];
  self.character.element = [self resolveElementFromParameters: parameters];
  self.character.religion = [self resolveReligionFromParameters: parameters];
  self.character.hairColor = [self resolveHairColorFromParameters: parameters];
  self.character.eyeColor = [self resolveEyeColorFromParameters: parameters];
  self.character.height = [self resolveHeightFromParameters: parameters];
  self.character.weight = [self resolveWeightFromParameters: parameters];
  self.character.birthday = [self resolveBirthdayFromParameters: parameters];
  self.character.god = [self resolveGodFromParameters: parameters];
  self.character.stars = [self resolveStarsFromParameters: parameters];
  self.character.socialStatus = [self resolveSocialStatusFromParameters: parameters];
  self.character.parents = [self resolveParentsFromParameters: parameters];
  self.character.siblings = [self resolveSiblingsFromParameters: parameters];
  self.character.money = [self resolveWealthFromParameters: parameters];
  self.character.birthPlace = [self resolveBirthplaceFromParameters: parameters];
  self.character.birthEvent = [self resolveBirthEventFromParameters: parameters];
  self.character.legitimation = [self resolveLegitimationFromParameters: parameters];
  self.character.childhoodEvents = [self resolveChildhoodEventsFromParameters: parameters];
  self.character.youthEvents = [self resolveYouthEventsFromParameters: parameters];
  self.character.portraitName = [self resolvePortraitNameFromParameters: parameters];
  self.character.mageAcademy = [self resolveAcademyFromParameters: parameters];   // also resolves Geodische Schule and Warrior Academy
  
  self.character.positiveTraits = [self resolvePositiveTraitsFromParameters: parameters];
  NSMutableDictionary *deepCopyPositiveTraits = [NSMutableDictionary dictionary];
  for (NSString *key in self.character.positiveTraits) {
    DSAPositiveTrait *value = self.character.positiveTraits[key];
    deepCopyPositiveTraits[key] = [value copy];
  }
  self.character.currentPositiveTraits = deepCopyPositiveTraits;

  self.character.negativeTraits = [self resolveNegativeTraitsFromParameters: parameters];
  NSMutableDictionary *deepCopyNegativeTraits = [NSMutableDictionary dictionary];
  for (NSString *key in self.character.negativeTraits) {
    DSANegativeTrait *value = self.character.negativeTraits[key];
    deepCopyNegativeTraits[key] = [value copy];
  }  
  self.character.currentNegativeTraits = deepCopyNegativeTraits;
  
  self.character.talents = [self resolveTalentsFromParameters: parameters];
  self.character.spells = [self resolveSpellsFromParameters: parameters];
  [Utils applySpellmodificatorsToCharacter: self.character];  
  
  for (NSString *modificator in @[ @"Goettergeschenke", @"Herkunft", @"Kriegerakademie", @"Magierakademie", @"Schamanenmodifikatoren"])
    {
      [self apply: modificator toCharacter: self.character];
    }
  [self makeCharacterAMagicalDabblerFromParameters: parameters];
  [self addEquipmentToCharacter];
    
  return self.character;
}

/* parameter parsing methods */

- (NSString *)resolveArchetypeFromParameters:(NSDictionary *)parameters {
    return parameters[@"archetype"];
}
- (BOOL)shouldMarkAsNPCFromParameters:(NSDictionary *)parameters {
    return [parameters[@"isNPC"] boolValue];
}
- (BOOL)shouldMarkAsMagicalDabblerFromParameters:(NSDictionary *)parameters {
    return [parameters[@"isMagicalDabbler"] boolValue];
}
- (NSString *)resolveSexFromParameters:(NSDictionary *)parameters {
    NSString *sex = parameters[@"sex"];
    if (sex && [sex length] > 0)
      {
        return sex;
      }
    else
      {
        return @"Ohne Geschlecht";
      }
}
- (NSString *)resolveNameFromParameters:(NSDictionary *)parameters {
    NSString *name = parameters[@"name"];
    if (name && [name length] > 0)
      {
        return name;
      }
    else
      {
        return @"Ohne Name";
      }
}
- (NSString *)resolveTitleFromParameters:(NSDictionary *)parameters {
    NSString *title = parameters[@"title"];
    if (title && [title length] > 0)
      {
        return title;
      }
    else
      {
        return @"Ohne Titel";
      }
}
- (NSString *)resolveOriginFromParameters:(NSDictionary *)parameters {
    NSString *origin = parameters[@"origin"];
    if (origin && [origin length] > 0)
      {
        return origin;
      }
    else
      {
        return @"Aventurien";
      }
}
- (NSMutableDictionary *)resolveProfessionFromParameters:(NSDictionary *)parameters {
  NSString *professionName = parameters[@"profession"];
  NSMutableDictionary *professionsDictionary = [[NSMutableDictionary alloc] init];
  if (professionName)
    {
      NSDictionary *professionDict = [NSDictionary dictionaryWithDictionary: [[Utils getProfessionsDict] objectForKey: professionName]];
      DSAProfession *profession = [[DSAProfession alloc] initProfession: professionName
                                                             ofCategory: [professionDict objectForKey: @"Freizeittalent"] ? _(@"Freizeittalent") : _(@"Beruf")
                                                                onLevel: 3
                                                               withTest: [professionDict objectForKey: @"Probe"]
                                                 withMaxTriesPerLevelUp: 6
                                                      withMaxUpPerLevel: 2
                                                      influencesTalents: [professionDict objectForKey: @"Bonus"]];     

      [professionsDictionary setObject: profession forKey: professionName];
    }
  else
    {
      professionsDictionary = nil;
    }        
    
  return professionsDictionary;
}
- (NSString *)resolveElementFromParameters:(NSDictionary *)parameters {
  return parameters[@"element"];
}

- (NSString *)resolveReligionFromParameters:(NSDictionary *)parameters {  
  NSString *religion = parameters[@"religion"];
  if (religion)
    {
      return religion;
    }
    
  NSString *origin = self.character.origin;  
  NSString *archetype = self.character.archetype;
  
  // Otherwise, let's see if we can auto-generate one...
  NSMutableArray *religions = [[NSMutableArray alloc] init];
  NSMutableArray *categories = [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typkategorie"];
  if (!categories)  // might be a NPC ???
    {
      categories = [[[Utils getNpcTypesDict] objectForKey: archetype] objectForKey: @"Typkategorie"];
    }

  if ([categories containsObject: _(@"Geweihter")])  // Blessed ones only have their own God to choose from ;)
    {
      [categories removeObject: _(@"Mensch")];
    }
    
  for (NSString *god in [Utils getGodsDict])
    {
      NSDictionary *values = [[Utils getGodsDict] objectForKey: god];
      // Check Typus
      NSArray *typusArray = [values objectForKey: @"Typus"];
      if (typusArray)
        {
          for (NSString *typus in typusArray)
            {
              if ([archetype isEqualToString:typus])
                {
                  [religions addObject:god];
                  break; // Break to avoid adding the same religion multiple times
                }
            }
        }

      // Check Typkategorie
      NSArray *typkategorieArray = values[@"Typkategorie"];
      if (typkategorieArray)
        {
          for (NSString *typkategorie in typkategorieArray)
            {
              if ([categories containsObject:typkategorie])
                {
                  [religions addObject:god];
                  break; // Break to avoid adding the same religion multiple times
                }
            }
        }
        
      // Check Herkunft
      NSArray *originsArray = values[@"Herkunft"];
      if (originsArray)
        {
          if ([originsArray containsObject: origin])
            {
              [religions addObject:god];
            }
        }        
    }
  if ([religions count] > 0)
    {
      return religions[arc4random_uniform([religions count])];
    }
  else
    {
      return @"Keine Religion";
    }
}

- (NSString *)resolveHairColorFromParameters:(NSDictionary *)parameters {  
  NSString *hairColor = parameters[@"hairColor"];
  if (hairColor)
    {
      return hairColor;
    }
    
  NSString *origin = self.character.origin;
  NSString *archetype = self.character.archetype;
  
  NSDictionary *hairConstraint;
  
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      hairConstraint = [NSDictionary dictionaryWithDictionary: [[[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typus"] objectForKey: origin] objectForKey: @"Haarfarbe"]];
    }
  else
    {
      hairConstraint = [NSDictionary dictionaryWithDictionary: [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Haarfarbe"]];    
    }
  NSInteger diceResult = [Utils rollDice: @"1W20"];
  
  NSArray *colors = [NSArray arrayWithArray: [hairConstraint allKeys]];
  
  for (NSString *color in colors)
    {
      if ([[hairConstraint objectForKey: color] containsObject: @(diceResult)])
        {
          return color;
        }
    }
  return @"nix";
}

- (NSString *)resolveEyeColorFromParameters:(NSDictionary *)parameters {  
  NSString *eyeColor = parameters[@"eyeColor"];
  if (eyeColor)
    {
      return eyeColor;
    }
    
  NSString *archetype = self.character.archetype;
  NSString *hairColor = self.character.hairColor;
  
  NSInteger diceResult = [Utils rollDice: @"1W20"];
  
  if ([[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Augenfarbe"] == nil)
    {
      // No special Augenfarbe defined for the characterType, we use the default calculation
      // algorithm as defined in "Mit Mantel, Schwert und Zauberstab S. 61"
      for (NSDictionary *entry in [Utils getEyeColorsDict])
        {
          for (NSString *color in [entry objectForKey: @"Haarfarben"])
            {
              if ([color isEqualTo: hairColor])
                {
                  for (NSString *ec in [[entry objectForKey: @"Augenfarben"] allKeys])
                    {
                      if ([[[entry objectForKey: @"Augenfarben"] objectForKey: ec] containsObject: @(diceResult)])
                        {
                          return ec;
                        }
                    }
                }
            }
        }        
    }
  else
    {
      // We're dealing with a Character that has special Augenfarben constraints
      NSDictionary *eyeColors = [NSDictionary dictionaryWithDictionary: [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Haarfarbe"]];
      
      for (NSString *color in [eyeColors allKeys])
        {
          if ([[eyeColors objectForKey: color] containsObject: @(diceResult)])
            {
              // we found the color
              return color;
            }
        }
    }
  return @"nix";
}

- (float) resolveHeightFromParameters:(NSDictionary *)parameters {
  float height = [parameters[@"height"] floatValue];
  if (height)
    {
      return height;
    }
  NSString *origin = self.character.origin;
  NSString *archetype = self.character.archetype;
  
  NSArray *heightArr;
  
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      heightArr = [NSArray arrayWithArray: [[[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typus"] objectForKey: origin] objectForKey: @"Körpergröße"]];
    }
  else
    {
      heightArr = [NSArray arrayWithArray: [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Körpergröße"]];      
    }
  height = [[heightArr objectAtIndex: 0] floatValue];
  unsigned int count = [heightArr count];
  for (unsigned int i = 1;i<count; i++)
    {
      height += [Utils rollDice: [heightArr objectAtIndex: i]];
    }
  return height;
}

- (float) resolveWeightFromParameters:(NSDictionary *)parameters {
  float weight = [parameters[@"weight"] floatValue];
  if (weight)
    {
      return weight;
    }

  NSString *archetype = self.character.archetype;
  float height = self.character.height;
  weight = [[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Gewicht"] floatValue];
  return weight + height;
}

- (DSAAventurianDate *) resolveBirthdayFromParameters:(NSDictionary *)parameters {
  DSAAventurianDate *birthday = parameters[@"birthday"];
  if (birthday)
    {
      return birthday;
    }

  NSInteger level = self.character.level;
  NSString *monthName = [[NSString alloc] init];
  NSUInteger day;
  NSInteger year;
  NSInteger diceResult = [Utils rollDice: @"1W20"];
  NSArray *months = [[[Utils getBirthdaysDict] objectForKey: @"Monat"] allKeys];

  for (NSString *month in months)
    {
      if ([[[[Utils getBirthdaysDict] objectForKey: @"Monat"] objectForKey: month] containsObject: @(diceResult)])
        {
          monthName = [NSString stringWithFormat: @"%@", month];
        }
    }

  diceResult = [Utils rollDice: @"1W20"];
  NSArray *fifthOfMonth = [[[Utils getBirthdaysDict] objectForKey: @"Monatsfuenftel"] allKeys];
  for (NSString *fifth in fifthOfMonth)  
    {
      if ([[[[Utils getBirthdaysDict] objectForKey: @"Monatsfuenftel"] objectForKey: fifth] containsObject: @(diceResult)])
        {
          day = [fifth intValue] + [Utils rollDice: @"1W6"] - 1;
        }
    }
  NSLog(@"generateBirthday before year with this month %lu for monthName: %@", (unsigned long) [DSAAventurianCalendar monthForString: monthName], monthName);
  year = [DSAAventurianCalendar calculateAventurianYearOfBirthFromCurrentDate: [DSAAventurianCalendar convertToAventurian: [NSDate date]]
                                                                birthdayMonth: [DSAAventurianCalendar monthForString: monthName]
                                                                  birthdayDay: day
                                                                   currentAge: 16 + 2 * level];   // always starting with 16 years for now

  NSLog(@"generateBirthday after year %li", (long) year);                                                                     
  return [[DSAAventurianDate alloc] initWithYear: year
                                           month: [DSAAventurianCalendar monthForString: monthName]
                                             day: day
                                            hour: [Utils rollDice: @"1W24"] - 1];         // for now, everyone is born at 5 am in the morning
}

- (NSString *)resolveGodFromParameters:(NSDictionary *)parameters {
  NSString *god = parameters[@"god"];
  if (god)
    {
      return god;
    }
  NSString *monthName = self.character.birthday.monthName;
  NSDictionary *godsDict = [Utils getGodsDict];
  for (NSString *god in [godsDict allKeys])
    {
      if ([[[godsDict objectForKey: god] objectForKey: @"Monat"] isEqualToString: monthName])
        {
          return god;
        }
    }
  return nil;
}


- (NSString *)resolveStarsFromParameters:(NSDictionary *)parameters {
  NSString *stars = parameters[@"stars"];
  if (stars)
    {
      return stars;
    }
  NSString *god = self.character.god;
  NSDictionary *godsDict = [Utils getGodsDict];
  
  return [[godsDict objectForKey: god] objectForKey: @"Sternbild"];
}

- (NSString *)resolveSocialStatusFromParameters:(NSDictionary *)parameters {
  NSString *socialStatus = parameters[@"socialStatus"];
  if (socialStatus)
    {
      return socialStatus;
    }

  NSString *dice;
  NSDictionary *herkuenfteDict;

  NSString *archetype = self.character.archetype;
  NSString *origin = self.character.origin;
  BOOL isMagicalDabbler = self.character.isMagicalDabbler;
  NSDictionary *archetypeDict = [[Utils getArchetypesDict] objectForKey: archetype];
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      dice = [[[[archetypeDict objectForKey: @"Typus"] objectForKey: origin] objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
      herkuenfteDict = [NSDictionary dictionaryWithDictionary: [[[archetypeDict objectForKey: @"Typus"] objectForKey: origin] objectForKey: @"Herkunft"]];    
    }
  else
    {
      dice = [[archetypeDict objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
      herkuenfteDict = [NSDictionary dictionaryWithDictionary: [archetypeDict objectForKey: @"Herkunft"]];    
    }
    
  NSLog(@"generateFamilyBackground %@ %@", dice, herkuenfteDict);
  NSArray *herkuenfteArr = [NSArray arrayWithArray: [herkuenfteDict allKeys]];
  
  BOOL finished = NO;
  while (!finished)
    {
      NSInteger diceResult = [Utils rollDice: dice];
  
      for (NSString *socialStatus in herkuenfteArr)
        {
          if ([@"Würfel" isEqualTo: socialStatus])
            {
              continue;
            }
          NSDictionary *socialStatusDict = [herkuenfteDict objectForKey: socialStatus];
      
          if ([[socialStatusDict objectForKey: dice] containsObject: @(diceResult)])
            {
              if (isMagicalDabbler && [@[_(@"reich"), _(@"adelig")] containsObject: socialStatus])
                {
                  break;  // roll dice and try again
                }
              else
                {
                  return socialStatus;
                }
            }
        }
    }
  return nil;
}


- (NSString *)resolveParentsFromParameters:(NSDictionary *)parameters {
  NSString *parents = parameters[@"parents"];
  if (parents)
    {
      return parents;
    }

  NSString *dice;
  NSDictionary *herkuenfteDict;

  NSString *archetype = self.character.archetype;
  NSString *origin = self.character.origin;
  NSDictionary *archetypeDict = [[Utils getArchetypesDict] objectForKey: archetype];
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      dice = [[[[archetypeDict objectForKey: @"Typus"] objectForKey: origin] objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
      herkuenfteDict = [NSDictionary dictionaryWithDictionary: [[[archetypeDict objectForKey: @"Typus"] objectForKey: origin] objectForKey: @"Herkunft"]];    
    }
  else
    {
      dice = [[archetypeDict objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
      herkuenfteDict = [NSDictionary dictionaryWithDictionary: [archetypeDict objectForKey: @"Herkunft"]];    
    }
    
  NSLog(@"generateFamilyBackground %@ %@", dice, herkuenfteDict);
  NSArray *herkuenfteArr = [NSArray arrayWithArray: [herkuenfteDict allKeys]];
  
  NSInteger diceResult = [Utils rollDice: dice];
  
  for (NSString *socialStatus in herkuenfteArr)
    {
      if ([@"Würfel" isEqualTo: socialStatus])
        {
          continue;
        }
      NSDictionary *socialStatusDict = [herkuenfteDict objectForKey: socialStatus];
      if ([[socialStatusDict objectForKey: dice] containsObject: @(diceResult)])
        {
          for (NSString *parents in [[socialStatusDict objectForKey: @"Eltern"] allKeys])
            {
              if ([[[socialStatusDict objectForKey: @"Eltern"] objectForKey: parents] containsObject: @(diceResult)])
                {
                  return parents;
                }
            }
        }
    }
  return nil;
}

/* generates initial wealth/money, as described in "Mit Mantel, Schwert
   und Zauberstab" S. 61 */
- (NSMutableDictionary *)resolveWealthFromParameters:(NSDictionary *)parameters {   
   NSMutableDictionary *money = [NSMutableDictionary dictionaryWithDictionary: @{@"K": [NSNumber numberWithInt: 0], 
                                                                                 @"H": [NSNumber numberWithInt: 0], 
                                                                                 @"S": [NSNumber numberWithInt: 0], 
                                                                                 @"D": [NSNumber numberWithInt: 0]}];
   NSString *socialStatus = self.character.socialStatus;
                                                                                                                                                                  
   if ([socialStatus isEqualTo: @"unfrei"])
     {
       [money setObject: @([Utils rollDice: @"1W6"]) forKey: @"S"];
     }
   else if ([socialStatus isEqualTo: @"arm"])
     {
       [money setObject: @([Utils rollDice: @"1W6"]) forKey: @"D"];
     }
   else if ([socialStatus isEqualTo: @"mittelständisch"])
     {
       [money setObject: @([Utils rollDice: @"3W6"]) forKey: @"D"];
     }
   else if ([socialStatus isEqualTo: @"reich"])
     {
       [money setObject: [NSNumber numberWithInteger: [Utils rollDice: @"2W20"] + 20] forKey: @"D"];
     }
   else if ([socialStatus isEqualTo: @"adelig"] || [socialStatus isEqualTo: @"niederer Adel"] || [socialStatus isEqualTo: @"Hochadel"] || [socialStatus isEqualTo: @"unbekannt"]) // "unbekannt" can be quite rich, or poor 
     {
       [money setObject: @([Utils rollDice: @"3W20"]) forKey: @"D"];
     }
   else
     {
       NSLog(@"DSACharacterGenerationController: generateWealth: don't know how to handle socialStatus: %@", socialStatus);
     }
  return money;
}

// loosely following "Vom Leben in Aventurien", S. 34
- (NSArray *) resolveSiblingsFromParameters:(NSDictionary *)parameters {
  NSArray *siblings = parameters[@"siblings"];
  if (siblings)
    {
      return siblings;
    }
    
  NSInteger diceResult = [Utils rollDice: @"1W10"];
  NSMutableArray *resultArr = [[NSMutableArray alloc] init];
  if (diceResult == 1)
    {
      return resultArr; // no siblings
    }
  else
    {
      for (NSInteger cnt = 1;cnt <= diceResult;cnt++)
        {
          NSMutableDictionary *sibling = [[NSMutableDictionary alloc] init];
          NSInteger result = [Utils rollDice: @"1W2"];
          if (result == 1)
            {
              [sibling setObject: _(@"älter") forKey: @"age"];
            }
          else
            {
              [sibling setObject: _(@"jünger") forKey: @"age"];
            }
          result = [Utils rollDice: @"1W2"];
          if (result == 1)
            {
              [sibling setObject: _(@"weiblich") forKey: @"sex"];
            }
          else
            {
              [sibling setObject: _(@"männlich") forKey: @"sex"];
            }
          [resultArr addObject: sibling];
        }
    }
  return resultArr;  
}

// loosely following "Vom Leben in Aventurien" S. 34
- (NSString *) resolveBirthplaceFromParameters:(NSDictionary *)parameters {
  NSString *birthPlace = parameters[@"birthPlace"];
  if (birthPlace)
    {
      return birthPlace;
    }

  NSString *selectedArchetype = self.character.archetype;
  NSString *selectedOrigin = self.character.origin;

  NSInteger diceResult = [Utils rollDice: @"1W20"];
  NSInteger typusOffset = 0;
  if ([selectedArchetype isEqualToString: _(@"Jäger")])
    {
      typusOffset = -8;
    }
  else if ([@[_(@"Gaukler"), _(@"Streuner")] containsObject: selectedArchetype])
    {
      typusOffset = 5;
    }
  else if ([@[_(@"Moha"), _(@"Nivese")] containsObject: selectedArchetype] || [@[_(@"Moha"), _(@"Nivese")] containsObject: selectedOrigin])
    {
      typusOffset = -17;
    }
  
  NSInteger testValue = diceResult + typusOffset;  
  NSString *resultStr;
  if (testValue >= -16 && testValue <= 2)
    {
      diceResult = [Utils rollDice: @"1W20"];

      if (diceResult == 1)
        {
          resultStr = _(@"in der Wildnis");
        }
      else
        {
          resultStr = _(@"in einer Hütte im Wald");
        }
    }
  else if (testValue == 3)
    {
      diceResult = [Utils rollDice: @"1W3"];
      if (diceResult == 1)
        {
          resultStr = _(@"in einer Ruine in einem verlassenem Dorf");
        }
      else if (diceResult == 2)
        {
          resultStr = _(@"in einer Ruine einer Festung");
        }
      else if (diceResult == 3)
        {
          resultStr = _(@"in einer Ruine eines Tempels");
        }
    }
  else if (testValue >= 4 && testValue <= 12)
    {
      diceResult = [Utils rollDice: @"1W3"];
      if (diceResult == 1)
        {
          resultStr = _(@"in einem Dorf");
        }
      else if (diceResult == 2)
        {
          resultStr = _(@"in einem Weiler");
        }
      else if (diceResult == 3)
        {
          resultStr = _(@"in einer Burg");
        }    
    }
  else if (testValue >= 13 && testValue <= 17)
    {
      resultStr = _(@"in einer Stadt");
    }
  else if (testValue >= 18 && testValue <= 19)
    {
      resultStr = _(@"in einer Großstadt");
    }
  else if (testValue >= 20 && testValue <= 25)
    {
      if ([@[_(@"Thorwaler"), _(@"Skalde"), _(@"Seefahrer")] containsObject: selectedArchetype])
        {
          resultStr = _(@"auf einem Schiff");
        }
      else
        {
          resultStr = _(@"in einem Wagen auf der Straße");
        }
    }

  return [NSString stringWithFormat: _(@"%@ wird %@ geboren."), self.character.name, resultStr];
}

// loosely following "Vom Leven in Aventurien" S. 35
- (NSString *) resolveBirthEventFromParameters:(NSDictionary *)parameters {
  NSString *birthEvent = parameters[@"birthEvent"];
  if (birthEvent)
    {
      return birthEvent;
    }

  NSInteger diceResult = [Utils rollDice: @"1W20"];
  
  if (diceResult == 1)
    {
      if ([self.character.siblings count] == 0)
        { 
          return [self resolveBirthEventFromParameters: parameters];
        }
      else
        {
          return _(@"Die Geburt war eine Zwillingsgeburt.");
        }
    }
  else if (diceResult == 2)
    {
      return _(@"Es erscheint ein erster Sonnenstrahl nach einem schweren Unwetter.");
    }
  else if (diceResult == 3)
    {
      return _(@"Die Sonne und Regen formten einen prächtigen Regenbogen.");
    }
  else if (diceResult == 4)
    {
      return _(@"Sternschnuppen und Kometen zeigten sich am Himmel.");
    }
  else if (diceResult == 5)
    {
      return _(@"Ucri, der Siegesstern, ging auf.");
    }
  else if (diceResult == 6)
    {
      return _(@"Nicht weit enfernt färbte sich ein Bach blutrot.");
    }
  else if (diceResult == 7)
    {
      return _(@"Zur gleichen Zeit starb in der Nähe ein Tier.");
    }
  else if (diceResult == 8)
    {
      return _(@"\"Lämmerschwänzchen\": Das Kind trägt eine auffällige Locke am Hinterkopf - angeblich ein Zeichen, daß es von den Göttern auswerwählt ist.");
    }
  else if (diceResult == 9)
    {
      diceResult = [Utils rollDice: @"1W3"];
      NSString *result;
      if (diceResult == 1)
        {
          result = _(@"in geistige Verwirrung");
        }
      else if (diceResult == 2)
        {
          result = _(@"in Apathie");
        }
      else if (diceResult == 3)
        {
          result = _(@"in einen Weinkrampf");
        }        
      return [NSString stringWithFormat: _(@"Die Mutter verfiel unmittelbar nach der Geburt für mehrere Stunden %@."), result];
    }
  else if (diceResult == 10)
    {
      return _(@"Der Vater stieß beim Anblick des Säuglings ein hysterisches Gelächter aus.");
    }
  else if (diceResult == 11)
    {
      return _(@"Während der Geburt war aus nächster Nähe stetes, unheimliches Gepolter zu hören.");
    }
  else if (diceResult >= 12 && diceResult <= 15)
    {
      return _(@"Es gab keine besonderen Vorkommnisse bei der Geburt.");
    }
  else if (diceResult == 16)
    {
      return _(@"Die Wölfe und Hunde in der Umgebung begannen zu heulen.");
    }
  else if (diceResult == 17)
    {
      return _(@"Gewitter und Hagelsturm tobten an diesem Tag.");
    }                
  else if (diceResult == 18)
    {
      return _(@"Ein Blitz fuhr aus heiterem Himmel nieder.");
    }                
  else if (diceResult == 19)
    {
      return _(@"Zeitgleich verdunkelte der Mond die Sonne zu einer Sonnenfinsternis.");
    }                    
  else if (diceResult == 20)
    {
      return _(@"Zeitgleich erschütterte die Erde bei einem Erdbeben.");
    }
  // we shouldn't end up here, but ...
  return _(@"Es gab keine besonderen Vorkommnisse bei der Geburt.");               
}

- (NSString *) resolveLegitimationFromParameters:(NSDictionary *)parameters {
  NSString *legitimation = parameters[@"legitimation"];
  if (legitimation)
    {
      return legitimation;
    }

  NSString *selectedArchetype = self.character.archetype;
  NSString *selectedOrigin = self.character.origin;
  NSString *name = self.character.name;

  NSInteger diceResult = [Utils rollDice: @"1W20"];
  NSInteger typusOffset = -1;
  if ([selectedArchetype isEqualToString: _(@"Moha")] || [selectedOrigin isEqualTo: _(@"Moha")])
    {
      typusOffset = 3;
    }
  else if ([selectedArchetype isEqualToString: _(@"Nivese")] || [selectedOrigin isEqualTo: _(@"Nivese")])
    {
      typusOffset = 3;
    }
  
  NSInteger testValue = diceResult + typusOffset;
  if (testValue >= 0 && testValue <= 2)
    {
      diceResult = [Utils rollDice: @"1W3"];
      if (diceResult == 1)
        {
          return [NSString stringWithFormat: _(@"%@ wird in einem Dorf ausgesetzt und wächst als Findelkind bei Pflegeeltern auf."), name];
        }
      else if (diceResult == 2)
        {
          return [NSString stringWithFormat: _(@"%@ wird in einer Stadt ausgesetzt und wächst als Findelkind bei Pflegeeltern auf."), name];
        } 
      else if (diceResult == 3)
        {
          return [NSString stringWithFormat: _(@"%@ wird in einer Großstadt ausgesetzt und wächst als Findelkind bei Pflegeeltern auf."), name];
        }                
    }
  else if (testValue >= 3 && testValue <= 17)
    {
      return [NSString stringWithFormat: _(@"%@ wird von den Eltern bei der Geburt anerkannt."), name];
    }
  else if (testValue == 18)
    {
      return [NSString stringWithFormat: _(@"%@'s Vater behauptet, daß das Kind von einem anderen Mann stammt."), name];
    } 
  else if (testValue == 19)
    {
      return [NSString stringWithFormat: _(@"%@'s Mutter behauptet, daß ihr Gefährte nicht der Vater ist."), name];
    }
  else if (testValue >= 20 && testValue <= 22)
    {
      return [NSString stringWithFormat: _(@"%@ gilt bei der Geburt als schwächlich und nicht lebensfähig, weshalb es in der Wildnis ausgesetzt wird. Es wird jedoch gefunden, und wächst bei einer anderen Sippe auf."), name];
    } 
  else if (testValue == 23)
    {
      return [NSString stringWithFormat: _(@"%@ gilt bei der Geburt als schwächlich und nicht lebensfähig, weshalb es in der Wildnis ausgesetzt wird. Es wird bis zum sechten Jahr von Wölfen aufgezogen. Danach wird es von einer fremden Sippe aufgenommen."), name];
    }
  return @"nix";            
}


- (NSArray *) resolveChildhoodEventsFromParameters:(NSDictionary *)parameters {
  NSArray *childhoodEvents = parameters[@"childhoodEvents"];
  if (childhoodEvents)
    {
      return childhoodEvents;
    }
  NSString *selectedArchetype = self.character.archetype;
  NSString *name = self.character.name;
  NSInteger eventCount = [Utils rollDice: @"1W3"];
  NSMutableArray *resultArr = [[NSMutableArray alloc] init];
  
  NSMutableArray *tracker = [[NSMutableArray alloc] init];
  
  NSInteger cnt = 0;
  
  while (cnt < eventCount)
    {
      NSInteger eventResult = [Utils rollDice: @"1W20"];
      NSString *resultStr;
      if ([tracker containsObject: [NSNumber numberWithInteger: eventResult]])
        {
          continue;  // we don't want to have the same event happen twice
        }
      else
        {
          [tracker addObject: [NSNumber numberWithInteger: eventResult]];
        }
      if (eventResult == 1)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird Zeuge eines Zwölfgöttlichen Wunders."), name];
        }
      else if (eventResult == 2)
        {
          eventResult = [Utils rollDice: @"1W7"];
          NSString *who;
          if (eventResult == 1)
            {
              who = _(@"Dieb");
            }
          else if (eventResult == 2)
            {
              who = _(@"Räuber");
            }
          else if (eventResult == 3 || eventResult == 4)
            {
              who = _(@"Geweihter");
            }
          else if (eventResult == 5)
            {
              who = _(@"Zauberer");
            }
          else if (eventResult == 6)
            {
              who = _(@"alter Gaukler");
            }
          else if (eventResult == 7)
            {
              who = _(@"Kriegsveteran");
            }            
          resultStr = [NSString stringWithFormat: _(@"%@ findet einen Gönner: Ein %@ wird auf das Kleine aufmerksam, weil er in ihm eine besondere Begabung entdeckt. Er verwöhnt es mit Geschenken, erzählt ihm von seinem Leben und seinen Fahrten und bring ihm möglicherweise ein paar spezielle Fertigkeiten oder kleine Kunststücke bei."), name, who];
        }
      else if (eventResult == 3)
        {
          eventResult = [Utils rollDice: @"1W6"];
          if (eventResult == 1 | eventResult == 2)
            {
              eventResult = [Utils rollDice: @"2W6"];
              resultStr = [NSString stringWithFormat: _(@"%@ findet einen Beutel mit %lu Goldstücken."), name, (unsigned long) eventResult];
            }
          else if (eventResult == 3)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet ein wertvolles Instrument."), name];
            }
          else if (eventResult == 4)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet ein wertvolles Schmuckstück."), name];
            }
          else if (eventResult == 5)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet eine kostbare Waffe."), name];
            }
          else if (eventResult == 6)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet einen magischen Gegenstand."), name];
            }            
        }
      else if (eventResult == 4)
        {
          eventResult = [Utils rollDice: @"1W3"];
          // more flesh to be added here, see book
          resultStr = _(@"Die Eltern werden vom Fürsten für eine besondere Tat belohnt.");

        }
      else if (eventResult == 5)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSInteger socialStatus = [Utils rollDice: @"1W6"];
          NSString *timeFrame;
          NSString *status;
          if (eventResult == 1 || eventResult == 2)
            {
              timeFrame = [NSString stringWithFormat: _(@"%lu Jahr%@"), eventResult, eventResult == 1? _(@""): _(@"e")];
            }
          else 
            {
              timeFrame = _(@"ein Leben lang");
            }
          if (socialStatus == 1)
            {
              status = _(@"unfrei");
            }
          else if (socialStatus == 2 || socialStatus == 3)
            {
              status = _(@"arm");
            }
          else if (socialStatus == 2 || socialStatus == 3)
            {
              status = _(@"reich");
            }
          else if (socialStatus == 6)
            {
              status = _(@"adelig");
            }            
          resultStr = [NSString stringWithFormat: _(@"%@ findet einen guten Freund gleichen Alters. Der Freund ist %@. Die Freundschaft währt %@."), name, status, timeFrame];
        }
      else if (eventResult == 6)
        {
          NSInteger who = [Utils rollDice: @"1W2"];
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whoStr;
          if (who == 1)
            {
              whoStr = _(@"Ein freundlicher Nachbar");
            }
          else
            {
              whoStr = _(@"Ein Geweihter");
            }
          if (eventResult == 1 || eventResult == 2)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Lesen und Schreiben."), whoStr, name];
            }
          if (eventResult == 3 || eventResult == 4)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Rechnen."), whoStr, name];
            }
          if (eventResult == 5)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Malen und Zeichnen."), whoStr, name];
            }            
          if (eventResult == 6)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Musizieren."), whoStr, name];
            }             
        }
      else if (eventResult == 7)
        {
          eventResult = [Utils rollDice: @"1W2"];
          NSString *whereTo;
          if (eventResult == 1)
            {
              whereTo = _(@"eine andere Stadt");
            }
          else
            {
              whereTo = _(@"ein anderes Dorf");
            }
          resultStr = [NSString stringWithFormat: _(@"Die Familie zieht in %@. %@ erlebt eine unglückliche Zeit der Trennung von den Gefährten der Heimat."), whereTo, name];
        }
      else if (eventResult == 8)
        {
          resultStr = [NSString stringWithFormat: _(@"Eine Wahrsagerin sagt %@ eine große Zukunft voraus."), name];
        }
      else if (eventResult == 9)
        {
          resultStr = [NSString stringWithFormat: _(@"Ein alter Kämpe und guter Freund der Familie erzählt von Abenteuern und Heldentaten. %@ ist davon sehr beeindruckt und möchte es später einmal diesem Recken gleichtun."), name];
        }
      else if (eventResult == 10)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSInteger typusOffset = 0;
          if ([selectedArchetype isEqualToString: _(@"Streuner")])
            {
              typusOffset = 2;
            }
          NSInteger testValue = eventResult + typusOffset;
          NSString *whatStr;
          if (testValue >= 1 && testValue <= 4)
            {
              whatStr = _(@"ist freundlich zu dem Kind");
            }
          else
            {
              whatStr = _(@"ist unfreundlich und nutzt das Kind als billige Arbeitskraft aus");
            }
          resultStr = [NSString stringWithFormat: _(@"Die Eltern können ihre Nachkommen nicht mehr ernähren. Sie geben %@ in die Hände einer anderen Familie. Diese %@"), name, whatStr];
        }
      else if (eventResult == 11)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSInteger typusOffset = 0;
          if ([selectedArchetype isEqualToString: _(@"Streuner")])
            {
              typusOffset = -2;
            }
          NSInteger testValue = eventResult + typusOffset;
          NSString *whatStr;
          if (testValue >= -1 && testValue <= 1)
            {
              whatStr = _(@"und kehrt nicht zurück und schlägt sich allein durch");
            }
          else if (testValue == 2)
            {
              whatStr = _(@"und kehrt nicht zurück und wächst bei Gauklern auf");
            }
          else if (testValue == 3)
            {
              whatStr = _(@"und kehrt nicht zurück und wächst bei anderen Pflegeeltern auf");
            }                        
          else
            {
              NSInteger days = [Utils rollDice: @"1W6"] + 3;
              whatStr = [NSString stringWithFormat: _(@"und kehrt nach %lu Tagen wieder zurück"), (unsigned long) days];
            }
          resultStr = [NSString stringWithFormat: _(@"%@ läuft von zu Hause fort, %@"), name, whatStr];
        }
      else if (eventResult == 12)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird seinen Eltern geraubt und verschleppt. Es wächst fortan bei Pflegeeltern auf."), name];
        }
      else if (eventResult == 13)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *article;
          NSString *whatStr;
          if ([self.character.sex isEqualToString: _(@"männlich")])
            {
              article = _(@"er");
            }
          else
            {
              article = _(@"sie");
            }
          if (eventResult == 1 || eventResult == 2)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ wird nicht erwischt"), article];
            }
          else if (eventResult == 3 || eventResult == 4 || eventResult == 5)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ wird erwischt und milde bestraft"), article];
            }
          else
            {
              whatStr = [NSString stringWithFormat: _(@"%@ wird erwischt und hart bestraft"), article];
            }
          resultStr = [NSString stringWithFormat: _(@"Freunde verführen %@ dazu, etwas verbotenes zu tun. %@."), name, whatStr];
        }
      else if (eventResult == 14)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whoStr;         
          if (eventResult == 1)
            {
              whoStr = _(@"dem Vater");
            }
          else if (eventResult == 2)
            {
              whoStr = _(@"der Mutter");
            }
          else
            {
              if ([self.character.siblings count] == 0)
                {
                  if (eventResult == 3 || eventResult == 5)
                    {
                      whoStr = _(@"dem Vater");
                    }
                  else
                    {
                      whoStr = _(@"der Mutter");
                    }                  
                }
              else if ([self.character.siblings count] == 1)
                {
                  if ([[[self.character.siblings objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
                    {
                      whoStr = _(@"dem Bruder");
                    }
                  else
                    {
                      whoStr = _(@"der Schwester");
                    }
                }
              else
                {
                  whoStr = _(@"einem der Geschwister");
                }
            }
          resultStr = [NSString stringWithFormat: _(@"%@ verstreitet sich mit %@. Zwischen beiden regiert fortan blinder Haß."), name, whoStr];
        }
      else if (eventResult == 15)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whatStr;
          NSString *article;
          if ([self.character.sex isEqualToString: _(@"männlich")])
            {
              article = _(@"er");
            }
          else
            {
              article = _(@"sie");
            }          
          if (eventResult >= 1 && eventResult <= 4)
            {
              whatStr = _(@"läßt Milde walten");
            }
          else
            {
              whatStr = _(@"bleibt hart");
            }
          resultStr = [NSString stringWithFormat: _(@"%@ wird für etwas bestraft, was %@ nicht getan hat. Der Richter %@."), name, article, whatStr];
        }
      else if (eventResult == 16)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird von einem wilden Tier schwer verletzt."), name];        
        }
      else if (eventResult == 17)
        {
          eventResult = [Utils rollDice: @"1W2"];
          NSString *event;
          if (eventResult == 1)
            {
              event = _(@"Krieg");
            }
          else
            {
              event = _(@"Aufstand");
            }
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whatStr;
          if (eventResult == 1 || eventResult == 2)
            {
              whatStr = _(@"kommt dabei zu Tode");
            }
          else
            {
              whatStr = _(@"wird dabei schwer verletzt");
            }
          NSString *whoStr;         
          if (eventResult == 1)
            {
              whoStr = _(@"Der Vater");
            }
          else if (eventResult == 2)
            {
              whoStr = _(@"Die Mutter");
            }
          else
            {
              if ([self.character.siblings count] == 0)
                {
                  if (eventResult == 3 || eventResult == 5)
                    {
                      whoStr = _(@"Der Vater");
                    }
                  else
                    {
                      whoStr = _(@"Die Mutter");
                    }                  
                }
              else if ([self.character.siblings count] == 1)
                {
                  if ([[[self.character.siblings objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
                    {
                      whoStr = _(@"Der Bruder");
                    }
                  else
                    {
                      whoStr = _(@"Die Schwester");
                    }
                }
              else
                {
                  whoStr = _(@"Eines der Geschwister");
                }
            }
          resultStr = [NSString stringWithFormat: _(@"Ein %@ überzieht das Land. %@ %@."), event, whoStr, whatStr];            
        }
      else if (eventResult == 18)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *reason;
          if (eventResult == 1)
            {
              reason = _(@"wegen einem berechtigtem Todesurteil");
            }
          else if (eventResult == 2)
            {
              reason = _(@"wegen einem unberechtigtem Todesurteil");
            }
          else if (eventResult == 3)
            {
              eventResult = [Utils rollDice: @"1W3"];
              NSString *whoStr;
              if (eventResult == 1)
                {
                  whoStr = _(@"der Orks");
                }
              if (eventResult == 2)
                {
                  whoStr = _(@"von Ogern");
                }                
              else
                {
                  whoStr = _(@"von Räubern");
                }
              reason = [NSString stringWithFormat: _(@"bei einem Überfall %@"), whoStr];
            }
          else if (eventResult == 4)
            {
              reason = _(@"in einer Rauferei");
            }
          else if (eventResult == 5)
            {
              reason = _(@"wegen eines Unfalles");
            }
          else
            {
              reason = _(@"bei einem Selbstmord");
            }
          eventResult = [Utils rollDice: @"1W6"];  
          NSString *whoStr;         
          if (eventResult == 1)
            {
              whoStr = _(@"Der Vater");
            }
          else if (eventResult == 2)
            {
              whoStr = _(@"Die Mutter");
            }
          else
            {
              if ([self.character.siblings count] == 0)
                {
                  if (eventResult == 3 || eventResult == 5)
                    {
                      whoStr = _(@"Der Vater");
                    }
                  else
                    {
                      whoStr = _(@"Die Mutter");
                    }                  
                }
              else if ([self.character.siblings count] == 1)
                {
                  if ([[[self.character.siblings objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
                    {
                      whoStr = _(@"Der Bruder");
                    }
                  else
                    {
                      whoStr = _(@"Die Schwester");
                    }
                }
              else
                {
                  whoStr = _(@"Eines der Geschwister");
                }
            }
          resultStr = [NSString stringWithFormat: _(@"%@ kommt %@ zu Tode."), whoStr, reason];            
        }
      else if (eventResult == 19)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *sickness;
          if (eventResult >= 1 && eventResult <= 3)
            {
              sickness = [NSString stringWithFormat: _(@"%@ erkrankt auch schwer, aber überlebt."), name];
            }
          else
            {
              sickness = [NSString stringWithFormat: _(@"%@ bleibt von der Krankheit verschont."), name];
            }
          
          NSString *whoStr;         
          if (eventResult == 1)
            {
              whoStr = _(@"Der Vater");
            }
          else if (eventResult == 2)
            {
              whoStr = _(@"Die Mutter");
            }
          else
            {
              if ([self.character.siblings count] == 0)
                {
                  if (eventResult == 3 || eventResult == 5)
                    {
                      whoStr = _(@"Der Vater");
                    }
                  else
                    {
                      whoStr = _(@"Die Mutter");
                    }                  
                }
              else if ([self.character.siblings count] == 1)
                {
                  if ([[[self.character.siblings objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
                    {
                      whoStr = _(@"Der Bruder");
                    }
                  else
                    {
                      whoStr = _(@"Die Schwester");
                    }
                }
              else
                {
                  whoStr = _(@"Eines der Geschwister");
                }
            }
          resultStr = [NSString stringWithFormat: _(@"Die Familie wird von einer schweren Krankheit heimgesucht. %@ stirbt dabei. %@."), whoStr, sickness];       
        }
      else if (eventResult == 20)
        {
           eventResult = [Utils rollDice: @"1W3"];
           NSString *whoStr;
           NSString *reason;
           if (eventResult == 1)
             {
               whoStr = _(@"der Orks");
             }
           if (eventResult == 2)
             {
               whoStr = _(@"von Ogern");
             }                
           else
             {
               whoStr = _(@"von Räubern");
             }
           reason = [NSString stringWithFormat: _(@"bei einem Überfall %@"), whoStr];
           eventResult = [Utils rollDice: @"1W3"];
           NSString *whatStr;
           if (eventResult == 1)
             {
               whatStr = [NSString stringWithFormat: _(@"%@ schlägt sich von nun an allein durch"), name];
             }
           else
             {
               whatStr = [NSString stringWithFormat: _(@"%@ wird von einer Pflegefamilie aufgenommen"), name];
             }
           resultStr = [NSString stringWithFormat: _(@"Die gesamte Familie kommt %@ ums Leben. %@."), reason, whatStr];
        }
      [resultArr addObject: resultStr];  
      cnt++;
    }
  return resultArr;
}

- (NSArray *) resolveYouthEventsFromParameters:(NSDictionary *)parameters {
  NSArray *youthEvents = parameters[@"youthEvents"];
  if (youthEvents)
    {
      return youthEvents;
    }
  NSString *selectedArchetype = self.character.archetype;
  NSString *name = self.character.name;

  NSInteger eventCount = [Utils rollDice: @"1W3"];
  NSMutableArray *resultArr = [[NSMutableArray alloc] init];
  
  NSMutableArray *tracker = [[NSMutableArray alloc] init];
  
  NSInteger cnt = 0;
  
  NSString *pronoun;
  NSString *pronounUpper;
  NSString *personalPronounDativ;
  NSString *personalPronounDativUpper;
  NSString *personalPronounAkkusativ;
  NSString *possesivPronounDativ;
  NSString *possesivPronounAkkusativ;
  NSString *whateverTypeOfWord1Upper;
  if ([self.character.sex isEqualToString: _(@"männlich")])
    {
      pronoun = _(@"er");
      pronounUpper = _(@"Er");
      personalPronounDativ = _(@"ihm");
      personalPronounDativUpper = _(@"Ihm");
      personalPronounAkkusativ = _(@"ihn");
      possesivPronounDativ = _(@"seiner");
      possesivPronounAkkusativ = _(@"sein");
      whateverTypeOfWord1Upper = _(@"Dieser");
    }
  else
    {
      pronoun = _(@"sie");
      pronounUpper = _(@"Sie");
      personalPronounDativ = _(@"ihr");
      personalPronounDativUpper = _(@"Ihr");
      personalPronounAkkusativ = _(@"sie");
      possesivPronounDativ = _(@"ihrer");
      possesivPronounAkkusativ = _(@"ihr");
      whateverTypeOfWord1Upper = _(@"Diese");
    }
  
  while (cnt < eventCount)
    {
      NSInteger eventResult = [Utils rollDice: @"1W20"];
      NSString *resultStr;
      NSString *whatStr;
      NSInteger testValue = 0;
      if ([tracker containsObject: [NSNumber numberWithInteger: eventResult]])
        {
          continue;  // we don't want to have the same event happen twice
        }
      else
        {
          [tracker addObject: [NSNumber numberWithInteger: eventResult]];
        }
      if (eventResult >= 1 && eventResult <= 4)
        {
          eventResult = [Utils rollDice: @"1W13"];
          NSString *godStr;
          if (eventResult == 1)
            {
              godStr = _(@"des Praios");
            }
          else if (eventResult == 2)
            {
              godStr = _(@"der Rondra");
            }
          else if (eventResult == 3)
            {
              godStr = _(@"des Efferd");
            }
          else if (eventResult == 4)
            {
              godStr = _(@"der Travia");
            }
          else if (eventResult == 5)
            {
              godStr = _(@"des Boron");
            }
          else if (eventResult == 6)
            {
              godStr = _(@"der Hesinde");
            }
          else if (eventResult == 7)
            {
              godStr = _(@"des Firun");
            }
          else if (eventResult == 8)
            {
              godStr = _(@"der Tsa");
            }
          else if (eventResult == 9)
            {
              godStr = _(@"des Phes");
            }
          else if (eventResult == 10)
            {
              godStr = _(@"der Peraine");
            }
          else if (eventResult == 11)
            {
              godStr = _(@"des Ingerimm");
            }
          else if (eventResult == 12)
            {
              godStr = _(@"der Rahja");
            }
          eventResult = [Utils rollDice: @"1W6"];
          if (eventResult == 1 || eventResult == 2)
            {
              whatStr = [NSString stringWithFormat: _(@"Nach dieser Zeit entscheidet %@ sich, Geweihter zu werden."), pronoun];
            }
          else if (eventResult == 3 || eventResult == 4)
            {
              whatStr = [NSString stringWithFormat: _(@"Nach dieser Zeit behält %@ einen starken Glauben an die Gottheit."), pronoun];              
            }
          else if (eventResult == 6)
            {
              whatStr = [NSString stringWithFormat: _(@"Nach dieser Zeit wendet %@ sich wieder von der Gottheit ab."), pronoun];              
            }
          resultStr = [NSString stringWithFormat: _(@"%@ durchlebt eine Phase der Frömmigkeit. %@ such die Nähe von Geweihten %@. %@"), name, pronounUpper, godStr, whatStr];
        }
      else if (eventResult == 5)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSInteger typusOffset = +3;
          NSString *akademieStr;
          if ([@[_(@"Krieger"), _(@"Magier")] containsObject: selectedArchetype])
            {
              typusOffset = -3;
            }
          testValue = eventResult + typusOffset;            
          if ([selectedArchetype isEqualToString: _(@"Magier")])
            {
              akademieStr = _(@"Magierakademie");
            }
          else if ([selectedArchetype isEqualToString: _(@"Krieger")])
            {
              akademieStr = _(@"Kriegerakademie");
            }
          else
            {
              eventResult = [Utils rollDice: @"1W2"];
              if (eventResult == 1)
                {
                  akademieStr = _(@"Magierakademie");
                }
              else
                {
                  akademieStr = _(@"Kriegerakademie");
                }            
            }

          if (testValue >= -2 && testValue <= 2)      
            {
              whatStr = [NSString stringWithFormat: _(@"%@ schafft den Abschluß."), pronounUpper];
            }
          else
            {
              whatStr = [NSString stringWithFormat: _(@"%@ fliegt von der Schule."), pronounUpper];
            }
          resultStr = [NSString stringWithFormat: _(@"%@ erhält ein Stipendium für eine %@. %@"), name, akademieStr, whatStr];
        }
      else if (eventResult == 6)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ hilft einem verletzen Tier, das %@ von nun an treu folgt."), name, personalPronounDativ];
        }
      else if (eventResult >= 7 && eventResult <= 11)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whatStr;
          if (eventResult == 1 || eventResult == 2)
            {
              whatStr = _(@" unsterblich, stößt aber nicht auf Gegenliebe.");
            }
          else if (eventResult == 3 || eventResult == 4)
            {
              whatStr = [NSString stringWithFormat: _(@", aber der geliebte Mensch zieht fort, und %@ kann ihn nicht mehr vergessen."), pronoun];
            }
          else if (eventResult == 5)
            {
              whatStr = _(@", doch der geliebte Mensch kommt ums Leben.");
            }
          else if (eventResult == 6)
            {
              whatStr = _(@"und stößt auf Gegenliebe.");
            }
          resultStr = [NSString stringWithFormat: _(@"%@ verliebt sich%@"), name, whatStr];
        }
      else if (eventResult == 12)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ trifft auf eine berühmte Persönlichkeit und ist von ihr sehr beeindruckt."), name];
        }
      else if (eventResult == 13)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whatStr;
          if (eventResult == 1)
            {
              whatStr = _(@"Eine Warnung im Traum rettet ihm das Leben.");
            }
          else if (eventResult == 2)
            {
              eventResult = [Utils rollDice: @"1W2"];
              NSString *whoStr;
              if (eventResult == 1)
                {
                  whoStr = _(@"Freund");
                }
              else 
                {
                  whoStr = _(@"Verwandten");
                }
              whatStr = [NSString stringWithFormat: _(@"%@ begegnet einem längst verstorbenem %@."), pronounUpper, whoStr];
            }
          else if (eventResult == 3)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ träumt von einer Queste. Der Gedanke daran läßt %@ nicht mehr los."), pronounUpper, personalPronounAkkusativ];
            }
          else if (eventResult == 4)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ steht einem wilden Tier gegenüber, kann diesem aber offenbar befehlen, nicht anzugreifen."), pronounUpper];
            }
          else if (eventResult == 5)
            {
              eventResult = [Utils rollDice: @"1W2"];
              NSString *whoStr;
              if (eventResult == 1)
                {
                  whoStr = _(@"einem Kobold");
                }
              else
                {
                  whoStr = _(@"einer Fee");
                }
              whatStr = [NSString stringWithFormat: _(@"%@ begegnet %@."), pronounUpper, whoStr];
            }
          else if (eventResult == 6)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ sieht ein Einhorn."), pronounUpper];
            }
          resultStr = [NSString stringWithFormat: _(@"%@ wiederfährt etwas Seltsames. %@"), name, whatStr];
        }
      else if (eventResult == 14)
        {
          if ([@[_(@"Krieger"), _(@"Magier")] containsObject: selectedArchetype])  //those go to academies
            {
              continue;
            }
          eventResult = [Utils rollDice: @"1W6"];
          NSInteger typusOffset = 0;
          if ([selectedArchetype isEqualToString: _(@"Streuner")])
            {
              typusOffset = -1;
            }
          testValue = eventResult + typusOffset;
          if (testValue >= 0 && testValue <= 5)
            {
              eventResult = [Utils rollDice: @"1W3"];
              if (eventResult == 1)
                {
                  whatStr =[NSString stringWithFormat: _(@"%@ bricht diese aber nach einem Jahr ab."), pronounUpper];
                }
              else
                {
                  whatStr = [NSString stringWithFormat: _(@"%@ bricht diese aber nach %lu Jahren ab."), pronounUpper, (unsigned long) eventResult];
                }
            }
          else
            {
              whatStr = [NSString stringWithFormat: _(@"%@ erhält die Freisprechung %@ Zunft."), pronounUpper, possesivPronounDativ];
            }
          resultStr = [NSString stringWithFormat: _(@"Wie es üblich ist, geht %@ bei einem Handwerker in die Lehre. %@"), name, whatStr];  
        }
      else if (eventResult == 15)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSInteger typusOffset = 0;
          if ([selectedArchetype isEqualToString: _(@"Streuner")])
            {
              typusOffset = 2;
            }
          NSInteger testValue = eventResult + typusOffset;
          NSString *whatStr;
          if (testValue >= 1 && testValue <= 4)
            {
              whatStr = _(@"schlägt sich von nun an alleine durch.");
            }
          else if (testValue == 5)
            {
              whatStr = _(@"beginnt in jungen Jahren ein Abenteuerleben.");
            }
          else
            {
              whatStr = _(@"wird von einer anderen Familie aufgenommen.");
            }
          resultStr = [NSString stringWithFormat: _(@"Die Eltern können ihre Familie nicht mehr ernähren, und schicken deshalb %@ fort, allein %@ Glück zu machen. %@ %@"), name, possesivPronounAkkusativ, pronounUpper, whatStr];
        } 
      else if (eventResult == 16)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whoStr;
          if ([self.character.sex isEqualToString: _(@"männlich")])
            {
              whoStr = _(@"einen Rivalen");
            }
          else
            {
              whoStr = _(@"eine Rivalin");
            }          
          if (eventResult == 1)
            {
              if ([self.character.sex isEqualToString: _(@"männlich")])
                {
                  whatStr = _(@"Dieser ist ein alter Familienfeind.");
                }
              else
                {
                  whatStr = _(@"Diese ist eine alte Feindin der Familie.");
                }
            }
          else if (eventResult == 2)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ ist neidisch auf das Äußere von %@."), whateverTypeOfWord1Upper, name];
            }
          else if (eventResult == 3)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ ist neidisch auf ein Besitzstück von %@."), whateverTypeOfWord1Upper, personalPronounDativ];
            }
          else if (eventResult >= 4 && eventResult <= 6)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ ist in die selbe Person verliebt wie %@."), whateverTypeOfWord1Upper, pronoun];
            }
          resultStr = [NSString stringWithFormat: _(@"%@ hat %@. %@"), name, whoStr, whatStr];
        }
      else if (eventResult == 17 || eventResult == 18)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whoStr;
          if ([self.character.sex isEqualToString: _(@"männlich")])
            {
              whoStr = _(@"die zukünftige Ehepartnerin");
            }
          else
            {
              whoStr = _(@"der zukunftige Ehepartner");
            }          
          NSInteger typusOffset = 0;
          if ([selectedArchetype isEqualToString: _(@"Streuner")])
            {
              typusOffset = -1;
            }
          NSInteger testValue = eventResult + typusOffset;
          if (testValue >= 0 && testValue <= 5)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ schlägt sich von nun an allein durchs Leben."), pronounUpper];
            }
          else
            {
              whatStr = [NSString stringWithFormat: _(@"%@ wird von einer anderen Familie aufgenommen."), pronounUpper];
            }
            
          resultStr = [NSString stringWithFormat: _(@"%@ soll verheiratet werden. %@ jedoch gefällt %@ nicht, so das %@ fortläuft. %@"), name, personalPronounDativUpper, whoStr, pronoun, whatStr];
        }
      else if (eventResult == 19)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird von einem wilden Tier schwer verletzt."), name];        
        }
      else if (eventResult == 20)      
        {
           eventResult = [Utils rollDice: @"1W3"];
           NSString *whoStr;
           NSString *reason;
           if (eventResult == 1)
             {
               whoStr = _(@"der Orks");
             }
           if (eventResult == 2)
             {
               whoStr = _(@"von Ogern");
             }                
           else
             {
               whoStr = _(@"von Räubern");
             }
           reason = [NSString stringWithFormat: _(@"bei einem Überfall %@"), whoStr];
           eventResult = [Utils rollDice: @"1W6"];
           NSString *whatStr;
           if (eventResult == 1 || eventResult == 2)
             {
               whatStr = [NSString stringWithFormat: _(@"%@ schlägt sich von nun an allein durch"), name];
             }
           else
             {
               whatStr = [NSString stringWithFormat: _(@"%@ wird von einer Pflegefamilie aufgenommen"), name];
             }
           resultStr = [NSString stringWithFormat: _(@"Die gesamte Familie kommt %@ ums Leben. %@."), reason, whatStr];
        }      
        
      [resultArr addObject: resultStr];
      cnt++;
    }
  return resultArr;   
}

- (NSString *) resolvePortraitNameFromParameters:(NSDictionary *)parameters {
  NSString *portraitName = parameters[@"portraitName"];
  if (portraitName)
    {
      return portraitName;
    }

  NSString *selectedArchetype = self.character.archetype;
  NSString *sex = self.character.sex;
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: selectedArchetype]];
  NSArray *subtypen = [[charConstraints objectForKey: @"Subtypen"] allKeys];
  NSString *subtype;
  if (subtypen)
    {
      if ([subtypen containsObject: selectedArchetype])
        {
          subtype = selectedArchetype;
        }
    }
  
  NSArray *portraitNames = [[[[charConstraints objectForKey: @"Subtypen"]
                                               objectForKey: subtype]
                                               objectForKey: @"Images"]
                                               objectForKey: sex];
  if ([portraitNames count] == 0)
    {
      portraitNames = [[charConstraints objectForKey: @"Images"]
                                        objectForKey: sex];
    }
  NSUInteger randomIndex = arc4random_uniform((uint32_t) [portraitNames count]);
  
  return [portraitNames objectAtIndex: randomIndex];
}

- (NSString *) resolveAcademyFromParameters:(NSDictionary *)parameters {
  NSString *academy = parameters[@"academy"];
  if (academy)
    {
      return academy;
    }

  NSString *selectedArchetype = self.character.archetype;
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: selectedArchetype]];
  NSArray *academies;
  if ([self.character isMemberOfClass: [DSACharacterHeroHumanMage class]])
    {
       academies = [[Utils getMageAcademiesDict] allKeys];
       NSInteger randomIndex = arc4random_uniform([academies count]);
       academy = [academies objectAtIndex: randomIndex];
    }
  else if ([self.character isMemberOfClass: [DSACharacterHeroDwarfGeode class]])
    {
       academies = [charConstraints objectForKey: @"Schule"];
       NSInteger randomIndex = arc4random_uniform([academies count]);
       academy = [academies objectAtIndex: randomIndex];      
    }
  else if ([self.character isMemberOfClass: [DSACharacterHeroHumanWarrior class]])
    {
       academies = [[Utils getWarriorAcademiesDict] allKeys];
       NSInteger randomIndex = arc4random_uniform([academies count]);
       academy = [academies objectAtIndex: randomIndex];
    }
  return academy;
}

/* generates positive traits, as described in
   "Mit Mantel, Schwert und Zauberstab" S. 7,
   8 * 1W6 + 7, then discard lowest result */

- (NSArray *) generatePositiveTraits
{
  NSMutableArray *traits = [[NSMutableArray alloc] init];
  NSInteger cnt;
  NSInteger lowest = 14;
  for ( cnt = 1; cnt < 9; cnt++ )
    {
      NSInteger result;
      result = [Utils rollDice: @"1W6"] + 7;
      if (result < lowest)
        {
          lowest = result;
        }
      [traits addObject: [NSNumber numberWithInt: result]];
    }
  [traits removeObjectAtIndex:[traits indexOfObject: [NSNumber numberWithInt: lowest]]];
  
  return traits;
}

/* generates negative traits, as described in
   "Mit Mantel, Schwert und Zauberstab" S. 7,
   7 * 1W6 + 1 */

- (NSArray *) generateNegativeTraits
{
  NSMutableArray *traits = [[NSMutableArray alloc] init];
  NSInteger cnt;
  for ( cnt = 1; cnt < 8; cnt++ )
    {
      NSInteger result;
      result = [Utils rollDice: @"1W6"] + 1;
      [traits addObject: [NSNumber numberWithInt: result]];
    }
  
  return traits;
}

- (NSDictionary *) generatePositiveTraitConstraints {
  // start with the basic archetype constraints
  NSString *archetype = self.character.archetype;
  NSString *origin = self.character.origin;
  NSMutableDictionary *professions = self.character.professions;
  BOOL isMagicalDabbler = self.character.isMagicalDabbler;
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: archetype]];

  NSDictionary *traitsDict = [NSDictionary dictionaryWithDictionary: [charConstraints objectForKey: @"Eigenschaften"]];
  NSMutableDictionary *positiveTraitsConstraintsDict = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {         
      if ([traitsDict objectForKey: field])
        {
          [positiveTraitsConstraintsDict setObject: [traitsDict objectForKey: field] forKey: field];
        }
    }
    
  // some origins have extra constraints
  NSDictionary *originConstraints = [[[Utils getOriginsDict] objectForKey: origin] objectForKey: @"Basiswerte"];  
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {        
      if ([originConstraints objectForKey: field])
        {
          [positiveTraitsConstraintsDict setObject: [originConstraints objectForKey: field] forKey: field];              
        }
    }
    
  // some professions have extra constraints as well
  for (NSString *profession in [professions allKeys])
    {
      NSDictionary *professionConstraints = [[[[Utils getProfessionsDict] objectForKey: profession] objectForKey: @"Bedingung"] objectForKey: @"Basiswerte"];  
      for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
        {          
          if ([professionConstraints objectForKey: field])
            {
              [positiveTraitsConstraintsDict setObject: [professionConstraints objectForKey: field] forKey: field];             
            }
        }
    }
    
  // last but not least, the magical dabbler has it's own constraints
  if (isMagicalDabbler)
    {      
      // As described in "Die Magie des Schwarzen Auges", S. 36
      NSDictionary *magicDabblerConstraints = @{ @"KL": @"10+", @"IN": @"13+"};
      for (NSString *field in @[ @"KL", @"IN" ])
        {
          NSString *curVal = [positiveTraitsConstraintsDict objectForKey: field];
          NSString *curValNr = [curVal stringByReplacingOccurrencesOfString:@"+" withString:@""];
          NSString *dabblerValNr = [[magicDabblerConstraints objectForKey: field] stringByReplacingOccurrencesOfString: @"+" withString: @""];
          if ([curValNr integerValue] < [dabblerValNr integerValue])
            {
              [positiveTraitsConstraintsDict setObject: [magicDabblerConstraints objectForKey: field] forKey: field];
            }             
        }
    }
  return positiveTraitsConstraintsDict;
}

- (NSDictionary *) generateNegativeTraitConstraints {
  // start with the basic archetype constraints
  NSString *archetype = self.character.archetype;
  NSString *origin = self.character.origin;
  NSMutableDictionary *professions = self.character.professions;
  BOOL isMagicalDabbler = self.character.isMagicalDabbler;
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: archetype]];

  NSDictionary *traitsDict = [NSDictionary dictionaryWithDictionary: [charConstraints objectForKey: @"Eigenschaften"]];
  NSMutableDictionary *negativeTraitsConstraintsDict = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {         
      if ([traitsDict objectForKey: field])
        {
          [negativeTraitsConstraintsDict setObject: [traitsDict objectForKey: field] forKey: field];
        }
    }
    
  // some origins have extra constraints
  NSDictionary *originConstraints = [[[Utils getOriginsDict] objectForKey: origin] objectForKey: @"Basiswerte"];  
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {        
      if ([originConstraints objectForKey: field])
        {
          [negativeTraitsConstraintsDict setObject: [originConstraints objectForKey: field] forKey: field];              
        }
    }
    
  // some professions have extra constraints as well
  for (NSString *profession in [professions allKeys])
    {
      NSDictionary *professionConstraints = [[[[Utils getProfessionsDict] objectForKey: profession] objectForKey: @"Bedingung"] objectForKey: @"Basiswerte"];  
      for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
        {          
          if ([professionConstraints objectForKey: field])
            {
              [negativeTraitsConstraintsDict setObject: [professionConstraints objectForKey: field] forKey: field];             
            }
        }
    }
    
  // last but not least, the magical dabbler has it's own constraints
  if (isMagicalDabbler)
    {      
      // As described in "Die Magie des Schwarzen Auges", S. 36
      NSDictionary *magicDabblerConstraints = @{ @"AG": @"6+" };
      for (NSString *field in @[ @"AG" ])
        {
          NSString *curVal = [negativeTraitsConstraintsDict objectForKey: field];
          NSString *curValNr = [curVal stringByReplacingOccurrencesOfString:@"+" withString:@""];
          NSString *dabblerValNr = [[magicDabblerConstraints objectForKey: field] stringByReplacingOccurrencesOfString: @"+" withString: @""];
          if ([curValNr integerValue] < [dabblerValNr integerValue])
            {
              [negativeTraitsConstraintsDict setObject: [magicDabblerConstraints objectForKey: field] forKey: field];
            }             
        }
    }
  return negativeTraitsConstraintsDict;
}

- (BOOL) verifyTraitValue: (NSInteger) traitValue againstConstraint: (NSString *) traitConstraint
{
  NSMutableDictionary *constraint = [[NSMutableDictionary alloc] init];
  if ([traitConstraint length] > 0)
    {
      [constraint removeAllObjects];
      [constraint addEntriesFromDictionary: [Utils parseConstraint: traitConstraint]];
      if ([[constraint objectForKey: @"constraint"] isEqualToString: @"MAX"])
        {
          if (traitValue < [[constraint objectForKey: @"value"] integerValue])
            {
              return NO;
            }
          else
            {
              return YES;
            }
        }
      else
        {
          if (traitValue > [[constraint objectForKey: @"value"] integerValue])
            {
              return NO;
            }        
          else
            {
              return YES;
            }            
        }
    }
  return YES;
}

- (NSMutableDictionary *) resolvePositiveTraitsFromParameters:(NSDictionary *)parameters {
  NSMutableDictionary *positiveTraits = parameters[@"positiveTraits"];
  
  if (positiveTraits)
    {
      NSLog(@"DSACharacterGenerator resolvePositiveTraitsFromParameters got positive traits: %@", positiveTraits);
      return positiveTraits;
    }
  NSLog(@"DSACharacterGenerator resolvePositiveTraitsFromParameters going to generate positive traits");
  positiveTraits = [[NSMutableDictionary alloc] init];

  NSArray *positiveTraitsArr = [self generatePositiveTraits];
  NSDictionary *traitConstraints = [self generatePositiveTraitConstraints];
  BOOL all_good = NO;
 
  do
    {
      NSInteger cnt = 0;
      for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
        {
          NSInteger traitValue = [[positiveTraitsArr objectAtIndex: cnt] integerValue];
          all_good = [self verifyTraitValue: traitValue againstConstraint: [traitConstraints objectForKey: field]];
          if (!all_good)
            {
              break;  // break out of the for loop, to start all over
            }
          [positiveTraits setObject: 
            [[DSAPositiveTrait alloc] initTrait: field 
                                        onLevel: traitValue]
                             forKey: field];
        }
    }
  while (!all_good);
  
  return positiveTraits;
}

- (NSMutableDictionary *) resolveNegativeTraitsFromParameters:(NSDictionary *)parameters {
  NSMutableDictionary *negativeTraits = parameters[@"negativeTraits"];
  if (negativeTraits)
    {
      NSLog(@"DSACharacterGenerator resolveNegativeTraitsFromParameters got positive traits: %@", negativeTraits);
      return negativeTraits;
    }

  negativeTraits = [[NSMutableDictionary alloc] init];

  NSArray *negativeTraitsArr = [self generateNegativeTraits];
  NSDictionary *traitConstraints = [self generateNegativeTraitConstraints];
  BOOL all_good = NO;
 
  do
    {
      NSInteger cnt = 0;
      for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
        {
          NSInteger traitValue = [[negativeTraitsArr objectAtIndex: cnt] integerValue];
          all_good = [self verifyTraitValue: traitValue againstConstraint: [traitConstraints objectForKey: field]];
          if (!all_good)
            {
              break;  // break out of the for loop, to start all over
            }
          [negativeTraits setObject: 
            [[DSAPositiveTrait alloc] initTrait: field 
                                        onLevel: traitValue]
                             forKey: field];
        }
    }
  while (!all_good);
  
  return negativeTraits;
}

- (NSMutableDictionary *) resolveTalentsFromParameters:(NSDictionary *)parameters {
  NSMutableDictionary *talentsDict = parameters[@"talents"];
  if (talentsDict)
    {
      return talentsDict;
    }

  // handle talents
  NSDictionary *talents = [[NSDictionary alloc] init];
  talents = [Utils getTalentsForCharacter: self.character];
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

- (NSMutableDictionary *) resolveSpellsFromParameters:(NSDictionary *)parameters {
  NSMutableDictionary *spellsDict = parameters[@"spells"];
  if (spellsDict)
    {
      return spellsDict;
    }
  NSLog(@"DSACharacterGenerator character going to generate spells");  
  NSMutableDictionary *newSpells = [[NSMutableDictionary alloc] init];
  //NSLog(@"THE CHARACTER SO FAR: %@", self.character);
  NSLog(@"The character IS MAGIC %@ ?????", [NSNumber numberWithBool: self.character.isMagic]);
  if (self.character.isMagic)
    {
      NSLog(@"DSACharacterGenerator character isMagic!!!!");
      NSDictionary *spells = [[NSDictionary alloc] init];
      
      spells = [Utils getSpellsForCharacter: self.character];
      NSLog(@"GOT SPELLS FROM UTILS: %@", [spells allKeys]);
      for (NSString *category in spells)
        {
          for (NSString *s in [spells objectForKey: category])
            {
              NSDictionary *sDict = [[spells objectForKey: category] objectForKey: s];
              DSASpell *spell = [DSASpell spellWithName: s
                                              ofVariant: [sDict objectForKey: @"Variante"]
                                      ofDurationVariant: [sDict objectForKey: @"Dauer Variante"]
                                             ofCategory: category
                                                onLevel: [[sDict objectForKey: @"Startwert"] integerValue]
                                             withOrigin: [sDict objectForKey: @"Ursprung"]
                                               withTest: [sDict objectForKey: @"Probe"]
                                        withMaxDistance: [[sDict objectForKey: @"Maximale Entfernung" ] integerValue]       
                                           withVariants: [sDict objectForKey: @"Varianten"]     
                                   withDurationVariants: [sDict objectForKey: @"Dauer Varianten"]                                             
                                 withMaxTriesPerLevelUp: [[sDict objectForKey: @"Versuche"] integerValue]
                                      withMaxUpPerLevel: [[sDict objectForKey: @"Steigern"] integerValue]
                                        withLevelUpCost: 1];
              if (!spell) // as long as not every spell is implemented in it's own subclass, fall back to this simple default...
                {
                    spell = [[DSASpell alloc] initSpell: s
                                                  ofVariant: [sDict objectForKey: @"Variante"]
                                          ofDurationVariant: [sDict objectForKey: @"Dauer Variante"]           
                                                 ofCategory: category
                                                    onLevel: [[sDict objectForKey: @"Startwert"] integerValue]
                                                 withOrigin: [sDict objectForKey: @"Ursprung"]
                                                   withTest: [sDict objectForKey: @"Probe"]
                                            withMaxDistance: [[sDict objectForKey: @"Maximale Entfernung" ] integerValue]       
                                               withVariants: [sDict objectForKey: @"Varianten"]
                                       withDurationVariants: [sDict objectForKey: @"Dauer Varianten"]                                                    
                                     withMaxTriesPerLevelUp: [[sDict objectForKey: @"Versuche"] integerValue]
                                          withMaxUpPerLevel: [[sDict objectForKey: @"Steigern"] integerValue]
                                            withLevelUpCost: 1];
                 }
              [spell setElement: [sDict objectForKey: @"Element"]];
              [newSpells setObject: spell forKey: s];
            }
        }
    }
  else
    {
      NSLog(@"The character IS NOT MAGIC %@", [NSNumber numberWithBool: self.character.isMagic]);
    }
  NSLog(@"returning newSpells: %@", [newSpells allKeys]);
  return newSpells;  
}

-(void) applySpecialsToCharacter {
  DSACharacter *newCharacter = self.character;
  
  if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanWitch class]])
    {
      [self addWitchCursesToCharacter: newCharacter];
    }
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanDruid class]])
    {
      [self addDruidRitualsToCharacter: newCharacter];
    }
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroDwarfGeode class]])
    {
      [self addGeodeRitualsToCharacter: newCharacter];
    }
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanMage class]])
    {
      [self addMageRitualsToCharacter: newCharacter];
    }
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanSharisad class]])
    {
      [self addSharisadDancesToCharacter: newCharacter];
    }       
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanShaman class]])
    {
      [self addShamanRitualsToCharacter: newCharacter];
      if (newCharacter.isMagic)
        {
          [self addDruidRitualsToCharacter: newCharacter];
        }
    }        
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanJester class]])
    {
      [self addMischievousPranksToCharacter: newCharacter];
    }
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroElfMeadow class]] ||
           [newCharacter isMemberOfClass: [DSACharacterHeroElfSnow class]] || 
           [newCharacter isMemberOfClass: [DSACharacterHeroElfWood class]] )
    {
      [self addElvenSongsToCharacter: newCharacter];
    }
  else if ([newCharacter isKindOfClass: [DSACharacterHeroBlessed class]])
    {
      [self addBlessedLiturgiesToCharacter: newCharacter];
    }
}

- (void) addElvenSongsToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *song in [[Utils getElvenSongsDict] allKeys])
    {
      NSLog(@"checking song: %@", song);
      DSASpellElvenSong *s = [[DSASpellElvenSong alloc] initSpell: song
                                                         withTest: [[[Utils getElvenSongsDict] objectForKey: song] objectForKey: @"Probe" ]];                
      [specialTalents setObject: s forKey: song];
    }
  [character setSpecials: specialTalents];  
}

- (void) addBlessedLiturgiesToCharacter: (DSACharacter *) character
{
  NSDictionary *blessedLiturgiesDict = [Utils getBlessedLiturgiesDict];
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *category in [blessedLiturgiesDict allKeys])
    {
      if ([category isEqualToString: @"META"])
        {
          continue;
        }    
      for (NSString *liturgy in [blessedLiturgiesDict objectForKey: category])
        {
          if ([[[[blessedLiturgiesDict objectForKey: category] objectForKey: liturgy] objectForKey: @"Anwender"] containsObject: character.religion] ||
              ([[[[blessedLiturgiesDict objectForKey: category] objectForKey: liturgy] objectForKey: @"Anwender"] count] == 0 && 
              ![[[[blessedLiturgiesDict objectForKey: category] objectForKey: liturgy] objectForKey: @"Nicht Anwender"] containsObject: character.religion]))
            {
              DSALiturgy *l = [[DSALiturgy alloc] initLiturgy: liturgy
                                                   ofCategory: category];
              [specialTalents setObject: l forKey: liturgy];
            }
        }
    }
  [character setSpecials: specialTalents];  
}

- (void) addShamanRitualsToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *category in [[Utils getShamanRitualsDict] allKeys])
    {
      for (NSString *ritual in [[Utils getShamanRitualsDict] objectForKey: category])
        {
          if ([[[[[Utils getShamanRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Typen"] containsObject: self.character.origin])
            {
              DSASpellShamanRitual *r = [[DSASpellShamanRitual alloc] initSpell: ritual
                                                                       withTest: [[[[Utils getShamanRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probe" ]];
              [specialTalents setObject: r forKey: ritual];
            }
        }
    }
  [character setSpecials: specialTalents];  
}

- (void) addSharisadDancesToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];
  NSString *origin = character.origin;
  NSString *religion = character.religion;
NSLog(@"DSACharacterGenerationController addSharisadDancesToCharacter called");  
  NSDictionary *dances = [[Utils getSharisadDancesDict] objectForKey: @"Magische Tänze"];
  
  for (NSString *dance in dances)
    {
      NSLog(@"THE DANCE: %@", dance);
      if ([[dances objectForKey: dance] objectForKey: @"Glaube"])  // only in case Glaube is set, we have to ensure that the characters religion matches, otherwise, we don't care
        {
          NSLog(@"XXX %@ %@", [[dances objectForKey: dance] objectForKey: @"Glaube"], religion);
          if (![[[dances objectForKey: dance] objectForKey: @"Glaube"] containsObject: religion])
            {
              NSLog(@"continuing...");
              continue;
            }
        }
      NSLog(@"now looking for origin: %@", origin);  
      if ([[[dances objectForKey: dance] objectForKey: @"Typen"] containsObject: origin])
        {
          NSLog(@"yuck!");
          DSASpellSharisadDance *d = [[DSASpellSharisadDance alloc] initSpell: dance
                                                                     withTest: [[dances objectForKey: dance] objectForKey: @"Probe"]];
          d.isTraditionSpell = YES;                                                                     
          [specialTalents setObject: d forKey: dance];
        }
    }
  NSLog(@"all the dances: %@", specialTalents);    
  [character setSpecials: specialTalents];
  character.isMagic = YES;
  character.maxLevelUpSpellsTries = [character.specials count] * 3;  // depending on number of spells, see: Die Magie des Schwarzen Auges S. 48
}

- (void) addGeodeRitualsToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *category in [[Utils getGeodeRitualsDict] allKeys])
    {
      if ([category isEqualToString: @"META"])
        {
          continue;
        }
      for (NSString *ritual in [[Utils getGeodeRitualsDict] objectForKey: category])
        {
          if ([[[[[Utils getGeodeRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Typen"] containsObject: self.character.mageAcademy])
            {
              DSASpellGeodeRitual *r = [[DSASpellGeodeRitual alloc] initSpell: ritual
                                                                   ofCategory: category
                                                                     withTest: [[[[Utils getGeodeRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probe" ]
                                                                    isLearned: NO];                                                          
              [specialTalents setObject: r forKey: ritual];
            }
        }
    }
  [character setSpecials: specialTalents];  
}

- (void) addMageRitualsToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *category in [[Utils getMageRitualsDict] allKeys])
    {
      if ([category isEqualToString: @"META"])
        {
          continue;
        }
      for (NSString *ritual in [[Utils getMageRitualsDict] objectForKey: category])
        {
            NSDictionary *ritualDict = [[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual];
            DSASpellMageRitual *r = [DSASpellMageRitual ritualWithName: ritual
                                                             ofVariant: [ritualDict objectForKey: @"Variante" ]
                                                     ofDurationVariant: [ritualDict objectForKey: @"Dauer Variante" ]
                                                            ofCategory: category
                                                              withTest: [ritualDict objectForKey: @"Probe" ]
                                                       withMaxDistance: [[ritualDict objectForKey: @"Maximale Entfernung" ] integerValue]
                                                          withVariants: [ritualDict objectForKey: @"Varianten" ]
                                                  withDurationVariants: [ritualDict objectForKey: @"Dauer Varianten" ]
                                                           withPenalty: [[ritualDict objectForKey: @"Probenaufschlag" ] integerValue]
                                                           withASPCost: [ritualDict objectForKey: @"ASP Kosten" ] ? [[ritualDict objectForKey: @"ASP Kosten" ] integerValue]: 0
                                                  withPermanentASPCost: [ritualDict objectForKey: @"davon permanente ASP Kosten" ] ? [[ritualDict objectForKey: @"davon permanente ASP Kosten" ] integerValue]: 0
                                                            withLPCost: [[ritualDict objectForKey: @"LP Kosten" ] integerValue] ? [[ritualDict objectForKey: @"LP Kosten" ] integerValue]: 0
                                                   withPermanentLPCost: [ritualDict objectForKey: @"davon permanente LP Kosten" ] ? [[ritualDict objectForKey: @"davon permanente LP Kosten" ] integerValue]: 0];
            if (!r)
              {
                r = [[DSASpellMageRitual alloc] initRitual: ritual
                                                 ofVariant: [ritualDict objectForKey: @"Variante" ]
                                         ofDurationVariant: [ritualDict objectForKey: @"Dauer Variante" ]
                                                ofCategory: category
                                                  withTest: [ritualDict objectForKey: @"Probe" ]
                                           withMaxDistance: [[ritualDict objectForKey: @"Maximale Entfernung" ] integerValue]       
                                              withVariants: [ritualDict objectForKey: @"Varianten" ]
                                      withDurationVariants: [ritualDict objectForKey: @"Dauer Varianten" ]       
                                               withPenalty: [[ritualDict objectForKey: @"Probenaufschlag" ] integerValue]
                                               withASPCost: [ritualDict objectForKey: @"ASP Kosten" ] ? [[ritualDict objectForKey: @"ASP Kosten" ] integerValue]: 0
                                      withPermanentASPCost: [ritualDict objectForKey: @"davon permanente ASP Kosten" ] ? [[ritualDict objectForKey: @"davon permanente ASP Kosten" ] integerValue]: 0
                                                withLPCost: [[ritualDict objectForKey: @"LP Kosten" ] integerValue] ? [[ritualDict objectForKey: @"LP Kosten" ] integerValue]: 0
                                       withPermanentLPCost: [ritualDict objectForKey: @"davon permanente LP Kosten" ] ? [[ritualDict objectForKey: @"davon permanente LP Kosten" ] integerValue]: 0];              
              }
            [specialTalents setObject: r forKey: ritual];
        }
    }
  [character setSpecials: specialTalents];  
}

- (void) addMischievousPranksToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *prank in [[Utils getMischievousPranksDict] allKeys])
    {
      NSLog(@"checking prank: %@", prank);
      DSASpellMischievousPrank *p = [[DSASpellMischievousPrank alloc] initSpell: prank
                                                                       withTest: [[[Utils getMischievousPranksDict] objectForKey: prank] objectForKey: @"Probe" ]
                                                                      isLearned: NO];                                                          
      [specialTalents setObject: p forKey: prank];
    }
  [character setSpecials: specialTalents];  
}

- (void) addWitchCursesToCharacter: (DSACharacter *) character
{
  NSDictionary *curses = [[Utils getWitchCursesDict] objectForKey: @"Flüche"];

  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *curse in [curses allKeys])
    {
      NSLog(@"checking curse: %@", curse);
      DSASpellWitchCurse *spell = [[DSASpellWitchCurse alloc] initSpell: curse
                                                               withTest: @[ @"KL", @"IN", @"CH", [[curses objectForKey: curse] objectForKey: @"PenaltyLernen"]]
                                                              isLearned: NO];                                                          
      [specialTalents setObject: spell forKey: curse];
    }
  [character setSpecials: specialTalents];  
}

- (void) addDruidRitualsToCharacter: (DSACharacter *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];
  if ([character specials]) // there might be shaman rituals already
    {
      specialTalents = [[character specials] mutableCopy];  
    }
  for (NSString *category in [[Utils getDruidRitualsDict] allKeys])
    {
      if ([category isEqualToString: @"META"])
        {
          continue;
        }
      for (NSString *ritualName in [[[Utils getDruidRitualsDict] objectForKey: category] allKeys])
        {
          NSLog(@"Checking if Typen contains: %@ XXX %@", character.archetype, [[[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: ritualName] objectForKey: @"Typen"]);
          NSDictionary *ritualDict = [[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: ritualName];
          if ([[ritualDict objectForKey: @"Typen"] containsObject: character.archetype])
            {
             /* DSASpellDruidRitual *spell = [[DSASpellDruidRitual alloc] initSpell: spellName
                                                                        ofVariant: [ritualDict objectForKey: @"Variante"]
                                                                ofDurationVariant: [ritualDict objectForKey: @"Dauer Variante"]
                                                                       ofCategory: category
                                                                          onLevel: 0
                                                                       withOrigin: nil
                                                                         withTest: [ritualDict objectForKey: @"Probe"]
                                                                     withVariants: [ritualDict objectForKey: @"Varianten"]
                                                             withDurationVariants: [ritualDict objectForKey: @"Dauer Varianten"]
                                                           withMaxTriesPerLevelUp: 0
                                                                withMaxUpPerLevel: 0
                                                                  withLevelUpCost: 0];
               */                                                   
            NSDictionary *ritialDict = [[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: ritualName];
            DSASpellDruidRitual *r = [DSASpellDruidRitual ritualWithName: ritualName
                                                               ofVariant: [ritialDict objectForKey: @"Variante" ]
                                                       ofDurationVariant: [ritialDict objectForKey: @"Dauer Variante" ]
                                                              ofCategory: category
                                                                withTest: [ritialDict objectForKey: @"Probe" ]
                                                         withMaxDistance: [[ritialDict objectForKey: @"Maximale Entfernung" ] integerValue]         
                                                            withVariants: [ritialDict objectForKey: @"Varianten" ]
                                                    withDurationVariants: [ritialDict objectForKey: @"Dauer Varianten" ]
                                                             withPenalty: [[ritialDict objectForKey: @"Probenaufschlag" ] integerValue]
                                                             withASPCost: [ritialDict objectForKey: @"ASP Kosten" ] ? [[ritialDict objectForKey: @"ASP Kosten" ] integerValue]: 0
                                                    withPermanentASPCost: [ritialDict objectForKey: @"davon permanente ASP Kosten" ] ? [[ritialDict objectForKey: @"davon permanente ASP Kosten" ] integerValue]: 0
                                                              withLPCost: [[ritialDict objectForKey: @"LP Kosten" ] integerValue] ? [[ritialDict objectForKey: @"LP Kosten" ] integerValue]: 0
                                                     withPermanentLPCost: [ritialDict objectForKey: @"davon permanente LP Kosten" ] ? [[ritialDict objectForKey: @"davon permanente LP Kosten" ] integerValue]: 0];
            if (!r)  
              {
                r = [[DSASpellDruidRitual alloc] initRitual: ritualName
                                                  ofVariant: [ritialDict objectForKey: @"Variante" ]
                                          ofDurationVariant: [ritialDict objectForKey: @"Dauer Variante" ]
                                                 ofCategory: category
                                                   withTest: [ritialDict objectForKey: @"Probe" ]
                                            withMaxDistance: [[ritialDict objectForKey: @"Maximale Entfernung" ] integerValue]
                                               withVariants: [ritialDict objectForKey: @"Varianten" ]
                                       withDurationVariants: [ritialDict objectForKey: @"Dauer Varianten" ]       
                                                withPenalty: [[ritialDict objectForKey: @"Probenaufschlag" ] integerValue]
                                                withASPCost: [ritialDict objectForKey: @"ASP Kosten" ] ? [[ritialDict objectForKey: @"ASP Kosten" ] integerValue]: 0
                                       withPermanentASPCost: [ritialDict objectForKey: @"davon permanente ASP Kosten" ] ? [[ritialDict objectForKey: @"davon permanente ASP Kosten" ] integerValue]: 0
                                                 withLPCost: [[ritialDict objectForKey: @"LP Kosten" ] integerValue] ? [[ritialDict objectForKey: @"LP Kosten" ] integerValue]: 0
                                        withPermanentLPCost: [ritialDict objectForKey: @"davon permanente LP Kosten" ] ? [[ritialDict objectForKey: @"davon permanente LP Kosten" ] integerValue]: 0];              
              }                                                                  
                                                                  
                                                                  
              [specialTalents setObject: r forKey: ritualName];
               NSLog(@"YES");              
            }
          else
            {
               NSLog(@"NO");
            }
        }
    }
    NSLog(@"specialTalents: %@", specialTalents);
  [character setSpecials: specialTalents];
}

// to apply "Göttergeschenke", "Herkunfsmodifikatoren", etc.
- (void) apply: (NSString *) modificator toCharacter: (DSACharacter *) archetype
{
  NSMutableDictionary *traits = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *talents = [[NSMutableDictionary alloc] init];
  
  if ([@"Goettergeschenke" isEqualTo: modificator])
    {
      traits = [[[Utils getGodsDict] objectForKey: archetype.god] objectForKey: @"Basiswerte"];
      talents = [[[Utils getGodsDict] objectForKey: archetype.god] objectForKey: @"Talente"]; 
    }
  else if ([@"Herkunft" isEqualTo: modificator])
    {
      if ([archetype.archetype isEqualToString: _(@"Magier")])
        {
           NSLog(@"not applying Herkunft to archetype %@, die Magierakademie prägt mehr als die Herkunft.", archetype.archetype);
        }
      if ([archetype.archetype isEqualToString: _(@"Thorwaler")] || [archetype.archetype isEqualToString: _(@"Skalde")])
        {
           NSLog(@"not applying Herkunft to archetype %@, der Thorwaler bzw. Skalde hat schon ordentliche Thorwaler Werte ;)", archetype.archetype);
        }        
      else
        {
          talents = [[[Utils getOriginsDict] objectForKey: archetype.origin] objectForKey: @"Talente"];
        }
    }
  else if ([@"Kriegerakademie" isEqualTo: modificator])
    {
      talents = [[[Utils getWarriorAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Talente"];  // mageAcademy is misused here for the Kriegerakademie...
      archetype.firstLevelUpTalentTriesPenalty = [[[[Utils getWarriorAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Initiale Steigerungsversuche"] integerValue];
    }
  else if ([@"Magierakademie" isEqualTo: modificator])
    {
      if ([archetype.archetype isEqualToString: _(@"Magier")])
        {
          NSLog(@"applying Magierakademie modificators: %@", archetype.archetype);
          talents = [[[Utils getMageAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Talente"];
          NSLog(@"Talents: %@", talents);
        }
      else
        {
          NSLog(@"not applying Magierakademie modificator to archetype: %@", archetype.archetype);
        }
      NSDictionary *equipment = [[[Utils getMageAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Equipment"];
      if (equipment)
        {
          for (NSString *itemName in [equipment allKeys])
            {
              NSDictionary *itemInfo = [equipment objectForKey: itemName];
              NSMutableDictionary *itemDict = [[Utils getDSAObjectInfoByName: itemName] mutableCopy];
              if ([itemInfo objectForKey: @"Sprüche"])
                {
                  [itemDict setObject: [itemInfo objectForKey: @"Sprüche"] forKey: @"Sprüche"];
                }
              NSLog(@"THE ITEM DICT: %@", itemDict);
              DSAObject *item = [[DSAObject alloc] initWithObjectInfo: itemDict forOwner: archetype.modelID];
              for (NSString *spellName in item.appliedSpells)
                {
                  [[item.appliedSpells objectForKey: spellName] applyEffectOnTarget: item forOwner: archetype];  
                }
              NSLog(@"AFTER CREATING ITEM %@", item);
              if ([[itemInfo objectForKey: @"persönliches Objekt"] isEqualTo: @YES])
                {
                  [item setOwnerUUID: archetype.modelID];
                }
              [archetype.inventory addObject: item quantity: [[itemInfo objectForKey: @"Anzahl"] integerValue]];
            }
        }
    }
  else if ([@"Schamanenmodifikatoren" isEqualTo: modificator])
    {
      if ([archetype.archetype isEqualToString: _(@"Schamane")])
        {
          NSLog(@"applying Schamanenmodifikatoren origin: %@", archetype.origin);
          talents = [[[Utils getShamanOriginsDict] objectForKey: archetype.origin] objectForKey: @"Talente"];
          NSLog(@"Talents: %@", talents);
        }
      else
        {
          NSLog(@"not applying Schamanenmodifikatoren to archetype: %@", archetype.archetype);
        }
    }
  else
    {
      NSLog(@"Don't know how to apply modificator: %@", modificator);
    }  

  // positive traits
  if ([traits count] > 0)
    {
      for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
        {
          if ([[traits allKeys] containsObject: field])
            {
              [archetype setValue: [NSNumber numberWithInteger: [[archetype valueForKeyPath: [NSString stringWithFormat: @"positiveTraits.%@.level", field]] integerValue]  + 
                                   [[traits objectForKey: field] integerValue]]
                       forKeyPath: [NSString stringWithFormat: @"positiveTraits.%@.level", field]];
            }
        }
      // negative traits
      for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
        {
          if ([[traits allKeys] containsObject: field])
            {
              [archetype setValue: [NSNumber numberWithInteger: [[archetype valueForKeyPath: [NSString stringWithFormat: @"negativeTraits.%@.level", field]] integerValue]  + 
                                   [[traits objectForKey: field] integerValue]]
                       forKeyPath: [NSString stringWithFormat: @"negativeTraits.%@.level", field]];
            }
        }
    }
  for (NSString *category in [talents allKeys])
    {
      if ([category isEqualTo: @"Kampftechniken"])
        {
          for (NSString *subCategory in [talents objectForKey: category])
            {
              for (NSString *talent in [[talents objectForKey: category] objectForKey: subCategory])
                {
                  NSLog(@"testing talent: %@", talent);
                  NSInteger geschenk = [[archetype valueForKeyPath: [NSString stringWithFormat: @"talents.%@.level", talent]] integerValue] + 
                                                                    [[[[talents objectForKey: category] objectForKey: subCategory] objectForKey: talent] integerValue];
                  [archetype setValue: [NSNumber numberWithInteger: geschenk]
                           forKeyPath: [NSString stringWithFormat: @"talents.%@.level", talent]];
                }
            }
        }
      else
        {
          for (NSString *talent in [[talents objectForKey: category] allKeys])
            {
              NSLog(@"testing talent: %@", talent);
              NSInteger geschenk = [[archetype valueForKeyPath: [NSString stringWithFormat: @"talents.%@.level", talent]] integerValue] + [[[talents objectForKey: category] objectForKey: talent] integerValue];
              [archetype setValue: [NSNumber numberWithInteger: geschenk]             
                       forKeyPath: [NSString stringWithFormat: @"talents.%@.level", talent]];
            }
        }
    }    
}

- (void) addEquipmentToCharacter
{

  DSACharacter *character = self.character;
  
  NSDictionary *equipmentDict = [[[[[Utils getArchetypesDict] objectForKey: [character archetype]] 
                                                              objectForKey: @"Herkunft"] 
                                                              objectForKey: [character socialStatus]] 
                                                              objectForKey: @"Equipment"];
  NSLog(@"The EQUIPMENT DICT: %@", equipmentDict);
  for (NSString *equipment in equipmentDict)
    {
      NSDictionary *tEquipment = [equipmentDict objectForKey: equipment];
      DSAObject *item;
      NSLog(@"GOT THIS tEquipment HERE: %@", tEquipment);
      
      
      if ([tEquipment objectForKey: @"Sprüche"])
        {
          NSMutableDictionary *eEquipment = [[Utils getDSAObjectInfoByName: equipment] mutableCopy];
          NSLog(@"THE eEquipment: %@", eEquipment);
          [eEquipment setObject: [tEquipment objectForKey: @"Sprüche"] forKey: @"Sprüche"];
          NSLog(@"AGAIN THE eEquipment: %@", eEquipment);          
          item = [[DSAObject alloc] initWithObjectInfo: eEquipment forOwner: character.modelID];
          for (NSString *spellName in item.appliedSpells)
            {
              [[item.appliedSpells objectForKey: spellName] applyEffectOnTarget: item forOwner: character];
              
            }
        }
      else
        {
          item = [[DSAObject alloc] initWithName: equipment forOwner: character.modelID];
        }
      
      NSLog(@"DSACharacterGenerationController: addEquipmentToCharacter %@", item.name);
      [character.inventory addObject: item
                            quantity: [[[equipmentDict objectForKey: equipment] objectForKey: @"Anzahl"] integerValue]];
    } 
  NSLog(@"THE INVENTORY: %@", character.inventory);
}

-(void) makeCharacterAMagicalDabblerFromParameters: (NSDictionary *)parameters
{
  NSLog(@"DSACharacterGenerator makeCharacterAMagicalDabblerFromParameters called");
  NSDictionary *magicalDabblerInfo = [parameters objectForKey: @"magicalDabblerInfo"];
  NSLog(@"DSACharacterGenerator makeCharacterAMagicalDabblerFromParameters magicalDabblerInfo: %@", magicalDabblerInfo);
  BOOL isMagicalDabbler = [[magicalDabblerInfo objectForKey: @"isMagicalDabbler"] boolValue];
  if (! isMagicalDabbler)
    {
      return;
    }
  NSArray *spells = [magicalDabblerInfo objectForKey: @"spells"];
  NSArray *specialTalents = [magicalDabblerInfo objectForKey: @"specialTalents"];
  
  DSACharacter *character = self.character;
  character.isMagicalDabbler = isMagicalDabbler;
  character.astralEnergy = [[magicalDabblerInfo objectForKey: @"AE"] integerValue];
  character.currentAstralEnergy = character.astralEnergy;

  NSMutableDictionary * newTalents = [[NSMutableDictionary alloc] init];        
  for (NSString *specialTalent in specialTalents)
    {
        NSLog(@"Checking specialTalent: %@", specialTalent);
        DSASpecialTalent *talent = [[DSASpecialTalent alloc] initTalent: specialTalent
                                                             ofCategory: _(@"Spezialtalent")
                                                                onLevel: 0
                                                               withTest: nil
                                                 withMaxTriesPerLevelUp: 0
                                                      withMaxUpPerLevel: 0
                                                        withLevelUpCost: 0];
        if ([specialTalent isEqualToString: _(@"Magisches Meisterhandwerk")])                                             
          {
            [talent setTest: @[ @"IN"] ];
          }
        NSLog(@"created Talent: %@", talent);
        [newTalents setObject: talent forKey: specialTalent];
    }
  [self.character setSpecials: newTalents];
  NSLog(@"THE magical dabbler talents: %@", newTalents);
  NSMutableDictionary *newSpells = [[NSMutableDictionary alloc] init];
  NSDictionary *spellsDict = [[NSDictionary alloc] init];
  spellsDict = [Utils getSpellsForCharacter: character];

  for (NSString *spellName in spells)
    {
      for (NSString *category in spellsDict)
        {
           for (NSString *s in [spellsDict objectForKey: category])
             {
               if ([s isEqualToString: spellName])
                 {
                    NSDictionary *sDict = [[spellsDict objectForKey: category] objectForKey: s];
                    DSASpell *spell = [[DSASpell alloc] initSpell: s
                                                        ofVariant: [sDict objectForKey: @"Variante"]
                                                ofDurationVariant: [sDict objectForKey: @"Dauer Variante"]
                                                       ofCategory: category
                                                          onLevel: 0               // See Compendium Salamandris S. 29
                                                       withOrigin: [sDict objectForKey: @"Ursprung"]
                                                         withTest: [sDict objectForKey: @"Probe"]
                                                  withMaxDistance: [[sDict objectForKey: @"Maximale Entfernung"] integerValue]
                                                     withVariants: [sDict objectForKey: @"Varianten"]
                                             withDurationVariants: [sDict objectForKey: @"Dauer Varianten"]        
                                           withMaxTriesPerLevelUp: 3
                                                withMaxUpPerLevel: 1
                                                  withLevelUpCost: 2]; 
                    [newSpells setObject: spell forKey: s];
                 }
             }
         }
    }
  [self.character setSpells: newSpells];
  NSLog(@"the magical dabbler spells: %@", newSpells);
           
}

@end


