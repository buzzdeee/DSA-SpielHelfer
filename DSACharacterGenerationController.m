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
#import "DSACharacterGenerator.h"
#import "DSACharacter.h"
#import "Utils.h"

#import "DSATrait.h"
#import "DSATalent.h"
#import "DSASpell.h"
#import "NSMutableDictionary+Extras.h"
#import "DSANameGenerator.h"
#import "DSAObject.h"

@implementation DSACharacterGenerationController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"CharacterGeneration"];
  if (self)
    {
      self.generatedCharacter = [[DSACharacter alloc] init];
      self.traitsDict = [[NSMutableDictionary alloc] init];
      _portraitsArray = [[NSMutableArray alloc] init];
                                                                                                                                    
    }
  return self;
}

- (NSMutableArray *)loadPortraitsForArchetype: (NSString *) archetype
{
    NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: archetype]];
    NSMutableArray *portraitNames = [[NSMutableArray alloc] init];
    portraitNames = [[charConstraints objectForKey: @"Images"]
                                      objectForKey: [[self.popupSex selectedItem] title]];

    if ([portraitNames count] > 0)
      {
        return portraitNames;
      }
    portraitNames = [[NSMutableArray alloc] init];
    // those character types that have a .webp are all good,
    // fallback to load all Character_*.png files to select from ...
      
    // Get the main bundle path
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    // Create file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Get all files in the resource directory
    NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:resourcePath error:nil];
    // Regular expression to match "Character_XXXX.png" where XXXX is a number
    NSString *pattern = @"^Character_\\d*\\.png$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    // Iterate through the files and filter for files that match the pattern
    for (NSString *fileName in allFiles) {
        NSRange range = NSMakeRange(0, fileName.length);
        if ([regex numberOfMatchesInString:fileName options:0 range:range] > 0) {
            // Add the file name to the array
            [portraitNames addObject:fileName];
        }
    }
    return portraitNames;
}

- (void)startCharacterGeneration: (id)sender
{
  [self windowDidLoad];
  [self showWindow:self];
  [[self window] makeKeyAndOrderFront: self];
  [self.popupCategories removeAllItems];
  [self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [Utils getAllArchetypesCategories]];
   
  [self.popupArchetypes removeAllItems];
  [self.popupArchetypes addItemWithTitle: _(@"Typus wählen")];
  
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
  [self.popupProfessions removeAllItems];
  [self.popupProfessions addItemWithTitle: _(@"Beruf wählen")];  
  [self.popupMageAcademies removeAllItems];
  [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];  
  
  [self.popupArchetypes setEnabled: NO];   
  [self.popupOrigins setEnabled: NO];
  [self.popupProfessions setEnabled: NO];
  [self.popupMageAcademies setEnabled: NO];
  [self.popupElements setEnabled: NO];
  [self.popupReligions setEnabled: NO];  
  [self.buttonGenerate setEnabled: NO];  
  [self.buttonFinish setEnabled: NO];
  [self.buttonGenerateName setEnabled: NO];
 
  [self.fieldName setEnabled: NO];
  [self.fieldTitle setEnabled: NO];  
}

- (void)createCharacter:(id)sender
{
  NSLog(@"DSACharacterGenerationController createCharacter called!");

  DSACharacterGenerator *generator = [[DSACharacterGenerator alloc] init];
  NSMutableDictionary *characterParameters = [[NSMutableDictionary alloc] init];

  NSString *characterName = [self.fieldName stringValue];
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: selectedArchetype]];
    
  [characterParameters setObject: [NSNumber numberWithBool: NO] forKey: @"isNPC"];      // we only create characters here
  [characterParameters setObject: characterName forKey: @"name"];                       // name is enforced to be set
  [characterParameters setObject: [self.fieldTitle stringValue] forKey: @"title"];      // title is enforced to be set
  [characterParameters setObject: selectedArchetype forKey: @"archetype"];              // and we definitely have an archetype
  [characterParameters setObject: [[self.popupSex selectedItem] title] forKey: @"sex"]; // one is always selected
  NSLog(@"DSACharacterGenerationController createCharacter before origins");
  if ([self.popupOrigins isEnabled])
    {
      [characterParameters setObject: selectedOrigin forKey: @"origin"];
    }
  if ([self.popupProfessions isEnabled] && [self.popupProfessions indexOfSelectedItem] != 0)
    {
      [characterParameters setObject: [[self.popupProfessions selectedItem] title] forKey: @"profession"];
    }
  if ([self.popupElements isEnabled] && [self.popupElements indexOfSelectedItem] != 0)
    {
      [characterParameters setObject: [[self.popupElements selectedItem] title] forKey: @"element"];
    }
  if ([self.popupReligions isEnabled])
    {
      [characterParameters setObject: [[self.popupReligions selectedItem] title] forKey: @"religion"];
    }
  NSLog(@"DSACharacterGenerationController createCharacter before Magiedilettant");
  // Sigh, misusing UI elements for multiple purposes ;)
  if ([self.popupMageAcademies isEnabled] && [[charConstraints allKeys] containsObject: @"Magiedilettant"])
    {
      if ([[[self.popupMageAcademies selectedItem] title] isEqualToString: _(@"Ja")])
        {
          [characterParameters setObject: [NSNumber numberWithBool: YES] forKey: @"isMagicalDabbler"];
        }
      else
        {
          [characterParameters setObject: [NSNumber numberWithBool: NO] forKey: @"isMagicalDabbler"];
        }
    }
  NSLog(@"DSACharacterGenerationController createCharacter before Schamane");  
  // Sigh, Sigh, even more misusing UI elements for multiple purposes
  if ([selectedArchetype isEqualToString: @"Schamane"] && [[[self.popupMageAcademies selectedItem] title] isEqualToString: _(@"Ja")])
    {
      [characterParameters setObject: [NSNumber numberWithBool: YES] forKey: @"isMagic"];
    }    
  if ([self.popupMageAcademies isEnabled] && ([selectedArchetype isEqualToString: @"Magier"] || 
                                              [selectedArchetype isEqualToString: @"Geode"]))
    {
       [characterParameters setObject: [[self.popupMageAcademies selectedItem] title] forKey: @"academy"];
    }
  else if ([self.popupMageAcademies isEnabled] && [selectedArchetype isEqualToString: @"Krieger"])
    {
       [characterParameters setObject: [[self.popupMageAcademies selectedItem] title] forKey: @"academy"];  // misusing mageAcademy here for the Warrior Academy as well
    }
    
  [characterParameters setObject: _portraitsArray[_currentPortraitIndex] forKey: @"portraitName"];

  NSMutableDictionary *positiveTraits = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      [positiveTraits setObject: 
        [[DSAPositiveTrait alloc] initTrait: field 
                                    onLevel: [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] integerValue]]
                         forKey: field];  
    }    
  [characterParameters setObject: positiveTraits forKey: @"positiveTraits"];
  NSMutableDictionary *negativeTraits = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      [negativeTraits setObject: 
        [[DSANegativeTrait alloc] initTrait: field 
                                    onLevel: [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] integerValue]]
                         forKey: field];  
    }
  [characterParameters setObject: negativeTraits forKey: @"negativeTraits"];
  if (self.magicalDabblerInfo)
    {
      [characterParameters setObject: self.magicalDabblerInfo forKey: @"magicalDabblerInfo"];
    }
  NSLog(@"DSACharacterGenerationController calling character generator!");              
  DSACharacter *newCharacter = [generator generateCharacterWithParameters: characterParameters];
  NSLog(@"DSACharacterGenerationController createCharacter created!");

  // Store the generated character
  self.generatedCharacter = newCharacter;
  NSLog(@"DSACharacterGenerationController createCharacter finished!");
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

// returns all relevant religions for a given Archetype in an array
- (NSArray *) getReligionsForArchetype: (NSString *) archetype
{
  NSMutableArray *religions = [[NSMutableArray alloc] init];
  NSMutableArray *categories = [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typkategorie"];

  if ([categories containsObject: _(@"Geweihter")])  // Blessed ones only have their own God to choose from ;)
    {
      [categories removeObject: _(@"Mensch")];
    }
  
  if (archetype == nil)
    {
      return religions;
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
          if ([originsArray containsObject:[[self.popupOrigins selectedItem] title]])
            {
              [religions addObject:god];
            }
        }        
    }
    
  NSArray *sortedReligions = [religions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  NSLog(@"SOPRTED RELIGIONS: %@", sortedReligions);
  return sortedReligions;
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

- (void) makeCharacterAMagicalDabbler
{

  NSLog(@"makeCharacterAMagicalDabbler called");
  NSString *characterName = [self.fieldName stringValue];
  self.magicalDabblerInfo = [[NSMutableDictionary alloc] init];
  [self.magicalDabblerInfo setObject: [NSNumber numberWithBool: YES] forKey: @"isMagicalDabbler"];
  self.magicalDabblerDiceResult = [Utils rollDice: @"1W20"];
  
  NSInteger ae = [Utils rollDice: @"1W6"] + 3;
  [self.magicalDabblerInfo setObject: [NSNumber numberWithInteger: ae] forKey: @"AE"];
  
  NSString *headline;
  NSString *secondLine;

  if (!self.windowMagicalDabbler)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterGenerationMagicalDabbler" owner:self];
    }
  [self.windowMagicalDabbler makeKeyAndOrderFront:nil];  
    
  if (self.magicalDabblerDiceResult == 1)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen. Weiterhin kann er 3 Zauber aus der unten stehenden Liste wählen."),
                                             characterName, (signed long)ae];
      secondLine = _(@"3 Zaubersprüche auswählen");
      self.magicalDabblerMaxSwitchesToBeSelected = 3;
      [self.buttonMagicalDabblerFinish setEnabled: NO];
    }
  else if (self.magicalDabblerDiceResult >= 2 && self.magicalDabblerDiceResult <= 6)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen. Weiterhin kann er 2 Zauber aus der unten stehenden Liste wählen."),
                                             characterName, (signed long) ae];
      secondLine = _(@"2 Zaubersprüche auswählen");                                                   
      self.magicalDabblerMaxSwitchesToBeSelected = 2; 
      [self.buttonMagicalDabblerFinish setEnabled: NO];     
    }
  else if (self.magicalDabblerDiceResult >= 7 && self.magicalDabblerDiceResult <= 15)    
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen. Weiterhin kann er 1 Zauber aus der unten stehenden Liste wählen."),
                                             characterName, (signed long) ae];
      secondLine = _(@"1 Zauberspruch auswählen");                                                   
      self.magicalDabblerMaxSwitchesToBeSelected = 1; 
      [self.buttonMagicalDabblerFinish setEnabled: NO];     
    }
  else if (self.magicalDabblerDiceResult >= 16 && self.magicalDabblerDiceResult <= 19)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen."),
                                             characterName, (signed long) ae];
      secondLine = @"";  
      [self.buttonMagicalDabblerFinish setEnabled: YES];    
    }
  else if (self.magicalDabblerDiceResult == 20)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' oder das 'Magische Meisterhandwerk' einsetzen."),
                                             characterName, (signed long) ae];
      secondLine = _(@"Auswählen");     
      self.magicalDabblerMaxSwitchesToBeSelected = 1; 
      [self.buttonMagicalDabblerFinish setEnabled: NO];     
    }

  [self.fieldHeadline setStringValue: headline];
  [self.fieldSecondLine setStringValue: secondLine];
  if (self.magicalDabblerDiceResult >= 1 && self.magicalDabblerDiceResult <= 15)
    {
      NSArray *magicalDabblerSpells = [[Utils getMagicalDabblerSpellsDict] allValues];
      NSLog(@"magicalDabblerSpells: %@", magicalDabblerSpells);
      NSMutableArray *allSpells = [NSMutableArray array];
      for (NSArray *spells in magicalDabblerSpells)
        {
          [allSpells addObjectsFromArray: spells];
        }
      for (NSInteger i=0; i< 20; i++)
        {
          NSLog(@"Adding field: %@", [allSpells objectAtIndex: i]);
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          [[self valueForKey: fieldName] setTitle: [allSpells objectAtIndex: i]];
        }
    }
  else if (self.magicalDabblerDiceResult >= 16 && self.magicalDabblerDiceResult <= 19)
    {
      for (NSInteger i=0; i< 20; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          [[self valueForKey: fieldName] setHidden: YES];
          [[self valueForKey: fieldName] setEnabled: NO];          
        }      
    }
  else if (self.magicalDabblerDiceResult == 20)
    {
      [self.switchMagicalDabbler0 setTitle: _(@"Schutzgeist")];
      [self.switchMagicalDabbler1 setTitle: _(@"Magisches Meisterhandwerk")];      
      for (NSInteger i=2; i< 20; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          [[self valueForKey: fieldName] setHidden: YES];
          [[self valueForKey: fieldName] setEnabled: NO];          
        }      
    }
}

- (IBAction) switchMagicalDabblerSelected: (id)sender
{
  NSLog(@"switchMagicalDabblerSelected called %@", [sender title]);
  NSInteger counter = 0;
  for (NSInteger i=0; i<= 19; i++)
    {
      NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
      if ([[self valueForKey: fieldName] state] == 1)
        {
          counter++;
        }
    }
  if (counter == self.magicalDabblerMaxSwitchesToBeSelected)
    {
      [self.buttonMagicalDabblerFinish setEnabled: YES];
    }
  else
    {
      [self.buttonMagicalDabblerFinish setEnabled: NO];
    }
}

- (IBAction) buttonMagicalDabblerFinish: (id)sender
{

  NSLog(@"buttonMagicalDabblerFinish have to do the magical dabbler thing on the generated character...");
  
  if (self.magicalDabblerDiceResult >= 1 && self.magicalDabblerDiceResult <= 15)
    {
      [self.magicalDabblerInfo setObject: @[_(@"Schutzgeist"), _(@"Magisches Meisterhandwerk")] forKey: @"specialTalents"];

      NSMutableArray *newSpells = [[NSMutableArray alloc] init];
      for (NSInteger i=0; i <= 19; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          NSButton *button = [self valueForKey: fieldName];
          if ([button state] == 1)
            {
               NSLog(@"testing spell: %@", [button title]);
               [newSpells addObject: [button title]];
            }
        }
      [self.magicalDabblerInfo setObject: newSpells forKey: @"spells"];
    }
  else if (self.magicalDabblerDiceResult >= 16 && self.magicalDabblerDiceResult <= 19)
    {
       [self.magicalDabblerInfo setObject: @[_(@"Schutzgeist"), _(@"Magisches Meisterhandwerk")] forKey: @"specialTalents"];
    }
  else if (self.magicalDabblerDiceResult == 20)
    {
      for (NSInteger i=0; i< 2; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          NSButton *button = [self valueForKey: fieldName];          
          if ([button state] == 1)
            {
              [self.magicalDabblerInfo setObject: @[[button title]] forKey: @"specialTalents"];
              break;
            }
        }
    }
  NSLog(@"Going to create the character!");
  [self createCharacter:sender];    
  NSLog(@"Going to close the magical dabbler window");
  [self.windowMagicalDabbler close];
  NSLog(@"going to complete character generation");
  [self completeCharacterGeneration];  
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
  if ([sender indexOfSelectedItem] == 0)
    {
      return;
    }
NSLog(@"popupCategorySelected called!");  
  [self.popupArchetypes removeAllItems];
  [self.popupArchetypes addItemWithTitle: _(@"Typus wählen")];
  [self.popupArchetypes addItemsWithTitles: [Utils getAllArchetypesForCategory: [[self.popupCategories selectedItem] title]]];
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
  [self.popupElements setEnabled: NO];
  [self.popupReligions setEnabled: NO];     
}

- (IBAction) popupArchetypeSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      return;
    }
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];

  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: selectedArchetype]];
  [self.popupSex removeAllItems];
  [self.popupSex addItemsWithTitles: [charConstraints objectForKey: @"Geschlecht"]];  
  _portraitsArray = [self loadPortraitsForArchetype: selectedArchetype];
  [self assignPortraitToCharacter];
  
  if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Magier")] )
    {
      [self.popupMageAcademies setEnabled: NO];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];      
      [self.popupMageAcademies addItemsWithTitles: [[Utils getMageAcademiesDict] allKeys]];
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)];      
      [self.fieldMageSchool setStringValue: _(@"Magierakademie")];
    }
  else if ( [selectedArchetype isEqualToString: _(@"Geode")] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemsWithTitles: [charConstraints objectForKey: @"Schule"]];
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)]; 
      [self.fieldMageSchool setStringValue: _(@"Geodische Schule")];           
    }
  else if ( [selectedArchetype isEqualToString: _(@"Krieger")] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];      
      [self.popupMageAcademies addItemsWithTitles: [[[Utils getWarriorAcademiesDict] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)]; 
      [self.fieldMageSchool setStringValue: _(@"Kriegerakademie")];           
    }
  else if ([selectedArchetype isEqualToString: _(@"Schamane")] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemsWithTitles: @[_(@"Nein"), _(@"Ja")]];      
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)];      
      [self.fieldMageSchool setStringValue: _(@"Magiebegabt")];
    }    
  else if ([[charConstraints allKeys] containsObject: @"Magiedilettant"])
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemsWithTitles: @[_(@"Nein"), _(@"Ja")]];      
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMagicDabblerSelected:)];      
      [self.fieldMageSchool setStringValue: _(@"Magiedilettant")];
    }
  else
    {
      [self.popupMageAcademies selectItemAtIndex: 0];    
      [self.popupMageAcademies setEnabled: NO];   
      [self.popupMageAcademies setTitle: _(@"Akademie")]; 
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)];       
      [self.fieldMageSchool setStringValue: _(@"Magierakademie")];
    }
    
  if ([selectedArchetype isEqualToString: _(@"Geode")] || 
      [selectedArchetype isEqualToString: _(@"Druide")] ||
      [selectedArchetype isEqualToString: _(@"Magier")])
    {
      if ([selectedArchetype isEqualToString: _(@"Magier")])
        {
          [self.popupElements setEnabled: YES];
          [self.popupElements removeAllItems];
          [self.popupElements addItemWithTitle: @"Spezialgebiet wählen"];
          [self.popupElements addItemsWithTitles: [Utils getMageAcademiesAreasOfExpertise]];
          [self.fieldElement setStringValue: _(@"Spezialgebiet")];
        }
      else
        {
          [self.popupElements setEnabled: YES];
          [self.popupElements removeAllItems];
          [self.popupElements addItemWithTitle: @"Element wählen"];
          [self.popupElements addItemsWithTitles: [charConstraints objectForKey: @"Elemente"]];
          [self.fieldElement setStringValue: _(@"Element")];
        }
    }
  else
    {
      [self.popupElements setEnabled: NO];
    }
  NSArray *religions = [self getReligionsForArchetype: selectedArchetype];
  if (religions)
    {
      [self.popupReligions setEnabled: YES];
      [self.popupReligions removeAllItems];
      [self.popupReligions addItemsWithTitles: religions];
    }
  else
    {
      [self.popupReligions setEnabled: NO];
    }
        
  // Die Herkünfte
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemsWithTitles: [Utils getOriginsForArchetype: selectedArchetype]];
  if ([self.popupOrigins numberOfItems] == 0)
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
  [self.popupProfessions addItemsWithTitles: [Utils getProfessionsForArchetype: selectedArchetype]];
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

  [self updateTraitsConstraints];
}

- (IBAction) popupElementSelected: (id)sender
{
  if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Magier")] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];      
      [self.popupMageAcademies addItemsWithTitles: [Utils getMageAcademiesOfExpertise: [[self.popupElements selectedItem] title]]];
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)];      
      [self.fieldMageSchool setStringValue: _(@"Magierakademie")];
    }
}

- (IBAction) popupOriginSelected: (id)sender
{

  NSLog(@"DSACharacterGenerationController popupOriginSelected archetype: %@", [[self.popupArchetypes selectedItem] title]);
  NSArray *religions = [self getReligionsForArchetype: [[self.popupArchetypes selectedItem] title]];
  NSLog(@"DSACharacterGenerationController popupOriginSelected religions: %@", religions);
  if (religions)
    {
      [self.popupReligions setEnabled: YES];
      [self.popupReligions removeAllItems];
      [self.popupReligions addItemsWithTitles: religions];
    }
  else
    {
      [self.popupReligions setEnabled: NO];
    }
  [self updateTraitsConstraints];
}

- (IBAction) popupMagicDabblerSelected: (id)sender
{
  [self updateTraitsConstraints];
}

- (IBAction) popupProfessionSelected: (id)sender
{ 
  [self updateTraitsConstraints]; 
}

// based on archetype, origin, profession, or having a magical dabbler or not, 
// different constraints to apply. Easiest to reset and start from scratch, whichever is selected and changed.
- (void) updateTraitsConstraints {
  // start with the basic archetype constraints
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: [[self.popupArchetypes selectedItem] title]]];

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
    
  // some origins have extra constraints
  NSDictionary *originConstraints = [[[Utils getOriginsDict] objectForKey: [[self.popupOrigins selectedItem] title]] objectForKey: @"Basiswerte"];  
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                            @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {        
      if (!([originConstraints objectForKey: field] == nil))
        {
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [originConstraints objectForKey: field]];              
        }
    }
    
  // some professions have extra constraints as well
  NSDictionary *professionConstraints = [[[[Utils getProfessionsDict] objectForKey: [[self.popupProfessions selectedItem] title]] objectForKey: @"Bedingung"] objectForKey: @"Basiswerte"];  
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", 
                             @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {          
      if ([professionConstraints objectForKey: field])
        {
          [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [professionConstraints objectForKey: field]];              
        }
    }
    
  // last but not least, the magical dabbler has it's own constraints
  if ([[[self.popupMageAcademies selectedItem] title] isEqualToString: _(@"Ja")])
    {      
      // As described in "Die Magie des Schwarzen Auges", S. 36
      NSDictionary *magicDabblerConstraints = @{ @"KL": @"10+", @"IN": @"13+", @"AG": @"6+" };
      for (NSString *field in @[ @"KL", @"IN", @"AG" ])
        {
          NSString *curVal = [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] stringValue];
          NSString *curValNr = [curVal stringByReplacingOccurrencesOfString:@"+" withString:@""];
          NSString *dabblerValNr = [[magicDabblerConstraints objectForKey: field] stringByReplacingOccurrencesOfString: @"+" withString: @""];
          if ([curValNr integerValue] < [dabblerValNr integerValue])
            {
              [[self valueForKey: [NSString stringWithFormat: @"field%@Constraint", field]] setStringValue: [magicDabblerConstraints objectForKey: field]];
            }             
        }
    }
}

- (IBAction) popupMageAcademySelected: (id)sender
{
  NSLog(@"DSACharacterGenerationController: popupMageAcademySelected called");
  if ([[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Magier")])
    {
      NSLog(@"have to check mage academies for professions...");
      NSDictionary *academy = [[Utils getMageAcademiesDict] objectForKey: [[self.popupMageAcademies selectedItem] title]];
      if ([academy objectForKey: @"Berufe"])
        {
          NSLog(@"found Berufe: %@", [[[academy objectForKey: @"Berufe"] objectForKey: @"Startwerte"] allKeys]);
          [self.popupProfessions removeAllItems];
          [self.popupProfessions addItemWithTitle: _(@"Beruf wählen")];  
          [self.popupProfessions addItemsWithTitles: [[[academy objectForKey: @"Berufe"] objectForKey: @"Startwerte"] allKeys]];
          if ([self.popupProfessions numberOfItems] == 1)
            {
              [self.popupProfessions setEnabled: NO];        
            }
          else
            {
              [self.popupProfessions setEnabled: YES];        
            }          
          
        }
    }
}

- (IBAction) popupSexSelected: (id)sender
{
  _portraitsArray = [self loadPortraitsForArchetype: [[self.popupArchetypes selectedItem] title]];
  [self assignPortraitToCharacter];
}

- (IBAction) buttonGenerateClicked: (id)sender
{
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: [[self.popupArchetypes selectedItem] title]]];
  NSArray *positiveArr = [NSArray arrayWithArray: [self generatePositiveTraits]];
  NSArray *negativeArr = [NSArray arrayWithArray: [self generateNegativeTraits]];

  [self.fieldHairColor setStringValue: @"TBD"];
  [self.fieldEyeColor setStringValue: @"TBD"];  
  [self.fieldBirthday setStringValue: @"TBD"];
  [self.fieldHeight setStringValue: @"TBD"];
  [self.fieldWeight setStringValue: @"TBD"];
  [self.fieldName setEnabled: YES];
  [self.fieldTitle setEnabled: YES];
  [self.buttonGenerateName setEnabled: YES];
  
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
    
  [self.fieldSocialStatus setStringValue: @"TBD" ];
  [self.fieldParents setStringValue: @"TBD" ];
  [self.fieldWealth setStringValue: @"TBD" ];
  [self.fieldStars setStringValue: @"TBD" ];
  [self.fieldGod setStringValue: @"TBD" ];
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
  
/*  if (self.portraitsArray.count > 0)
    { */
      [self assignPortraitToCharacter];
      //[ self.imageViewPortrait setImageScaling:NSImageScaleProportionallyUpOrDown];
/*    }
  else
    {
      NSLog(@"The portraitsArray is empty.");
    } */
    
    
}

-(IBAction) buttonGenerateNameClicked: (id)sender
{
  NSArray *supportedNames = [DSANameGenerator getTypesOfNames];
  NSLog(@"DSACharacterGenerationController: buttonGenerateNameClicked: supportedNames: %@", supportedNames);
  NSString *origin;
  if ([supportedNames containsObject: [[self.popupCategories selectedItem] title]])
    {
      origin = [[self.popupCategories selectedItem] title];
    }
  else if ([supportedNames containsObject: [[self.popupArchetypes selectedItem] title]])
    {
      origin = [[self.popupArchetypes selectedItem] title];
    }
  else
    {
      origin = [[self.popupOrigins selectedItem] title];
    }


  [self.fieldName setStringValue: [DSANameGenerator generateNameWithGender: [[self.popupSex selectedItem] title] 
                                                                   isNoble: [[self.fieldSocialStatus stringValue] isEqualToString: @"adelig"] ||
                                                                            [[self.fieldSocialStatus stringValue] isEqualToString: @"niederer Adel"] || 
                                                                            [[self.fieldSocialStatus stringValue] isEqualToString: @"Hochadel"] ? YES : NO
                                                                  nameData: [Utils getNamesForRegion: origin]
                                                                        ]]; 
  if ([[self.fieldName stringValue] length] > 0)
    {
      [self.fieldName setBackgroundColor: [NSColor whiteColor]];
    }
  else
    {
      [self.fieldName setBackgroundColor: [NSColor redColor]];    
    }                                                                                                                                              
}
                                                                        
- (IBAction)buttonFinishClicked:(id)sender
{

  if ([self.popupMageAcademies isEnabled] && 
      ![self.generatedCharacter isMagic] && 
      [[[self.popupMageAcademies selectedItem] title] isEqualToString: _(@"Ja")])
    {  
       [self makeCharacterAMagicalDabbler];
    }
  else
    {
      // we do the same at the end of the makeCharacterAMagicalDabbler flow
      [self createCharacter:sender];
      [self completeCharacterGeneration];
    }
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

- (void)assignPortraitToCharacter {
    // Get the current portrait file name from the array
    NSString *selectedPortraitName = _portraitsArray[_currentPortraitIndex];

    // Assign the name to the new character's portraitName property
    // newCharacter.portraitName = selectedPortraitName;

    // Dynamically load the image and set it to the imageView
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:selectedPortraitName ofType:nil];
    if (imagePath) {
        self.imageViewPortrait.image = [[NSImage alloc] initWithContentsOfFile:imagePath];
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
    
    // Get the current portrait file name
    NSString *currentPortraitName = [self.portraitsArray objectAtIndex:self.currentPortraitIndex];
    
    // Dynamically load the image from the app bundle
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:currentPortraitName ofType:nil];
    if (imagePath)
    {
        NSImage *newImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
        [self.imageViewPortrait setImage:newImage];
    }
    else
    {
        // Handle the case where the image is missing or cannot be loaded
        NSLog(@"Error: Image file %@ could not be found in the bundle.", currentPortraitName);
        [self.imageViewPortrait setImage:nil]; // Clear the image view if loading fails
    }
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
