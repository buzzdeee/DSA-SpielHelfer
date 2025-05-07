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

@implementation DSACharacterGenerator

- (DSACharacter *)generateCharacterWithParameters:(NSDictionary *)parameters
{
  NSString *archetype = [self resolveArchetypeFromParameters:parameters];
  
  
  
  self.character = [DSACharacter characterWithType: archetype];
  self.character.isNPC = [self shouldMarkAsNPCFromParameters: parameters];
  self.character.isMagicalDabbler = [self shouldMarkAsMagicalDabblerFromParameters: parameters];
  self.character.archetype = archetype;
  self.character.name = [self resolveNameFromParameters: parameters];
  self.character.title = [self resolveNameFromParameters: parameters];
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
  self.character.money = [self resolveWealthFromParameters: parameters];
  
/*  newCharacter.hairColor = [self.fieldHairColor stringValue];
  newCharacter.eyeColor = [self.fieldEyeColor stringValue];
  newCharacter.height = [self.fieldHeight floatValue];
  newCharacter.weight = [self.fieldWeight floatValue];
  newCharacter.god = [self.fieldGod stringValue];
  newCharacter.stars = [self.fieldStars stringValue];
  newCharacter.socialStatus = [self.fieldSocialStatus stringValue];
  newCharacter.parents = [self.fieldParents stringValue];
  newCharacter.sex = [[self.popupSex selectedItem] title];
  newCharacter.title = [self.fieldTitle stringValue];  */
    
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

/* end of parameter parsing methods */

@end
