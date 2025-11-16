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
#import "DSASpell.h"
#import "DSASlot.h"
#import "NSMutableDictionary+Extras.h"
#import "DSADefinitions.h"
#import "DSAAdventure.h"
#import "DSAAdventureClock.h"
#import "DSAAdventureGroup.h"
#import "DSALocations.h"


NSArray<NSString *> *DSAShopGeneralStoreCategories(void) {
    static NSArray<NSString *> *categories = nil;
    if (categories == nil) {
        categories = [[NSArray alloc] initWithObjects:
            @"Behälter", @"Beleuchtung", @"Kleidung und Schuhwerk",
            @"Koch- und Essgeschirr", @"Körperpflege", @"Musikinstrumente",
            @"Nahrungs- und Genußmittel", @"Schmuck",
            @"Schreibwaren, Feinmechanik, Optik", @"Seile, Netze, Ketten",
            @"Sonstiger Reisebedarf", @"Spielzeug, Dekoration und Luxusartikel",
            @"Tierbedarf", @"Werkzeug",
            nil];
    }
    return categories;
}

NSArray<NSString *> *DSAShopWeaponStoreCategories(void) {
    static NSArray<NSString *> *categories = nil;
    if (categories == nil) {
        categories = [[NSArray alloc] initWithObjects:
            @"Munition", @"Rüstzeug", @"Waffen", @"Waffenzubehör",
            nil];
    }
    return categories;
}

NSArray<NSString *> *DSAShopHerbsStoreCategories(void) {
    static NSArray<NSString *> *categories = nil;
    if (categories == nil) {
        categories = [[NSArray alloc] initWithObjects:
            @"Gift", @"Pflanzen",
            nil];
    }
    NSLog(@"Utils.m DSAShopHerbsStoreCategories(): returning categories: %@", categories);
    return categories;
}

#pragma mark - translator functions for DSAUseObjectWithActionType defined in DSADefinitions.h

NSString *NSStringFromDSAUseObjectWithActionType(DSAUseObjectWithActionType type) {
    switch (type) {
#define X(name) case name: return @#name;
        DSA_USE_OBJECT_WITH_ACTION_TYPES
#undef X
    }
    return @"Unknown";
}

DSAUseObjectWithActionType DSAUseObjectWithActionTypeFromString(NSString *string) {
#define X(name) if ([string isEqualToString:@#name]) return name;
    DSA_USE_OBJECT_WITH_ACTION_TYPES
#undef X
    return -1; // oder NSNotFound
}

@implementation Utils

static Utils *sharedInstance = nil;
static NSMutableDictionary *masseDict;
static NSMutableDictionary *spellsDict;
static NSMutableDictionary *archetypesDict;
static NSMutableDictionary *npcTypesDict;
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
static NSMutableDictionary *imagesIndexDict;



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
                             
          filePath = [[NSBundle mainBundle] pathForResource:@"Masse" ofType:@"json"];
          masseDict = [NSJSONSerialization 
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
          filePath = [[NSBundle mainBundle] pathForResource:@"image_index" ofType:@"json"];                         
          imagesIndexDict = [NSJSONSerialization 
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

// blessed liturgies related methods
+ (NSDictionary *) getBlessedLiturgiesDict
{
  return blessedLiturgiesDict;
}
// end of blessed liturgies related methods


+ (NSDictionary *)searchForDSAObjectWithName:(NSString *)name
                                inDictionary:(NSDictionary *)dictionary
                               categoryStack:(NSMutableArray *)categoryStack
{
  //NSLog(@"Utils.m searchForDSAObjectWithName: %@", name);
  // Iterate through the dictionary
  for (NSString *key in [dictionary allKeys])
    {
      //NSLog(@"Utils.m searchForDSAObjectWithName checking key: %@", key);
      id value = dictionary[key];
      NSDictionary *entry;
      BOOL looksLikeItem = NO;
      if ([value isKindOfClass:[NSDictionary class]])
        {
          entry = (NSDictionary *)value;
        
            looksLikeItem = (entry[@"TrefferpunkteKK"] ||
                      entry[@"TP Entfernung"] ||
                      entry[@"Rüstschutz"] ||
                      entry[@"Waffenvergleichswert"] ||
                      entry[@"Waffenvergleichswert Schild"] ||
                      entry[@"Preis"] ||
                      entry[@"Gewicht"]);
        } 
      if (looksLikeItem && [key isEqualToString:name] && [value isKindOfClass:[NSDictionary class]])
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

// image indices dict related methods
+ (NSDictionary *) getImagesIndexDict
{
  return imagesIndexDict;
}

+ (NSArray<NSString *> *)filteredImageNames:(NSArray<NSString *> *)allNames withSizeSuffix:(NSString *)sizeSuffix {
    if (!sizeSuffix || sizeSuffix.length == 0) {
        // Falls kein Suffix angegeben wurde, gib alle ohne -WxH zurück
        NSRegularExpression *sizeRegex = [NSRegularExpression regularExpressionWithPattern:@"-\\d+x\\d+\\." options:0 error:nil];
        NSMutableArray<NSString *> *result = [NSMutableArray array];
        
        for (NSString *name in allNames) {
            NSRange match = [sizeRegex rangeOfFirstMatchInString:name options:0 range:NSMakeRange(0, name.length)];
            if (match.location == NSNotFound) {
                [result addObject:name];
            }
        }
        return result;
    } else {
        // Suche nach genau dieser Größe, z. B. -512x512
        NSString *pattern = [NSString stringWithFormat:@"-%@\\.", sizeSuffix];
        NSRegularExpression *exactSizeRegex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSMutableArray<NSString *> *result = [NSMutableArray array];
        
        for (NSString *name in allNames) {
            NSRange match = [exactSizeRegex rangeOfFirstMatchInString:name options:0 range:NSMakeRange(0, name.length)];
            if (match.location != NSNotFound) {
                [result addObject:name];
            }
        }
        return result;
    }
}

+ (NSString *)randomImageNameForKey:(NSString *)key
                     withSizeSuffix:(NSString *)sizeSuffix
                         seedString:(NSString *)seedString
{
    NSDictionary *index = [self getImagesIndexDict];
    NSArray<NSString *> *candidates = index[key];
    if (!candidates || candidates.count == 0) {
        return nil;
    }

    // Filtern nach Größe
    NSArray<NSString *> *filtered = [self filteredImageNames:candidates withSizeSuffix:sizeSuffix];
    if (filtered.count == 0) {
        // Fallback: alles ohne Größenfilter
        filtered = [self filteredImageNames:candidates withSizeSuffix:nil];
        if (filtered.count == 0) {
            return nil;
        }
    }

    // Pseudozufällige Auswahl, abhängig vom seedString (z.B. Position, Tile, etc.)
    NSUInteger seed = [seedString hash];
    NSUInteger indexInList = seed % filtered.count;
    return filtered[indexInList];
}

// takes a region abbreviation in all uppercase letters, i.e. TH for Thorwal
// when region name is nil, it will check current adventure for current Region
// gender may be male or female, otherwise when nil, it will randomly choose.
+ (NSString *)randomImageNameForKey:(NSString *)key
                     withSizeSuffix:(NSString *)sizeSuffix
                          forRegion:(NSString *)regionName
                             gender:(NSString *)gender
                         seedString:(NSString *)seedString
{
    NSDictionary *index = [self getImagesIndexDict];
    if (!index || index.count == 0) return nil;
    
    NSLog(@"Utils randomImageNameForKey: Looking for image with size suffix: %@", sizeSuffix);
    
    NSString *region = regionName.length > 0 ? regionName.uppercaseString : [self currentRegionCode];
    NSString *useGender = gender.length > 0 ? gender.lowercaseString : (([seedString hash] % 2 == 0) ? @"male" : @"female");
    
    NSArray<NSString *> *candidates = nil;
    
    // 1️⃣ REGION + KEY + GENDER
    NSString *key1 = [NSString stringWithFormat:@"%@_%@_%@", region, key, useGender];
    candidates = index[key1];
    NSLog(@"Utils randomImageNameForKey: candidates after checking with region/key/gender: %@", candidates);
    // 2️⃣ KEY + GENDER
    if (!candidates || candidates.count == 0) {
        NSString *key2 = [NSString stringWithFormat:@"%@_%@", key, useGender];
        candidates = index[key2];
    }
    NSLog(@"Utils randomImageNameForKey: candidates after checking with key/gender only: %@", candidates);
    // 3️⃣ REGION + KEY
    if (!candidates || candidates.count == 0) {
        NSString *key3 = [NSString stringWithFormat:@"%@_%@", region, key];
        candidates = index[key3];
    }
    NSLog(@"Utils randomImageNameForKey: candidates after checking with region/key only: %@", candidates);
    // 4️⃣ KEY allein
    if (!candidates || candidates.count == 0) {
        candidates = index[key];
    }
    NSLog(@"Utils randomImageNameForKey: candidates after checking with key only: %@", candidates);
    if (!candidates || candidates.count == 0) return nil;
    
    // Filter nach Größe
    NSLog(@"Utils randomImageNameForKey: candidates before filtering by size: %@", candidates);
    NSArray<NSString *> *filtered = [self filteredImageNames:candidates withSizeSuffix:sizeSuffix];
    if (!filtered || filtered.count == 0) {
        filtered = candidates; // fallback: alle nehmen
    }
    NSLog(@"Utils randomImageNameForKey: candidates after  filtering by size: %@", filtered);
    // Deterministische Auswahl basierend auf seed
    NSUInteger seed = seedString.hash;
    NSUInteger idx = seed % filtered.count;
    return filtered[idx];
}


+ (NSString *)currentRegionCode
{
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;

    DSALocation *globalLocation =
        [[DSALocations sharedInstance]
            locationWithName: currentPosition.globalLocationName
                      ofType:@"global"];

    DSAGlobalMapLocation *gl = (DSAGlobalMapLocation *)globalLocation;
    return gl.region.uppercaseString; // i.e. "TH"
}

@end
