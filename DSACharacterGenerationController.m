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
      NSError *e = nil;
      NSString *filePath;
      
      _generatedCharacter = [[DSACharacter alloc] init];

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
    }
  return self;
}

- (void)startCharacterGeneration: (id)sender
{
  NSLog(@"DSACharacterGenerationController startCharacterGeneration was called, sender: %@", sender);
  [self windowDidLoad];
  [self showWindow:self];
  [[self window] makeKeyAndOrderFront: self];
//  [self.popupCategories removeAllItems];
  [self.popupCategories addItemsWithTitles: [self getAllArchetypesCategories]];
   
//  [self.popupArchetypes removeAllItems];
  [self.popupArchetypes addItemsWithTitles: [self getAllArchetypesForCategory: [[self.popupCategories selectedItem] title]]];
  
  
  [self.popupOrigins addItemsWithTitles: [originsDict allKeys]];
  [self.popupProfessions addItemsWithTitles: [self getProfessionsForArchetype: [[self.popupCategories selectedItem] title]]];
  [self.popupMageAcademies addItemsWithTitles: [[self mageAcademiesDict] allKeys]];
  
/*  if ([[sender title] isEqualTo: @"Charakter generieren"])
    {
      [self.popupArchetypes setEnabled: NO];   
    }
  else
    { */
      [self.popupArchetypes setEnabled: YES];       
//    }
  [self.popupOrigins setEnabled: NO];
  [self.popupProfessions setEnabled: NO];
  [self.popupMageAcademies setEnabled: NO];
  [self.buttonGenerate setEnabled: NO];  
  [self.buttonFinish setEnabled: NO];
/* 
//  [fieldCharGenName setEnabled: NO];
//  [fieldCharGenTitel setEnabled: NO];  
  */  
  NSLog(@"DSACharacterGenerationController: startCharacterGeneration %@, %@", self.popupCategories, [self getAllArchetypesCategories]);


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
  NSLog(@"DSACharacterGenerationController: getAllArchetypesCategories returning: %@", [categories array]);
  return [categories array];
}

// finds all archetypes for a given category and returns them as an array
- (NSArray *) getAllArchetypesForCategory: (NSString *) category
{
  NSMutableArray *archetypes = [[NSMutableArray alloc] init];
  
  for (NSString *type in [archetypesDict allKeys])
    {
      NSLog(@"checking type: %@ for kategorie: %@", type, category);
      NSLog(@"type: %@", [archetypesDict objectForKey: type]);
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
      NSLog(@"getOriginsForArchetype: archetype was NIL");
      [origins addObject: _(@"Mittelreich")];
      return origins;
    }
  
  NSLog(@"the origins dict: %@", originsDict);  
    
  for (NSString *origin in [originsDict allKeys])
    {
      NSLog(@"checking ORIGIN: %@", origin);
      NSLog(@"YIKES: %@", [originsDict objectForKey: origin]);
      if ([[originsDict objectForKey: origin] objectForKey: @"Typen"] != nil)
        {
          NSLog(@"ORIGIN contained Typen!!!!");
          if ([[[originsDict objectForKey: origin] objectForKey: @"Typen"] containsObject: archetype])
            {
              NSLog(@"ORIGIN contained archetype: %@", archetype);
              [origins addObject: origin];
            }
        }
      else
        {
          NSLog(@"ORIGIN din't contained Typen!!!!");        
        }
    }
    
  [origins insertObject: _(@"Mittelreich") atIndex: 0];
  return origins;  
}

// returns all relevant professions for a given Archetype in an array
- (NSArray *) getProfessionsForArchetype: (NSString *) archetype
{
  NSMutableArray *professions = [[NSMutableArray alloc] init];
  
  if (archetype == nil)
    {
      NSLog(@"getProfessionsForArchetypes: archetype was NIL");
      [professions addObject: _(@"Kein Beruf")];
      return professions;
    }
  
  NSLog(@"the professions dict: %@", professionsDict);  
    
  for (NSString *profession in [professionsDict allKeys])
    {
      NSLog(@"checking BERUF: %@", profession);
      NSLog(@"YIKES: %@", [professionsDict objectForKey: profession]);
      if ([[professionsDict objectForKey: profession] objectForKey: @"Typen"] != nil)
        {
          NSLog(@"BERUF contained Typen!!!!");
          if ([[[professionsDict objectForKey: profession] objectForKey: @"Typen"] containsObject: archetype])
            {
              NSLog(@"BERUF contained characterType: %@", archetype);
              [professions addObject: profession];
            }
        }
      else
        {
          NSLog(@"BERUF din't contained Typen!!!!");        
        }
    }
    
  [professions insertObject: _(@"Kein Beruf") atIndex: 0];
  return professions;
}

- (IBAction) popupCategorySelected: (id)sender
{

  NSLog(@"popupCategorySelected got called");
  [self.popupArchetypes removeAllItems];
  [self.popupArchetypes addItemsWithTitles: [self getAllArchetypesForCategory: [[self.popupCategories selectedItem] title]]];
  [self.popupArchetypes setEnabled: YES];       

}

- (void) popupArchetypeSelected: (id)sender
{

  NSLog(@"popupArchetypeSelected got called");
  
//  [aktiverCharakter setTypus: [[popupWinCharDefTypus selectedItem] title]];
  
//  NSLog(@"aktiverCharakter: %@ %@", [aktiverCharakter typus], aktiverCharakter);
  
//  if ([popupWinCharDefTypus indexOfSelectedItem] != 0)
//    {
  
      NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [archetypesDict objectForKey: [[self.popupArchetypes selectedItem] title]]];
      NSLog(@"charConstraints: %@", charConstraints);
      
      if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: @"Magier"] )
        {
          [self.popupMageAcademies setEnabled: YES];
          [self.popupMageAcademies removeAllItems];
          [self.popupMageAcademies addItemsWithTitles: [mageAcademiesDict allKeys]];
          [self.fieldMageSchool setStringValue: _(@"Magierakademie")];
        }
      else if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: @"Geode"] )
        {
          [self.popupMageAcademies setEnabled: YES];
          [self.popupMageAcademies removeAllItems];
          [self.popupMageAcademies addItemsWithTitles: [charConstraints objectForKey: @"Schule"]];
          [self.fieldMageSchool setStringValue: _(@"Geodische Fakultät")];
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
/*    }
  else
    {
      [buttonCharGenGenerieren setEnabled: NO];
      [buttonCharGenAuswahl setEnabled: NO];
      [popupWinCharDefMagischeSchule setEnabled: NO];      
    }   */
}

- (IBAction) popupOriginSelected: (id)sender
{

  NSLog(@"popupOriginSelected got called");

  // einige Herkünfte haben extra Bedingungen
  NSDictionary *originConstraints = [[originsDict objectForKey: [[self.popupOrigins selectedItem] title]] objectForKey: @"Basiswerte"];  
  NSLog(@"originConstraints: %@", originConstraints);    
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                            @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {        
      if ([originConstraints objectForKey: field] == nil)
        {
          NSLog(@"checking field was nil: %@", field);
          // Herkunft hat stärkere Bedingung als Typus
        }
      else
        {
          NSLog(@"checking field had value: %@", field);
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [originConstraints objectForKey: field]];              
        }
    }    
}

- (IBAction) popupProfessionSelected: (id)sender
{

  NSLog(@"popupProfessionSelected got called");
  
  NSDictionary *professionConstraints = [[[professionsDict objectForKey: [[self.popupProfessions selectedItem] title]] objectForKey: @"Bedingung"] objectForKey: @"Basiswerte"];  
  NSLog(@"professionConstraints: %@", professionConstraints);    
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                             @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {          
      if ([professionConstraints objectForKey: field] == nil)
        {
          NSLog(@"checking field was nil: %@", field);
          // Beruf hat stärkere Bedingung als Typus
          // gibt eh keine logischen Konflikte, da nur Anatom Bedingung auf TA hat...
        }
      else
        {
          NSLog(@"checking field had value: %@", field);
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [professionConstraints objectForKey: field]];              
        }
    } 
}

- (void) popupMageAcademySelected: (id)sender
{

  NSLog(@"popupMageAcademySelected got called");
  
//  [aktiverCharakter setMagischeSchule: [[popupWinCharDefMagischeSchule selectedItem] title]];
  
}

@end
