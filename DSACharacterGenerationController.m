/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 20:45:24 +0200 by sebastia

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

#import "DSACharacterGenerationController.h"
#import "DSACharacter.h"
#import "Utils.h"
#import "DSACharacterHeroHumanThorwaler.h"
#import "DSACharacterHeroMage.h"
#import "DSAPositiveTrait.h"
#import "DSANegativeTrait.h"
#import "DSAFightingTalent.h"
#import "DSAOtherTalent.h"
#import "NSMutableDictionary+Extras.h"

@implementation DSACharacterGenerationController

@synthesize talentsDict;
@synthesize archetypesDict;
@synthesize professionsDict;
@synthesize originsDict;
@synthesize mageAcademiesDict;
@synthesize eyeColorsDict;
@synthesize birthdaysDict;
@synthesize godsDict;

//@synthesize popupCategories;


- (instancetype)init
{
  NSLog(@"DSACharacterGenerationController init was called");
  self = [super initWithWindowNibName:@"CharacterGeneration"];
  if (self)
    {
      _generatedCharacter = [[DSACharacter alloc] init];
      _traitsDict = [[NSMutableDictionary alloc] init];
      _wealth = [[NSMutableDictionary alloc] init];
      _birthday = [[NSMutableDictionary alloc] init];
      _portraitsArray = [[NSMutableArray alloc] init];
    
      NSError *e = nil;
      NSString *filePath;
            
      filePath = [[NSBundle mainBundle] pathForResource:@"Talente" ofType:@"json"];
      talentsDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];
        
      filePath = [[NSBundle mainBundle] pathForResource:@"Typus" ofType:@"json"];  
      archetypesDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e]; 
             
      filePath = [[NSBundle mainBundle] pathForResource:@"Berufe" ofType:@"json"];        
      professionsDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];
        
      filePath = [[NSBundle mainBundle] pathForResource:@"Herkunft" ofType:@"json"];         
      originsDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];
        
      filePath = [[NSBundle mainBundle] pathForResource:@"Magierakademien" ofType:@"json"];                 
      mageAcademiesDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];
      
      filePath = [[NSBundle mainBundle] pathForResource:@"Augenfarben" ofType:@"json"];                       
      eyeColorsDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];
      
      filePath = [[NSBundle mainBundle] pathForResource:@"Geburtstag" ofType:@"json"];                       
      birthdaysDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];      
        
      filePath = [[NSBundle mainBundle] pathForResource:@"Goetter" ofType:@"json"];                         
      godsDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
        options: NSJSONReadingMutableContainers
        error: &e];      
        
      [self loadPortraits];
    }
  return self;
}

- (void)loadPortraits {
    // Get the main bundle path
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    // Create file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Get all files in the resource directory
    NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:resourcePath error:nil];
    
    // Iterate through the files and filter for files that match "*male.png"
    for (NSString *fileName in allFiles) {
        if ([fileName hasSuffix:@"male.png"]) {
            // Get the full path for the image
            NSString *imagePath = [resourcePath stringByAppendingPathComponent:fileName];
            
            // Load the image as NSImage
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
            
            // Add the image to the array if it is valid
            if (image) {
                [self.portraitsArray addObject:image];
            }
        }
    }
    
    NSLog(@"Loaded %lu portraits images.", (unsigned long)self.portraitsArray.count);
}

- (void)startCharacterGeneration: (id)sender
{
  NSLog(@"DSACharacterGenerationController startCharacterGeneration was called, sender: %@", sender);
  [self windowDidLoad];
  [self showWindow:self];
  [[self window] makeKeyAndOrderFront: self];
  [self.popupCategories removeAllItems];
  [self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [self getAllArchetypesCategories]];
   
  [self.popupArchetypes removeAllItems];
  [self.popupArchetypes addItemWithTitle: _(@"Typus wählen")];
//  [self.popupArchetypes addItemsWithTitles: [self getAllArchetypesForCategory: [[self.popupCategories selectedItem] title]]];
  
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
//  [self.popupOrigins addItemsWithTitles: [originsDict allKeys]];
  [self.popupProfessions removeAllItems];
  [self.popupProfessions addItemWithTitle: _(@"Beruf wählen")];  
//  [self.popupProfessions addItemsWithTitles: [self getProfessionsForArchetype: [[self.popupCategories selectedItem] title]]];
  [self.popupMageAcademies removeAllItems];
  [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];  
//  [self.popupMageAcademies addItemsWithTitles: [[self mageAcademiesDict] allKeys]];
  
  [self.popupArchetypes setEnabled: NO];   
  [self.popupOrigins setEnabled: NO];
  [self.popupProfessions setEnabled: NO];
  [self.popupMageAcademies setEnabled: NO];
  [self.buttonGenerate setEnabled: NO];  
  [self.buttonFinish setEnabled: NO];
 
  [self.fieldName setEnabled: NO];
  [self.fieldTitle setEnabled: NO];  
  
  NSLog(@"DSACharacterGenerationController: startCharacterGeneration %@, %@", self.popupCategories, [self getAllArchetypesCategories]);
}

- (void)createCharacter:(id)sender
{
    NSString *characterName = [self.fieldName stringValue];
    NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
    NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
    NSString *selectedProfession = [[self.popupProfessions selectedItem] title];
    
    DSACharacterHero *newCharacter = nil;

    // Based on selectedArchetype, create the correct character subclass
    if ([selectedArchetype isEqualToString:_(@"Thorwaler")]) {
        newCharacter = [[DSACharacterHeroHumanThorwaler alloc] init];
    } else if ([selectedArchetype isEqualToString:_(@"Magier")]) {
        newCharacter = [[DSACharacterHeroMage alloc] init];
/*    } else {
        // Default to the base class or handle errors
        newCharacter = [[DSACharacterHero alloc] init]; */
    }

    // Set common properties for the new character
    newCharacter.name = characterName;
    newCharacter.archetype = selectedArchetype;

    [newCharacter setValue: [NSNumber numberWithInteger: 22] forKey: @"adventurePoints"];
    newCharacter.professions = [NSMutableArray arrayWithArray: @[ selectedProfession ]];
    newCharacter.hairColor = [self.fieldHairColor stringValue];
    newCharacter.eyeColor = [self.fieldEyeColor stringValue];
    newCharacter.height = [self.fieldHeight stringValue];
    newCharacter.weight = [self.fieldWeight stringValue];
    newCharacter.god = [self.fieldGod stringValue];
    newCharacter.stars = [self.fieldStars stringValue];
    newCharacter.socialStatus = [self.fieldSocialStatus stringValue];
    newCharacter.parents = [self.fieldParents stringValue];
    newCharacter.sex = [[self.popupSex selectedItem] title];
    newCharacter.title = [self.fieldTitle stringValue];
    newCharacter.birthday = self.birthday;
    newCharacter.money = [NSMutableDictionary dictionaryWithDictionary: self.wealth];
    newCharacter.portrait = [self.imageViewPortrait image];
    
    if ([self.popupMageAcademies isEnabled])
      {
         newCharacter.mageAcademy = [[self.popupMageAcademies selectedItem] title];
      }
    else
      {
         newCharacter.mageAcademy = nil;
      }

    if ([self.popupOrigins isEnabled] && [self.popupOrigins indexOfSelectedItem] != 0)
      {
        newCharacter.origin = selectedOrigin;
      }
    // handle positive Traits
    NSMutableDictionary *positiveTraits = [[NSMutableDictionary alloc] init];
    for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
      {
        [positiveTraits setObject: 
          [[DSAPositiveTrait alloc] initTrait: field 
                                      onLevel: [NSNumber numberWithInt: 
                                          [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] integerValue]]]
                           forKey: field];  
      }
    newCharacter.positiveTraits = positiveTraits;
    // handle negative Traits    
    NSMutableDictionary *negativeTraits = [[NSMutableDictionary alloc] init];
    for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
      {
        [negativeTraits setObject: 
          [[DSANegativeTrait alloc] initTrait: field 
                                      onLevel: [NSNumber numberWithInt: 
                                          [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] integerValue]]]
                           forKey: field];  
      }
    newCharacter.negativeTraits = negativeTraits;
    
    // handle talents
    NSDictionary *talents = [[NSDictionary alloc] init];
    talents = [self getTalentsForArchetype: selectedArchetype];
//    NSLog(@"THE TALENTS WE GOT: %@", talents);
    NSMutableDictionary *newTalents = [[NSMutableDictionary alloc] init];
    for (NSString *category in talents)
      {
        if ([category isEqualTo: @"Kampftechniken"])
          {   
            for (NSString *subCategory in [talents objectForKey: category])
              {
                for (NSString *t in [[talents objectForKey: category] objectForKey: subCategory])
                  {
                     NSDictionary *tDict = [[[talents objectForKey: category] objectForKey: subCategory] objectForKey: t];
                     DSAFightingTalent *talent = [[DSAFightingTalent alloc] initTalent: t
                                                                         inSubCategory: subCategory
                                                                            ofCategory: category
                                                                               onLevel: [NSNumber numberWithInteger: [[tDict objectForKey: @"Startwert"] integerValue]]
                                                                withMaxTriesPerLevelUp: [NSNumber numberWithInteger: [[tDict objectForKey: @"Versuche"] integerValue]]
                                                                     withMaxUpPerLevel: [NSNumber numberWithInteger: [[tDict objectForKey: @"Steigern"] integerValue]]];
                    [newTalents setObject: talent forKey: t];
                  }
              }
          }
        else
          {
            for (NSString *t in [talents objectForKey: category])
              {
                NSDictionary *tDict = [[talents objectForKey: category] objectForKey: t];                             
                DSAOtherTalent *talent = [[DSAOtherTalent alloc] initTalent: t
                                                                 ofCategory: category
                                                                    onLevel: [NSNumber numberWithInteger: [[tDict objectForKey: @"Startwert"] integerValue]]
                                                                   withTest: [tDict objectForKey: @"Probe"]
                                                     withMaxTriesPerLevelUp: [NSNumber numberWithInteger: [[tDict objectForKey: @"Versuche"] integerValue]]
                                                          withMaxUpPerLevel: [NSNumber numberWithInteger: [[tDict objectForKey: @"Steigern"] integerValue]]]; 
                [newTalents setObject: talent forKey: t];
              }
          }
          
      }
    newCharacter.talents = newTalents;
    
    // apply Göttergeschenke and Origins modificators
    [self apply: @"Goettergeschenke" toArchetype: newCharacter];
    [self apply: @"Herkunft" toArchetype: newCharacter];    
    
    // Store the generated character
    self.generatedCharacter = newCharacter;
}

// Call this once the character generation process is complete
- (void)completeCharacterGeneration
{
  if (self.completionHandler)
    {
      self.completionHandler(self.generatedCharacter);
    }
  [self close]; // Close the character generation window
}

// to apply "Göttergeschenke" or "Herkunfsmodifikatoren"
- (void) apply: (NSString *) modificator toArchetype: (DSACharacterHero *) archetype
{
  NSMutableDictionary *traits = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *talents = [[NSMutableDictionary alloc] init];
  
  if ([@"Goettergeschenke" isEqualTo: modificator])
    {
      traits = [[self.godsDict objectForKey: archetype.god] objectForKey: @"Basiswerte"];
      talents = [[self.godsDict objectForKey: archetype.god] objectForKey: @"Talente"];

       
    }
  else if ([@"Herkunft" isEqualTo: modificator])
    {

      talents = [[self.originsDict objectForKey: archetype.origin] objectForKey: @"Talente"]; 
    }
  else
    {
      NSLog(@"Don't know how to apply modificator: %@", modificator);
    }  

  // positive traits
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
  for (NSString *category in [talents allKeys])
    {
      if ([category isEqualTo: @"Kampftechniken"])
        {
          for (NSString *subCategory in [talents objectForKey: category])
            {
              for (NSString *talent in [[talents objectForKey: category] objectForKey: subCategory])
                {
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
              NSInteger geschenk = [[archetype valueForKeyPath: [NSString stringWithFormat: @"talents.%@.level", talent]] integerValue] + [[[talents objectForKey: category] objectForKey: talent] integerValue];
              [archetype setValue: [NSNumber numberWithInteger: geschenk]             
                       forKeyPath: [NSString stringWithFormat: @"talents.%@.level", talent]];
            }
        }
    }    
}

// lots of private methods here....

// finds and returns all archetypes as an array
- (NSArray *) getAllArchetypesCategories
{
  NSLog(@"getAllArchetypesCategories");
  NSMutableOrderedSet *categories = [[NSMutableOrderedSet alloc] init];
  
  for (NSDictionary *archetypus in archetypesDict)
    {
      [categories addObjectsFromArray: [[archetypesDict objectForKey: archetypus] objectForKey: @"Typkategorie"]];
    }
  return [categories array];
}

// finds all archetypes for a given category and returns them as an array
- (NSArray *) getAllArchetypesForCategory: (NSString *) category
{
  NSMutableArray *archetypes = [[NSMutableArray alloc] init];
  
  for (NSString *type in [archetypesDict allKeys])
    {
      if ([[[archetypesDict objectForKey: type] objectForKey: @"Typkategorie"] containsObject: category])
        {
          [archetypes addObject: type];
        }
    }
  return archetypes;
}

// returns an array of possible regional origins
- (NSArray *) getOriginsForArchetype: (NSString *) archetype
{
  NSMutableArray *origins = [[NSMutableArray alloc] init];
  
  if (archetype == nil)
    {
      [origins addObject: _(@"Mittelreich")];
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
    
  return origins;  
}

// returns all relevant professions for a given Archetype in an array
- (NSArray *) getProfessionsForArchetype: (NSString *) archetype
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
    
  return professions;
}

- (NSDictionary *) getTalentsForArchetype: (NSString *)archetype
{
  NSMutableDictionary *talente = [[NSMutableDictionary alloc] init];
  
  NSArray *talentGruppen = [NSArray arrayWithArray: [[self talentsDict] allKeys]];
  for (NSString *talentGruppe in talentGruppen)
    {
      if ([@"Kampftechniken" isEqualTo: talentGruppe])
        {
          NSString *steigern = [NSString stringWithFormat: @"%@", [[[self talentsDict] objectForKey: talentGruppe] objectForKey: @"Steigern"]];
          NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3];
         
          for (NSString *key in [[self talentsDict] objectForKey: talentGruppe])
            {
              NSString *waffentyp;
              NSString *startwert;
              if ([@"Steigern" isEqualTo: key])
                {
                  continue;
                }
              else
                {
                  waffentyp = [NSString stringWithFormat: @"%@", [[[[self talentsDict] objectForKey: talentGruppe] objectForKey: key] objectForKey: @"Waffentyp"]];
                  startwert = [NSString stringWithFormat: @"%@", [[[[[self talentsDict] objectForKey: talentGruppe] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: archetype]];
                }
                [talente setValue: @{@"Startwert": startwert, @"Steigern": steigern, @"Versuche": versuche} 
                  forKeyHierarchy: @[talentGruppe, waffentyp, key]];
            } 
        }
      else
        {
          NSString *steigern = [NSString stringWithFormat: @"%@", [[[self talentsDict] objectForKey: talentGruppe] objectForKey: @"Steigern"]];
          NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3]; 
          for (NSString *key in [[self talentsDict] objectForKey: talentGruppe])
            {
              NSArray *probe;
              NSString *startwert;
              if ([@"Steigern" isEqualTo: key])
                {
                  continue;
                }
              else
                {
                  probe = [NSArray arrayWithArray: [[[[self talentsDict] objectForKey: talentGruppe] objectForKey: key] objectForKey: @"Probe"]];
                  startwert = [NSString stringWithFormat: @"%@", [[[[[self talentsDict] objectForKey: talentGruppe] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: archetype]];
                }
                [talente setValue: @{@"Startwert": startwert, @"Probe": probe, @"Steigern": steigern, @"Versuche": versuche} forKeyHierarchy: @[talentGruppe, key]];
            }       
        }
    }
  return talente;
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
      result = [[Utils rollDice: @"1W6"] intValue] + 7;
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
      result = [[Utils rollDice: @"1W6"] intValue] + 1;
      [traits addObject: [NSNumber numberWithInt: result]];
    }
  
  return traits;
}


- (NSDictionary *) generateFamilyBackground: (NSString *)archetype
{

  NSString *dice = [[[archetypesDict objectForKey: archetype] objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
  NSNumber *diceResult = [Utils rollDice: dice];

  NSDictionary *herkuenfteDict = [NSDictionary dictionaryWithDictionary: [[archetypesDict objectForKey: archetype] objectForKey: @"Herkunft"]];
  NSArray *herkuenfteArr = [NSArray arrayWithArray: [herkuenfteDict allKeys]];
  NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
  
  for (NSString *socialStatus in herkuenfteArr)
    {
      if ([@"Würfel" isEqualTo: socialStatus])
        {
          continue;
        }
      
      if ([[[herkuenfteDict objectForKey: socialStatus] objectForKey: dice] containsObject: diceResult])
        {
          [retVal setObject: socialStatus forKey:@"Stand"];
          for (NSString *parents in [[[herkuenfteDict objectForKey: socialStatus] objectForKey: @"Eltern"] allKeys])
            {
              if ([[[[herkuenfteDict objectForKey: socialStatus] objectForKey: @"Eltern"] objectForKey: parents] containsObject: diceResult])
                {
                  [retVal setObject: parents forKey: @"Eltern"];
                  break;
                }
            }
          break;
        }
    }
  return retVal;
} 

/* generates initial wealth/money, as described in "Mit Mantel, Schwert
   und Zauberstab" S. 61 */
- (NSDictionary *) generateWealth: (NSString *)socialStatus
{
   NSMutableDictionary *money = [NSMutableDictionary dictionaryWithDictionary: @{@"K": [NSNumber numberWithInt: 0], 
                                                                                 @"H": [NSNumber numberWithInt: 0], 
                                                                                 @"S": [NSNumber numberWithInt: 0], 
                                                                                 @"D": [NSNumber numberWithInt: 0]}];
   if ([socialStatus isEqualTo: @"unfrei"])
     {
       [money setObject: [Utils rollDice: @"1W6"] forKey: @"S"];
     }
   else if ([socialStatus isEqualTo: @"arm"])
     {
       [money setObject: [Utils rollDice: @"1W6"] forKey: @"D"];
     }
   else if ([socialStatus isEqualTo: @"mittelständisch"])
     {
       [money setObject: [Utils rollDice: @"3W6"] forKey: @"D"];
     }
   else if ([socialStatus isEqualTo: @"reich"])
     {
       [money setObject: [NSNumber numberWithInt: [[Utils rollDice: @"2W20"] integerValue] + 20] forKey: @"D"];
     }
   else if ([socialStatus isEqualTo: @"adelig"])
     {
       [money setObject: [Utils rollDice: @"3W20"] forKey: @"D"];
     }
  NSLog(@"Money: %@", money);
  return money;
}


- (NSString *) generateHairColorForArchetype: (NSString *) archetype
{
  NSDictionary *hairConstraint = [NSDictionary dictionaryWithDictionary: [[archetypesDict objectForKey: archetype] objectForKey: @"Haarfarbe"]];
  NSNumber *diceResult = [Utils rollDice: @"1W20"];

  NSArray *colors = [NSArray arrayWithArray: [hairConstraint allKeys]];
  
  for (NSString *color in colors)
    {
      if ([[hairConstraint objectForKey: color] containsObject: diceResult])
        {
          return color;
        }
    }
  return @"nix";
}

/* if no Augenfarbe in the Typus description, 
   use the formula as defined in "Mit Mantel, Schwert und Zauberstab" */
- (NSString *) generateEyeColorForArchetype: (NSString *) archetype withHairColor: (NSString *) hairColor
{
  NSNumber *diceResult = [Utils rollDice: @"1W20"];
  
  if ([[archetypesDict objectForKey: archetype] objectForKey: @"Augenfarbe"] == nil)
    {
      // No special Augenfarbe defined for the characterType, we use the default calculation
      // algorithm as defined in "Mit Mantel, Schwert und Zauberstab S. 61"
      for (NSDictionary *entry in eyeColorsDict)
        {
          for (NSString *color in [entry objectForKey: @"Haarfarben"])
            {
              if ([color isEqualTo: hairColor])
                {
                  for (NSString *ec in [[entry objectForKey: @"Augenfarben"] allKeys])
                    {
                      if ([[[entry objectForKey: @"Augenfarben"] objectForKey: ec] containsObject: diceResult])
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
      NSDictionary *eyeColors = [NSDictionary dictionaryWithDictionary: [[archetypesDict objectForKey: archetype] objectForKey: @"Haarfarbe"]];
      
      for (NSString *color in [eyeColors allKeys])
        {
          if ([[eyeColors objectForKey: color] containsObject: diceResult])
            {
              // we found the color
              return color;
            }
        }
    }
  return @"nix";
}

/* generates the birthday, as described in  "Die Helden des Schwarzen Auges",
   Regelbuch II, S. 9. */

- (NSDictionary *) generateBirthday
{
  NSString *monthName = [[NSString alloc] init];
  NSNumber *day = [[NSNumber alloc] init];
  NSNumber *year = [[NSNumber alloc] init];
  NSNumber *diceResult = [Utils rollDice: @"1W20"];
  NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
  NSArray *months = [[birthdaysDict objectForKey: @"Monat"] allKeys];

  for (NSString *month in months)
    {
      if ([[[birthdaysDict objectForKey: @"Monat"] objectForKey: month] containsObject: diceResult])
        {
          monthName = [NSString stringWithFormat: @"%@", month];
        }
    }

  diceResult = [Utils rollDice: @"1W20"];
  NSArray *fifthOfMonth = [[birthdaysDict objectForKey: @"Monatsfuenftel"] allKeys];
  for (NSString *fifth in fifthOfMonth)  
    {
      if ([[[birthdaysDict objectForKey: @"Monatsfuenftel"] objectForKey: fifth] containsObject: diceResult])
        {
          day = [NSNumber numberWithInt: [fifth intValue] + [[Utils rollDice: @"1W6"] intValue] - 1];
        }
    }
  year = [NSNumber numberWithInt: 0];
  [retVal setObject: monthName forKey: @"month"];
  [retVal setObject: day forKey: @"day"];
  [retVal setObject: year forKey: @"year"];
  [retVal setObject: [NSString stringWithFormat: @"%@. %@ im Jahr %@ Hal", day, monthName, year] forKey: @"date"];
  return retVal;
}


- (NSString *) generateHeightForArchetype: (NSString *) archetype
{
  NSArray *heightArr = [NSArray arrayWithArray: [[archetypesDict objectForKey: archetype] objectForKey: @"Körpergröße"]];
  unsigned int height = [[heightArr objectAtIndex: 0] intValue];
  unsigned int count = [heightArr count];
  for (unsigned int i = 1;i<count; i++)
    {
      height += [[Utils rollDice: [heightArr objectAtIndex: i]] intValue];
    }
  return [NSString stringWithFormat: @"%u", height];
}

- (NSString *) generateWeightForArchetype: (NSString *) archetype withHeight: (NSString *) height
{
  int weight = [[[archetypesDict objectForKey: archetype] objectForKey: @"Gewicht"] intValue];
  return [NSString stringWithFormat: @"%u", (weight + [height intValue])];
}

- (void) setBackgroundColorForTraitsField: (NSString *) fieldName
{
  NSString *traitsFieldName = [NSString stringWithFormat: @"field%@", fieldName];
  NSString *constraintFieldName = [NSString stringWithFormat: @"field%@Constraint", fieldName];
  NSMutableDictionary *constraint = [[NSMutableDictionary alloc] init];
  NSTextField *traitsField = [[NSTextField alloc] init];
  NSTextField *constraintField = [[NSTextField alloc] init];
  traitsField = [self valueForKey: traitsFieldName];
  constraintField = [self valueForKey: constraintFieldName];
  if ([[constraintField stringValue] length] > 0)
    {
      [constraint removeAllObjects];
      [constraint addEntriesFromDictionary: [Utils parseConstraint: [constraintField stringValue]]];
      if ([[constraint objectForKey: @"constraint"] isEqualToString: @"MAX"])
        {
          if ([[traitsField stringValue] integerValue] < [[constraint objectForKey: @"value"] integerValue])
            {
              [traitsField setBackgroundColor: [NSColor redColor]];
            }
          else
            {
              [traitsField setBackgroundColor: [NSColor whiteColor]];
            }
        }
      else
        {
          if ([[traitsField stringValue] integerValue] > [[constraint objectForKey: @"value"] integerValue])
            {
              [traitsField setBackgroundColor: [NSColor redColor]];
            }        
          else
            {
              [traitsField setBackgroundColor: [NSColor whiteColor]];
            }            
        }
    }
}

- (void) enableFinishButtonIfPossible
{
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      if ([[[self valueForKey: [NSString stringWithFormat: @"field%@", field]] backgroundColor] isEqualTo: [NSColor redColor]])
        {
          [self.buttonFinish setEnabled: NO];
          return;
        }
    }
  if ([[self.fieldName backgroundColor] isEqualTo: [NSColor redColor]] || [[self.fieldTitle backgroundColor] isEqualTo: [NSColor redColor]])
    {
      [self.buttonFinish setEnabled: NO];
    }
  else
    {    
      [self.buttonFinish setEnabled: YES];
      NSFont *boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
      [self.buttonFinish setFont:boldFont];
      [self.buttonFinish setKeyEquivalent:@"\r"];
    }
} 


- (IBAction) popupCategorySelected: (id)sender
{
  NSLog(@"popupCategorySelected got called");
  if ([sender indexOfSelectedItem] == 0)
    {
      return;
    }
  
  [self.popupArchetypes removeAllItems];
  [self.popupArchetypes addItemWithTitle: _(@"Typus wählen")];
  [self.popupArchetypes addItemsWithTitles: [self getAllArchetypesForCategory: [[self.popupCategories selectedItem] title]]];
  [self.popupArchetypes setEnabled: YES];  
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
  [self.popupProfessions removeAllItems];
  [self.popupProfessions addItemWithTitle: _(@"Beruf wählen")];  
  [self.popupMageAcademies removeAllItems];
  [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];        
  [self.popupOrigins setEnabled: NO];
  [self.popupProfessions setEnabled: NO];  
  [self.popupMageAcademies setEnabled: NO];    
}

- (IBAction) popupArchetypeSelected: (id)sender
{

  NSLog(@"popupArchetypeSelected got called");
  if ([sender indexOfSelectedItem] == 0)
    {
      return;
    }

  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [archetypesDict objectForKey: [[self.popupArchetypes selectedItem] title]]];
      
  if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: @"Magier"] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];      
      [self.popupMageAcademies addItemsWithTitles: [mageAcademiesDict allKeys]];
      [self.fieldMageSchool setStringValue: _(@"Magierakademie")];
    }
  else if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: @"Geode"] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemWithTitle: _(@"Schule wählen")];
      [self.popupMageAcademies addItemsWithTitles: [charConstraints objectForKey: @"Schule"]];
      [self.fieldMageSchool setStringValue: _(@"Geodische Schule")];
    }
  else
    {
      [self.popupMageAcademies selectItemAtIndex: 0];    
      [self.popupMageAcademies setEnabled: NO];   
      [self.popupMageAcademies setTitle: _(@"Akademie")];  
      [self.fieldMageSchool setStringValue: _(@"Magierakademie")];
    }
        
  // Die Herkünfte
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
  [self.popupOrigins addItemsWithTitles: [self getOriginsForArchetype: [[self.popupArchetypes selectedItem] title]]];
  if ([self.popupOrigins numberOfItems] == 1)
    {
      [self.popupOrigins setEnabled: NO];        
    }
  else
    {
      [self.popupOrigins setEnabled: YES];        
    }  
                        
  // Die Berufe
  [self.popupProfessions removeAllItems];
  [self.popupProfessions addItemWithTitle: _(@"Beruf wählen")];  
  [self.popupProfessions addItemsWithTitles: [self getProfessionsForArchetype: [[self.popupArchetypes selectedItem] title]]];
  if ([self.popupProfessions numberOfItems] == 1)
    {
      [self.popupProfessions setEnabled: NO];        
    }
  else
    {
      [self.popupProfessions setEnabled: YES];        
    }
  
  [self.buttonGenerate setEnabled: YES];

      
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                             @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ", 
                             @"HairColor", @"EyeColor", @"Height", @"Weight",
                             @"Birthday", @"God", @"Stars", @"SocialStatus", @"Parents", @"Wealth" ])
    {
      [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] setBackgroundColor: [NSColor whiteColor]];
      [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] setStringValue: @""];
    }      
        
  NSDictionary *traitsDict = [NSDictionary dictionaryWithDictionary: [charConstraints objectForKey: @"Eigenschaften"]];      
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                             @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {         
      if ([traitsDict objectForKey: field] == nil)
        {
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: @""];
        }
      else
        {
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [traitsDict objectForKey: field]];              
        }
    }
}

- (IBAction) popupOriginSelected: (id)sender
{

  NSLog(@"popupOriginSelected got called");

  // einige Herkünfte haben extra Bedingungen
  NSDictionary *originConstraints = [[originsDict objectForKey: [[self.popupOrigins selectedItem] title]] objectForKey: @"Basiswerte"];  
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                            @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {        
      if (!([originConstraints objectForKey: field] == nil))
        {
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [originConstraints objectForKey: field]];              
        }
    }    
}

- (IBAction) popupProfessionSelected: (id)sender
{

  NSLog(@"popupProfessionSelected got called");
  
  NSDictionary *professionConstraints = [[[professionsDict objectForKey: [[self.popupProfessions selectedItem] title]] objectForKey: @"Bedingung"] objectForKey: @"Basiswerte"];  
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                             @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {          
      if ([professionConstraints objectForKey: field] == nil)
        {
          // Beruf hat stärkere Bedingung als Typus
          // gibt eh keine logischen Konflikte, da nur Anatom Bedingung auf TA hat...
        }
      else
        {
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [professionConstraints objectForKey: field]];              
        }
    } 
}

- (IBAction) popupMageAcademySelected: (id)sender
{

  NSLog(@"popupMageAcademySelected got called");
  
//  [aktiverCharakter setMagischeSchule: [[popupWinCharDefMagischeSchule selectedItem] title]];
  
}

- (IBAction) popupSexSelected: (id)sender
{

  NSLog(@"popupSexSelected got called");
  
//  [aktiverCharakter setMagischeSchule: [[popupWinCharDefMagischeSchule selectedItem] title]];
  
}

- (IBAction) buttonGenerateClicked: (id)sender
{
  NSLog(@"HERE in buttonGeneratePressed");

  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [archetypesDict objectForKey: [[self.popupArchetypes selectedItem] title]]];
  NSArray *positiveArr = [NSArray arrayWithArray: [self generatePositiveTraits]];
  NSArray *negativeArr = [NSArray arrayWithArray: [self generateNegativeTraits]];
  NSDictionary *birthday = [[NSDictionary alloc] init];
  NSDictionary *socialStatusParents = [self generateFamilyBackground: [[self.popupArchetypes selectedItem] title]];
  NSDictionary *wealthDict = [self generateWealth: [socialStatusParents objectForKey: @"Stand"]];
  
  [self.fieldHairColor setStringValue: [self generateHairColorForArchetype: [[self.popupArchetypes selectedItem] title]]];
  [self.fieldEyeColor setStringValue: [self generateEyeColorForArchetype: [[self.popupArchetypes selectedItem] title] withHairColor: [self.fieldHairColor stringValue]]];  
  birthday = [self generateBirthday];
  [self.fieldBirthday setStringValue: [birthday objectForKey: @"date"]];
  [self.fieldGod setStringValue: [birthday objectForKey: @"month"]];
  [self.fieldHeight setStringValue: [self generateHeightForArchetype: [[self.popupArchetypes selectedItem] title]]];
  [self.fieldWeight setStringValue: [self generateWeightForArchetype: [[self.popupArchetypes selectedItem] title] withHeight: [self.fieldHeight stringValue]]];
  [self.fieldName setEnabled: YES];
  [self.fieldTitle setEnabled: YES];
  
  [self.popupSex removeAllItems];
  [self.popupSex addItemsWithTitles: [charConstraints objectForKey: @"Geschlecht"]];
  
  if ([[self.fieldName stringValue] length] > 0)
    {
      [self.fieldName setBackgroundColor: [NSColor whiteColor]];
    }
  else
    {
      [self.fieldName setBackgroundColor: [NSColor redColor]];    
    }
  if ([[self.fieldTitle stringValue] length] > 0)
    {
      [self.fieldTitle setBackgroundColor: [NSColor whiteColor]];
    }
  else
    {
      [self.fieldTitle setBackgroundColor: [NSColor redColor]];    
    }
    
  [self.fieldSocialStatus setStringValue: [socialStatusParents objectForKey: @"Stand"]];
  [self.fieldParents setStringValue: [socialStatusParents objectForKey: @"Eltern"]];
  [self.fieldWealth setStringValue: [NSString stringWithFormat: @"%@D %@S %@H %@K", 
                                              [wealthDict objectForKey: @"D"], 
                                              [wealthDict objectForKey: @"S"], 
                                              [wealthDict objectForKey: @"H"], 
                                              [wealthDict objectForKey: @"K"]]];
  [self.fieldStars setStringValue: [[[self godsDict] objectForKey: [birthday objectForKey: @"month"]] objectForKey: @"Sternbild"]];

  
  // positive traits  
  int i = 0;
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] setStringValue: [positiveArr objectAtIndex: i]];
      [self setBackgroundColorForTraitsField: field];
      i++;
    }
        
  // Negative Eigenschaften
  i = 0;
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] setStringValue: [negativeArr objectAtIndex: i]];
      [self setBackgroundColorForTraitsField: field];
      i++;
    }
      
  [self enableFinishButtonIfPossible];

  // save that temporarily here, so we can assign it later when it comes to character creation....
  self.birthday = birthday;
  self.wealth = wealthDict;
  
  if (self.portraitsArray.count > 0)
    {
      // Get the first image from the array
      NSImage *firstImage = [self.portraitsArray objectAtIndex:0];
    
      // Set it to the image view
      [self.imageViewPortrait setImage:firstImage];
      [self.imageViewPortrait setImageScaling:NSImageScaleProportionallyUpOrDown];
    }
  else
    {
      NSLog(@"The portraitsArray is empty.");
    }
}


- (IBAction)buttonFinishClicked:(id)sender
{
  NSLog(@"DSACharacterGenerationController: finishCharacterCreation was called");

  // Validate all required fields, create the appropriate character subclass
  [self createCharacter:sender];

  // Complete the character generation and trigger the completion handler
  [self completeCharacterGeneration];
}

- (IBAction) buttonTraitsClicked: (id)sender
{
  NSString *buttonTypeName;
  
  if ([@[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ] containsObject: [sender title]])
    {
      buttonTypeName = @"activePosButton";
    }
  else
    {
      buttonTypeName = @"activeNegButton";    
    }
  
  //in case two buttons are marked, then the related fields are supposed
  // to exchange values, and button state to be reset
  if ([sender state] == 1 && [[self.traitsDict objectForKey: buttonTypeName] length] > 0)
    {
       NSString *tmpVal = [[self valueForKey:[NSString stringWithFormat: @"field%@", [sender title]]] stringValue];
       NSString *otherField = [NSString stringWithString: [self.traitsDict objectForKey: buttonTypeName]];

       [[self valueForKey: [NSString stringWithFormat: @"field%@", otherField]] setStringValue: tmpVal];
       [[self valueForKey: [NSString stringWithFormat: @"field%@", [sender title]]] setStringValue: [self.traitsDict objectForKey: otherField]];
       [sender setState: 0];
       [[self valueForKey: [NSString stringWithFormat: @"button%@", otherField]] setState: 0];
              
       [self.traitsDict setObject: @"" forKey: buttonTypeName];
       [self.traitsDict removeObjectForKey: otherField];
       [self setBackgroundColorForTraitsField: [sender title]];
       [self setBackgroundColorForTraitsField: otherField];
       [self enableFinishButtonIfPossible];
       return;
    }
  
  // a button is pressed, and the same button pressed again
  if ([sender state] == 0)
    {
      [self.traitsDict setObject: @"" forKey: buttonTypeName];
      [self.traitsDict removeObjectForKey: [sender title]];
      [self enableFinishButtonIfPossible];      
      return;
    }
  else if ([sender state] == 1)
    {
      [self.traitsDict setObject: [sender title] forKey: buttonTypeName];
      [self.traitsDict setObject: [[self valueForKey: [NSString stringWithFormat: @"field%@", [sender title]]] stringValue]
                          forKey: [sender title]];
      [self enableFinishButtonIfPossible];      
    }  
   
}

- (IBAction)buttonImageClicked:(NSButton *)sender
{
  // Check the button's tag: 0 for previous, 1 for next
  if (sender.tag == 0)
    {
      // Previous button clicked
      self.currentPortraitIndex--;
      if (self.currentPortraitIndex < 0)
        {
          self.currentPortraitIndex = self.portraitsArray.count - 1; // Wrap around to the last image
        }
    }
  else if (sender.tag == 1)
    {
      // Next button clicked
      self.currentPortraitIndex++;
      if (self.currentPortraitIndex >= self.portraitsArray.count)
        {
          self.currentPortraitIndex = 0; // Wrap around to the first image
        }
    }
    
  // Update the image view with the new image
  NSImage *newImage = [self.portraitsArray objectAtIndex:self.currentPortraitIndex];
  [self.imageViewPortrait setImage:newImage];
}

- (IBAction) textFieldUpdated: (id)sender
{
  if ([[sender stringValue] length] > 0)
    {
      [sender setBackgroundColor: [NSColor whiteColor]];
    }
  else
    {
      [sender setBackgroundColor: [NSColor redColor]];
    }
  [self enableFinishButtonIfPossible];    
}

@end
