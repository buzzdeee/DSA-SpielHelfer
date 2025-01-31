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
#import "DSACharacterHeroHumanAlchemist.h"
#import "DSACharacterHeroHumanAmazon.h"
#import "DSACharacterHeroHumanJuggler.h"
#import "DSACharacterHeroHumanHuntsman.h"
#import "DSACharacterHeroHumanWarrior.h"
#import "DSACharacterHeroHumanPhysician.h"
#import "DSACharacterHeroHumanMoha.h"
#import "DSACharacterHeroHumanNivese.h"
#import "DSACharacterHeroHumanNorbarde.h"
#import "DSACharacterHeroHumanNovadi.h"
#import "DSACharacterHeroHumanSeafarer.h"
#import "DSACharacterHeroHumanMercenary.h"
#import "DSACharacterHeroHumanRogue.h"
#import "DSACharacterHeroHumanThorwaler.h"
#import "DSACharacterHeroHumanSkald.h"
#import "DSACharacterHeroHumanBard.h"

#import "DSACharacterHeroHumanMage.h"
#import "DSACharacterHeroHumanDruid.h"
#import "DSACharacterHeroHumanJester.h"
#import "DSACharacterHeroHumanCharlatan.h"
#import "DSACharacterHeroHumanWitch.h"
#import "DSACharacterHeroHumanShaman.h"
#import "DSACharacterHeroHumanSharisad.h"

#import "DSACharacterHeroElfMeadow.h"
#import "DSACharacterHeroElfSnow.h"
#import "DSACharacterHeroElfWood.h"
#import "DSACharacterHeroElfHalf.h"

#import "DSACharacterHeroDwarfAngroschPriest.h"
#import "DSACharacterHeroDwarfFighter.h"
#import "DSACharacterHeroDwarfGeode.h"
#import "DSACharacterHeroDwarfCavalier.h"
#import "DSACharacterHeroDwarfJourneyman.h"

#import "DSACharacterHeroBlessedPraios.h"
#import "DSACharacterHeroBlessedRondra.h"
#import "DSACharacterHeroBlessedEfferd.h"
#import "DSACharacterHeroBlessedTravia.h"
#import "DSACharacterHeroBlessedBoron.h"
#import "DSACharacterHeroBlessedHesinde.h"
#import "DSACharacterHeroBlessedFirun.h"
#import "DSACharacterHeroBlessedTsa.h"
#import "DSACharacterHeroBlessedPhex.h"
#import "DSACharacterHeroBlessedPeraine.h"
#import "DSACharacterHeroBlessedIngerimm.h"
#import "DSACharacterHeroBlessedRahja.h"
#import "DSACharacterHeroBlessedSwafnir.h"

#import "DSAPositiveTrait.h"
#import "DSANegativeTrait.h"
#import "DSAFightingTalent.h"
#import "DSAOtherTalent.h"
#import "DSASpecialTalent.h"
#import "DSASpell.h"
#import "DSASpellWitchCurse.h"
#import "DSASpellDruidRitual.h"
#import "DSASpellMischievousPrank.h"
#import "DSASpellGeodeRitual.h"
#import "DSASpellMageRitual.h"
#import "DSASpellShamanRitual.h"
#import "DSASpellElvenSong.h"
#import "DSALiturgy.h"
#import "DSAProfession.h"
#import "NSMutableDictionary+Extras.h"
#import "DSAAventurianCalendar.h"

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
      self.wealth = [[NSMutableDictionary alloc] init];
      self.birthday = [[DSAAventurianDate alloc] init];
      _portraitsArray = [[NSMutableArray alloc] init];
                                                                                                                                    
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
    
    // Regular expression to match "Character_XXXX.png" where XXXX is a number
    NSString *pattern = @"^Character_\\d*\\.png$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    // Iterate through the files and filter for files that match the pattern
    for (NSString *fileName in allFiles) {
        NSRange range = NSMakeRange(0, fileName.length);
        if ([regex numberOfMatchesInString:fileName options:0 range:range] > 0) {
            // Add the file name to the array
            [_portraitsArray addObject:fileName];
        }
    }
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
  NSString *characterName = [self.fieldName stringValue];
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSString *selectedProfession = [[self.popupProfessions selectedItem] title];
   
  DSACharacterHero *newCharacter = nil;

  // Based on selectedArchetype, create the correct character subclass
  if ([selectedArchetype isEqualToString:_(@"Alchimist")])
    {
      newCharacter = [[DSACharacterHeroHumanAmazon alloc] init];
    }  
  else if ([selectedArchetype isEqualToString:_(@"Amazone")])
    {
      newCharacter = [[DSACharacterHeroHumanAmazon alloc] init];
    }  
  else if ([selectedArchetype isEqualToString:_(@"Gaukler")])
    {
      newCharacter = [[DSACharacterHeroHumanJuggler alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Jäger")])
    {
      newCharacter = [[DSACharacterHeroHumanHuntsman alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Krieger")])
    {
      newCharacter = [[DSACharacterHeroHumanWarrior alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Medicus")])
    {
      newCharacter = [[DSACharacterHeroHumanPhysician alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Moha")])
    {
      newCharacter = [[DSACharacterHeroHumanMoha alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Nivese")])
    {
      newCharacter = [[DSACharacterHeroHumanNivese alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Norbarde")])
    {
      newCharacter = [[DSACharacterHeroHumanNorbarde alloc] init];
    } 
  else if ([selectedArchetype isEqualToString:_(@"Novadi")])
    {
      newCharacter = [[DSACharacterHeroHumanNovadi alloc] init];
    }        
  else if ([selectedArchetype isEqualToString:_(@"Seefahrer")])
    {
      newCharacter = [[DSACharacterHeroHumanSeafarer alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Söldner")])
    {
      newCharacter = [[DSACharacterHeroHumanMercenary alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Skalde")])
    {
      newCharacter = [[DSACharacterHeroHumanSkald alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Barde")])
    {
      newCharacter = [[DSACharacterHeroHumanBard alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Thorwaler")])
    {
      newCharacter = [[DSACharacterHeroHumanThorwaler alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Streuner")])
    {
      newCharacter = [[DSACharacterHeroHumanRogue alloc] init];        
    }
  else if ([selectedArchetype isEqualToString:_(@"Magier")])
    {
      newCharacter = [[DSACharacterHeroHumanMage alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Druide")])
    {
      newCharacter = [[DSACharacterHeroHumanDruid alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Schamane")])
    {
      newCharacter = [[DSACharacterHeroHumanShaman alloc] init];
    }    
  else if ([selectedArchetype isEqualToString:_(@"Scharlatan")])
    {
      newCharacter = [[DSACharacterHeroHumanCharlatan alloc] init];
    }      
  else if ([selectedArchetype isEqualToString:_(@"Schelm")])
    {
      newCharacter = [[DSACharacterHeroHumanJester alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Hexe")])
    {
      newCharacter = [[DSACharacterHeroHumanWitch alloc] init];
    } 
  else if ([selectedArchetype isEqualToString:_(@"Sharisad")])
    {
      newCharacter = [[DSACharacterHeroHumanSharisad alloc] init];
    }             
  else if ([selectedArchetype isEqualToString:_(@"Auelf")])
    {
      newCharacter = [[DSACharacterHeroElfMeadow alloc] init]; 
    }
  else if ([selectedArchetype isEqualToString:_(@"Firnelf")])
    {
      newCharacter = [[DSACharacterHeroElfSnow alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Waldelf")])
    {
      newCharacter = [[DSACharacterHeroElfWood alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Halbelf")])
    {
      newCharacter = [[DSACharacterHeroElfHalf alloc] init];
    }
  else if ([selectedArchetype isEqualToString:_(@"Angroschpriester")])
    {
      newCharacter = [[DSACharacterHeroDwarfAngroschPriest alloc] init];                                       
    }
  else if ([selectedArchetype isEqualToString:_(@"Geode")])
    {
      newCharacter = [[DSACharacterHeroDwarfGeode alloc] init];                                       
    }
  else if ([selectedArchetype isEqualToString:_(@"Kämpfer")])
    {
      newCharacter = [[DSACharacterHeroDwarfFighter alloc] init];                                       
    }
  else if ([selectedArchetype isEqualToString:_(@"Kavalier")])
    {
      newCharacter = [[DSACharacterHeroDwarfCavalier alloc] init];                                       
    }
  else if ([selectedArchetype isEqualToString:_(@"Wandergeselle")])
    {
      newCharacter = [[DSACharacterHeroDwarfJourneyman alloc] init];                                       
    }
  else if ([selectedArchetype isEqualToString:_(@"Praiosgeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedPraios alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Rondrageweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedRondra alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Efferdgeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedEfferd alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Traviageweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedTravia alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Borongeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedBoron alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Hesindegeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedHesinde alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Firungeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedFirun alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Tsageweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedTsa alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Phexgeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedPhex alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Perainegeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedPeraine alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Ingerimmgeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedIngerimm alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Rahjageweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedRahja alloc] init];                                       
    } 
  else if ([selectedArchetype isEqualToString:_(@"Swafnirgeweihter")])
    {
      newCharacter = [[DSACharacterHeroBlessedSwafnir alloc] init];                                       
    }                                                   
  else
    {
      NSLog(@"DSACharacterGenerationController: createCharacter: don't know how to create Archetype: %@", selectedArchetype);
    }

  NSLog(@"DSACharacterGenerationController: created newCharacter for archetype: %@", selectedArchetype);
  // Set common properties for the new character
  newCharacter.name = characterName;
  newCharacter.archetype = selectedArchetype;
  NSLog(@"DSACharacterGenerationController: assigned archetype to newCharacter");
  if ([self.popupProfessions isEnabled] && [self.popupProfessions indexOfSelectedItem] != 0)
    {
      NSDictionary *professionDict = [NSDictionary dictionaryWithDictionary: [[Utils getProfessionsDict] objectForKey: selectedProfession]];
      DSAProfession *profession = [[DSAProfession alloc] initProfession: selectedProfession
                                                             ofCategory: [professionDict objectForKey: @"Freizeittalent"] ? _(@"Freizeittalent") : _(@"Beruf")
                                                                onLevel: 3
                                                               withTest: [professionDict objectForKey: @"Probe"]
                                                 withMaxTriesPerLevelUp: 6
                                                      withMaxUpPerLevel: 2
                                                      influencesTalents: [professionDict objectForKey: @"Bonus"]];     

      NSMutableDictionary *professionsDictionary = [[NSMutableDictionary alloc] init];
      [professionsDictionary setObject: profession forKey: selectedProfession];
      newCharacter.professions = professionsDictionary;
    }
  else
    {
      newCharacter.professions = nil;
    }
  if ([self.popupElements isEnabled] && [self.popupElements indexOfSelectedItem] != 0)
    {
      newCharacter.element = [[self.popupElements selectedItem] title];
    }
  else
    {
      newCharacter.element = nil;
    }
  NSLog(@"DSACharacterGenerationController: assigned professions to newCharacter");
  newCharacter.religion = [[self.popupReligions selectedItem] title]; 
  newCharacter.hairColor = [self.fieldHairColor stringValue];
  newCharacter.eyeColor = [self.fieldEyeColor stringValue];
  newCharacter.height = [self.fieldHeight floatValue];
  newCharacter.weight = [self.fieldWeight floatValue];
  newCharacter.god = [self.fieldGod stringValue];
  newCharacter.stars = [self.fieldStars stringValue];
  newCharacter.socialStatus = [self.fieldSocialStatus stringValue];
  newCharacter.parents = [self.fieldParents stringValue];
  newCharacter.sex = [[self.popupSex selectedItem] title];
  newCharacter.title = [self.fieldTitle stringValue];
  NSLog(@"DSACharacterGenerationController: before assiging birthday to newCharacter");
  newCharacter.birthday = self.birthday;
  NSLog(@"DSACharacterGenerationController: assigned birthday to newCharacter");
  newCharacter.money = [NSMutableDictionary dictionaryWithDictionary: self.wealth];
  //newCharacter.portrait = [self.imageViewPortrait image];
  newCharacter.portraitName = _portraitsArray[_currentPortraitIndex];
  NSLog(@"DSACharacterGenerationController: assigned portrait to newCharacter");
  // A Mage or Geode
  if ([self.popupMageAcademies isEnabled] && ([newCharacter isMemberOfClass: [DSACharacterHeroHumanMage class]] || 
                                              [newCharacter isMemberOfClass: [DSACharacterHeroDwarfGeode class]]))
    {
       newCharacter.mageAcademy = [[self.popupMageAcademies selectedItem] title];
    }
  else if ([self.popupMageAcademies isEnabled] && [newCharacter isMemberOfClass: [DSACharacterHeroHumanWarrior class]])
    {
       newCharacter.mageAcademy = [[self.popupMageAcademies selectedItem] title];  // misusing mageAcademy here for the Warrior Academy as well
    }
  else  
    {
       newCharacter.mageAcademy = nil;
    }

  if ([self.popupOrigins isEnabled])
    {
      newCharacter.origin = selectedOrigin;
    }
  // handle positive Traits
  NSMutableDictionary *positiveTraits = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      [positiveTraits setObject: 
        [[DSAPositiveTrait alloc] initTrait: field 
                                    onLevel: [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] integerValue]]
                         forKey: field];  
    }
  newCharacter.positiveTraits = positiveTraits;
  // deep copy of the traits
  NSMutableDictionary *deepCopyPositiveTraits = [NSMutableDictionary dictionary];
  for (id key in positiveTraits) {
    id value = positiveTraits[key];
    if ([value conformsToProtocol:@protocol(NSCopying)]) {
        deepCopyPositiveTraits[key] = [value copy];
    } else {
        deepCopyPositiveTraits[key] = value; // or handle non-copyable objects appropriately
    }
  }
  newCharacter.currentPositiveTraits = [deepCopyPositiveTraits mutableCopy];
  // handle negative Traits    
  NSMutableDictionary *negativeTraits = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      [negativeTraits setObject: 
        [[DSANegativeTrait alloc] initTrait: field 
                                    onLevel: [[self valueForKey: [NSString stringWithFormat: @"field%@", field]] integerValue]]
                         forKey: field];  
    }
  newCharacter.negativeTraits = negativeTraits;
  NSMutableDictionary *deepCopyNegativeTraits = [NSMutableDictionary dictionary];
  for (id key in negativeTraits) {
    id value = negativeTraits[key];
    if ([value conformsToProtocol:@protocol(NSCopying)]) {
        deepCopyNegativeTraits[key] = [value copy];
    } else {
        deepCopyNegativeTraits[key] = value; // or handle non-copyable objects appropriately
    }
  }
  newCharacter.currentNegativeTraits = [deepCopyNegativeTraits mutableCopy];
  NSLog(@"DSACharacterGenerationController: assigned traits to newCharacter"); 
  // handle talents
  NSDictionary *talents = [[NSDictionary alloc] init];
  talents = [Utils getTalentsForCharacter: newCharacter];
  NSMutableDictionary *newTalents = [[NSMutableDictionary alloc] init];
  for (NSString *category in talents)
    {
      if ([category isEqualTo: @"Kampftechniken"])
        {   
          for (NSString *subCategory in [talents objectForKey: category])
            {
              for (NSString *t in [[talents objectForKey: category] objectForKey: subCategory])
                {
                   NSLog(@"dealing with talent in if clause for loop: %@", t);
                   NSDictionary *tDict = [[[talents objectForKey: category] objectForKey: subCategory] objectForKey: t];
                   DSAFightingTalent *talent = [[DSAFightingTalent alloc] initTalent: t
                                                                       inSubCategory: subCategory
                                                                          ofCategory: category
                                                                             onLevel: [[tDict objectForKey: @"Startwert"] integerValue]
                                                              withMaxTriesPerLevelUp: [[tDict objectForKey: @"Versuche"] integerValue]
                                                                   withMaxUpPerLevel: [[tDict objectForKey: @"Steigern"] integerValue]
                                                                     withLevelUpCost: 1];
                  NSLog(@"DSACharacterGenerationController: initialized talent: %@", talent);                                                                     
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
  newCharacter.talents = newTalents;
  //NSLog(@"DSACharacterGenerationController: assigned talents to newCharacter: %@", newCharacter.talents);  
  if ([newCharacter isMagic])
    {
      NSDictionary *spells = [[NSDictionary alloc] init];
      if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanShaman class]])
        {
          spells = [self getSpellsForArchetype: _(@"Druide")];
        }
      else
        {
          spells = [self getSpellsForArchetype: selectedArchetype];
        }
      NSMutableDictionary *newSpells = [[NSMutableDictionary alloc] init];
      for (NSString *category in spells)
        {
          for (NSString *s in [spells objectForKey: category])
            {
              NSDictionary *sDict = [[spells objectForKey: category] objectForKey: s];
              DSASpell *spell = [DSASpell spellWithName: s
                                                 ofCategory: category
                                                    onLevel: [[sDict objectForKey: @"Startwert"] integerValue]
                                                 withOrigin: [sDict objectForKey: @"Ursprung"]
                                                   withTest: [sDict objectForKey: @"Probe"]
                                           withAlternatives: [sDict objectForKey: @"Alternativen"]       
                                     withMaxTriesPerLevelUp: [[sDict objectForKey: @"Versuche"] integerValue]
                                          withMaxUpPerLevel: [[sDict objectForKey: @"Steigern"] integerValue]
                                            withLevelUpCost: 1];
              if (!spell) // as long as not every spell is implemented in it's own subclass, fall back to this simple default...
                {
                    spell = [[DSASpell alloc] initSpell: s
                                                 ofCategory: category
                                                    onLevel: [[sDict objectForKey: @"Startwert"] integerValue]
                                                 withOrigin: [sDict objectForKey: @"Ursprung"]
                                                   withTest: [sDict objectForKey: @"Probe"]
                                           withAlternatives: [sDict objectForKey: @"Alternativen"]        
                                     withMaxTriesPerLevelUp: [[sDict objectForKey: @"Versuche"] integerValue]
                                          withMaxUpPerLevel: [[sDict objectForKey: @"Steigern"] integerValue]
                                            withLevelUpCost: 1];
                 }
              [spell setElement: [sDict objectForKey: @"Element"]];
              [newSpells setObject: spell forKey: s];
            }
        }
      newCharacter.spells = newSpells;
      [self applySpellmodificatorsToArchetype: newCharacter];
      if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanSharisad class]])
        {
          newCharacter.maxLevelUpSpellsTries = [newCharacter.spells count] * 3;  // depending on number of spells, see: Die Magie des Schwarzen Auges S. 48
        }
      else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanShaman class]])
        {
          if ([_(@"Ja") isEqualToString: [[self.popupMageAcademies selectedItem] title]])
            {
              newCharacter.maxLevelUpSpellsTries = 20;  // See "Compendium Salamandris" S. 77
              newCharacter.astralEnergy = 25;
              newCharacter.currentAstralEnergy = 25;
            }
        }        
    }
  NSLog(@"DSACharacterGenerationController: assigned spells to newCharacter");
  newCharacter.birthPlace = [self generateBirthPlaceForCharacter: newCharacter];
  newCharacter.birthEvent = [self generateBirthEventForCharacter: newCharacter];  
  newCharacter.legitimation = [self generateLegitimationForCharacter: newCharacter];
  newCharacter.siblings = [self generateSiblings];
  newCharacter.childhoodEvents = [self generateChildhoodEventsForCharacter: newCharacter];
  newCharacter.youthEvents = [self generateYouthEventsForCharacter: newCharacter];    
  NSLog(@"DSACharacterGenerationController: assigned events to newCharacter");
  if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanWitch class]])
    {
      [self addWichCursesToCharacter: newCharacter];
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
  else if ([newCharacter isMemberOfClass: [DSACharacterHeroHumanShaman class]])
    {
      [self addShamanRitualsToCharacter: newCharacter];
      if ([_(@"Ja") isEqualToString: [[self.popupMageAcademies selectedItem] title]])
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
      
  // apply Göttergeschenke and Origins modificators
  [self apply: @"Goettergeschenke" toArchetype: newCharacter];
  [self apply: @"Herkunft" toArchetype: newCharacter];
  [self apply: @"Kriegerakademie" toArchetype: newCharacter];
  [self apply: @"Magierakademie" toArchetype: newCharacter];
  [self apply: @"Schamanenmodifikatoren" toArchetype: newCharacter];
  [self addEquipmentToCharacter: newCharacter];
  NSLog(@"DSACharacterGenerationController: assigned equipment to newCharacter");
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

- (void) applySpellmodificatorsToArchetype: (DSACharacterHero *) archetype
{
  if ([archetype isKindOfClass: [DSACharacterHeroElf class]])
    {
      // All Elf spells can be leveled up two times per level
      // All others only once, see: "Geheimnisse der Elfen", S. 68
      NSMutableArray *originIdentifiers = [NSMutableArray arrayWithArray:@[ @"A", @"W", @"F"] ];
      NSString *originIdentifier;
      if ([archetype.archetype isEqualTo: _(@"Waldelf")])
        {
          originIdentifier = @"W";
        }
      else if ([archetype.archetype isEqualTo: _(@"Firnelf")])
        {
          originIdentifier = @"F";
        }
      else if ([archetype.archetype isEqualTo: _(@"Auelf")])
        {
          originIdentifier = @"A";
        }

      for (DSASpell *spell in [archetype.spells allValues])      
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
  else if ([archetype isKindOfClass: [DSACharacterHeroDwarfGeode class]])  // as described in "Die Magie des schwarzen Auges", S. 49
    {
      NSString *ownSchool;
      NSString *otherSchool;
      NSLog(@"DSACHaracterGenerationController applying Geode related stuff");
      if ([archetype.mageAcademy isEqualToString: _(@"Diener Sumus")])
        {
          ownSchool = @"DS";
          otherSchool = @"HdE";
        }
      else
        {
          ownSchool = @"HdE";
          otherSchool = @"DS";        
        }
      for (DSASpell *spell in [archetype.spells allValues])      
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
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanDruid class]])
    {
      // All Druid spells can be leveled up three times per level
      // All others only once, see: "Die Magie des Schwarzen Auges", S. 45
      for (DSASpell *spell in [archetype.spells allValues])      
        {
          if ([spell.origin containsObject: @"D"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
        }
    }
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanShaman class]])
    {
      // All Shaman spells can be leveled up three times per level (same as Druid)
      // All others only once, see: "Compendium Salamandris" S. 77
      // but can't learn any other spells
      for (DSASpell *spell in [archetype.spells allValues])      
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
    }
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanWitch class]])
    {
      // All Witch spells can be leveled up three times per level
      // All others only once, see: "Die Magie des Schwarzen Auges", S. 43
      for (DSASpell *spell in [archetype.spells allValues])      
        {
          if ([spell.origin containsObject: @"H"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
        }
    }    
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanJester class]])
    {
      // All Jester spells can be leveled up three times per level
      // All others only once, see: "Die Magie des Schwarzen Auges", S. 47
      for (DSASpell *spell in [archetype.spells allValues])      
        {
          if ([spell.origin containsObject: @"S"])
            {
              spell.isTraditionSpell = YES;
              spell.maxUpPerLevel = 3;
              spell.maxTriesPerLevelUp = spell.maxUpPerLevel * 3;
            }
        }
    }
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanCharlatan class]])
    {
      // Nothing special for Charlatans, only mark the start spells
      // see "Die Magie des Schwarzen Auges", S. 34
      NSLog(@"Applying Spell modificators for Charlatan");
      for (DSASpell *spell in [archetype.spells allValues])      
        {
          NSLog(@"spell %@, origin: %@", spell.name, spell.origin);
          if ([spell.origin containsObject: @"Scharlatan"])
            {
              spell.isTraditionSpell = YES;
            }
        }
    }
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanSharisad class]])
    {
      for (DSASpell *spell in [archetype.spells allValues])
        {
          spell.isTraditionSpell = YES;  // comes from a different list of spells, the SharisadDances.json
        }
    }
  else if ([archetype isKindOfClass: [DSACharacterHeroHumanMage class]])
    {
      NSLog(@"Applying spellModificatorsToArchetype: %@", archetype.archetype);
      NSArray *haussprueche = [[[Utils getMageAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Haussprüche"];
      NSDictionary *academySpellModificators = [[[Utils getMageAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Zaubersprüche"];
      NSString *spezialgebiet = [[[Utils getMageAcademiesDict] objectForKey: archetype.mageAcademy] objectForKey: @"Spezialgebiet"];
      for (DSASpell *spell in [archetype.spells allValues])
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
      NSLog(@"DSACharacterGenerationController: applySpellmodificatorsToArchetype: don't know about Archetype: %@", archetype.archetype);
    }
  if ([archetype element])
    {
      // special treatment for Archetypes specialized on one of the Elements, as described in Mysteria Arkana S. 94
      

      NSArray *elements = @[ _(@"Feuer"), _(@"Erz"), _(@"Eis"), _(@"Wasser"), _(@"Luft"), _(@"Humus")];
      NSInteger count = [elements count];
      NSInteger selectedIndex;
      NSInteger oppositeIndex;
      NSString *ownElement = [archetype element];
      
      selectedIndex = [elements indexOfObject: ownElement];
      oppositeIndex = (selectedIndex + count / 2) % count;      
      NSString *oppositeElement = [elements objectAtIndex: oppositeIndex];
//      NSLog(@"applying spell modificators for own element: %@ opposite element: %@", ownElement, oppositeElement);
      for (DSASpell *spell in [archetype.spells allValues])
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

// to apply "Göttergeschenke" or "Herkunfsmodifikatoren"
- (void) apply: (NSString *) modificator toArchetype: (DSACharacterHero *) archetype
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
              NSLog(@"AFTER CREATING ITEM %@", item);
              if ([[itemInfo objectForKey: @"persönliches Objekt"] isEqualTo: @YES])
                {
                  [item setOwnerUUID: archetype.modelID];
                }
              [archetype.inventory addObject: item quantity: [[itemInfo objectForKey: @"Anzahl"] integerValue]];
              if ([itemInfo objectForKey: @"Kosten permanente ASP"])
                {
                  [archetype setAstralEnergy: archetype.astralEnergy - [[itemInfo objectForKey: @"Kosten permanente ASP"] integerValue]];
                  [archetype setCurrentAstralEnergy: archetype.currentAstralEnergy - [[itemInfo objectForKey: @"Kosten permanente ASP"] integerValue]];
                }
              
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

// lots of private methods here....

// returns all relevant professions for a given Archetype in an array
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

- (NSDictionary *) getSpellsForArchetype: (NSString *)archetype
{
  NSMutableDictionary *spells = [[NSMutableDictionary alloc] init];
  
  NSArray *categories;
  
  NSString *typus;
  if ([archetype isEqualToString: _(@"Geode")])
    {
      // For Geode, the different start values are in the .json dictionary directly
      typus = [[self.popupMageAcademies selectedItem] title];
    }
  else
    {
      typus = archetype;
    }
  
  if ([typus isEqualToString: _(@"Sharisad")])
    {
      categories = [NSArray arrayWithArray: [[Utils getSharisadDancesDict] allKeys]];
      NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
      NSString *selectedReligion = [[self.popupReligions selectedItem] title];
      for (NSString *category in categories)
        {
          for (NSString *key in [[Utils getSharisadDancesDict] objectForKey: category])
            {
              NSArray *probe = [NSArray arrayWithArray: [[[[Utils getSharisadDancesDict] objectForKey: category] objectForKey: key] objectForKey: @"Probe"]];
              NSArray *typen = [NSArray arrayWithArray: [[[[Utils getSharisadDancesDict] objectForKey: category] objectForKey: key] objectForKey: @"Typen"]];
              NSArray *religions = [NSArray arrayWithArray: [[[[Utils getSharisadDancesDict] objectForKey: category] objectForKey: key] objectForKey: @"Glaube"]];
              // starting values for the dances see: Die Magie des schwarzen Auges S. 85
              if ([typen containsObject: selectedOrigin])
                {
                  if ([religions count] > 0)  // Novadi Sharisad may have 2 more dances, but only when she is of a given religion
                    {
                      if ([religions containsObject: selectedReligion])
                        {
                          [spells setValue: @{@"Startwert": @"3",
                                              @"Probe": probe,
                                              @"Steigern": @"2",
                                              @"Versuche": @"6"}
                           forKeyHierarchy: @[category, key]];
                        }
                    }
                  else
                    {
                       [spells setValue: @{@"Startwert": @"3",
                                               @"Probe": probe,
                                            @"Steigern": @"2",
                                            @"Versuche": @"6"}
                        forKeyHierarchy: @[category, key]];                    
                    }
                }
            }
        }
      return spells;  // Sharisad finished here (:
    }
  else if ([typus isEqualToString: _(@"Schamane")] && [[[self.popupMageAcademies selectedItem] title] isEqualToString: _(@"Nein")])
    {
      return spells;  // if not magic, we dont have spells
    }
  else
    {
      categories = [NSArray arrayWithArray: [[Utils getSpellsDict] allKeys]];
    }
    
    
  for (NSString *category in categories)
    {
      NSString *steigern = @"1";
      NSString *versuche = [NSString stringWithFormat: @"%li", [steigern integerValue] * 3];
      for (NSString *key in [[Utils getSpellsDict] objectForKey: category])
        {
          NSString *startwert;
          NSString *element = nil;
          NSArray *probe = [NSArray arrayWithArray: [[[[Utils getSpellsDict] objectForKey: category] objectForKey: key] objectForKey: @"Probe"]];
          NSArray *origin = [NSArray arrayWithArray: [[[[Utils getSpellsDict] objectForKey: category] objectForKey: key] objectForKey: @"Ursprung"]];
          if ([[[[[Utils getSpellsDict] objectForKey: category] objectForKey: key] allKeys] containsObject: @"Element"])
            {
              element = [NSString stringWithString: [[[[Utils getSpellsDict] objectForKey: category] objectForKey: key] objectForKey: @"Element"]];
            }
          else
            {
              element = nil;
            }
          startwert = [NSString stringWithFormat: @"%@", [[[[[Utils getSpellsDict] objectForKey: category] objectForKey: key] objectForKey: @"Startwerte"] objectForKey: typus]];
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
  return spells;  
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


- (NSDictionary *) generateFamilyBackground: (NSString *)archetype
{
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSLog(@"the origin: %@", selectedOrigin);
  NSString *dice;
  NSDictionary *herkuenfteDict;
  
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      dice = [[[[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typus"] objectForKey: selectedOrigin] objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
      herkuenfteDict = [NSDictionary dictionaryWithDictionary: [[[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typus"] objectForKey: selectedOrigin] objectForKey: @"Herkunft"]];    
    }
  else
    {
      dice = [[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Herkunft"] objectForKey: @"Würfel"];
      herkuenfteDict = [NSDictionary dictionaryWithDictionary: [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Herkunft"]];    
    }
    
  NSLog(@"generateFamilyBackground %@ %@", dice, herkuenfteDict);
  NSArray *herkuenfteArr = [NSArray arrayWithArray: [herkuenfteDict allKeys]];
  NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
  
  NSInteger diceResult = [Utils rollDice: dice];
  
  for (NSString *socialStatus in herkuenfteArr)
    {
      if ([@"Würfel" isEqualTo: socialStatus])
        {
          continue;
        }
      
      if ([[[herkuenfteDict objectForKey: socialStatus] objectForKey: dice] containsObject: @(diceResult)])
        {
          [retVal setObject: socialStatus forKey:@"Stand"];
          for (NSString *parents in [[[herkuenfteDict objectForKey: socialStatus] objectForKey: @"Eltern"] allKeys])
            {
              if ([[[[herkuenfteDict objectForKey: socialStatus] objectForKey: @"Eltern"] objectForKey: parents] containsObject: @(diceResult)])
                {
                  [retVal setObject: parents forKey: @"Eltern"];
                  break;
                }
            }
          break;
        }
    }
NSLog(@"generateFamilyBackground %@", retVal);
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


- (NSString *) generateHairColorForArchetype: (NSString *) archetype
{
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSDictionary *hairConstraint;
  
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      hairConstraint = [NSDictionary dictionaryWithDictionary: [[[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typus"] objectForKey: selectedOrigin] objectForKey: @"Haarfarbe"]];
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

/* if no Augenfarbe in the Typus description, 
   use the formula as defined in "Mit Mantel, Schwert und Zauberstab" */
- (NSString *) generateEyeColorForArchetype: (NSString *) archetype withHairColor: (NSString *) hairColor
{
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

- (DSAAventurianDate *) generateBirthday
{
  NSLog(@"generateBirthday called");
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
                                                                   currentAge: 16];   // always starting with 16 years for now

  NSLog(@"generateBirthday after year %li", (long) year);                                                                     
  return [[DSAAventurianDate alloc] initWithYear: year
                                           month: [DSAAventurianCalendar monthForString: monthName]
                                             day: day
                                            hour: [Utils rollDice: @"1W24"] - 1];         // for now, everyone is born at 5 am in the morning
}

// loosely following "Vom Leben in Aventurien", S. 34
- (NSArray *) generateSiblings
{
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
- (NSString *) generateBirthPlaceForCharacter: (DSACharacter *) character
{
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];

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

  return [NSString stringWithFormat: _(@"%@ wird %@ geboren."), [character name], resultStr];
}

// loosely following "Vom Leven in Aventurien" S. 35
- (NSString *) generateBirthEventForCharacter: (DSACharacter *) character
{
  NSInteger diceResult = [Utils rollDice: @"1W20"];
  
  if (diceResult == 1)
    {
      if ([character.siblings count] == 0)
        { 
          return [self generateBirthEventForCharacter: character];
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

- (NSString *) generateLegitimationForCharacter: (DSACharacter *)character
{
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];

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
          return [NSString stringWithFormat: _(@"%@ wird in einem Dorf ausgesetzt und wächst als Findelkind bei Pflegeeltern auf."), [character name]];
        }
      else if (diceResult == 2)
        {
          return [NSString stringWithFormat: _(@"%@ wird in einer Stadt ausgesetzt und wächst als Findelkind bei Pflegeeltern auf."), [character name]];
        } 
      else if (diceResult == 3)
        {
          return [NSString stringWithFormat: _(@"%@ wird in einer Großstadt ausgesetzt und wächst als Findelkind bei Pflegeeltern auf."), [character name]];
        }                
    }
  else if (testValue >= 3 && testValue <= 17)
    {
      return [NSString stringWithFormat: _(@"%@ wird von den Eltern bei der Geburt anerkannt."), [character name]];
    }
  else if (testValue == 18)
    {
      return [NSString stringWithFormat: _(@"%@'s Vater behauptet, daß das Kind von einem anderen Mann stammt."), [character name]];
    } 
  else if (testValue == 19)
    {
      return [NSString stringWithFormat: _(@"%@'s Mutter behauptet, daß ihr Gefährte nicht der Vater ist."), [character name]];
    }
  else if (testValue >= 20 && testValue <= 22)
    {
      return [NSString stringWithFormat: _(@"%@ gilt bei der Geburt als schwächlich und nicht lebensfähig, weshalb es in der Wildnis ausgesetzt wird. Es wird jedoch gefunden, und wächst bei einer anderen Sippe auf."), [character name]];
    } 
  else if (testValue == 23)
    {
      return [NSString stringWithFormat: _(@"%@ gilt bei der Geburt als schwächlich und nicht lebensfähig, weshalb es in der Wildnis ausgesetzt wird. Es wird bis zum sechten Jahr von Wölfen aufgezogen. Danach wird es von einer fremden Sippe aufgenommen."), [character name]];
    }
  return @"nix";            
}

- (NSArray *) generateChildhoodEventsForCharacter: (DSACharacter *) character
{
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
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
          resultStr = [NSString stringWithFormat: _(@"%@ wird Zeuge eines Zwölfgöttlichen Wunders."), [character name]];
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
          resultStr = [NSString stringWithFormat: _(@"%@ findet einen Gönner: Ein %@ wird auf das Kleine aufmerksam, weil er in ihm eine besondere Begabung entdeckt. Er verwöhnt es mit Geschenken, erzählt ihm von seinem Leben und seinen Fahrten und bring ihm möglicherweise ein paar spezielle Fertigkeiten oder kleine Kunststücke bei."), [character name], who];
        }
      else if (eventResult == 3)
        {
          eventResult = [Utils rollDice: @"1W6"];
          if (eventResult == 1 | eventResult == 2)
            {
              eventResult = [Utils rollDice: @"2W6"];
              resultStr = [NSString stringWithFormat: _(@"%@ findet einen Beutel mit %lu Goldstücken."), [character name], (unsigned long) eventResult];
            }
          else if (eventResult == 3)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet ein wertvolles Instrument."), [character name]];
            }
          else if (eventResult == 4)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet ein wertvolles Schmuckstück."), [character name]];
            }
          else if (eventResult == 5)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet eine kostbare Waffe."), [character name]];
            }
          else if (eventResult == 6)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ findet einen magischen Gegenstand."), [character name]];
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
          resultStr = [NSString stringWithFormat: _(@"%@ findet einen guten Freund gleichen Alters. Der Freund ist %@. Die Freundschaft währt %@."), [character name], status, timeFrame];
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
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Lesen und Schreiben."), whoStr, [character name]];
            }
          if (eventResult == 3 || eventResult == 4)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Rechnen."), whoStr, [character name]];
            }
          if (eventResult == 5)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Malen und Zeichnen."), whoStr, [character name]];
            }            
          if (eventResult == 6)
            {
              resultStr = [NSString stringWithFormat: _(@"%@ unterweist %@ im Musizieren."), whoStr, [character name]];
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
          resultStr = [NSString stringWithFormat: _(@"Die Familie zieht in %@. %@ erlebt eine unglückliche Zeit der Trennung von den Gefährten der Heimat."), whereTo, [character name]];
        }
      else if (eventResult == 8)
        {
          resultStr = [NSString stringWithFormat: _(@"Eine Wahrsagerin sagt %@ eine große Zukunft voraus."), [character name]];
        }
      else if (eventResult == 9)
        {
          resultStr = [NSString stringWithFormat: _(@"Ein alter Kämpe und guter Freund der Familie erzählt von Abenteuern und Heldentaten. %@ ist davon sehr beeindruckt und möchte es später einmal diesem Recken gleichtun."), [character name]];
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
          resultStr = [NSString stringWithFormat: _(@"Die Eltern können ihre Nachkommen nicht mehr ernähren. Sie geben %@ in die Hände einer anderen Familie. Diese %@"), [character name], whatStr];
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
          resultStr = [NSString stringWithFormat: _(@"%@ läuft von zu Hause fort, %@"), [character name], whatStr];
        }
      else if (eventResult == 12)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird seinen Eltern geraubt und verschleppt. Es wächst fortan bei Pflegeeltern auf."), [character name]];
        }
      else if (eventResult == 13)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *article;
          NSString *whatStr;
          if ([[character sex] isEqualToString: _(@"männlich")])
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
          resultStr = [NSString stringWithFormat: _(@"Freunde verführen %@ dazu, etwas verbotenes zu tun. %@."), [character name], whatStr];
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
              if ([[character siblings] count] == 0)
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
              else if ([[character siblings] count] == 1)
                {
                  if ([[[[character siblings] objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
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
          resultStr = [NSString stringWithFormat: _(@"%@ verstreitet sich mit %@. Zwischen beiden regiert fortan blinder Haß."), [character name], whoStr];
        }
      else if (eventResult == 15)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whatStr;
          NSString *article;
          if ([[character sex] isEqualToString: _(@"männlich")])
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
          resultStr = [NSString stringWithFormat: _(@"%@ wird für etwas bestraft, was %@ nicht getan hat. Der Richter %@."), [character name], article, whatStr];
        }
      else if (eventResult == 16)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird von einem wilden Tier schwer verletzt."), [character name]];        
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
              if ([[character siblings] count] == 0)
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
              else if ([[character siblings] count] == 1)
                {
                  if ([[[[character siblings] objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
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
              if ([[character siblings] count] == 0)
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
              else if ([[character siblings] count] == 1)
                {
                  if ([[[[character siblings] objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
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
              sickness = [NSString stringWithFormat: _(@"%@ erkrankt auch schwer, aber überlebt."), [character name]];
            }
          else
            {
              sickness = [NSString stringWithFormat: _(@"%@ bleibt von der Krankheit verschont."), [character name]];
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
              if ([[character siblings] count] == 0)
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
              else if ([[character siblings] count] == 1)
                {
                  if ([[[[character siblings] objectAtIndex: 0] objectForKey: @"sex"] isEqualTo: _(@"männlich")])
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
               whatStr = [NSString stringWithFormat: _(@"%@ schlägt sich von nun an allein durch"), [character name]];
             }
           else
             {
               whatStr = [NSString stringWithFormat: _(@"%@ wird von einer Pflegefamilie aufgenommen"), [character name]];
             }
           resultStr = [NSString stringWithFormat: _(@"Die gesamte Familie kommt %@ ums Leben. %@."), reason, whatStr];
        }
      [resultArr addObject: resultStr];  
      cnt++;
    }
  return resultArr;
}


- (NSArray *) generateYouthEventsForCharacter: (DSACharacter *) character
{
  NSString *selectedArchetype = [[self.popupArchetypes selectedItem] title];
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
  if ([[character sex] isEqualToString: _(@"männlich")])
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
          resultStr = [NSString stringWithFormat: _(@"%@ durchlebt eine Phase der Frömmigkeit. %@ such die Nähe von Geweihten %@. %@"), [character name], pronounUpper, godStr, whatStr];
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
          resultStr = [NSString stringWithFormat: _(@"%@ erhält ein Stipendium für eine %@. %@"), [character name], akademieStr, whatStr];
        }
      else if (eventResult == 6)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ hilft einem verletzen Tier, das %@ von nun an treu folgt."), [character name], personalPronounDativ];
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
          resultStr = [NSString stringWithFormat: _(@"%@ verliebt sich%@"), [character name], whatStr];
        }
      else if (eventResult == 12)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ trifft auf eine berühmte Persönlichkeit und ist von ihr sehr beeindruckt."), [character name]];
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
          resultStr = [NSString stringWithFormat: _(@"%@ wiederfährt etwas Seltsames. %@"), [character name], whatStr];
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
          resultStr = [NSString stringWithFormat: _(@"Wie es üblich ist, geht %@ bei einem Handwerker in die Lehre. %@"), [character name], whatStr];  
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
          resultStr = [NSString stringWithFormat: _(@"Die Eltern können ihre Familie nicht mehr ernähren, und schicken deshalb %@ fort, allein %@ Glück zu machen. %@ %@"), [character name], possesivPronounAkkusativ, pronounUpper, whatStr];
        } 
      else if (eventResult == 16)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whoStr;
          if ([[character sex] isEqualToString: _(@"männlich")])
            {
              whoStr = _(@"einen Rivalen");
            }
          else
            {
              whoStr = _(@"eine Rivalin");
            }          
          if (eventResult == 1)
            {
              if ([[character sex] isEqualToString: _(@"männlich")])
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
              whatStr = [NSString stringWithFormat: _(@"%@ ist neidisch auf das Äußere von %@."), whateverTypeOfWord1Upper, [character name]];
            }
          else if (eventResult == 3)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ ist neidisch auf ein Besitzstück von %@."), whateverTypeOfWord1Upper, personalPronounDativ];
            }
          else if (eventResult >= 4 && eventResult <= 6)
            {
              whatStr = [NSString stringWithFormat: _(@"%@ ist in die selbe Person verliebt wie %@."), whateverTypeOfWord1Upper, pronoun];
            }
          resultStr = [NSString stringWithFormat: _(@"%@ hat %@. %@"), [character name], whoStr, whatStr];
        }
      else if (eventResult == 17 || eventResult == 18)
        {
          eventResult = [Utils rollDice: @"1W6"];
          NSString *whoStr;
          if ([[character sex] isEqualToString: _(@"männlich")])
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
            
          resultStr = [NSString stringWithFormat: _(@"%@ soll verheiratet werden. %@ jedoch gefällt %@ nicht, so das %@ fortläuft. %@"), [character name], personalPronounDativUpper, whoStr, pronoun, whatStr];
        }
      else if (eventResult == 19)
        {
          resultStr = [NSString stringWithFormat: _(@"%@ wird von einem wilden Tier schwer verletzt."), [character name]];        
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
               whatStr = [NSString stringWithFormat: _(@"%@ schlägt sich von nun an allein durch"), [character name]];
             }
           else
             {
               whatStr = [NSString stringWithFormat: _(@"%@ wird von einer Pflegefamilie aufgenommen"), [character name]];
             }
           resultStr = [NSString stringWithFormat: _(@"Die gesamte Familie kommt %@ ums Leben. %@."), reason, whatStr];
        }      
        
      [resultArr addObject: resultStr];
      cnt++;
    }
  return resultArr;   
}
  
- (float) generateHeightForArchetype: (NSString *) archetype
{
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSArray *heightArr;
  
  if ([archetype isEqualToString: _(@"Schamane")])
    {
      heightArr = [NSArray arrayWithArray: [[[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Typus"] objectForKey: selectedOrigin] objectForKey: @"Körpergröße"]];
    }
  else
    {
      heightArr = [NSArray arrayWithArray: [[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Körpergröße"]];      
    }
  float height = [[heightArr objectAtIndex: 0] floatValue];
  unsigned int count = [heightArr count];
  for (unsigned int i = 1;i<count; i++)
    {
      height += [Utils rollDice: [heightArr objectAtIndex: i]];
    }
  return height;
}

- (float) generateWeightForArchetype: (NSString *) archetype withHeight: (float) height
{
  float weight = [[[[Utils getArchetypesDict] objectForKey: archetype] objectForKey: @"Gewicht"] floatValue];
  return weight + height;
}

- (void) addElvenSongsToCharacter: (DSACharacterHero *) character
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

- (void) addBlessedLiturgiesToCharacter: (DSACharacterHero *) character
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

- (void) addShamanRitualsToCharacter: (DSACharacterHero *) character
{
  NSMutableDictionary * specialTalents = [[NSMutableDictionary alloc] init];    
  for (NSString *category in [[Utils getShamanRitualsDict] allKeys])
    {
      for (NSString *ritual in [[Utils getShamanRitualsDict] objectForKey: category])
        {
          if ([[[[[Utils getShamanRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Typen"] containsObject: [[self.popupOrigins selectedItem] title]])
            {
              DSASpellShamanRitual *r = [[DSASpellShamanRitual alloc] initSpell: ritual
                                                                       withTest: [[[[Utils getShamanRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probe" ]];
              [specialTalents setObject: r forKey: ritual];
            }
        }
    }
  [character setSpecials: specialTalents];  
}

- (void) addGeodeRitualsToCharacter: (DSACharacterHero *) character
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
          if ([[[[[Utils getGeodeRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Typen"] containsObject: [[self.popupMageAcademies selectedItem] title]])
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

- (void) addMageRitualsToCharacter: (DSACharacterHero *) character
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
            DSASpellMageRitual *r = [DSASpellMageRitual ritualWithName: ritual
                                                            ofCategory: category
                                                              withTest: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probe" ]
                                                      withAlternatives: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Alternativen" ]
                                                           withPenalty: [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probenaufschlag" ] integerValue]
                                                           withASPCost: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"ASP Kosten" ] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"ASP Kosten" ] integerValue]: 0
                                                  withPermanentASPCost: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente ASP Kosten" ] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente ASP Kosten" ] integerValue]: 0
                                                            withLPCost: [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"LP Kosten" ] integerValue] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"LP Kosten" ] integerValue]: 0
                                                   withPermanentLPCost: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente LP Kosten" ] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente LP Kosten" ] integerValue]: 0];
            if (!r)
              {
                r = [[DSASpellMageRitual alloc] initRitual: ritual
                                        ofCategory: category
                                          withTest: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probe" ]
                                  withAlternatives: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Alternativen" ]       
                                       withPenalty: [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"Probenaufschlag" ] integerValue]
                                       withASPCost: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"ASP Kosten" ] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"ASP Kosten" ] integerValue]: 0
                              withPermanentASPCost: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente ASP Kosten" ] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente ASP Kosten" ] integerValue]: 0
                                        withLPCost: [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"LP Kosten" ] integerValue] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"LP Kosten" ] integerValue]: 0
                               withPermanentLPCost: [[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente LP Kosten" ] ? [[[[[Utils getMageRitualsDict] objectForKey: category] objectForKey: ritual] objectForKey: @"davon permanente LP Kosten" ] integerValue]: 0];              
              }
            [specialTalents setObject: r forKey: ritual];
        }
    }
  [character setSpecials: specialTalents];  
}

- (void) addMischievousPranksToCharacter: (DSACharacterHero *) character
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

- (void) addWichCursesToCharacter: (DSACharacterHero *) character
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

- (void) addDruidRitualsToCharacter: (DSACharacterHero *) character
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
      for (NSString *spellName in [[[Utils getDruidRitualsDict] objectForKey: category] allKeys])
        {
          NSLog(@"Checking if Typen contains: %@ XXX %@", character.archetype, [[[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: spellName] objectForKey: @"Typen"]);
          if ([[[[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: spellName] objectForKey: @"Typen"] containsObject: character.archetype])
            {
              DSASpellDruidRitual *spell = [[DSASpellDruidRitual alloc] initSpell: spellName
                                                                       ofCategory: category
                                                                          onLevel: 0
                                                                       withOrigin: nil
                                                                         withTest: [[[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: spellName] objectForKey: @"Probe"]
                                                                 withAlternatives: [[[[Utils getDruidRitualsDict] objectForKey: category] objectForKey: spellName] objectForKey: @"Alternativen"]
                                                           withMaxTriesPerLevelUp: 0
                                                                withMaxUpPerLevel: 0
                                                                  withLevelUpCost: 0];
              [specialTalents setObject: spell forKey: spellName];
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

- (void) addEquipmentToCharacter: (DSACharacterHero *) character
{
  NSArray *equipmentDict = [NSArray arrayWithArray: [[[[[Utils getArchetypesDict] objectForKey: [character archetype]] objectForKey: @"Herkunft"] objectForKey: [character socialStatus]] objectForKey: @"Equipment"]];
//  NSLog(@"The EQUIPMENT DICT: %@", equipmentDict);
  for (NSDictionary *equipment in equipmentDict)
    {
//    NSLog(@"THE EQUIPMENT: %@", equipment);
      [character.inventory addObject: [[DSAObject alloc] initWithName: [[equipment allKeys] objectAtIndex: 0] forOwner: character.modelID] quantity: [[[equipment allValues] objectAtIndex: 0] integerValue]];
    } 
//  NSLog(@"THE INVENTORY: %@", character.inventory);
}

- (void) makeCharacterAMagicalDabbler
{

  NSLog(@"makeCharacterAMagicalDabbler called");
  [self.generatedCharacter setIsMagicalDabbler: YES];
  NSInteger diceResult = [Utils rollDice: @"1W20"];
  self.magicalDabblerDiceResult = diceResult;
  
  NSInteger ae = [Utils rollDice: @"1W6"] + 3;
  [self.generatedCharacter setAstralEnergy: ae];
  [self.generatedCharacter setCurrentAstralEnergy: ae];  
  
  NSString *headline;
  NSString *secondLine;

  if (!self.windowMagicalDabbler)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterGenerationMagicalDabbler" owner:self];
    }
  [self.windowMagicalDabbler makeKeyAndOrderFront:nil];  
    
  if (diceResult == 1)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen. Weiterhin kann er 3 Zauber aus der unten stehenden Liste wählen."),
                                             [self.generatedCharacter name], (signed long)ae];
      secondLine = _(@"3 Zaubersprüche auswählen");
      self.magicalDabblerMaxSwitchesToBeSelected = 3;
      [self.buttonMagicalDabblerFinish setEnabled: NO];
    }
  else if (diceResult >= 2 && diceResult <= 6)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen. Weiterhin kann er 2 Zauber aus der unten stehenden Liste wählen."),
                                             [self.generatedCharacter name], (signed long)ae];
      secondLine = _(@"2 Zaubersprüche auswählen");                                                   
      self.magicalDabblerMaxSwitchesToBeSelected = 2; 
      [self.buttonMagicalDabblerFinish setEnabled: NO];     
    }
  else if (diceResult >= 7 && diceResult <= 15)    
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen. Weiterhin kann er 1 Zauber aus der unten stehenden Liste wählen."),
                                             [self.generatedCharacter name], (signed long)ae];
      secondLine = _(@"1 Zauberspruch auswählen");                                                   
      self.magicalDabblerMaxSwitchesToBeSelected = 1; 
      [self.buttonMagicalDabblerFinish setEnabled: NO];     
    }
  else if (diceResult >= 16 && diceResult <= 19)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' und das 'Magische Meisterhandwerk' einsetzen."),
                                             [self.generatedCharacter name], (signed long)ae];
      secondLine = @"";  
      [self.buttonMagicalDabblerFinish setEnabled: YES];    
    }
  else if (diceResult == 20)
    {
      headline = [NSString stringWithFormat: _(@"%@ besitzt %ld AE und kann seine AE für einen 'Schutzgeist' oder das 'Magische Meisterhandwerk' einsetzen."),
                                             [self.generatedCharacter name], (signed long)ae];
      secondLine = _(@"Auswählen");     
      self.magicalDabblerMaxSwitchesToBeSelected = 1; 
      [self.buttonMagicalDabblerFinish setEnabled: NO];     
    }

  [self.fieldHeadline setStringValue: headline];
  [self.fieldSecondLine setStringValue: secondLine];
  if (diceResult >= 1 && diceResult <= 15)
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
  else if (diceResult >= 16 && diceResult <= 19)
    {
      for (NSInteger i=0; i< 20; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          [[self valueForKey: fieldName] setHidden: YES];
          [[self valueForKey: fieldName] setEnabled: NO];          
        }      
    }
  else if (diceResult == 20)
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
  NSLog(@"switchMagicalDabblerSelected called");
  NSInteger counter = 0;
  for (NSInteger i=0; i< 19; i++)
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
      NSMutableDictionary * newTalents = [[NSMutableDictionary alloc] init];    
      for (NSString *specialTalent in @[_(@"Schutzgeist"), _(@"Magisches Meisterhandwerk")])
        {
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
          [newTalents setObject: talent forKey: specialTalent];
        }
    
      [(DSACharacterHero *)self.generatedCharacter setSpecials: newTalents];
      NSMutableDictionary *newSpells = [[NSMutableDictionary alloc] init];
      NSDictionary *spells = [[NSDictionary alloc] init];
      spells = [self getSpellsForArchetype: @"Magier"];      // doesn't matter what we use, we initialize the values differently
      for (NSInteger i=0; i< 19; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];

          if ([[self valueForKey: fieldName] state] == 1)
            {
               NSLog(@"testing spell: %@", [[self valueForKey: fieldName] title]);
               for (NSString *category in spells)
                 {
                    for (NSString *s in [spells objectForKey: category])
                      {
                        if ([s isEqualToString: [[self valueForKey: fieldName] title]])
                          {
                            NSDictionary *sDict = [[spells objectForKey: category] objectForKey: s];
                            DSASpell *spell = [[DSASpell alloc] initSpell: s
                                                               ofCategory: category
                                                                  onLevel: 0               // See Compendium Salamandris S. 29
                                                               withOrigin: [sDict objectForKey: @"Ursprung"]
                                                                 withTest: [sDict objectForKey: @"Probe"]
                                                         withAlternatives: [sDict objectForKey: @"Alternativen"]
                                                   withMaxTriesPerLevelUp: 3
                                                        withMaxUpPerLevel: 1
                                                          withLevelUpCost: 2]; 
                            [newSpells setObject: spell forKey: s];
                          }
                      }
                 }
            }
        }
      [(DSACharacterHero *)self.generatedCharacter setSpells: newSpells];
    }
  else if (self.magicalDabblerDiceResult >= 16 && self.magicalDabblerDiceResult <= 19)
    {
      [(DSACharacterHero *)self.generatedCharacter setSpecials: [NSMutableDictionary dictionaryWithDictionary: @{ _(@"Schutzgeist"): @{}, _(@"Magisches Meisterhandwerk"): @{}}]];
    }
  else if (self.magicalDabblerDiceResult == 20)
    {
      for (NSInteger i=0; i< 2; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          if ([[self valueForKey: fieldName] state] == 1)
            {
              [(DSACharacterHero *)self.generatedCharacter setSpecials: [NSMutableDictionary dictionaryWithDictionary: @{ [[self valueForKey: fieldName] title]: @{}}]];
              break;
            }
        }
    }
    
  [self.windowMagicalDabbler close];
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

  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: [[self.popupArchetypes selectedItem] title]]];
      
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
  else if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Geode")] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemsWithTitles: [charConstraints objectForKey: @"Schule"]];
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)]; 
      [self.fieldMageSchool setStringValue: _(@"Geodische Schule")];           
    }
  else if ( [[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Krieger")] )
    {
      [self.popupMageAcademies setEnabled: YES];
      [self.popupMageAcademies removeAllItems];
      [self.popupMageAcademies addItemWithTitle: _(@"Akademie wählen")];      
      [self.popupMageAcademies addItemsWithTitles: [[[Utils getWarriorAcademiesDict] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
      [self.popupMageAcademies setTarget:self];
      [self.popupMageAcademies setAction:@selector(popupMageAcademySelected:)]; 
      [self.fieldMageSchool setStringValue: _(@"Kriegerakademie")];           
    }
  else if ([[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Schamane")] )
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
    
  if ([[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Geode")] || 
      [[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Druide")] ||
      [[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Magier")])
    {
      if ([[[self.popupArchetypes selectedItem] title] isEqualToString: _(@"Magier")])
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
  NSArray *religions = [self getReligionsForArchetype: [[self.popupArchetypes selectedItem] title]];
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
  [self.popupOrigins addItemsWithTitles: [Utils getOriginsForArchetype: [[self.popupArchetypes selectedItem] title]]];
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
  [self.popupProfessions addItemsWithTitles: [Utils getProfessionsForArchetype: [[self.popupArchetypes selectedItem] title]]];
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
  NSArray *religions = [self getReligionsForArchetype: [[self.popupArchetypes selectedItem] title]];
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
}

- (IBAction) buttonGenerateClicked: (id)sender
{
  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getArchetypesDict] objectForKey: [[self.popupArchetypes selectedItem] title]]];
  NSArray *positiveArr = [NSArray arrayWithArray: [self generatePositiveTraits]];
  NSArray *negativeArr = [NSArray arrayWithArray: [self generateNegativeTraits]];
  DSAAventurianDate *birthday = [[DSAAventurianDate alloc] init];
  NSDictionary *socialStatusParents = [self generateFamilyBackground: [[self.popupArchetypes selectedItem] title]];
  if ([[self.fieldMageSchool stringValue] isEqualToString: _(@"Magiedilettant")])
    {
      while ([@[_(@"reich"), _(@"adelig")] containsObject: [socialStatusParents objectForKey: @"Stand"]])
        {
          socialStatusParents = [self generateFamilyBackground: [[self.popupArchetypes selectedItem] title]];        
        }
    }
  NSDictionary *wealthDict = [self generateWealth: [socialStatusParents objectForKey: @"Stand"]];
  
  [self.fieldHairColor setStringValue: [self generateHairColorForArchetype: [[self.popupArchetypes selectedItem] title]]];
  [self.fieldEyeColor setStringValue: [self generateEyeColorForArchetype: [[self.popupArchetypes selectedItem] title] withHairColor: [self.fieldHairColor stringValue]]];  
  birthday = [self generateBirthday];
  [self.fieldBirthday setStringValue: [NSString stringWithFormat: @"%lu. %@ %lu %@", (unsigned long)birthday.day, birthday.monthName, (unsigned long)birthday.year, birthday.year > 0 ? @"AF" : @"BF"]];
  [self.fieldHeight setStringValue: [NSString stringWithFormat: @"%f", [self generateHeightForArchetype: [[self.popupArchetypes selectedItem] title]]]];
  [self.fieldWeight setStringValue: [NSString stringWithFormat: @"%f", [self generateWeightForArchetype: [[self.popupArchetypes selectedItem] title] withHeight: [self.fieldHeight floatValue]]]];
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
    
  [self.fieldSocialStatus setStringValue: [socialStatusParents objectForKey: @"Stand"]];
  [self.fieldParents setStringValue: [socialStatusParents objectForKey: @"Eltern"]];
  [self.fieldWealth setStringValue: [NSString stringWithFormat: @"%@D %@S %@H %@K", 
                                              [wealthDict objectForKey: @"D"], 
                                              [wealthDict objectForKey: @"S"], 
                                              [wealthDict objectForKey: @"H"], 
                                              [wealthDict objectForKey: @"K"]]];
  for (NSString *god in [[Utils getGodsDict] allKeys])
    {
      if ([[[[Utils getGodsDict] objectForKey: god] objectForKey: @"Monat"] isEqualToString: birthday.monthName])
        {
          [self.fieldStars setStringValue: [[[Utils getGodsDict] objectForKey: god] objectForKey: @"Sternbild"]];
          [self.fieldGod setStringValue: god];
          break;
        }
    }
  
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
  // Validate all required fields, create the appropriate character subclass
  [self createCharacter:sender];

  NSLog(@"DSACharacterGenerationController buttonFinishClicked: after createCharacter, going to test for Magical Dabbler");
  // A Magical Dabbler
  if ([self.popupMageAcademies isEnabled] && ![self.generatedCharacter isMagic])
    {
        NSLog(@"DSACharacterGenerationController buttonFinishClicked: first IF test survived");
      if ([[[self.popupMageAcademies selectedItem] title] isEqualToString: _(@"Ja")])
        {
        NSLog(@"DSACharacterGenerationController buttonFinishClicked: second IF test survived");
        
          [self makeCharacterAMagicalDabbler];
        }
      else
        {
          NSLog(@"DSACharacterGenerationController buttonFinishClicked: it was chosen NOT to create a magical dabbler, going to complete character generation");
          [self completeCharacterGeneration];
        }
    }
  else 
    { 
      // Complete the character generation and trigger the completion handler
      NSLog(@"DSACharacterGenerationController buttonFinishClicked: not a magical dabbler, going to complete character generation");
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
