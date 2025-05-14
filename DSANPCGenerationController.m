/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-04-13 21:06:14 +0200 by sebastia

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

#import "DSANPCGenerationController.h"
#import "Utils.h"
#import "DSANameGenerator.h"
#import "DSATrait.h"
#import "DSAInventoryManager.h"
#import "DSACharacterGenerator.h"

@implementation DSANPCGenerationController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSANPCGenerator"];
  if (self)
    {
      self.generatedNpc = [[DSACharacter alloc] init];
                                                                                                                                    
    }
  return self;
}


- (void)startNpcGeneration: (id)sender
{
  [self windowDidLoad];
  [self showWindow:self];
  [[self window] makeKeyAndOrderFront: self];
  [self.popupCategories removeAllItems];
  [self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [Utils getAllNpcTypesCategories]];
   
  [self.popupTypes removeAllItems];
  [self.popupTypes addItemWithTitle: _(@"Typus wählen")];

  [self.popupSubtypes removeAllItems];
  [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];  

  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];
    
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];
  
  [self.popupCount removeAllItems];
  [self.popupCount addItemWithTitle: _(@"1")];  
//  [self.popupCount addItemWithTitle: _(@"2")];
//  [self.popupCount addItemWithTitle: _(@"3")];
   
  [self.popupTypes setEnabled: NO];   
  [self.popupTypes setAutoenablesItems: NO];
  [self.popupSubtypes setEnabled: NO];   
  [self.popupSubtypes setAutoenablesItems: NO];
  [self.popupOrigins setEnabled: NO];   
  [self.popupOrigins setAutoenablesItems: NO];    
  [self.popupLevel setEnabled: NO];   
  [self.popupLevel setAutoenablesItems: NO];      
  [self.popupCount setEnabled: NO];
  [self.popupCount setAutoenablesItems: NO];
  
  [self.buttonGenerate setEnabled: NO];
}

- (void)completeNpcGeneration
{
  if (self.completionHandler)
    {
      self.completionHandler(self.generatedNpc);
    }
  [self close]; // Close the character generation window
}

- (void)createNpc:(id)sender
{

  DSACharacterGenerator *generator = [[DSACharacterGenerator alloc] init];
  NSMutableDictionary *characterParameters = [[NSMutableDictionary alloc] init];

  NSDictionary *charConstraints = [NSDictionary dictionaryWithDictionary: [[Utils getNpcTypesDict] objectForKey: [[self.popupTypes selectedItem] title]]];

  NSString *selectedArchetype = [[self.popupTypes selectedItem] title];
  NSString *selectedSubtype = [[self.popupSubtypes selectedItem] title];
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSLog(@"DSANPCGenerationController selectedOrigin: %@", selectedOrigin);

  [characterParameters setObject: selectedArchetype forKey: @"archetype"];
  if (![selectedSubtype isEqualToString: @"Subtypus wählen"])
    {
      [characterParameters setObject: selectedSubtype forKey: @"subarchetype"];
    }

  [characterParameters setObject: [NSNumber numberWithBool: YES] forKey: @"isNPC"];      // we only create characters here
  [characterParameters setObject: selectedOrigin forKey: @"origin"];

  DSACharacterNpc *newCharacter = [generator generateCharacterWithParameters: characterParameters];
  
  
  //DSACharacterNpc *newCharacter = (DSACharacterNpc *)[DSACharacter characterWithType: selectedArchetype];

/*  NSLog(@"DSANPCGenerationController createNpc in the beginning... charConstraints: %@", charConstraints);
  NSLog(@"DSANPCGenerationController createNpc in the beginning... selectedSubtype: %@", selectedSubtype);
  if ([selectedSubtype isEqualToString: @"Subtypus wählen"])
    {
      newCharacter.archetype = selectedArchetype;
    }
  else
    {
      newCharacter.archetype = selectedSubtype;
    } */
  // newCharacter.origin = selectedOrigin; 
  // newCharacter.level = [self generateLevel: charConstraints];
  //newCharacter.lifePoints = [self generateLifePoints: charConstraints];
  //newCharacter.currentLifePoints = newCharacter.lifePoints;
  //newCharacter.astralEnergy = [self generateAstralEnergy: charConstraints];
  //newCharacter.currentAstralEnergy = newCharacter.astralEnergy;
  //newCharacter.karmaPoints = [self generateKarmaPoints: charConstraints];
  //newCharacter.currentKarmaPoints = newCharacter.karmaPoints;
  // newCharacter.mrBonus = [self generateMagicResistance: charConstraints];  // NPCs return just the mrBonus as magicResistance, no calculations ...
  // newCharacter.sex = [self generateGender: charConstraints];
  // newCharacter.name = [self generateNameForGender: newCharacter.sex];
  //newCharacter.height = [self generateHeight: charConstraints];
  //newCharacter.weight = [self generateWeight: charConstraints];
  newCharacter.staticAttackBaseValue = [self generateAttackBaseValue: charConstraints];
  newCharacter.staticParryBaseValue = [self generateParryBaseValue: charConstraints];
  newCharacter.armorBaseValue = [self generateArmorBaseValue: charConstraints];
  // newCharacter.isMagic = [[charConstraints objectForKey: @"isMagic"] boolValue];
  
  newCharacter.positiveTraits = [self generatePositiveTraits: charConstraints];
  NSMutableDictionary *deepCopyPositiveTraits = [NSMutableDictionary dictionary];
  for (NSString *key in newCharacter.positiveTraits)
    {
      DSAPositiveTrait *value = newCharacter.positiveTraits[key];
      deepCopyPositiveTraits[key] = [value copy];
    }
  newCharacter.currentPositiveTraits = [deepCopyPositiveTraits mutableCopy];

  newCharacter.negativeTraits = [self generateNegativeTraits: charConstraints];
  NSMutableDictionary *deepCopyNegativeTraits = [NSMutableDictionary dictionary];
  for (NSString *key in newCharacter.negativeTraits)
    {
      DSANegativeTrait *value = newCharacter.negativeTraits[key];
      deepCopyNegativeTraits[key] = [value copy];
    }
  newCharacter.currentNegativeTraits = [deepCopyNegativeTraits mutableCopy];  
  newCharacter.portraitName = [self generatePortraitName: charConstraints forGender: newCharacter.sex ofSubtype: selectedSubtype];
  
  [self addTalentsToCharacter: newCharacter];
  if (newCharacter.isMagic)
    {
      [self addSpellsToCharacter: newCharacter];
      [Utils applySpellmodificatorsToCharacter: newCharacter];
    }
  
  [self apply: @"Herkunft" to: newCharacter using: charConstraints];
  [self apply: @"Subtypen" to: newCharacter using: charConstraints];
  [self addEquipmentToCharacter: newCharacter using: charConstraints];
  self.generatedNpc = newCharacter;
  
  NSLog(@"DSANPCGenerationController: newCharacter: %@", newCharacter);
}

- (NSString *) generatePortraitName: (NSDictionary *) charConstraints forGender: (NSString *) gender ofSubtype: (NSString *) subtype
{
  NSArray *portraitNames = [[[[charConstraints objectForKey: @"Subtypen"]
                                               objectForKey: subtype]
                                               objectForKey: @"Images"]
                                               objectForKey: gender];
  if ([portraitNames count] == 0)
    {
      portraitNames = [[charConstraints objectForKey: @"Images"]
                                        objectForKey: gender];
    }
  NSUInteger randomIndex = arc4random_uniform((uint32_t) [portraitNames count]);
  
  NSLog(@"DSANPCGenerationController generatePortraitName: %@", [portraitNames objectAtIndex: randomIndex]);
  return [portraitNames objectAtIndex: randomIndex];
}

- (NSMutableDictionary *) generatePositiveTraits: (NSDictionary *) charConstraints
{
   NSString *selectedLevel = [[self.popupLevel selectedItem] title];
   NSDictionary *traitDefinitions = [[[charConstraints objectForKey: @"Erfahrungsstufen"]
                                                       objectForKey: selectedLevel]
                                                       objectForKey: @"Eigenschaften"];
   NSMutableDictionary *positiveTraits = [[NSMutableDictionary alloc] init];
   if (!traitDefinitions)
     {
       traitDefinitions = [charConstraints objectForKey: @"Eigenschaften"];
     }
     
   for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK"])
     {
       NSArray *traitDefinition = [traitDefinitions objectForKey: field];
       NSInteger traitValue;
       if ([traitDefinition count] == 1)
         {
            traitValue = [Utils rollDice: [traitDefinition objectAtIndex: 0]];
         }
       else
         {
            traitValue = [Utils rollDice: [traitDefinition objectAtIndex: 0]] + [[traitDefinition objectAtIndex: 1] integerValue];
         }
       [positiveTraits setObject:
         [[DSAPositiveTrait alloc] initTrait: field
                                     onLevel: traitValue]
                          forKey: field];
     }
  return positiveTraits;   
}

// There might be constraints on some negative traits...
- (NSMutableDictionary *) generateNegativeTraits: (NSDictionary *) charConstraints
{
  NSDictionary *traitConstraints = [charConstraints objectForKey: @"Eigenschaften Constraints"];
  NSMutableDictionary *negativeTraits = [[NSMutableDictionary alloc] init];
  for (NSString *field in @[@"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ"])
    {
      NSInteger result;
      result = [Utils rollDice: @"1W6"] + 1;
      NSString *traitConstraint = [traitConstraints objectForKey: field];
      if (traitConstraint)
        {
          NSDictionary *constraintsDict = [Utils parseConstraint: traitConstraint];
          if ([[constraintsDict objectForKey: @"constraint"] isEqualTo: @"MAX"])
            {
              if (result < [[constraintsDict objectForKey: @"value"] integerValue])
                {
                  result = [[constraintsDict objectForKey: @"value"] integerValue];
                }
            }
          else
            {
              if (result > [[constraintsDict objectForKey: @"value"] integerValue])
                {
                  result = [[constraintsDict objectForKey: @"value"] integerValue];
                }
            }
        }
      [negativeTraits setObject:
        [[DSANegativeTrait alloc] initTrait: field
                                    onLevel: result]
                         forKey: field];
    }
  return negativeTraits;
}

- (NSInteger) generateAttackBaseValue: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateAttackBaseValue selectedLevel: %@", selectedLevel);
  NSArray *atDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                             objectForKey: selectedLevel] 
                                             objectForKey: @"AT"];
  NSLog(@"DSANPCGenerationController generateAttackBaseValue atDefinition: %@", atDefinition);                                                  
  if (!atDefinition)
    {
      atDefinition = [charConstraints objectForKey: @"AT"];
    }
  NSLog(@"DSANPCGenerationController generateAttackBaseValue atDefinition: %@", atDefinition);

  if (!atDefinition)
    {
      return 0;
    }
  return [[atDefinition objectAtIndex: 0] integerValue];
}

- (NSInteger) generateParryBaseValue: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateParryBaseValue selectedLevel: %@", selectedLevel);
  NSArray *paDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                                objectForKey: selectedLevel] 
                                                objectForKey: @"PA"];
  NSLog(@"DSANPCGenerationController generateParryBaseValue paDefinition: %@", paDefinition);                                                  
  if (!paDefinition)
    {
      paDefinition = [charConstraints objectForKey: @"PA"];
    }
  NSLog(@"DSANPCGenerationController generateParryBaseValue paDefinition: %@", paDefinition);

  if (!paDefinition)
    {
      return 0;
    }
  return [[paDefinition objectAtIndex: 0] integerValue];
}

- (NSInteger) generateArmorBaseValue: (NSDictionary *) charConstraints
{
  NSInteger armorBaseValue = [[charConstraints objectForKey: @"RS"] integerValue];

  return armorBaseValue;
}

/*
- (NSInteger) generateMagicResistance: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateMagicResistance selectedLevel: %@", selectedLevel);
  NSArray *mrDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                                objectForKey: selectedLevel] 
                                                objectForKey: @"MR"];
  NSLog(@"DSANPCGenerationController generateMagicResistance mrDefinition: %@", mrDefinition);                                                  
  if (!mrDefinition)
    {
      mrDefinition = [charConstraints objectForKey: @"MR"];
    }
  NSLog(@"DSANPCGenerationController generateMagicResistance mrDefinition: %@", mrDefinition);

  if (!mrDefinition)
    {
      return 0;
    }  
    
  NSInteger mr;
  if ([mrDefinition count] == 1)
    {
       mr = [Utils rollDice: [mrDefinition objectAtIndex: 0]];
    }
  else
    {
      mr = [Utils rollDice: [mrDefinition objectAtIndex: 0]] + [[mrDefinition objectAtIndex: 1] integerValue];
    }
  return mr;
}


- (NSInteger) generateLifePoints: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateLifePoints selectedLevel: %@", selectedLevel);
  NSArray *leDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                                objectForKey: selectedLevel] 
                                                objectForKey: @"LE"];
  NSLog(@"DSANPCGenerationController generateLifePoints leDefinition: %@", leDefinition);                                                  
  if (!leDefinition)
    {
      leDefinition = [charConstraints objectForKey: @"LE"];
    }
  NSLog(@"DSANPCGenerationController generateLifePoints leDefinition: %@", leDefinition);
  
  NSInteger le;
  if ([leDefinition count] == 1)
    {
       le = [Utils rollDice: [leDefinition objectAtIndex: 0]];
    }
  else
    {
      le = [Utils rollDice: [leDefinition objectAtIndex: 0]] + [[leDefinition objectAtIndex: 1] integerValue];
    }
  return le;
}

- (NSInteger) generateAstralEnergy: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateAstralEnergy selectedLevel: %@", selectedLevel);
  NSArray *aeDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                                objectForKey: selectedLevel] 
                                                objectForKey: @"AE"];
  NSLog(@"DSANPCGenerationController generateAstralEnergy aeDefinition: %@", aeDefinition);                                                  
  if (!aeDefinition)
    {
      aeDefinition = [charConstraints objectForKey: @"AE"];
    }
  NSLog(@"DSANPCGenerationController generateAstralEnergy aeDefinition: %@", aeDefinition);
  
  if (!aeDefinition)
    {
      return 0;
    }
  
  NSInteger ae;
  if ([aeDefinition count] == 1)
    {
       ae = [Utils rollDice: [aeDefinition objectAtIndex: 0]];
    }
  else
    {
      ae = [Utils rollDice: [aeDefinition objectAtIndex: 0]] + [[aeDefinition objectAtIndex: 1] integerValue];
    }
  return ae;
}

- (NSInteger) generateKarmaPoints: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateKarmaPoints selectedLevel: %@", selectedLevel);
  NSArray *keDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                                objectForKey: selectedLevel] 
                                                objectForKey: @"KE"];
  NSLog(@"DSANPCGenerationController generateKarmaPoints keDefinition: %@", keDefinition);                                                  
  if (!keDefinition)
    {
      keDefinition = [charConstraints objectForKey: @"KE"];
    }
  NSLog(@"DSANPCGenerationController generateKarmaPoints keDefinition: %@", keDefinition);
  
  if (!keDefinition)
    {
      return 0;
    }
  
  NSInteger ke;
  if ([keDefinition count] == 1)
    {
       ke = [Utils rollDice: [keDefinition objectAtIndex: 0]];
    }
  else
    {
      ke = [Utils rollDice: [keDefinition objectAtIndex: 0]] + [[keDefinition objectAtIndex: 1] integerValue];
    }
  return ke;
}

- (NSInteger) generateHeight: (NSDictionary *) charConstraints
{
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSLog(@"DSANPCGenerationController generateHeight selectedOrigin: %@, %@", selectedOrigin, charConstraints);
  NSArray *heightDefinition = [[[charConstraints objectForKey: @"Herkunft"] 
                                                 objectForKey: selectedOrigin] 
                                                 objectForKey: @"Größe"];
  NSLog(@"DSANPCGenerationController generateHeight heightDefinition: %@", heightDefinition);                                                  
  if (! heightDefinition)
    {
      heightDefinition = [charConstraints objectForKey: @"Größe"];
    }
  NSLog(@"DSANPCGenerationController generateHeight heightDefinition: %@", heightDefinition);
  
  NSInteger height;
  if ([heightDefinition count] == 1)
    {
       height = [Utils rollDice: [heightDefinition objectAtIndex: 0]];
    }
  else
    {
      height = [Utils rollDice: [heightDefinition objectAtIndex: 0]] + [[heightDefinition objectAtIndex: 1] integerValue];
    }
  return height;
}

- (NSInteger) generateWeight: (NSDictionary *) charConstraints
{
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSLog(@"DSANPCGenerationController generateWeight selectedOrigin: %@", selectedOrigin);
  NSArray *weightDefinition = [[[charConstraints objectForKey: @"Herkunft"] 
                                                 objectForKey: selectedOrigin] 
                                                 objectForKey: @"Gewicht"];
  NSLog(@"DSANPCGenerationController generateWeight weightDefinition: %@", weightDefinition);                                                  
  if (! weightDefinition)
    {
      weightDefinition = [charConstraints objectForKey: @"Gewicht"];
    }
  NSLog(@"DSANPCGenerationController generateWeight weightDefinition: %@", weightDefinition);
  
  NSInteger weight;
  if ([weightDefinition count] == 1)
    {
       weight = [Utils rollDice: [weightDefinition objectAtIndex: 0]];
    }
  else
    {
      weight = [Utils rollDice: [weightDefinition objectAtIndex: 0]] + [[weightDefinition objectAtIndex: 1] integerValue];
    }
  return weight;
}

- (NSString *) generateGender: (NSDictionary *) charConstraints
{
  NSArray *gender = [charConstraints objectForKey: @"Geschlecht"];
  NSUInteger randomIndex = arc4random_uniform((uint32_t) [gender count]);
  
  return [gender objectAtIndex: randomIndex];
}

- (NSInteger) generateLevel: (NSDictionary *) charConstraints
{
  NSString *selectedLevel = [[self.popupLevel selectedItem] title];
  NSLog(@"DSANPCGenerationController generateLevel selectedLevel: %@", selectedLevel);
  NSArray *levelDefinition = [[[charConstraints objectForKey: @"Erfahrungsstufen"] 
                                                objectForKey: selectedLevel] 
                                                objectForKey: @"ST"];
  NSLog(@"DSANPCGenerationController generateLevel levelDefinition: %@", levelDefinition);                                                  
  if (!levelDefinition)
    {
      levelDefinition = [charConstraints objectForKey: @"ST"];
    }
  NSLog(@"DSANPCGenerationController generateLevel levelDefinition: %@", levelDefinition);
  
  NSInteger level;
  if ([levelDefinition count] == 1)
    {
       level = [Utils rollDice: [levelDefinition objectAtIndex: 0]];
    }
  else
    {
      level = [Utils rollDice: [levelDefinition objectAtIndex: 0]] + [[levelDefinition objectAtIndex: 1] integerValue];
    }
  return level;
}

-(NSString *) generateNameForGender: (NSString *) gender
{
  NSArray *supportedNames = [DSANameGenerator getTypesOfNames];
  NSLog(@"DSANPCGenerationCtroller: generateName: supportedNames: %@", supportedNames);
  NSString *origin;
  NSString *name;

  if ([supportedNames containsObject: [[self.popupSubtypes selectedItem] title]])     // first check Subtyp, might be more specifc name available
    {
      origin = [[self.popupSubtypes selectedItem] title];
    }    
  else if ([supportedNames containsObject: [[self.popupTypes selectedItem] title]])   // fall back to Typus
    {
      origin = [[self.popupTypes selectedItem] title];
    }    
  else if ([supportedNames containsObject: [[self.popupOrigins selectedItem] title]]) // or origin
    {
      origin = [[self.popupOrigins selectedItem] title];
    }
  if ([supportedNames containsObject: [[self.popupCategories selectedItem] title]])   // before falling back to more or less last resort...
    {
      origin = [[self.popupCategories selectedItem] title];
    }    
  if ([origin length] == 0)
    {
      name = @"ohne Namen";
      return name;
    }
    
  name = [DSANameGenerator generateNameWithGender: gender
                                          isNoble: NO
                                         nameData: [Utils getNamesForRegion: origin]]; 
  if ([name length] == 0)
    {
      name = @"ohne Namen";
    }       
  return name;                                                                                                                                   
}
*/

- (void) apply: (NSString *)modificator to: (DSACharacterNpc *) character using: (NSDictionary *) charConstraints
{
  NSString *charProperty;
  if ([modificator isEqualToString: @"Herkunft"])
    {
      charProperty = @"origin";
    }
  else if ([modificator isEqualToString: @"Subtypen"])
    {
      charProperty = @"archetype";
    }
  else
    {
      NSLog(@"DSANPCgenerationController apply: to: using: got unknown modificator: %@", modificator);
      return;
    }

  NSDictionary *modificators = [[charConstraints objectForKey: modificator]
                                                 objectForKey: [character valueForKey: charProperty]];
                                                 
  NSLog(@"DSANPCgenerationController apply: to: using: got these modificators: %@", modificators);
  
  for (NSString *field in @[ @"MU", @"IN", @"GE", @"KK", @"KL", @"CH", @"FF" ])
    {
      NSInteger value = 0;
      value = [[modificators objectForKey: field] integerValue];
      if (value != 0)
        {
           DSAPositiveTrait *trait = [[character valueForKey: @"positiveTraits"]
                                                objectForKey: field];
           trait.level = [trait level] + value;
           trait = [[character valueForKey: @"currentPositiveTraits"]
                              objectForKey: field];
           trait.level = [trait level] + value;           
        }
        
    }
  // other character properties that might be "different"
  // "RS" a.k.a. armorBaseValue
  NSInteger armorBaseValueModificator = 0;
  armorBaseValueModificator = [[modificators objectForKey: @"RS"] integerValue];
  if (armorBaseValueModificator != 0)
    {
      character.armorBaseValue = character.armorBaseValue + armorBaseValueModificator;
    }
  NSInteger attackBaseValueModificator = 0;
  attackBaseValueModificator = [[modificators objectForKey: @"AT"] integerValue];
  if (attackBaseValueModificator != 0)
    {
      character.staticAttackBaseValue = [character staticAttackBaseValue] + attackBaseValueModificator;
    }
  NSInteger parryBaseValueModificator = 0;
  parryBaseValueModificator = [[modificators objectForKey: @"PA"] integerValue];
  if (parryBaseValueModificator != 0)
    {
      character.staticParryBaseValue = [character staticParryBaseValue] + parryBaseValueModificator;
    }    
}

- (void) addTalentsToCharacter: (DSACharacterNpc *) character
{
    // handle talents
  NSDictionary *talents = [[NSDictionary alloc] init];
  talents = [Utils getTalentsForCharacter: character];
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
  character.talents = newTalents;
}

- (void) addSpellsToCharacter: (DSACharacterNpc *) character
{

  NSLog(@"DSANPCGenerationController addSpellsToCharacter called");
  if ([character isMagic])
    {
      NSLog(@"DSANPCGenerationController addSpellsToCharacter called and we have a magic character");
      NSDictionary *spells = [[NSDictionary alloc] init];
      spells = [Utils getSpellsForCharacter: character];

      NSLog(@"DSANPCGenerationController addSpellsToCharacter called and these are the spells for the character: %@", spells);
      
      NSMutableDictionary *newSpells = [[NSMutableDictionary alloc] init];
      
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
      character.spells = newSpells;
      NSLog(@"DSANPCGenerationController: addSpellsToCharacter: not applying any archetype related spell modificators");        
    }
}

- (void) addEquipmentToCharacter: (DSACharacterNpc *) character using: (NSDictionary *) charConstraints
{
  NSString *origin = character.origin;
  DSAInventoryManager *inventoryManager = [DSAInventoryManager sharedManager];
  NSLog(@"DSANPCGenerationController addEquipmentToCharacter selectedOrigin: %@", origin);
  NSArray *weaponArray = [[[charConstraints objectForKey: @"Herkunft"] 
                                            objectForKey: origin] 
                                            objectForKey: @"Waffen"];
  NSLog(@"DSANPCGenerationController addEquipmentToCharacter weaponArray: %@", weaponArray);                                                  
  if (! weaponArray)
    {
      weaponArray = [charConstraints objectForKey: @"Waffen"];
    }
  NSLog(@"DSANPCGenerationController addEquipmentToCharacter weaponArray: %@", weaponArray);
  
  NSUInteger randomIndex = arc4random_uniform((uint32_t) [weaponArray count]);
  NSString *weaponName = [weaponArray objectAtIndex: randomIndex];
  DSAObject *weapon = [[DSAObject alloc] initWithName: weaponName forOwner: nil];
  
  NSLog(@"DSANPCGenerationController addEquipmentToCharacter weapon: %@", weapon);
  
  [inventoryManager equipCharacter: character
                        withObject: weapon
                        ofQuantity: 1
                        toBodyPart: @"rightHand"
                          slotType: DSASlotTypeGeneral];
   if ([weapon isMemberOfClass:[DSAObjectWeaponLongRange class]])
     {
       NSArray *ammoArray = [(DSAObjectWeaponLongRange *)weapon ammunition];

       if (ammoArray != nil && [ammoArray count] > 0)
         {
           randomIndex = arc4random_uniform((uint32_t) [ammoArray count]);
           NSString *ammoName = [ammoArray objectAtIndex: randomIndex];
           DSAObject *ammo = [[DSAObject alloc] initWithName: ammoName forOwner: nil];
           [inventoryManager equipCharacter: character
                                 withObject: ammo
                                 ofQuantity: 20
                                 toBodyPart: @"leftHand"
                                   slotType: DSASlotTypeGeneral];
         }
     }
  
}

// depending on experience level, have to level up talents/spells etc.
// until better ideas, assume every talent starts with 0, and every spell starts at -5
// then just randomly level up talents and spells
- (void) levelUp
{

}

- (IBAction) popupCategorySelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self startNpcGeneration: self];
      return;
    }
NSLog(@"popupCategorySelected called!");  
  [self.popupTypes removeAllItems];
  [self.popupTypes addItemWithTitle: _(@"Typus wählen")];
  [self.popupTypes addItemsWithTitles: [Utils getAllNpcTypesForCategory: [[self.popupCategories selectedItem] title]]];
  [self.popupTypes setEnabled: YES];

  [self.popupSubtypes removeAllItems];
  [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];  
  [self.popupSubtypes setEnabled: NO];  
    
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
  [self.popupOrigins setEnabled: NO];
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
  [self.popupLevel setEnabled: NO];
  [self.popupCount setEnabled: NO];
  [self.buttonGenerate setEnabled: NO];
}

- (IBAction) popupTypesSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupSubtypes removeAllItems];
      [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];  
      [self.popupSubtypes setEnabled: NO];
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
      [self.popupOrigins setEnabled: NO];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];      
      return;
    }
NSLog(@"popupTypesSelected called!");
  NSArray *subtypes = [Utils getAllSubtypesForNpcType: [[self.popupTypes selectedItem] title]];
  [self.popupSubtypes removeAllItems];
  [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];
  if ([subtypes count] > 0)
    {
      [self.popupSubtypes addItemsWithTitles: subtypes];
      [self.popupSubtypes setEnabled: YES];
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
      [self.popupOrigins setEnabled: NO];      
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];      
    }
  else
    {
      [self.popupSubtypes setEnabled: NO];
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];
      [self.popupOrigins addItemsWithTitles: [Utils getAllOriginsForNpcType: [[self.popupTypes selectedItem] title] ofSubtype: [[self.popupSubtypes selectedItem] title]]];
      [self.popupOrigins setEnabled: YES];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];     
    }
}

- (IBAction) popupSubtypesSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
      [self.popupOrigins setEnabled: NO];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];    
      return;
    }
NSLog(@"popupSubtypesSelected called!");  
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];
  [self.popupOrigins addItemsWithTitles: [Utils getAllOriginsForNpcType: [[self.popupTypes selectedItem] title] ofSubtype: [[self.popupSubtypes selectedItem] title]]];
  [self.popupOrigins setEnabled: YES];
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
  [self.popupLevel setEnabled: NO];
  [self.popupCount setEnabled: NO];
  [self.buttonGenerate setEnabled: NO];   
}

- (IBAction) popupOriginSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];   
      return;
    }
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];
  [self.popupLevel addItemsWithTitles: [Utils getAllExperienceLevelsForNpcType: [[self.popupTypes selectedItem] title]]];
  [self.popupLevel setEnabled: YES];  
  [self.buttonGenerate setEnabled: NO];
     
}

- (IBAction) popupLevelSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupCount setEnabled: NO];    
      return;
    }
  [self.popupCount setEnabled: YES];
  [self.buttonGenerate setEnabled: YES];     
}



- (IBAction) buttonGenerateClicked: (id)sender
{
  NSLog(@"DSANPCGenerationController buttonGenerateClicked called");
  [self createNpc: sender];
  
  [self completeNpcGeneration];
}

@end
