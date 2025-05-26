/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-09 02:03:56 +0200 by sebastia

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

#import "Utils.h"
#import "DSASlot.h"
#import "NSMutableDictionary+Extras.h"

@implementation Utils

static Utils *sharedInstance = nil;
static NSMutableDictionary *objectsDict;
static NSMutableDictionary *masseDict;
static NSMutableDictionary *talentsDict;
static NSMutableDictionary *spellsDict;
static NSMutableDictionary *archetypesDict;
static NSMutableDictionary *npcTypesDict;
static NSMutableDictionary *professionsDict;
static NSMutableDictionary *originsDict;
static NSMutableDictionary *mageAcademiesDict;
static NSMutableDictionary *warriorAcademiesDict;
static NSMutableDictionary *eyeColorsDict;
static NSMutableDictionary *birthdaysDict;
static NSMutableDictionary *godsDict;
static NSMutableDictionary *magicalDabblerSpellsDict;
static NSMutableDictionary *witchCursesDict;
static NSMutableDictionary *druidRitualsDict;
static NSMutableDictionary *geodeRitualsDict;
static NSMutableDictionary *mageRitualsDict;
static NSMutableDictionary *mischievousPranksDict;
static NSMutableDictionary *elvenSongsDict;
static NSMutableDictionary *shamanOriginsDict;
static NSMutableDictionary *shamanRitualsDict;
static NSMutableDictionary *sharisadDancesDict;
static NSMutableDictionary *blessedLiturgiesDict;
static NSMutableDictionary *namesDict;

+ (instancetype)sharedInstance
{
  @synchronized(self)
    {
      if (sharedInstance == nil)
        {
          sharedInstance = [[self alloc] init];
            // Perform additional setup if needed
          NSError *e = nil;
          NSString *filePath;
          filePath = [[NSBundle mainBundle] pathForResource:@"Ausruestung" ofType:@"json"];
          objectsDict = [NSJSONSerialization 
          JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
               options: NSJSONReadingMutableContainers
                 error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          else
            {
              [Utils enrichEquipmentData: objectsDict withParentKeys:@[]];
            }                            
          filePath = [[NSBundle mainBundle] pathForResource:@"Masse" ofType:@"json"];
          masseDict = [NSJSONSerialization 
          JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
               options: NSJSONReadingMutableContainers
                 error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Talente" ofType:@"json"];
          talentsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }        
          filePath = [[NSBundle mainBundle] pathForResource:@"Zauberfertigkeiten" ofType:@"json"];
          spellsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];        
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }        
          filePath = [[NSBundle mainBundle] pathForResource:@"Typus" ofType:@"json"];  
          archetypesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e]; 
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }             
          filePath = [[NSBundle mainBundle] pathForResource:@"Berufe" ofType:@"json"];        
          professionsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }        
          filePath = [[NSBundle mainBundle] pathForResource:@"Herkunft" ofType:@"json"];         
          originsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }        
          filePath = [[NSBundle mainBundle] pathForResource:@"Magierakademien" ofType:@"json"];                 
          mageAcademiesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Kriegerakademien" ofType:@"json"];                 
          warriorAcademiesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];                     
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }                           
          filePath = [[NSBundle mainBundle] pathForResource:@"Augenfarben" ofType:@"json"];                       
          eyeColorsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }      
          filePath = [[NSBundle mainBundle] pathForResource:@"Geburtstag" ofType:@"json"];                       
          birthdaysDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];      
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }        
          filePath = [[NSBundle mainBundle] pathForResource:@"Goetter" ofType:@"json"];                         
          godsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];      
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Magiedilettantenzauber" ofType:@"json"];                         
          magicalDabblerSpellsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];                     
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Hexenflueche" ofType:@"json"];                         
          witchCursesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Druidenrituale" ofType:@"json"];                         
          druidRitualsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];                     
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Geodenrituale" ofType:@"json"];                         
          geodeRitualsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Magierrituale" ofType:@"json"];                         
          mageRitualsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];                     
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }                           
          filePath = [[NSBundle mainBundle] pathForResource:@"Schelmenstreiche" ofType:@"json"];                         
          mischievousPranksDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Elfenlieder" ofType:@"json"];                         
          elvenSongsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"SharisadTaenze" ofType:@"json"];                         
          sharisadDancesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];   
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Schamanenherkunft" ofType:@"json"];                         
          shamanOriginsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Schamanenrituale" ofType:@"json"];                         
          shamanRitualsDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          filePath = [[NSBundle mainBundle] pathForResource:@"Geweihtenliturgien" ofType:@"json"];                         
          blessedLiturgiesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }                      
          filePath = [[NSBundle mainBundle] pathForResource:@"Namen" ofType:@"json"];                         
          namesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];   
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }   
          filePath = [[NSBundle mainBundle] pathForResource:@"NPC" ofType:@"json"];                         
          npcTypesDict = [NSJSONSerialization 
            JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];   
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }                                                                 
        }
    }
  return sharedInstance;
}

- (instancetype)init
{
  self = [super init];
  if (self)
    {
   
    }
  return self;
}

// names spells dict related methods
+ (NSDictionary *) getNamesDict
{
  return namesDict;
}

+ (NSDictionary *) getNamesForRegion: (NSString *) region
{
    NSDictionary *regionData = [namesDict objectForKey: region];
    if (!regionData)
      {
        @throw [NSException exceptionWithName:@"RegionNotFoundException" reason:[NSString stringWithFormat:@"Region %@ not found in data", region] userInfo:nil];
      }
    return regionData;
}
// end of names dict related methods

// magical dabbler spells dict related methods
+ (NSDictionary *) getMagicalDabblerSpellsDict
{
  return magicalDabblerSpellsDict;
}
// end of magical dabbler spells dict related methods

// witch curses dict related methods
+ (NSDictionary *) getWitchCursesDict
{
  return witchCursesDict;
}
// end of witch curses dict related methods

// mischievous Pranks dict related methods
+ (NSDictionary *) getMischievousPranksDict
{
  return mischievousPranksDict;
}
// end of mischievous Pranks dict related methods

// mage rituals dict related methods
+ (NSDictionary *) getMageRitualsDict
{
  return mageRitualsDict;
}

+ (NSDictionary *) getMageRitualWithName: (NSString *) ritualName
{
  for (NSString *category in [mageRitualsDict allKeys])
    {
       NSLog(@"Utils: getMageRitualWithName checking category: %@", category);
       for (NSString *name in [[mageRitualsDict objectForKey: category] allKeys])
         {
           NSLog(@"Utils: getMageRitualWithName checking name: %@ against ritual name: %@", name, ritualName);
           if ([name isEqualToString: ritualName])
             {
               NSMutableDictionary *ritual = [[mageRitualsDict objectForKey: category] objectForKey: name];
               [ritual setObject: category forKey: @"category"];
               return ritual;
             }
         }
    }
  return nil;
}
// end of mage rituals dict related methods

// geode rituals dict related methods
+ (NSDictionary *) getGeodeRitualsDict
{
  return geodeRitualsDict;
}
// end of geode rituals dict related methods

// shaman rituals dict related methods
+ (NSDictionary *) getShamanRitualsDict
{
  return shamanRitualsDict;
}
// end of shaman rituals dict related methods

// druid rituals dict related methods
+ (NSDictionary *) getDruidRitualsDict
{
  return druidRitualsDict;
}
+ (NSDictionary *) getDruidRitualWithName: (NSString *) ritualName
{
  for (NSString *category in [druidRitualsDict allKeys])
    {
       NSLog(@"Utils: getDruidRitualWithName checking category: %@", category);
       for (NSString *name in [[druidRitualsDict objectForKey: category] allKeys])
         {
           NSLog(@"Utils: getDruidRitualWithName checking name: %@ against ritual name: %@", name, ritualName);
           if ([name isEqualToString: ritualName])
             {
               NSMutableDictionary *ritual = [[druidRitualsDict objectForKey: category] objectForKey: name];
               [ritual setObject: category forKey: @"category"];
               return ritual;
             }
         }
    }
  return nil;
}
// end of druid rituals dict related methods

// elven songs dict related methods
+ (NSDictionary *) getElvenSongsDict
{
  return elvenSongsDict;
}
// end of elven songs dict related methods

// birthdays dict related methods
+ (NSDictionary *) getBirthdaysDict
{
  return birthdaysDict;
}
// end of birthdays dict related methods

// eye colors dict related methods
+ (NSDictionary *) getEyeColorsDict
{
  return eyeColorsDict;
}
// end of eye colors dict related methods

// spells dict related methods
+ (NSDictionary *) getSpellsDict
{
  return spellsDict;
}

+ (NSDictionary *) getSpellWithName: (NSString *) spellName
{
  for (NSString *category in [spellsDict allKeys])
    {
       NSLog(@"Utils: getSpellWithName checking category: %@", category);
       for (NSString *name in [[spellsDict objectForKey: category] allKeys])
         {
           NSLog(@"Utils: getSpellWithName checking name: %@ against spell name: %@", name, spellName);
           if ([name isEqualToString: spellName])
             {
               NSMutableDictionary *spell = [[spellsDict objectForKey: category] objectForKey: name];
               [spell setObject: category forKey: @"category"];
               return spell;
             }
         }
    }
  return nil;
}

+ (NSDictionary *) getSpellsForCharacter: (DSACharacter *)character
{
  NSMutableDictionary *spells = [[NSMutableDictionary alloc] init];
  NSDictionary *spellsDict = [Utils getSpellsDict];
  
  NSArray *categories;
  
  NSString *typus;
  
  if ([character.archetype isEqualToString: _(@"Geode")])
    {
      // For Geode, the different start values, depending on their school, are in the .json dictionary directly
      typus = character.mageAcademy;
    }
  else if ([character.archetype isEqualToString: _(@"Steppenelf")])
    {
      typus = @"Auelf";  // Steppenelf only exists as NPC, but closely related to Auelf
    }
  else
    {
      typus = character.archetype;
    }
  
  NSLog(@"Utils getSpellsForCharacter typus: %@", typus);  
  
  if ([character isMemberOfClass: [DSACharacterHeroHumanShaman class]] && character.isMagic == NO)
    {
      return spells;  // non magic Shamans
    }
  else if ([character isMemberOfClass: [DSACharacterHeroHumanShaman class]] && character.isMagic == YES)
    {
      typus = @"Druide";  // Shamans have same start values like Druids if they are magic
    }    
  NSLog(@"Utils getSpellsForCharacter typus: %@", typus);  
  categories = [NSArray arrayWithArray: [[Utils getSpellsDict] allKeys]];
        
  for (NSString *category in categories)
    {
      NSString *steigern = @"1";
      NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3];
      for (NSString *key in [spellsDict objectForKey: category])
        {
          NSString *startwert;
          NSString *element = nil;
          NSDictionary *spellDict = [[spellsDict objectForKey: category] objectForKey: key];
          NSArray *probe = [NSArray arrayWithArray: [spellDict objectForKey: @"Probe"]];
          NSArray *origin = [NSArray arrayWithArray: [spellDict objectForKey: @"Ursprung"]];
          if ([[spellDict allKeys] containsObject: @"Element"])
            {
              element = [NSString stringWithString: [spellDict objectForKey: @"Element"]];
            }
          else
            {
              element = nil;
            }
          startwert = [NSString stringWithFormat: @"%@", [[spellDict objectForKey: @"Startwerte"] objectForKey: typus]];
          if (element)
            {
              [spells setValue: @{@"Startwert": startwert, 
                                  @"Probe": probe, 
                                  @"Ursprung": origin, 
                                  @"Steigern": steigern, 
                                  @"Versuche": versuche, 
                                  @"Element": element}
               forKeyHierarchy: @[category, key]];
            }
          else
            {
              [spells setValue: @{@"Startwert": startwert, 
                                  @"Probe": probe, 
                                  @"Ursprung": origin, 
                                  @"Steigern": steigern, 
                                  @"Versuche": versuche} 
               forKeyHierarchy: @[category, key]];   
            }
          }
    }
  NSLog(@"Utils getSpellsForCharacter returning spells: %@", [spells allKeys]);
  return spells;  
}

+ (void) applySpellmodificatorsToCharacter: (DSACharacter *) character
{
  if (character.isMagic == NO)  // safety belt, as should only be called on magic characters...
    {
      return;
    }

  NSString *archetype = character.archetype;

  if ([character isKindOfClass: [DSACharacterHeroElf class]] || [character isKindOfClass: [DSACharacterNpcHumanoidElf class]])
    {
      // All Elf spells can be leveled up two times per level
      // All others only once, see: "Geheimnisse der Elfen", S. 68
      NSMutableArray *originIdentifiers = [NSMutableArray arrayWithArray:@[ @"A", @"W", @"F"] ];
      NSString *originIdentifier;
      if ([archetype isEqualToString: _(@"Waldelf")])
        {
          originIdentifier = @"W";
        }
      else if ([archetype isEqualToString: _(@"Firnelf")])
        {
          originIdentifier = @"F";
        }
      else if ([@[@"Auelf", @"Steppenelf"] containsObject: archetype])
        {
          originIdentifier = @"A";
        }

      for (DSASpell *spell in [character.spells allValues])      
        {
          if ([spell.origin containsObject: originIdentifier])
            {
              spell.isTraditionSpell = YES;
            }
        
          NSSet *spellOrigin = [NSSet setWithArray: spell.origin];
          NSSet *otherElfOrigins = [NSSet setWithArray: originIdentifiers];
          if ([spellOrigin intersectsSet: otherElfOrigins])
            {
              spell.maxUpPerLevel = 2;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;            
            }
        }
    }
  else if ([character isKindOfClass: [DSACharacterHeroDwarfGeode class]])  // as described in "Die Magie des schwarzen Auges", S. 49
    {
      NSString *ownSchool;
      NSString *otherSchool;
      NSLog(@"DSACHaracterGenerationController applySpellmodificatorsToCharacter: applying Geode related stuff");
      if ([character.mageAcademy isEqualToString: _(@"Diener Sumus")])
        {
          ownSchool = @"DS";
          otherSchool = @"HdE";
        }
      else
        {
          ownSchool = @"HdE";
          otherSchool = @"DS";        
        }
      for (DSASpell *spell in [character.spells allValues])      
        {
          if ([spell.origin containsObject: ownSchool])
            { // own school 3 attampts per try
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;              
            }
          else if ([spell.origin containsObject: otherSchool])
            {
              // other school 2 attempts per try
              spell.maxUpPerLevel = 2;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;              
            }
        }      
    }
  else if ([character isKindOfClass: [DSACharacterHeroHumanDruid class]])
    {
      // All Druid spells can be leveled up three times per level
      // All others only once, see: "Die Magie des Schwarzen Auges", S. 45
      for (DSASpell *spell in [character.spells allValues])      
        {
          if ([spell.origin containsObject: @"D"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
        }
    }
  else if ([character isKindOfClass: [DSACharacterHeroHumanShaman class]])
    {
      // All Shaman spells can be leveled up three times per level (same as Druid)
      // All others only once, see: "Compendium Salamandris" S. 77
      // but can't learn any other spells
      for (DSASpell *spell in [character.spells allValues])      
        {
          if ([spell.origin containsObject: @"D"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
          else
            {
              spell.isTraditionSpell = NO;
              spell.level = -20;
              spell.maxUpPerLevel = 0;
              spell.maxTriesPerLevelUp = 0;
            }
        }
      character.maxLevelUpSpellsTries = 20;  // See "Compendium Salamandris" S. 77
      character.astralEnergy = 25;
      character.currentAstralEnergy = 25;
    }
  else if ([character isKindOfClass: [DSACharacterHeroHumanWitch class]])
    {
      // All Witch spells can be leveled up three times per level
      // All others only once, see: "Die Magie des Schwarzen Auges", S. 43
      for (DSASpell *spell in [character.spells allValues])      
        {
          if ([spell.origin containsObject: @"H"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
        }
    }    
  else if ([character isKindOfClass: [DSACharacterHeroHumanJester class]])
    {
      // All Jester spells can be leveled up three times per level
      // All others only once, see: "Die Magie des Schwarzen Auges", S. 47
      for (DSASpell *spell in [character.spells allValues])      
        {
          if ([spell.origin containsObject: @"S"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
        }
    }
  else if ([character isKindOfClass: [DSACharacterHeroHumanCharlatan class]])
    {
      // Nothing special for Charlatans, only mark the start spells
      // see "Die Magie des Schwarzen Auges", S. 34
      NSLog(@"Applying Spell modificators for Charlatan");
      for (DSASpell *spell in [character.spells allValues])      
        {
          NSLog(@"spell %@, origin: %@", spell.name, spell.origin);
          if ([spell.origin containsObject: @"Scharlatan"])
            {
              spell.isTraditionSpell = YES;
            }
        }
    }   
  else if ([character isKindOfClass: [DSACharacterHeroHumanMage class]])
    {
      NSLog(@"Applying spellModificatorsToArchetype: %@", archetype);
      NSDictionary *mageAcademyInfos = [[Utils getMageAcademiesDict] objectForKey: character.mageAcademy];
      NSArray *haussprueche = [mageAcademyInfos objectForKey: @"Haussprüche"];
      NSDictionary *academySpellModificators = [mageAcademyInfos objectForKey: @"Zaubersprüche"];
      NSString *spezialgebiet = [mageAcademyInfos objectForKey: @"Spezialgebiet"];
      for (DSASpell *spell in [character.spells allValues])
        {
          NSString *spellName = [spell name];
          NSString *spellCategory = [spell category];
          if ([spellCategory isEqualToString: spezialgebiet])
            {
              spell.maxUpPerLevel = 2;
              spell.maxTriesPerLevelUp = 6;
            }
          
          if ([[academySpellModificators allKeys] containsObject: spellCategory])
            {
              NSLog(@"Found spell category: %@", spellCategory);
              if ([[academySpellModificators objectForKey: spellCategory] objectForKey: spellName])
                {
                  NSLog(@"modifying spell.level for spell: %@", spellName);
                  spell.level = spell.level + [[[academySpellModificators objectForKey: spellCategory] objectForKey: spellName] integerValue];
                }
              for (NSDictionary *dict in haussprueche)
                {
                  if ([dict objectForKey: spellName])
                    {
                      NSLog(@"HAUSSPRUCH: modifying spell.level for spell: %@", spellName);
                      spell.level = spell.level + [[dict objectForKey: spellName] integerValue];
                      spell.maxUpPerLevel = 3;
                      spell.maxTriesPerLevelUp = 9;
                      spell.isTraditionSpell = YES;
                      break;
                    }
                  
                }
            }
        }      
    }
  else
    {
      NSLog(@"DSACharacterGenerationController: applySpellmodificatorsToCharacter: don't know about Archetype: %@", archetype);
    }
  if ([character element])
    {
      // special treatment for Archetypes specialized on one of the Elements, as described in Mysteria Arkana S. 94
      

      NSArray *elements = @[ _(@"Feuer"), _(@"Erz"), _(@"Eis"), _(@"Wasser"), _(@"Luft"), _(@"Humus")];
      NSInteger count = [elements count];
      NSInteger selectedIndex;
      NSInteger oppositeIndex;
      NSString *ownElement = [character element];
      
      selectedIndex = [elements indexOfObject: ownElement];
      oppositeIndex = (selectedIndex + count / 2) % count;      
      NSString *oppositeElement = [elements objectAtIndex: oppositeIndex];
//      NSLog(@"applying spell modificators for own element: %@ opposite element: %@", ownElement, oppositeElement);
      for (DSASpell *spell in [character.spells allValues])
        {
          if ([spell element]) NSLog(@"testing spell: %@ with element: %@", [spell name], [spell element]);
          if ([spell element] != nil)
            {
              if ([[spell element] isEqualToString: ownElement])
                {
//                  NSLog(@"own element spell before: %@ %@ %@", [spell name], [spell level], [spell maxUpPerLevel]);
                  spell.level = spell.level + 2;
                  if (spell.maxUpPerLevel < 3)
                    {
                      spell.maxUpPerLevel += 1;
                      spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
                    }
//                  NSLog(@"own element spell after: %@ %@ %@", [spell name], [spell level], [spell maxUpPerLevel]);                  
                }
              else if ([[spell element] isEqualToString: oppositeElement])
                {
//                  NSLog(@"opposite element spell before: %@ %@ %@", [spell name], [spell level], [spell maxUpPerLevel]);                
                  spell.level = spell.level - 3;
                  spell.maxUpPerLevel = spell.maxUpPerLevel - 1;
                  spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
//                  NSLog(@"opposite element spell after: %@ %@ %@", [spell name], [spell level], [spell maxUpPerLevel]);                
                }
              else
                {
//                  NSLog(@"other element spell before: %@ %@ %@", [spell name], [spell level], [spell maxUpPerLevel]);                
                  if (spell.maxUpPerLevel >= 3)
                    {
                      spell.maxUpPerLevel = 2;
                      spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;                    
                      
                    }
//                  NSLog(@"other element spell after: %@ %@ %@", [spell name], [spell level], [spell maxUpPerLevel]);                
                    
                }
            }
        }
    }
  else
    {
      NSLog(@"The character didn't have element selected!");
    }
}

// end of spells dict related methods

// sharisad dances dict related methods
+ (NSDictionary *) getSharisadDancesDict
{
  return sharisadDancesDict;
}
// end of sharisad dances dict related methods

// shaman origins dict related methods
+ (NSDictionary *) getShamanOriginsDict
{
  return shamanOriginsDict;
}
// end of shaman origins dict related methods

// talents dict related methods
+ (NSDictionary *) getTalentsDict
{
  return talentsDict;
}

+ (NSString *) findSpellOrRitualTypeWithName: (NSString *) name
{
  if ([Utils getSpellWithName: name])
    {
      return @"DSASpell";
    }
  else if ([Utils getMageRitualWithName: name])
    {
      return @"DSASpellMageRitual";
    }
  else if ([Utils getDruidRitualWithName: name])
    {
      return @"DSASpellDruidRitual";
    }  
  return nil;
}

// returns a dictionary of talents for the requested archetype
+ (NSDictionary *) getTalentsForCharacter: (DSACharacter *)character
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
  
  NSArray *categories = [NSArray arrayWithArray: [talentsDict allKeys]];
  for (NSString *category in categories)
    {
      if ([@"Kampftechniken" isEqualTo: category])
        {
          NSString *steigern = [NSString stringWithFormat: @"%@", [[talentsDict objectForKey: category] objectForKey: @"Steigern"]];
          NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3];
         
          for (NSString *key in [talentsDict objectForKey: category])
            {
              NSString *weapontype;
              NSString *startwert;
              if ([@"Steigern" isEqualTo: key])
                {
                  continue;
                }
              else
                {
                  weapontype = [NSString stringWithFormat: @"%@", [[[talentsDict objectForKey: category] objectForKey: key] objectForKey: @"Waffentyp"]];
                  startwert = [NSString stringWithFormat: @"%@", [[[[talentsDict objectForKey: category] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: typus]];
                }
                [talents setValue: @{@"Startwert": startwert, @"Steigern": steigern, @"Versuche": versuche} 
                  forKeyHierarchy: @[category, weapontype, key]];
            } 
        }
      else
        {
          NSString *steigern = [NSString stringWithFormat: @"%@", [[talentsDict objectForKey: category] objectForKey: @"Steigern"]];
          NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3]; 
          for (NSString *key in [talentsDict objectForKey: category])
            {
              NSArray *probe;
              NSString *startwert;
              if ([@"Steigern" isEqualTo: key])
                {
                  continue;
                }
              else
                {
                  probe = [NSArray arrayWithArray: [[[talentsDict objectForKey: category] objectForKey: key] objectForKey: @"Probe"]];
                  startwert = [NSString stringWithFormat: @"%@", [[[[talentsDict objectForKey: category] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: typus]];
                }
                [talents setValue: @{@"Startwert": startwert, @"Probe": probe, @"Steigern": steigern, @"Versuche": versuche} forKeyHierarchy: @[category, key]];
            }       
        }
    }
  return talents;
}
// end of talents dict related methods



// warriorAcademies dict related methods
+ (NSDictionary *) getWarriorAcademiesDict
{
  return warriorAcademiesDict;
}
// end of warriorAcademies dict related methods


// NPC dict related methods
+ (NSDictionary *) getNpcTypesDict
{
  return npcTypesDict;
}
// finds and returns all NPCTypes as an array
+ (NSArray *) getAllNpcTypesCategories
{
  NSMutableOrderedSet *categories = [[NSMutableOrderedSet alloc] init];
  
  for (NSDictionary *type in npcTypesDict)
    {
      [categories addObjectsFromArray: [[npcTypesDict objectForKey: type] objectForKey: @"Typkategorie"]];
    }
  NSArray *sortedCategories = [[categories array] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return sortedCategories;
}

// finds all NPC types for a given category and returns them as an array
+ (NSArray *) getAllNpcTypesForCategory: (NSString *) category
{
  NSMutableArray *npcTypes = [[NSMutableArray alloc] init];
  
  for (NSString *type in [npcTypesDict allKeys])
    {
      if ([[[npcTypesDict objectForKey: type] objectForKey: @"Typkategorie"] containsObject: category])
        {
          [npcTypes addObject: type];
        }
    }
  NSArray *sortedArchetypes = [npcTypes sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return sortedArchetypes;
}

// returns possible levels of experience
+ (NSArray *) getAllExperienceLevelsForNpcType: (NSString *) type
{
  NSArray *experienceLevels = [[NSArray alloc] init];
  
  NSLog(@"Utils getAllExperienceLeveslForNpcType: %@, %@", type, [npcTypesDict objectForKey: type]);
  
  experienceLevels = [[[npcTypesDict objectForKey: type] objectForKey: @"Erfahrungsstufen"] allKeys];
  
  if ([experienceLevels count] == 0)
    {
      experienceLevels = @[ @"standard" ];
    }
  return experienceLevels;
}

+ (NSArray *) getAllOriginsForNpcType: (NSString *) type ofSubtype: (NSString *) subtype
{
  NSArray *origins = [[NSArray alloc] init];
  
  NSLog(@"Utils getAllOriginsForNpcType: %@, %@", type, [npcTypesDict objectForKey: type]);
  
  if (subtype != nil && [subtype length] > 0)
    {
      origins = [[[[npcTypesDict objectForKey: type]
                                 objectForKey: @"Subtypen"]
                                 objectForKey: subtype]               
                                 objectForKey: @"Herkunft"];
    }
  if ([origins count] == 0)
    {
      origins = [[[npcTypesDict objectForKey: type] objectForKey: @"Herkunft"] allKeys];
    }
  if ([origins count] == 0)
    {
      origins = @[ @"Aventurien" ];
    }
  return origins;  
}

+ (NSArray *) getAllSubtypesForNpcType: (NSString *) type
{
  NSArray *subtypes = [[NSArray alloc] init];
  
  NSLog(@"Utils getAllSubtypesForNpcType: %@, %@", type, [npcTypesDict objectForKey: type]);
  
  subtypes = [[[npcTypesDict objectForKey: type] objectForKey: @"Subtypen"] allKeys];
  
  return subtypes;  // might be empty, i.e. no subtypes
}

// archetypes dict related methods
+ (NSDictionary *) getArchetypesDict
{
  return archetypesDict;
}
// finds and returns all archetypes as an array
+ (NSArray *) getAllArchetypesCategories
{
  NSMutableOrderedSet *categories = [[NSMutableOrderedSet alloc] init];
  
  for (NSDictionary *archetypus in archetypesDict)
    {
      [categories addObjectsFromArray: [[archetypesDict objectForKey: archetypus] objectForKey: @"Typkategorie"]];
    }
  NSArray *sortedCategories = [[categories array] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return sortedCategories;
}

// finds all archetypes for a given category and returns them as an array
+ (NSArray *) getAllArchetypesForCategory: (NSString *) category
{
  NSMutableArray *archetypes = [[NSMutableArray alloc] init];
  
  for (NSString *type in [archetypesDict allKeys])
    {
      if ([[[archetypesDict objectForKey: type] objectForKey: @"Typkategorie"] containsObject: category])
        {
          [archetypes addObject: type];
        }
    }
  NSArray *sortedArchetypes = [archetypes sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return sortedArchetypes;
}
// end of archetypes dict related methods

// origins dict related methods
+ (NSDictionary *) getOriginsDict
{
  return originsDict;
}

// returns an array of possible regional origins
+ (NSArray *) getOriginsForArchetype: (NSString *) archetype
{
  NSMutableArray *origins = [[NSMutableArray alloc] init];
  
  if (archetype == nil)
    {
      [origins addObject: _(@"Garethien")];
      return origins;
    }
      
  for (NSString *origin in [originsDict allKeys])
    {
      if ([[originsDict objectForKey: origin] objectForKey: @"Typen"] != nil)
        {
          if ([[[originsDict objectForKey: origin] objectForKey: @"Typen"] containsObject: archetype])
            {
              [origins addObject: origin];
            }
        }
    }
  NSArray *sortedOrigins = [origins sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];  
  return sortedOrigins;  
}
// end of origins dict related methods

// gods dict related methods
+ (NSDictionary *) getGodsDict
{
  return godsDict;
}
// end of gods dict related methods

// mage academies related methods
+ (NSDictionary *) getMageAcademiesDict
{
  return mageAcademiesDict;
}

// returns an Array of Strings with Areas of Expertise from all Mage academies
+ (NSArray *) getMageAcademiesAreasOfExpertise
{
  NSMutableArray *areasOfExpertise = [[NSMutableArray alloc] init];
  for (NSDictionary *academy in mageAcademiesDict)
    {
      if (![areasOfExpertise containsObject: [[mageAcademiesDict objectForKey: academy] objectForKey: @"Spezialgebiet"]])
        {
          [areasOfExpertise addObject: [[mageAcademiesDict objectForKey: academy] objectForKey: @"Spezialgebiet"]];
        }
    }
  NSArray *sortedAreasOfExpertise = [areasOfExpertise sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return sortedAreasOfExpertise;
}

// returns an Array of Strings with mage academies that match a given expertise
+ (NSArray *) getMageAcademiesOfExpertise: (NSString *) expertise
{
  NSMutableArray *academies = [[NSMutableArray alloc] init];
  for (NSString *academy in mageAcademiesDict)
    {
      if ([[[mageAcademiesDict objectForKey: academy] objectForKey: @"Spezialgebiet"] isEqualToString: expertise])
        {
          [academies addObject: academy];
        }
    }
  NSArray *sortedAcademies = [academies sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  return sortedAcademies;
}
// end of mage academies related methods


// professions related methods
+ (NSDictionary *) getProfessionsDict
{
  return professionsDict;
}

// returns all relevant professions for a given Archetype in an array
+ (NSArray *) getProfessionsForArchetype: (NSString *) archetype
{
  NSMutableArray *professions = [[NSMutableArray alloc] init];
  
  if (archetype == nil)
    {
      return professions;
    }
      
  for (NSString *profession in [professionsDict allKeys])
    {
      if ([[professionsDict objectForKey: profession] objectForKey: @"Typen"] != nil)
        {
          if ([[[professionsDict objectForKey: profession] objectForKey: @"Typen"] containsObject: archetype])
            {
              [professions addObject: profession];
            }
        }
    }
  NSArray *sortedProfessions = [professions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];  
  return sortedProfessions;
}
// end of professions related methods


// blessed liturgies related methods
+ (NSDictionary *) getBlessedLiturgiesDict
{
  return blessedLiturgiesDict;
}
// end of blessed liturgies related methods

// DSAObject related methods
+ (NSDictionary *) getDSAObjectsDict
{
  return objectsDict;
}

+ (void)enrichEquipmentData:(NSMutableDictionary *)data withParentKeys:(NSArray<NSString *> *)parentKeys {
    for (NSString *key in data) {
        id value = data[key];
        if ([value isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *entry = (NSMutableDictionary *)value;

            // Add category flags based on the presence of specific keys
            entry[@"Name"] = [key copy];
            
            if (entry[@"TrefferpunkteKK"] != nil) {
                entry[@"isHandWeapon"] = @YES;
            }
            if (entry[@"TP Entfernung"] != nil) {
                entry[@"isDistantWeapon"] = @YES;
            }
            if (entry[@"Rüstschutz"] != nil) {
                entry[@"isArmor"] = @YES;
            }
            if (entry[@"Waffenvergleichswert Schild"]) {
                entry[@"isShield"] = @YES;
                if (entry[@"Waffenvergleichswert"]) {
                  entry[@"isHandWeapon"] = @YES;
                }
            }
            
            if (entry[@"HatSlots"] != nil)
              {
                entry[@"isContainer"] = @YES;
              }
            
            // Optionally, compute and format additional fields here
            if (entry[@"Trefferpunkte"] != nil) {
                entry[@"TP"] = [entry[@"Trefferpunkte"] componentsJoinedByString:@", "];
            }
            if (entry[@"TP Entfernung"] != nil) {
                entry[@"TP Entfernung Formatted"] = [Utils formatTPEntfernung:entry[@"TP Entfernung"]];
            }
            if (entry[@"Waffenvergleichswert"] != nil) {
                NSString *waffenvergleichswert = entry[@"Waffenvergleichswert"];
                NSArray *values = [waffenvergleichswert componentsSeparatedByString:@"/"];
    
                if (values.count == 2) {
                  // Parse the attackPower and parryValue as integers
                  NSInteger attackPower = [values[0] integerValue];
                  NSInteger parryValue = [values[1] integerValue];
        
                  // Assign them back to the dictionary
                  entry[@"attackPower"] = @(attackPower);
                  entry[@"parryValue"] = @(parryValue);
                } else {
                  NSLog(@"Invalid Waffenvergleichswert format: %@", waffenvergleichswert);
                }
            }
            if (entry[@"Waffenvergleichswert Schild"] != nil) {
                NSString *waffenvergleichswertSchild = entry[@"Waffenvergleichswert Schild"];
                NSArray *values = [waffenvergleichswertSchild componentsSeparatedByString:@"/"];
    
                if (values.count == 2) {
                  // Parse the attackPower and parryValue as integers
                  NSInteger shieldAttackPower = [values[0] integerValue];
                  NSInteger shieldParryValue = [values[1] integerValue];
        
                  // Assign them back to the dictionary
                  entry[@"shieldAttackPower"] = @(shieldAttackPower);
                  entry[@"shieldParryValue"] = @(shieldParryValue);
                } else {
                  NSLog(@"Invalid Waffenvergleichswert Schild format: %@", waffenvergleichswertSchild);
                }
            }                 
            if (entry[@"Regionen"] != nil) {
                entry[@"Regionen Formatted"] = [entry[@"Regionen"] componentsJoinedByString:@", "];
                NSArray *regionen = [NSArray arrayWithArray: entry[@"Regionen"]];
                entry[@"Regionen"] = regionen;
            }
            
            // Add hierarchical information
            entry[@"category"] = parentKeys.count > 0 ? parentKeys[0] : @"";
            entry[@"subCategory"] = parentKeys.count > 1 ? parentKeys[1] : @"";
            entry[@"subSubCategory"] = parentKeys.count > 2 ? parentKeys[2] : @"";

            if ([entry[@"category"] isEqualToString: @"Behälter"])
              {
                entry[@"isContainer"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Werkzeug"])
              {
                entry[@"isTool"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Kleidung und Schuhwerk"])
              {
                entry[@"isCloth"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Musikinstrumente"])
              {
                entry[@"isInstrument"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Nahrungs- und Genußmittel"])
              {
                entry[@"isFood"] = @YES;
                if ([entry[@"subCategory"] isEqualToString: @"Getränke"])
                  {
                    entry[@"isDrink"] = @YES;
                    if ([entry[@"subSubCategory"] isEqualToString: @"Alkoholisch"])
                      {
                        entry[@"isAlcohol"] = @YES;
                      }
                    else
                      {
                        entry[@"isAlcohol"] = @NO;
                      }
                  }
                else
                  {
                    entry[@"isDrink"] = @NO;
                  }
              }

            if ([entry[@"MehrereProSlot"] isEqualTo: @YES])
              {
                entry[@"canShareSlot"] = @YES;
              }              
              
            // Add the slot types parsing logic here
            NSArray *validSlotTypes = entry[@"ErlaubtInSlots"];
            NSMutableArray<NSNumber *> *validSlotTypesEnum = [NSMutableArray array];

            // If validSlotTypes is missing or empty, default to DSASlotTypeGeneral
            if (validSlotTypes == nil || validSlotTypes.count == 0) {
                [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
            } else {
                // Convert slot types in JSON to DSASlotType enums
                for (NSString *slotTypeString in validSlotTypes) {
                    DSASlotType slotType = [self slotTypeFromString:slotTypeString];
                    if (slotType != NSNotFound) {
                        [validSlotTypesEnum addObject:@(slotType)];
                    }
                }
                // Always add DSASlotTypeGeneral to the list of valid slot types
                [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
            }

            // Store the parsed validSlotTypes as enum values
            entry[@"validSlotTypes"] = validSlotTypesEnum;              
            
            NSArray *occupiedBodySlots = entry[@"belegteKörperSlots"];
            NSMutableArray<NSNumber *> * occupiedBodySlotsEnum = [NSMutableArray array];
            // If occupiedBodySlots is missing or empty, we're fine with it, the item only occpuies a single named slot
            if (occupiedBodySlots == nil || occupiedBodySlots.count == 0) {
                occupiedBodySlots = nil;
            } else {
                // Convert slot types in JSON to DSASlotType enums
                for (NSString *slotTypeString in occupiedBodySlots) {
                    DSASlotType slotType = [self slotTypeFromString:slotTypeString];
                    if (slotType != NSNotFound) {
                        [occupiedBodySlotsEnum addObject:@(slotType)];
                    }
                }
            }
            entry[@"occupiedBodySlots"] = occupiedBodySlotsEnum;
                        
            // Recurse into deeper dictionaries with updated hierarchy
            [Utils enrichEquipmentData:entry withParentKeys:[parentKeys arrayByAddingObject:key]];
        } else if ([value isKindOfClass:[NSMutableArray class]]) {
            // Handle arrays of dictionaries (if applicable)
            for (id subValue in (NSMutableArray *)value) {
                if ([subValue isKindOfClass:[NSMutableDictionary class]]) {
                    [Utils enrichEquipmentData:(NSMutableDictionary *)subValue withParentKeys:parentKeys];
                }
            }
        }
    }
}

// helper method to enrich object data, DSASlot related info on DSAObjects
+ (DSASlotType)slotTypeFromString:(NSString *)slotTypeString {
    NSDictionary<NSString *, NSNumber *> *slotTypeMapping = @{
        @"Allgemein" : @(DSASlotTypeGeneral),
        @"Unterwäsche" : @(DSASlotTypeUnderwear),
        @"Körperrüstung" : @(DSASlotTypeBodyArmor),
        @"Kopfbedeckung" : @(DSASlotTypeHeadgear),
        @"Schuh" : @(DSASlotTypeShoes),
        @"Halskette" : @(DSASlotTypeNecklace),
        @"Ohrring" : @(DSASlotTypeEarring),
        @"Nasenring" : @(DSASlotTypeNosering),
        @"Brille" : @(DSASlotTypeGlasses),
        @"Maske" : @(DSASlotTypeMask),
        @"Rucksack" : @(DSASlotTypeBackpack),
        @"Rückenköcher" : @(DSASlotTypeBackquiver),
        @"Schärpe" : @(DSASlotTypeSash),
        @"Armrüstung" : @(DSASlotTypeArmArmor),
        @"Armreif" : @(DSASlotTypeArmRing),
        @"Handschuhe" : @(DSASlotTypeGloves),
        @"Hüfte" : @(DSASlotTypeHip),
        @"Ring" : @(DSASlotTypeRing),
        @"Weste" : @(DSASlotTypeVest),
        @"Shirt" : @(DSASlotTypeShirt),
        @"Jacke" : @(DSASlotTypeJacket),
        @"Beingurt" : @(DSASlotTypeLegbelt),
        @"Beinrüstung" : @(DSASlotTypeLegArmor),
        @"Beinkleidung" : @(DSASlotTypeTrousers),
        @"Socke" : @(DSASlotTypeSocks),
        @"Schuhaccesoir" : @(DSASlotTypeShoeaccessories),
        @"Sack" : @(DSASlotTypeBag),
        @"Korb" : @(DSASlotTypeBasket),
        @"Köcher" : @(DSASlotTypeQuiver),
        @"Bolzentasche" : @(DSASlotTypeBoltbag),
        @"Flüssigkeit" : @(DSASlotTypeLiquid),
        @"Schwert" : @(DSASlotTypeSword),
        @"Dolch" : @(DSASlotTypeDagger),
        @"Axt" : @(DSASlotTypeAxe),
        @"Geld" : @(DSASlotTypeMoney),
        @"Tabak" : @(DSASlotTypeTobacco)
    };

    // Look up the corresponding slot type
    NSNumber *slotTypeNumber = slotTypeMapping[slotTypeString];
    // NSLog(@"Utils: slotTypeFromString: for slot type: %@ returning: %@", slotTypeString, slotTypeNumber);
    return slotTypeNumber ? slotTypeNumber.unsignedIntegerValue : NSNotFound;
}

// another helper method
+ (NSMutableArray<NSNumber *> *)parseValidSlotTypesForItem:(NSDictionary *)itemData {
    NSArray<NSString *> *validSlotTypes = itemData[@"validSlotTypes"];
    NSMutableArray<NSNumber *> *validSlotTypesEnum = [NSMutableArray array];

    // If validSlotTypes is empty or nil, default to "General"
    if (validSlotTypes == nil || validSlotTypes.count == 0) {
        [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
    } else {
        // Convert slot types in JSON to DSASlotType enums
        for (NSString *slotTypeString in validSlotTypes) {
            DSASlotType slotType = [self slotTypeFromString:slotTypeString];
            if (slotType != NSNotFound) {
                [validSlotTypesEnum addObject:@(slotType)];
            }
        }
        // Always add "General" slot type to the list
        [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
    }

    return validSlotTypesEnum;
}


+ (NSDictionary *)getDSAObjectInfoByName:(NSString *)name
{
  NSMutableArray *categories = [NSMutableArray array]; // To track category path
  NSDictionary *result = [self searchForDSAObjectWithName: name
                                             inDictionary: objectsDict
                                            categoryStack: categories];

  if (result && categories.count > 0)
    {
       NSMutableDictionary *resultWithCategories = [result mutableCopy];
       for (NSInteger i = 0; i < categories.count; i++)
         {
           NSString *key = [NSString stringWithFormat:@"category%@", (i == 0 ? @"" : [NSString stringWithFormat:@"%ld", (long)i])];
           resultWithCategories[key] = categories[i];
         }
       resultWithCategories[@"name"] = name;
       return [resultWithCategories copy];
    }
  return result;
}

+ (NSDictionary *)searchForDSAObjectWithName:(NSString *)name
                                inDictionary:(NSDictionary *)dictionary
                               categoryStack:(NSMutableArray *)categoryStack
{
  // Iterate through the dictionary
  for (NSString *key in dictionary)
    {
      id value = dictionary[key];

      if ([key isEqualToString:name] && [value isKindOfClass:[NSDictionary class]])
        {
          // Found the key matching the name, and its value is a dictionary
          return value;
        }
      else if ([value isKindOfClass:[NSDictionary class]])
        {
          // Add the current key to the category stack
          [categoryStack addObject:key];

          // Recursively search within the nested dictionary
          NSDictionary *result = [self searchForDSAObjectWithName:name inDictionary:value categoryStack:categoryStack];
          if (result)
            {
              return result; // Found in nested dictionary
            }

          // Remove the current key from the stack if not found in this branch
          [categoryStack removeLastObject];
        }
    }

  // Return nil if not found
  return nil;
}
// end of DSAObject related methods

// parse character traits related constraints
+ (NSDictionary *) parseConstraint: (NSString *) constraintDefinition
{
  int value;
  NSString *cvalue;
  NSMutableDictionary *constraint = [[NSMutableDictionary alloc] init];
  NSScanner *scanner = [NSScanner scannerWithString: constraintDefinition];
  [scanner scanInt: &value];
  [scanner scanCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"+-"] intoString: &cvalue];
  
  [constraint setValue: [NSNumber numberWithInt: value] forKey: @"value"];
  if ([cvalue isEqualToString: @"+"])
    {
      [constraint setValue: @"MAX" forKey: @"constraint"];
    }
  else
    {
      [constraint setValue: @"MIN" forKey: @"constraint"];
    }
    
  return constraint;
}
// end of parse character traits related constraints

// dice related methods
+ (NSDictionary *) parseDice: (NSString *) diceDefinition
{
  int count, points;
  NSMutableDictionary *dice = [[NSMutableDictionary alloc] init];
  NSScanner *scanner = [NSScanner scannerWithString: diceDefinition];
  [scanner scanInt: &count];
  [scanner scanCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"W"] intoString: NULL];
  [scanner scanInt: &points];
  
  [dice setValue: [NSNumber numberWithInt: count] forKey: @"count"];
  [dice setValue: [NSNumber numberWithInt: points] forKey: @"points"];

//  NSLog(@"Utils : parseDice returning dice: %@", dice);  
  return dice;
}

+ (NSInteger) rollDice: (NSString *) diceDefinition
{
  NSDictionary *dice = [NSDictionary dictionaryWithDictionary: [Utils parseDice: diceDefinition]];
  int result = 0;
  for (int i=0; i<[[dice objectForKey: @"count"] intValue];i++)
    {
      result += arc4random_uniform([[dice objectForKey: @"points"] intValue]) + 1;
    }
  return result;
}
//end of dice related methods

// methods to format various strings
+ (NSString *)formatTPEntfernung:(NSDictionary *)tpEntfernung {
    if (![tpEntfernung isKindOfClass:[NSDictionary class]]) {
        return @"";
    }    
    // Extract the values in order of the keys
    NSArray<NSString *> *orderedKeys = @[@"extrem nah", @"sehr nah", @"nah", @"mittel", @"weit", @"sehr weit", @"extrem weit"];
    NSMutableArray<NSString *> *values = [NSMutableArray array];
    
    for (NSString *key in orderedKeys) {
        NSNumber *value = tpEntfernung[key];
        if (value) {
            [values addObject:value.stringValue];
        } else {
            [values addObject:@"-"]; // Default for missing values
        }
    }
    
    // Join the values with "/"
    return [NSString stringWithFormat: @"(%@)", [values componentsJoinedByString:@"/"]];
}
// end of methods to format various strings


+ (NSColor *)colorForDSASeverity:(DSASeverityLevel)level {
    switch (level) {
        case DSASeverityLevelNone: return [NSColor greenColor];
        case DSASeverityLevelMild: return [NSColor blueColor];
        case DSASeverityLevelModerate: return [NSColor yellowColor];
        case DSASeverityLevelSevere: return [NSColor redColor];
    }
    return [NSColor grayColor]; // Fallback
}

+ (NSColor *) colorForBooleanState:(BOOL)state {
    return state ? [NSColor redColor] : [NSColor greenColor];
}

+ (NSURL *)characterStorageDirectory {
    NSURL * url = [[Utils defaultDocumentsDirectory] URLByAppendingPathComponent:@"Characters"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: url.path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL: url
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error];
        if (error) {
            NSLog(@"Failed to create save directory: %@", error.localizedDescription);
        }
    }  
    return url;
}

+ (NSURL *)adventureStorageDirectory {
    NSURL * url = [[Utils defaultDocumentsDirectory] URLByAppendingPathComponent:@"Adventures"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: url.path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL: url
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error];
        if (error) {
            NSLog(@"Failed to create save directory: %@", error.localizedDescription);
        }
    }  
    return url;
}

+ (NSURL *)defaultDocumentsDirectory {
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *customDirectory = [documentsURL URLByAppendingPathComponent:@"MyDSAGameSaves"];
    
    // Ensure the directory exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:customDirectory.path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL:customDirectory
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error];
        if (error) {
            NSLog(@"Failed to create save directory: %@", error.localizedDescription);
        }
    }
    
    return customDirectory;
}

@end
