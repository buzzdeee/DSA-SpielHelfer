/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 00:03:31 +0200 by sebastia

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

#import <objc/runtime.h>
#import "DSACharacter.h"
#import "AppKit/AppKit.h"

#import "Utils.h"
#import "DSATrait.h"
#import "DSATalent.h"
#import "DSASpellMageRitual.h"
#import "DSASpellDruidRitual.h"
#import "DSARegenerationResult.h"
#import "DSAInventoryManager.h"
#import "DSALocation.h"
#import "DSAWallet.h"
#import "DSAGod.h"
#import "DSAIllness.h"
#import "DSAPoison.h"
#import "DSASpellResult.h"

@implementation DSACharacterEffect
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _uniqueKey = [coder decodeObjectOfClass:[NSString class] forKey:@"uniqueKey"];
        _effectType = [coder decodeIntegerForKey:@"effectType"];
        _expirationDate = [coder decodeObjectOfClass:[DSAAventurianDate class] forKey:@"expirationDate"];
        _reversibleChanges = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"reversibleChanges"];
        _oneTimeDamage = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"oneTimeDamage"];
        _recurringDamage = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"recurringDamage"];        
        _recurringDamageApplyNextDate = [coder decodeObjectOfClass:[DSAAventurianDate class] forKey:@"recurringDamageApplyNextDate"];        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uniqueKey forKey:@"uniqueKey"];
    [coder encodeInteger:self.effectType forKey:@"effectType"];
    [coder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [coder encodeObject:self.reversibleChanges forKey:@"reversibleChanges"];
    [coder encodeObject:self.oneTimeDamage forKey:@"oneTimeDamage"];
    [coder encodeObject:self.recurringDamage forKey:@"recurringDamage"]; 
    [coder encodeObject:self.recurringDamageApplyNextDate forKey:@"recurringDamageApplyNextDate"];       
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    DSACharacterEffect *copy = [[[self class] allocWithZone:zone] init];
    copy->_uniqueKey = [self.uniqueKey copyWithZone:zone];
    copy->_effectType = self.effectType;
    copy->_expirationDate = [self.expirationDate copyWithZone:zone];
    copy->_reversibleChanges = [[NSDictionary allocWithZone:zone] initWithDictionary:self.reversibleChanges copyItems:YES];
    copy->_oneTimeDamage = [[NSDictionary allocWithZone:zone] initWithDictionary:self.oneTimeDamage copyItems:YES];
    copy->_recurringDamage = [[NSDictionary allocWithZone:zone] initWithDictionary:self.recurringDamage copyItems:YES];   
    copy->_recurringDamageApplyNextDate = [self.recurringDamageApplyNextDate copyWithZone:zone];    
    return copy;
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];          
                      
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}
@end

@implementation DSAIllnessEffect
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _currentStage = [coder decodeIntegerForKey:@"currentStage"];    
        _followUpIllnessChance = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"followUpIllnessChance"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeInteger:self.currentStage forKey:@"currentStage"];    
    [coder encodeObject:_followUpIllnessChance forKey:@"followUpIllnessChance"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    DSAIllnessEffect *copy = [super copyWithZone:zone];
    copy->_currentStage = self.currentStage;    
    copy->_followUpIllnessChance = [_followUpIllnessChance copyWithZone:zone];
    return copy;
}
@end

@implementation DSAPoisonEffect

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    [coder encodeInteger:self.beforePoisonActiveCounter forKey:@"beforePoisonActiveCounter"];
    [coder encodeInteger:self.oncePoisonActiveCounter forKey:@"oncePoisonActiveCounter"];
    [coder encodeInteger:self.beforePoisonActive forKey:@"beforePoisonActive"];
    [coder encodeInteger:self.oncePoisonActive forKey:@"oncePoisonActive"];
    [coder encodeInteger:self.currentStage forKey:@"currentStage"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _beforePoisonActiveCounter = [coder decodeIntegerForKey:@"beforePoisonActiveCounter"];
        _oncePoisonActiveCounter = [coder decodeIntegerForKey:@"oncePoisonActiveCounter"];
        _beforePoisonActive = [coder decodeIntegerForKey:@"beforePoisonActive"];
        _oncePoisonActive = [coder decodeIntegerForKey:@"oncePoisonActive"];
        _currentStage = [coder decodeIntegerForKey:@"currentStage"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAPoisonEffect *copy = [super copyWithZone:zone];
    if (copy) {
        copy.beforePoisonActiveCounter = self.beforePoisonActiveCounter;
        copy.oncePoisonActiveCounter = self.oncePoisonActiveCounter;
        copy.beforePoisonActive = self.beforePoisonActive;
        copy.oncePoisonActive = self.oncePoisonActive;
        copy.currentStage = self.currentStage;
    }
    return copy;
}

@end
@implementation DSACharacter

static NSDictionary<NSString *, Class> *typeToClassMap = nil;
static NSMutableDictionary<NSUUID *, DSACharacter *> *characterRegistry = nil;

+ (void)initialize {
    if (self == [DSACharacter class]) {
        @synchronized(self) {
            if (!characterRegistry) {
                characterRegistry = [NSMutableDictionary dictionary];
            }
            if (!typeToClassMap) {
                typeToClassMap = @{
                    _(@"Alchimist"): [DSACharacterHeroHumanAlchemist class],
                    _(@"Amazone"): [DSACharacterHeroHumanAmazon class],
                    _(@"Gaukler"): [DSACharacterHeroHumanJuggler class],
                    _(@"Jäger"): [DSACharacterHeroHumanHuntsman class],
                    _(@"Krieger"): [DSACharacterHeroHumanWarrior class],
                    _(@"Medicus"): [DSACharacterHeroHumanPhysician class],
                    _(@"Moha"): [DSACharacterHeroHumanMoha class],
                    _(@"Nivese"): [DSACharacterHeroHumanNivese class],
                    _(@"Norbarde"): [DSACharacterHeroHumanNorbarde class],
                    _(@"Novadi"): [DSACharacterHeroHumanNovadi class],
                    _(@"Seefahrer"): [DSACharacterHeroHumanSeafarer class],
                    _(@"Söldner"): [DSACharacterHeroHumanMercenary class],
                    _(@"Skalde"): [DSACharacterHeroHumanSkald class],
                    _(@"Barde"): [DSACharacterHeroHumanBard class],
                    _(@"Thorwaler"): [DSACharacterHeroHumanThorwaler class],
                    _(@"Streuner"): [DSACharacterHeroHumanRogue class],
                    _(@"Magier"): [DSACharacterHeroHumanMage class],
                    _(@"Druide"): [DSACharacterHeroHumanDruid class],
                    _(@"Schamane"): [DSACharacterHeroHumanShaman class],
                    _(@"Scharlatan"): [DSACharacterHeroHumanCharlatan class],
                    _(@"Schelm"): [DSACharacterHeroHumanJester class],
                    _(@"Hexe"): [DSACharacterHeroHumanWitch class],
                    _(@"Sharisad"): [DSACharacterHeroHumanSharisad class],
                    _(@"Auelf"): [DSACharacterHeroElfMeadow class],
                    _(@"Firnelf"): [DSACharacterHeroElfSnow class],
                    _(@"Waldelf"): [DSACharacterHeroElfWood class],
                    _(@"Halbelf"): [DSACharacterHeroElfHalf class],
                    _(@"Angroschpriester"): [DSACharacterHeroDwarfAngroschPriest class],
                    _(@"Geode"): [DSACharacterHeroDwarfGeode class],
                    _(@"Kämpfer"): [DSACharacterHeroDwarfFighter class],
                    _(@"Kavalier"): [DSACharacterHeroDwarfCavalier class],
                    _(@"Wandergeselle"): [DSACharacterHeroDwarfJourneyman class],
                    _(@"Praiosgeweihter"): [DSACharacterHeroBlessedPraios class],
                    _(@"Rondrageweihter"): [DSACharacterHeroBlessedRondra class],
                    _(@"Efferdgeweihter"): [DSACharacterHeroBlessedEfferd class],
                    _(@"Traviageweihter"): [DSACharacterHeroBlessedTravia class],
                    _(@"Borongeweihter"): [DSACharacterHeroBlessedBoron class],
                    _(@"Hesindegeweihter"): [DSACharacterHeroBlessedHesinde class],
                    _(@"Firungeweihter"): [DSACharacterHeroBlessedFirun class],
                    _(@"Tsageweihter"): [DSACharacterHeroBlessedTsa class],
                    _(@"Phexgeweihter"): [DSACharacterHeroBlessedPhex class],
                    _(@"Perainegeweihter"): [DSACharacterHeroBlessedPeraine class],
                    _(@"Ingerimmgeweihter"): [DSACharacterHeroBlessedIngerimm class],
                    _(@"Rahjageweihter"): [DSACharacterHeroBlessedRahja class],
                    _(@"Swafnirgeweihter"): [DSACharacterHeroBlessedSwafnir class],
                    _(@"Achaz"): [DSACharacterNpcHumanoidAchaz class],
                    _(@"Affenmensch"): [DSACharacterNpcHumanoidApeman class],
                    _(@"Elf"): [DSACharacterNpcHumanoidElf class],
                    _(@"Ferkina"): [DSACharacterNpcHumanoidFerkina class],
                    _(@"Fischmensch"): [DSACharacterNpcHumanoidFishman class],
                    _(@"Goblin"): [DSACharacterNpcHumanoidGoblin class],
                    _(@"Krakonier"): [DSACharacterNpcHumanoidKrakonier class],
                    _(@"Maru"): [DSACharacterNpcHumanoidMarus class],
                    _(@"Oger"): [DSACharacterNpcHumanoidOger class],
                    _(@"Ork"): [DSACharacterNpcHumanoidOrk class],
                    _(@"Riese"): [DSACharacterNpcHumanoidRiese class],
                    _(@"Troll"): [DSACharacterNpcHumanoidTroll class],
                    _(@"Yeti"): [DSACharacterNpcHumanoidYeti class],
                    _(@"Zyklop"): [DSACharacterNpcHumanoidZyklop class],
                };
            }
        }
    }
}

+ (instancetype)characterWithType:(NSString *)type {
    Class subclass = [typeToClassMap objectForKey:type];
    if (subclass) {
        NSLog(@"DSACharacter characterWithType: %@", type);
        return [[subclass alloc] init];
    }
    // Handle unknown type
    NSLog(@"DSACharacter characterWithType: UNKNOWN");
    return nil;
}

+ (DSACharacter *)characterWithModelID:(NSUUID *)modelID {
    @synchronized(characterRegistry) {
        // Just look up the character by modelID (NSUUID key)
        DSACharacter *character = characterRegistry[modelID];
        if (character) {
            NSLog(@"Found matching modelID: %@", [modelID UUIDString]);
        } else {
            NSLog(@"Character with modelID: %@ not found", [modelID UUIDString]);
        }
        return character;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Generate a unique UUID for modelID
        @synchronized([DSACharacter class]) {
            if (!characterRegistry) {
                characterRegistry = [NSMutableDictionary dictionary];
            }
            if (_modelID == nil)
              {
                _modelID = [NSUUID UUID]; // Use NSUUID for a truly unique ID
                NSLog(@"Generated modelID: %@", _modelID);
              }

            if (!characterRegistry[_modelID]) {
                characterRegistry[_modelID] = self; // Register the character
            } else {
                NSLog(@"Warning: modelID %@ already exists!", _modelID);
            }
        }

        // Initialize other properties
        _isMagic = NO;
        _armorBaseValue = 0;
        _enduranceBaseValue = 0;
        _attackBaseBaseValue = 0;
        _parryBaseBaseValue = 0;
        _isBlessedOne = NO;
        _isMagicalDabbler = NO;
        _element = nil;
        _religion = nil;
        _currentLocation = [[DSALocation alloc] init];
        _siblings = [[NSArray alloc] init];
        _childhoodEvents = [[NSArray alloc] init];
        _youthEvents = [[NSArray alloc] init];
        _inventory = [[DSAInventory alloc] init];
        _bodyParts = [[DSABodyParts alloc] init];
        _birthday = [[DSAAventurianDate alloc] init];
        _talents = [[NSMutableDictionary alloc] init];
        _currentTalents = [[NSMutableDictionary alloc] init];
        _professions = [[NSMutableDictionary alloc] init];
        _currentProfessions = [[NSMutableDictionary alloc] init];
        _spells = [[NSMutableDictionary alloc] init];
        _currentSpells = [[NSMutableDictionary alloc] init];
        _specials = [[NSMutableDictionary alloc] init];
        _currentSpecials = [[NSMutableDictionary alloc] init];
        _appliedSpells = [[NSMutableDictionary alloc] init];   // to be replaced by below appliedEffects
        _appliedEffects = [[NSMutableDictionary alloc] init];
        _statesDict = [NSMutableDictionary dictionaryWithDictionary: @{ @(DSACharacterStateWounded): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStateSick): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStatePoisoned): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStateDrunken): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStateDead): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStateUnconscious): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStateSpellbound): @(DSASeverityLevelNone),
                                                                        @(DSACharacterStateHunger): @(DSASeverityLevelMild),
                                                                        @(DSACharacterStateThirst): @(DSASeverityLevelMild),
                                                                      }
                      ];
        _receivedUniqueMiracles = [NSMutableSet set];
    }
    return self;
}

- (void)moveToLocation:(DSALocation *)newLocation {
    _currentLocation = newLocation;
    NSLog(@"%@ moved to %@", _name, newLocation.name ?: @"an unknown location");
}

- (void)setCurrentLifePoints: (NSInteger) lifePoints
{
  NSLog(@"setting lifePoints %ld", (signed long)lifePoints);
  _currentLifePoints = lifePoints;
  
  [self willChangeValueForKey:@"statesDict"];
  if (_currentLifePoints <= 0)
    {
      NSLog(@"DSACharacter setCurrentLifePoints: marking character as dead!");
      NSDictionary *userInfo = @{ @"severity": @(LogSeverityCritical),
                                  @"message": [NSString stringWithFormat: @"%@ ist ins reich Borons übergegangen.", self.name]
                                };
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];      
      //[self.statesDict setValue: @(DSASeverityLevelMild) forKeyPath: @"statesDict.DSACharacterStateDead"];
      [self.statesDict setObject: @(DSASeverityLevelMild) forKey: @(DSACharacterStateDead)];
      [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStateUnconscious)];
    }
  else if (_currentLifePoints < 5)
    {
      NSDictionary *userInfo = @{ @"severity": @(LogSeverityWarning),
                                  @"message": [NSString stringWithFormat: @"%@ ist in Ohnmacht gefallen.", self.name]
                                };
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];    
      [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStateDead)];
      [self.statesDict setObject: @(DSASeverityLevelMild) forKey: @(DSACharacterStateUnconscious)];
    }
  else
    {
      NSLog(@"DSACharacter setCurrentLifePoints to value >= 5");
      [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStateDead)];
      [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStateUnconscious)];
    }
  NSLog(@"DSACharacter setCurrentLifePoints before didChangeValueForKey");
  [self didChangeValueForKey:@"statesDict"];
  NSLog(@"DSACharacter setCurrentLifePoints after didChangeValueForKey");
  return;
}

- (void)dealloc
{
    NSLog(@"DSACharacter dealloc called");
    @synchronized([DSACharacter class]) {
        [characterRegistry removeObjectForKey:_modelID];
        NSLog(@"Character with modelID %@ removed from registry.", _modelID);
    }
}

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray<NSString *> *)types {
    openPanel.allowedFileTypes = @[@"dsac"];
    openPanel.allowsMultipleSelection = NO;
    NSURL *defaultDirectory = [Utils characterStorageDirectory];
    if (defaultDirectory) {
        openPanel.directoryURL = defaultDirectory;
    }
    if ([openPanel runModal] == NSModalResponseOK) {
        return NSModalResponseOK;
    }    
    return NSModalResponseCancel;
}

- (NSInteger)runModalSavePanel:(NSSavePanel *)savePanel withAccessoryView:(NSView *)accessoryView {
    // Set default directory
    NSURL *defaultDirectory = [Utils characterStorageDirectory];
    if (defaultDirectory) {
        savePanel.directoryURL = defaultDirectory;
    }
    if ([savePanel runModal] == NSModalResponseOK) {
        return NSModalResponseOK;
    }    
    return NSModalResponseCancel;
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];          
                      
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSACharacter *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}


// Since we use NSKeyedArchiver, and we use secure coding
// we have to support it with the following three methods
// BUT: GNUstep doesn't support the SecureCoding protocol yet :(
+ (BOOL)supportsSecureCoding
{
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.portraitName forKey:@"portraitName"];  
  [coder encodeObject:self.modelID forKey:@"modelID"];  
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.title forKey:@"title"];
  [coder encodeObject:self.archetype forKey:@"archetype"];
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeInteger:self.lifePoints forKey:@"lifePoints"];
  [coder encodeInteger:self.astralEnergy forKey:@"astralEnergy"];
  [coder encodeInteger:self.karmaPoints forKey:@"karmaPoints"];
  [coder encodeInteger:self.currentLifePoints forKey:@"currentLifePoints"];
  [coder encodeInteger:self.currentAstralEnergy forKey:@"currentAstralEnergy"];
  [coder encodeInteger:self.currentKarmaPoints forKey:@"currentKarmaPoints"];
  [coder encodeBool:self.isNPC forKey:@"isNPC"];
  [coder encodeBool:self.isMagic forKey:@"isMagic"];
  [coder encodeBool:self.isMagicalDabbler forKey:@"isMagicalDabbler"]; 
  [coder encodeBool:self.isBlessedOne forKey:@"isBlessedOne"];    
  [coder encodeInteger:self.mrBonus forKey:@"mrBonus"];
  [coder encodeInteger:self.currentMrBonus forKey:@"currentMrBonus"];
  [coder encodeInteger:self.armorBaseValue forKey:@"armorBaseValue"];
  [coder encodeInteger:self.enduranceBaseValue forKey:@"enduranceBaseValue"];
  [coder encodeInteger:self.attackBaseBaseValue forKey:@"attackBaseBaseValue"];
  [coder encodeInteger:self.parryBaseBaseValue forKey:@"parryBaseBaseValue"];  
  [coder encodeInteger:self.staticAttackBaseValue forKey:@"staticAttackBaseValue"];
  [coder encodeInteger:self.staticParryBaseValue forKey:@"staticParryBaseValue"];
  [coder encodeInteger:self.adventurePoints forKey:@"adventurePoints"];
  [coder encodeObject:self.origin forKey:@"origin"];
  [coder encodeObject:self.mageAcademy forKey:@"mageAcademy"];
  [coder encodeObject:self.element forKey:@"element"];
  [coder encodeObject:self.sex forKey:@"sex"];
  [coder encodeObject:self.hairColor forKey:@"hairColor"];
  [coder encodeObject:self.eyeColor forKey:@"eyeColor"];
  [coder encodeObject:@(self.height) forKey:@"height"];
  [coder encodeObject:@(self.weight) forKey:@"weight"];
  [coder encodeObject:self.birthday forKey:@"birthday"];
  [coder encodeObject:self.god forKey:@"god"];
  [coder encodeObject:self.stars forKey:@"stars"];
  [coder encodeObject:self.religion forKey:@"religion"];  
  [coder encodeObject:self.socialStatus forKey:@"socialStatus"];
  [coder encodeObject:self.parents forKey:@"parents"];
  [coder encodeObject:self.siblings forKey:@"siblings"];
  [coder encodeObject:self.birthPlace forKey:@"birthPlace"];    
  [coder encodeObject:self.birthEvent forKey:@"birthEvent"];
  [coder encodeObject:self.legitimation forKey:@"legitimation"];
  [coder encodeObject:self.childhoodEvents forKey:@"childhoodEvents"];
  [coder encodeObject:self.youthEvents forKey:@"youthEvents"];
  [coder encodeObject:self.wallet forKey:@"wallet"];
  [coder encodeObject:self.positiveTraits forKey:@"positiveTraits"];
  [coder encodeObject:self.negativeTraits forKey:@"negativeTraits"];
  [coder encodeObject:self.currentPositiveTraits forKey:@"currentPositiveTraits"];
  [coder encodeObject:self.currentNegativeTraits forKey:@"currentNegativeTraits"]; 
  [coder encodeObject:self.inventory forKey:@"inventory"];
  [coder encodeObject:self.bodyParts forKey:@"bodyParts"];
  [coder encodeObject:self.talents forKey:@"talents"];
  [coder encodeObject:self.currentTalents forKey:@"currentTalents"];
  [coder encodeObject:self.professions forKey:@"professions"];
  [coder encodeObject:self.currentProfessions forKey:@"currentProfessions"];
  [coder encodeObject:self.spells forKey:@"spells"];
  [coder encodeObject:self.currentSpells forKey:@"currentSpells"];
  [coder encodeObject:self.specials forKey:@"specials"];
  [coder encodeObject:self.currentSpecials forKey:@"currentSpecials"];
  [coder encodeInteger:self.firstLevelUpTalentTriesPenalty forKey:@"firstLevelUpTalentTriesPenalty"];  
  [coder encodeInteger:self.maxLevelUpTalentsTries forKey:@"maxLevelUpTalentsTries"];
  [coder encodeInteger:self.maxLevelUpSpellsTries forKey:@"maxLevelUpSpellsTries"];
  [coder encodeInteger:self.maxLevelUpTalentsTriesTmp forKey:@"maxLevelUpTalentsTriesTmp"];
  [coder encodeInteger:self.maxLevelUpSpellsTriesTmp forKey:@"maxLevelUpSpellsTriesTmp"];  
  [coder encodeInteger:self.maxLevelUpVariableTries forKey:@"maxLevelUpVariableTries"];  
  [coder encodeObject:self.appliedSpells forKey:@"appliedSpells"];
  [coder encodeObject:self.appliedEffects forKey:@"appliedEffects"];
  [coder encodeObject:self.statesDict forKey:@"statesDict"];
  [coder encodeObject:self.currentLocation forKey:@"currentLocation"];
  [coder encodeObject:self.receivedUniqueMiracles forKey:@"receivedUniqueMiracles"];
 }

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      _modelID = [coder decodeObjectOfClass:[NSString class] forKey:@"modelID"];
      if (!characterRegistry[_modelID]) {
          characterRegistry[_modelID] = self; // Register the character
      } else {
          NSLog(@"DSACharacter initWithCoder: Warning: modelID %@ already exists!", _modelID);
      }      
      NSLog(@"DSACharacter initWithcoder: registered modelID: %@", [_modelID UUIDString]);
      
      self.portraitName = [coder decodeObjectForKey:@"portraitName"];
      NSLog(@"DSACharacter portraitName: %@", self.portraitName);
      // Backward compatibility: convert .png to .webp if needed
      if ([self.portraitName hasSuffix:@".png"]) {
          self.portraitName = [[self.portraitName stringByDeletingPathExtension] stringByAppendingPathExtension:@"webp"];
      }
            
      self.name = [coder decodeObjectForKey:@"name"];
      self.title = [coder decodeObjectForKey:@"title"];
      self.archetype = [coder decodeObjectForKey:@"archetype"];
      self.level = [coder decodeIntegerForKey:@"level"];
      self.lifePoints = [coder decodeIntegerForKey:@"lifePoints"];
      self.astralEnergy = [coder decodeIntegerForKey:@"astralEnergy"];
      self.karmaPoints = [coder decodeIntegerForKey:@"karmaPoints"];
      self.currentLifePoints = [coder decodeIntegerForKey:@"currentLifePoints"];
      self.currentAstralEnergy = [coder decodeIntegerForKey:@"currentAstralEnergy"];
      self.currentKarmaPoints = [coder decodeIntegerForKey:@"currentKarmaPoints"];   
      self.mrBonus = [coder decodeIntegerForKey:@"mrBonus"];
      if ([coder containsValueForKey:@"currentMrBonus"]) {
        self.currentMrBonus = [coder decodeIntegerForKey:@"currentMrBonus"];
      } else {
        self.currentMrBonus = self.mrBonus; // Fallback für alte Versionen
      }
      self.armorBaseValue = [coder decodeIntegerForKey:@"armorBaseValue"];
      self.enduranceBaseValue = [coder decodeIntegerForKey:@"enduranceBaseValue"];
      self.attackBaseBaseValue = [coder decodeIntegerForKey:@"attackBaseBaseValue"];               
      self.parryBaseBaseValue = [coder decodeIntegerForKey:@"parryBaseBaseValue"];      
      self.staticAttackBaseValue = [coder decodeIntegerForKey:@"staticAttackBaseValue"];               
      self.staticParryBaseValue = [coder decodeIntegerForKey:@"staticParryBaseValue"];
      self.isNPC = [coder decodeBoolForKey:@"isNPC"];
      self.isMagic = [coder decodeBoolForKey:@"isMagic"];
      self.isMagicalDabbler = [coder decodeBoolForKey:@"isMagicalDabbler"];      
      self.isBlessedOne = [coder decodeBoolForKey:@"isBlessedOne"];      
      self.adventurePoints = [coder decodeIntegerForKey:@"adventurePoints"];
      self.origin = [coder decodeObjectForKey:@"origin"];
      self.mageAcademy = [coder decodeObjectForKey:@"mageAcademy"];
      self.element = [coder decodeObjectForKey:@"element"];
      self.sex = [coder decodeObjectForKey:@"sex"];
      self.hairColor = [coder decodeObjectForKey:@"hairColor"];
      self.eyeColor = [coder decodeObjectForKey:@"eyeColor"];
      self.height = [[coder decodeObjectForKey:@"height"] floatValue];
      self.weight = [[coder decodeObjectForKey:@"weight"] floatValue];
      self.birthday = [coder decodeObjectForKey:@"birthday"];
      self.god = [coder decodeObjectForKey:@"god"];
      self.stars = [coder decodeObjectForKey:@"stars"];
      self.religion = [coder decodeObjectForKey:@"religion"];      
      self.socialStatus = [coder decodeObjectForKey:@"socialStatus"];
      self.parents = [coder decodeObjectForKey:@"parents"];
      self.siblings = [coder decodeObjectForKey:@"siblings"];
      self.birthPlace = [coder decodeObjectForKey:@"birthPlace"];
      self.birthEvent = [coder decodeObjectForKey:@"birthEvent"];
      self.legitimation = [coder decodeObjectForKey:@"legitimation"];
      self.childhoodEvents = [coder decodeObjectForKey:@"childhoodEvents"];
      self.youthEvents = [coder decodeObjectForKey:@"youthEvents"];
      self.wallet = [coder decodeObjectForKey:@"wallet"];
      // first try to load the wallet value
      if ([coder containsValueForKey:@"wallet"]) {
          _wallet = [coder decodeObjectOfClass:[DSAWallet class] forKey:@"wallet"];
      }
      // Fallback: try old money NSDictionary and convert to wallet
      else if ([coder containsValueForKey:@"money"]) {
          NSDictionary *oldMoney = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"money"];
          _wallet = [[DSAWallet alloc] init];
          _wallet.kreuzer = [oldMoney[@"K"] integerValue];
          _wallet.heller  = [oldMoney[@"H"] integerValue];
          _wallet.silber  = [oldMoney[@"S"] integerValue];
          _wallet.dukaten = [oldMoney[@"D"] integerValue];
          [_wallet normalize];
      } else {
          // No money or wallet?
          _wallet = [[DSAWallet alloc] init];
      }      
      self.positiveTraits = [coder decodeObjectForKey:@"positiveTraits"];
      self.negativeTraits = [coder decodeObjectForKey:@"negativeTraits"];
      self.currentPositiveTraits = [coder decodeObjectForKey:@"currentPositiveTraits"];
      self.currentNegativeTraits = [coder decodeObjectForKey:@"currentNegativeTraits"];      
      self.inventory = [coder decodeObjectForKey:@"inventory"];
      self.bodyParts = [coder decodeObjectForKey:@"bodyParts"];
      self.talents = [coder decodeObjectForKey:@"talents"];
      self.currentTalents = [coder decodeObjectForKey: @"currentTalents"];
      if (!self.currentTalents || [self.currentTalents count] == 0)
        {
          self.currentTalents = (NSMutableDictionary<NSString *, DSATalent *> *)
                                 [self deepCopyDictionary:self.talents usingBlock:^id(id obj) {
            return [(DSATalent *)obj copy];
          }];
        } 
      self.professions = [coder decodeObjectForKey:@"professions"];
      self.currentProfessions = [coder decodeObjectForKey: @"currentProfessions"];
      if (!self.currentProfessions  || [self.currentProfessions count] == 0)
        {
          self.currentProfessions = (NSMutableDictionary<NSString *, DSAProfession *> *)
                                     [self deepCopyDictionary:self.professions usingBlock:^id(id obj) {
            return [(DSAProfession *)obj copy];
          }];
        }      
      self.spells = [coder decodeObjectForKey:@"spells"];
      self.currentSpells = [coder decodeObjectForKey: @"currentSpells"];
      NSLog(@"DSACharacter initWithCoder: spell: %@ currentSpell: %@", self.spells[@"Balsam Salabunde"], self.currentSpells[@"Balsam Salabunde"]);
      if (!self.currentSpells  || [self.currentSpells count] == 0)
        {
          self.currentSpells = (NSMutableDictionary<NSString *, DSASpell *> *)
                                [self deepCopyDictionary:self.spells usingBlock:^id(id obj) {
            return [(DSASpell *)obj copy];
          }];
        }  
      self.specials = [coder decodeObjectForKey:@"specials"];
      // The most specials are subclasses of DSASpell, but there's also DSALiturgy, which COULD? break here
      // in case of backward compatibility. BUT up to now, we don't yet have Liturgies we could have saved ;)
      self.currentSpecials = [coder decodeObjectForKey: @"currentSpecials"];
      if (!self.currentSpecials || [self.currentSpecials count] == 0)
        {
          self.currentSpecials = [self deepCopyDictionary:self.specials usingBlock:^id(id obj) {
            return [(DSASpell *)obj copy];
          }];
        }
      self.firstLevelUpTalentTriesPenalty = [coder decodeIntegerForKey:@"firstLevelUpTalentTriesPenalty"];            
      self.maxLevelUpTalentsTries = [coder decodeIntegerForKey:@"maxLevelUpTalentsTries"];
      self.maxLevelUpSpellsTries = [coder decodeIntegerForKey:@"maxLevelUpSpellsTries"];
      self.maxLevelUpTalentsTriesTmp = [coder decodeIntegerForKey:@"maxLevelUpTalentsTriesTmp"];
      self.maxLevelUpSpellsTriesTmp = [coder decodeIntegerForKey:@"maxLevelUpSpellsTriesTmp"];      
      self.maxLevelUpVariableTries = [coder decodeIntegerForKey:@"maxLevelUpVariableTries"];       
      self.appliedSpells = [coder decodeObjectForKey:@"appliedSpells"];
      self.appliedEffects = [coder decodeObjectForKey:@"appliedEffects"];
      if (!self.appliedEffects)
        {
          self.appliedEffects = [[NSMutableDictionary alloc] init];
        }
      self.statesDict = [coder decodeObjectForKey:@"statesDict"];
      self.currentLocation = [coder decodeObjectForKey:@"currentLocation"];
      self.receivedUniqueMiracles = [coder decodeObjectForKey:@"receivedUniqueMiracles"];
    }
  return self;
}


- (NSMutableDictionary<NSString *, id> *)deepCopyDictionary:(NSDictionary<NSString *, id> *)dict
                                                 usingBlock:(id (^)(id obj))copyBlock {
    NSMutableDictionary *copy = [NSMutableDictionary dictionary];
    for (NSString *key in dict) {
        id obj = dict[key];
        copy[key] = copyBlock(obj);
    }
    return copy;
}



// helper function to produce a string based on siblings.
- (NSString *)siblingsString
{
    NSString *pronoun = [self.sex isEqualToString:_(@"männlich")] ? @"Er" : @"Sie";
    NSString *genderWord = [self.sex isEqualToString:_(@"männlich")] ? @"der" : @"die";
    
    // If no siblings, return a simple message
    if ([self.siblings count] == 0) {
        return [NSString stringWithFormat:@"%@ hat keine Geschwister.", self.name];
    }
    
    // Initialize counters for siblings
    NSInteger olderBrothers = 0;
    NSInteger youngerBrothers = 0;
    NSInteger olderSisters = 0;
    NSInteger youngerSisters = 0;
    
    // Count the number of older/younger brothers and sisters
    for (NSDictionary *sibling in self.siblings) {
        NSString *age = sibling[@"age"];
        NSString *sex = sibling[@"sex"];
        
        if ([age isEqualToString:_(@"älter")]) {
            if ([sex isEqualToString:_(@"männlich")]) {
                olderBrothers++;
            } else {
                olderSisters++;
            }
        } else {  // "jünger"
            if ([sex isEqualToString:_(@"männlich")]) {
                youngerBrothers++;
            } else {
                youngerSisters++;
            }
        }
    }
    
    // Total number of children in the family
    NSInteger totalChildren = [self.siblings count] + 1;  // +1 to include the character
    NSInteger numberOfOlderSiblings = olderBrothers + olderSisters;
    NSInteger characterPosition = totalChildren - numberOfOlderSiblings;  // Position of the character among the siblings
    // Generate a detailed sibling description
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"%@ ist %@ %ldte von %ld Kindern. ", self.name, genderWord, (long)characterPosition, (long)totalChildren];
    
    NSMutableArray *siblingDescriptions = [NSMutableArray array];
    
    // Build the description based on the sibling counts
    if (olderBrothers > 0) {
        NSString *olderBrothersString = [NSString stringWithFormat:@"%ld ältere%@ Br%@der", (long)olderBrothers, olderBrothers > 1 ? @"" : @"n", olderBrothers > 1 ? @"ü" : @"u"];
        [siblingDescriptions addObject:olderBrothersString];
    }
    
    if (olderSisters > 0) {
        NSString *olderSistersString = [NSString stringWithFormat:@"%ld ältere Schwester%@", (long)olderSisters, olderSisters > 1 ? @"n" : @""];
        [siblingDescriptions addObject:olderSistersString];
    }
    
    if (youngerBrothers > 0) {
        NSString *youngerBrothersString = [NSString stringWithFormat:@"%ld jüngere%@ Br%@der", (long)youngerBrothers, youngerBrothers > 1 ? @"" : @"n", youngerBrothers > 1 ? @"ü" : @"u"];
        [siblingDescriptions addObject:youngerBrothersString];
    }
    
    if (youngerSisters > 0) {
        NSString *youngerSistersString = [NSString stringWithFormat:@"%ld jüngere Schwester%@", (long)youngerSisters, youngerSisters > 1 ? @"n" : @""];
        [siblingDescriptions addObject:youngerSistersString];
    }
    
    // Append the sibling description
    if ([siblingDescriptions count] > 0) {
        [resultString appendFormat:@"%@ hat %@.", pronoun, [siblingDescriptions componentsJoinedByString:@", "]];
    }    
    return resultString;
}

// Calculate load of carried items
- (float)load {
    float totalWeight = 0.0;
    NSMutableSet<DSAObject *> *countedItems = [NSMutableSet set]; // For multi-slot items
    
    // Add weight from the general inventory
    totalWeight += [self weightOfInventory:self.inventory countedItems:countedItems];
    
    // Add weight from each body part inventory
    for (NSString *inventoryName in self.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [self.bodyParts valueForKey:inventoryName];
        totalWeight += [self weightOfInventory:inventory countedItems:countedItems];
    }
    
    return totalWeight;
}

- (float)weightOfInventory:(DSAInventory *)inventory countedItems:(NSMutableSet<DSAObject *> *)countedItems {
    float totalWeight = 0.0;
//    NSLog(@"weightOfInventory before for loop: %@", inventory);
    for (DSASlot *slot in inventory.slots) {
        DSAObject *item = slot.object;
//        NSLog(@"weightOfInventory %@", item.name);
        if (!item) continue; // Skip empty slots
        
        if ([countedItems containsObject:item]) {
            continue; // Skip already-counted multi-slot items
        }
        
        // Add the item's weight, considering quantity
        if ([item isKindOfClass:[DSAObjectContainer class]]) {
            // For containers, include the weight of the container and its contents
            DSAObjectContainer *container = (DSAObjectContainer *)item;
//            NSLog(@"found a container: %@", container);
            totalWeight += (item.weight + [self weightOfContainer:container countedItems:countedItems]);
        } else {
            // Add the item's weight, multiplied by quantity for single-slot items
            totalWeight += item.weight * slot.quantity;
        }
        
        // If this is a multi-slot item, mark it as counted
        if (item.occupiedBodySlots.count > 0) {
            [countedItems addObject:item];
        }
    }
    
    return totalWeight;
}

- (float)weightOfContainer:(DSAObjectContainer *)container countedItems:(NSMutableSet<DSAObject *> *)countedItems {
    float totalWeight = 0.0;
//    NSLog(@"weightOfContainer %@ before for loop", container);

    // If the container has no slots, its weight is just the container itself
    if ([container.slots count] == 0) {
//        NSLog(@"weightOfContainer returning totalWeight: %f", totalWeight);
        return totalWeight;
    }

    // Iterate over the slots in the container
    for (DSASlot *slot in container.slots) { // Assuming `slots` is an array of `DSASlot`
        DSAObject *containedItem = slot.object; // Get the actual object in the slot
        if (!containedItem) {
            continue; // Skip empty slots
        }

//        NSLog(@"weightOfContainer inspecting item: %@", containedItem.name);

        if ([countedItems containsObject:containedItem]) {
            continue; // Skip already-counted items to avoid infinite recursion or double-counting
        }

        if ([containedItem isKindOfClass:[DSAObjectContainer class]]) {
            // Recursively calculate weight for nested containers
            DSAObjectContainer *nestedContainer = (DSAObjectContainer *)containedItem;
            totalWeight += (containedItem.weight + [self weightOfContainer:nestedContainer countedItems:countedItems]);
        } else {
            totalWeight += containedItem.weight;
        }

        // Mark the item as counted if it's a multi-slot item
        if (containedItem.occupiedBodySlots.count > 0) {
            [countedItems addObject:containedItem];
        }
    }

//    NSLog(@"weightOfContainer returning totalWeight: %f", totalWeight);
    return totalWeight;
}

- (float)encumbrance {
    float totalEncumbrance = 0.0;
    NSMutableSet<DSAObject *> *countedItems = [NSMutableSet set];

    // Iterate over body parts inventories
    for (NSString *propertyName in self.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [self.bodyParts valueForKey:propertyName];

        // Iterate through all slots in the body part inventory
        for (DSASlot *slot in inventory.slots) {
            DSAObject *item = slot.object;

            // Skip empty slots
            if (!item) {
                continue;
            }

            // Skip already-counted multi-slot items
            if ([countedItems containsObject:item]) {
                continue;
            }

            // Add the penalty value to the total if it exists
            if (item.penalty > 0) {
                totalEncumbrance += item.penalty;
            }

            // Mark multi-slot items as counted
            if (item.occupiedBodySlots.count > 0) {
                [countedItems addObject:item];
            }
        }
    }

    return totalEncumbrance;
}

- (float)armor {
    float totalArmor = 0.0 + self.armorBaseValue;
    NSMutableSet<DSAObject *> *countedItems = [NSMutableSet set];

    // Iterate over body parts inventories
    for (NSString *propertyName in self.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [self.bodyParts valueForKey:propertyName];

        // Iterate through all slots in the body part inventory
        for (DSASlot *slot in inventory.slots) {
            DSAObject *item = slot.object;

            // Skip empty slots
            if (!item) {
                continue;
            }

            // Skip already-counted multi-slot items
            if ([countedItems containsObject:item]) {
                continue;
            }

            // Add the penalty value to the total if it exists
            if (item.protection > 0) {
                totalArmor += item.protection;
            }

            // Mark multi-slot items as counted
            if (item.occupiedBodySlots.count > 0) {
                [countedItems addObject:item];
            }
        }
    }
    return roundf(totalArmor);
}


/* Calculate Endurance, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
// enduranceBaseValue added, due to character effects that may have an effect on endurance, i.e. illnesses
- (NSInteger) endurance {
  NSInteger retVal;

  retVal = self.lifePoints + [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue] + self.enduranceBaseValue;  
  return retVal;
}

/* calculate CarryingCapacity, as described in: Abenteuer Basis Spiel, Regelbuch II, S. 9 */
- (NSInteger) carryingCapacity {
  NSInteger retVal;
  NSLog(@"DSACharacter carryingCapacity currentPositiveTraits: %@", self.currentPositiveTraits);
  retVal = [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue] * 50;  
  return retVal;
}

- (NSInteger) attackBaseValue {
  NSInteger retVal;
  
  retVal = round(([[self.currentPositiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"GE.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 5);
  return retVal + self.attackBaseBaseValue;
}


- (NSInteger) parryBaseValue {
  NSInteger retVal;
  
  retVal = round(([[self.currentPositiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"GE.level"] integerValue] + 
                  [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 5);
  return retVal + self.parryBaseBaseValue;
}


- (NSInteger) rangedCombatBaseValue {
  NSInteger retVal;
  
  retVal = floor(([[self.currentPositiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"FF.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"KK.level"] integerValue]) / 4);
  return retVal;
}

- (NSInteger) dodge {
  NSInteger retVal;
  
  retVal = floor(([[self.currentPositiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"IN.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"GE.level"] integerValue]) / 4) - 
                 roundf(self.encumbrance);
  return retVal;
}

- (NSInteger) magicResistance {
  NSInteger retVal;
  
  retVal = floor(([[self.currentPositiveTraits valueForKeyPath: @"MU.level"] integerValue] + 
                 [[self.currentPositiveTraits valueForKeyPath: @"KL.level"] integerValue] +
                 self.level) / 3) - 2 * [[self.currentNegativeTraits valueForKeyPath: @"AG.level"] integerValue] +
                 self.currentMrBonus;
  return retVal;
}

- (NSImage *)portrait {
    // Dynamically load the portrait from the app bundle
    if (self.portraitName) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:self.portraitName ofType:nil];
        if (imagePath) {
            return [[NSImage alloc] initWithContentsOfFile:imagePath];
        }
    }
    return nil; // Return nil if the portraitName or imagePath is invalid
}

- (DSARegenerationResult *) sleepForHours: (NSInteger) hours
                             sleepQuality: (DSASleepQuality) quality
{
  DSARegenerationResult *result = nil;
  if (hours >= 8)
    {
      if ([self canRegenerate])
        {
          result = [self regenerateBaseEnergiesForHours: hours
                                           sleepQuality: quality];
          NSString *message = [self regenerationSummaryForResult: result];
          if (message)
            {
              NSDictionary *userInfo = @{ @"severity": @(LogSeverityInfo),
                                           @"message": message
                                    };
              [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                  object: self
                                                                userInfo: userInfo];          
            }
        }
    }
  return result;
}

- (NSString *)regenerationSummaryForResult:(DSARegenerationResult *)regenResult {
    if (regenResult.result == DSARegenerationResultFailure) {
        return [NSString stringWithFormat:@"%@ kann nichts regenerieren.", self.name];
    }
    
    if (regenResult.result != DSARegenerationResultSuccess) {
        return nil; // oder eine leere Zeichenkette, je nach Bedarf
    }
    
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (regenResult.regenLE > 0) {
        [parts addObject:[NSString stringWithFormat:@"%ld LE", (long)regenResult.regenLE]];
    }
    if (regenResult.regenAE > 0) {
        [parts addObject:[NSString stringWithFormat:@"%ld AE", (long)regenResult.regenAE]];
    }
    if (regenResult.regenKE > 0) {
        [parts addObject:[NSString stringWithFormat:@"%ld KE", (long)regenResult.regenKE]];
    }
    
    if (parts.count == 0) {
        return [NSString stringWithFormat:@"%@ regeneriert nichts.", self.name];
    }

    NSString *joined = [parts componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"%@ regeneriert %@.", self.name, joined];
}


- (BOOL) isDeadOrUnconscious
{
  if ([[self.statesDict objectForKey: @(DSACharacterStateDead)] integerValue] > 0 ||
      [[self.statesDict objectForKey: @(DSACharacterStateUnconscious)] integerValue] > 0)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (BOOL) isDead
{
  if ([[self.statesDict objectForKey: @(DSACharacterStateDead)] integerValue] > 0)
    {
      NSLog(@"DSACharacter isDead: YES");
      return YES;
    }
  else
    {
      NSLog(@"DSACharacter isDead: NO");    
      return NO;
    }
}

- (BOOL) isIll
{
  if ([[self.statesDict objectForKey: @(DSACharacterStateSick)] integerValue] > 0)
    {
      NSLog(@"DSACharacter isIll: YES");
      return YES;
    }
  else
    {
      NSLog(@"DSACharacter isIll: NO");    
      return NO;
    }
}

- (BOOL) isPoisoned
{
  if ([[self.statesDict objectForKey: @(DSACharacterStatePoisoned)] integerValue] > 0)
    {
      NSLog(@"DSACharacter isPoisoned: YES");
      return YES;
    }
  else
    {
      NSLog(@"DSACharacter isPoisoned: NO");    
      return NO;
    }
}

- (DSAIllnessEffect *) activeIllnessEffect
{
  for (NSString *key in [self.appliedEffects allKeys])
    {
      if ([key hasPrefix:@"Illness_"])
        {
          DSAIllnessEffect *illnessEffect = (DSAIllnessEffect*)[self.appliedEffects objectForKey: key];
          if ([illnessEffect currentStage] == DSAIllnessStageIncubation || [illnessEffect currentStage] == DSAIllnessStageChronicInactive)
            {
              continue;
            }
          return illnessEffect;
        }
    }
  return nil;
}

- (DSAPoisonEffect *) activePoisonEffect
{
  for (NSString *key in [self.appliedEffects allKeys])
    {
      if ([key hasPrefix:@"Poison_"])
        {
          DSAPoisonEffect *poisonEffect = (DSAPoisonEffect*)[self.appliedEffects objectForKey: key];
          if ([poisonEffect currentStage] == DSAPoisonStageApplied)
            {
              continue;
            }
          return poisonEffect;
        }
    }
  return nil;
}

- (BOOL) canUseItem: (DSAObject *) item
{
  if ([self isDeadOrUnconscious])
    {
      return NO;
    }
  return YES;
}

// character regeneration related methods
- (BOOL) canRegenerate
{
  if ([self isDeadOrUnconscious])  // even when Unconscious can't regenerate
    {
      return NO;
    }

  NSLog(@"DSACharacter canRegenerate called, TO BE ENHANCED!!!");
  if ((self.isMagic && self.currentAstralEnergy < self.astralEnergy) ||
      (self.isBlessedOne && self.currentKarmaPoints < self.karmaPoints) ||
      self.currentLifePoints < self.lifePoints)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (DSARegenerationResult *)regenerateBaseEnergiesForHours:(NSInteger)hours
                                             sleepQuality:(DSASleepQuality)quality
{
    DSARegenerationResult *result = [[DSARegenerationResult alloc] init];
    
    NSInteger regenLE = 0;
    NSInteger regenKE = 0;
    NSInteger regenAE = 0;

    if (hours < 6) {
        result.regenLE = regenLE;
        result.regenKE = regenKE;
        result.regenAE = regenAE;
        result.result = DSARegenerationResultTimeTooShort;
        return result;
    }

    NSInteger mod = [self regenerationModifierForSleepQuality:quality]; // 🔹 hier
    
    if (self.currentLifePoints < self.lifePoints) {
        regenLE = [Utils rollDice:@"1W6"] + mod;
        regenLE = MAX(regenLE, 0); // nie negativ
        NSInteger diff = self.lifePoints - self.currentLifePoints;
        regenLE = MIN(regenLE, diff);
        self.currentLifePoints += regenLE;
        result.regenLE = regenLE;
    }

    if (self.isMagic && self.currentAstralEnergy < self.astralEnergy) {
        regenAE = [Utils rollDice:@"1W6"] + mod;
        regenAE = MAX(regenAE, 0);
        NSInteger diff = self.astralEnergy - self.currentAstralEnergy;
        regenAE = MIN(regenAE, diff);
        self.currentAstralEnergy += regenAE;
        result.regenAE = regenAE;
    }

    if (self.isBlessedOne && self.currentKarmaPoints < self.karmaPoints) {
        regenKE = [Utils rollDice:@"1W6"] + mod;
        regenKE = MAX(regenKE, 0);
        NSInteger diff = self.karmaPoints - self.currentKarmaPoints;
        regenKE = MIN(regenKE, diff);
        self.currentKarmaPoints += regenKE;
        result.regenKE = regenKE;
    }

    result.result = DSARegenerationResultSuccess;
    return result;
}

- (NSInteger)regenerationModifierForSleepQuality:(DSASleepQuality)quality {
    switch (quality) {
        case DSASleepQualityTerrible: return -1;
        case DSASleepQualityLousy: return 0;
        case DSASleepQualityMediocre: return 0;
        case DSASleepQualityNormal: return 1;
        case DSASleepQualityGood: return 2;
        case DSASleepQualityExcellent: return 3;
        case DSASleepQualityUnknown: return 0;
    }
    return 0;
}

// end of character regeneration related methods

// talent usage related methods
- (BOOL) canUseTalents
{
  NSLog(@"DSACharacter canUseTalent called, TO BE ENHANCED!!!");
  if ([self isDeadOrUnconscious])
    {
      return NO;
    }  
  return YES;
}

- (BOOL) canUseTalentWithName: (NSString *) name
{
  NSLog(@"DSACharacter canUseTalentWithName called, TO BE ENHANCED!!!");
  if ([self isDeadOrUnconscious])
    {
      return NO;
    } 
     
  if (self.talents && self.talents[name])
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (NSArray <DSATalent *>*) activeTalentsWithNames: (NSArray <NSString *>*) names
{
   NSMutableArray *talents = [[NSMutableArray alloc] init];
   for (NSString *name in names)
     {
       if (self.currentTalents[name] && [self canUseTalentWithName: name])
         {
           [talents addObject: self.talents[name]];
         }
     }
   return talents;
}
- (NSArray <DSASpell *>*) activeSpellsWithNames: (NSArray <NSString *>*) names
{
   NSMutableArray *spells = [[NSMutableArray alloc] init];
   for (NSString *name in names)
     {
       if (self.currentSpells[name] && [self canCastSpellWithName: name])
         {
           [spells addObject: self.spells[name]];
         }
     }
   return spells;
}
- (NSArray <DSASpell *>*) activeRitualsWithNames: (NSArray <NSString *>*) names
{
   NSLog(@"DSACharacter activeRitualsWithNames %@ called", names);
   NSMutableArray *rituals = [[NSMutableArray alloc] init];
   NSLog(@"DSACharacter activeRitualsWithNames checking specials: %@", self.specials);
   for (NSString *name in names)
     {
       NSLog(@"DSACharacter activeRitualsWithNames testing ritual: %@", name);
       if (self.currentSpecials[name] && [self canCastRitualWithName: name])
         {
           [rituals addObject: self.specials[name]];
         }
     }
   return rituals;
}

- (DSATalentResult *) useTalent: (NSString *) talentName withPenalty: (NSInteger) penalty
{
  NSLog(@"DSACharacter useTalent called");
  DSATalentResult *talentResult = [[DSATalentResult alloc] init];
  DSATalent *talent = self.currentTalents[talentName];
  NSInteger level = talent.level - penalty;
  NSInteger initialLevel = level;
  NSMutableArray *resultsArr = [[NSMutableArray alloc] init];
  NSInteger oneCounter = 0;
  NSInteger twentyCounter = 0;
  BOOL earlyFailure = NO;
  NSInteger counter = 0;
  for (NSString *trait in talent.test)
    {
      NSInteger traitLevel = [[self.positiveTraits objectForKey: trait] level];
      NSInteger result = [Utils rollDice: @"1W20"];
      [resultsArr addObject: @{ @"trait": trait, @"result": @(result) }];
              
      if (result == 1)
        {
          oneCounter += 1;
        }
      else if (result == 20)
        {
          twentyCounter += 1;
        }
      if (initialLevel >= 0)
        {
          NSLog(@"%@ initial Level > 0 current Level: %ld", trait, (signed long) level);
          if (result <= traitLevel)  // potential failure, but we may have enough talent
            {
              NSLog(@"result was <= traitLevel");
            }
          else
            {
              NSLog(@"result was > traitLevel");
              level = level - (result - traitLevel);
              if (level < 0)
                {
                  earlyFailure = YES;
                }                      
            }
        }
       else  // initialLevel < 0
        {
           NSLog(@"%@ initial Level < 0 current Level: %ld", trait, (signed long) level);
          if (result <= traitLevel)
            {
              NSLog(@"result was <= traitLevel");
              level = level + (traitLevel - result);
              if (level < 0 && counter == 2)
                {
                   NSLog(@"setting early failure becaue counter == 2");
                   earlyFailure = YES;
                }
            }
           else
            {
              NSLog(@"result was > traitLevel");
              earlyFailure = YES;
            }
        }
      counter += 1;        
    }
  if (oneCounter >= 2)
    {
      if (oneCounter == 2)
        {
           talentResult.result = DSAActionResultAutoSuccess;
           talentResult.remainingTalentPoints = level;
        }
      else
        {
           talentResult.result = DSAActionResultEpicSuccess;
           talentResult.remainingTalentPoints = level;
        }
    }
  else if (twentyCounter >= 2)
    {
      if (twentyCounter == 2)
        {
           talentResult.result = DSAActionResultAutoFailure;
           talentResult.remainingTalentPoints = level;
        }
      else
       {
          talentResult.result = DSAActionResultEpicFailure;
          talentResult.remainingTalentPoints = level;
       }              
    }
  else
    {
      if (earlyFailure == YES)
        {
           talentResult.result = DSAActionResultFailure;
           talentResult.remainingTalentPoints = level;                                    
        }
      else
        {
           talentResult.result = DSAActionResultSuccess;
           talentResult.remainingTalentPoints = level;                
        }
    }
  talentResult.diceResults = resultsArr;
  
  return talentResult;
}
// end of talent usage related methods

// casting spells related methods
- (BOOL) canCastSpells
{
  NSLog(@"DSACharacter canCastSpell called, TO BE ENHANCED!!!");
  if ([self isDeadOrUnconscious])
    {
      return NO;
    }  
  if (self.spells)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}
- (BOOL) canCastSpellWithName: (NSString *) name
{
  NSLog(@"DSACharacter canCastSpellWithName called, TO BE ENHANCED!!!");
  if ([self isDeadOrUnconscious])
    {
      return NO;
    } 
  NSLog(@"DSACharacter canCastSpellWithName %@ is alive", self.name);   
  if (self.spells && self.spells[name])
    {
      NSLog(@"DSACharacter canCastSpellWithName: %@ has spell with name: %@", self.name, name); 
      if (self.spells[name].isActiveSpell)
        {
           return YES;
        }
      else
        {
          return NO;
        }
    }
  else
    {
      NSLog(@"DSACharacter canCastSpellWithName: %@ NO", name);
      return NO;
    }
}

- (DSASpellResult *) castSpell: (DSASpell *) spell 
                     ofVariant: (nullable NSString *) variant
             ofDurationVariant: (nullable NSString *) durationVariant
                      onTarget: (DSACharacter *) targetCharacter 
                    atDistance: (NSInteger) distance
                   investedASP: (NSInteger) investedASP 
              currentAdventure: (DSAAdventure *) adventure                   
          spellOriginCharacter: (nullable DSACharacter *) originCharacter
{
  NSLog(@"DSACharacter castSpell called!!!");
  DSASpellResult *spellResult;
  if (!self.currentSpells[spell.name])
    {
      spellResult = [[DSASpellResult alloc] init];
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ hat den Spruch %@ doch gar nicht in seinem Repertoire", self.name, spell.name];
      return spellResult;
    }
  spellResult = [spell castOnTarget: targetCharacter
                          ofVariant: (NSString *) variant
                  ofDurationVariant: (NSString *) durationVariant
                         atDistance: distance
                        investedASP: investedASP 
                   currentAdventure: adventure
               spellOriginCharacter: originCharacter
              spellCastingCharacter: self];
  return spellResult;
}          
// end of casting spells related methods

// casting rituals related methods
- (BOOL) canCastRituals
{
  NSLog(@"DSACharacter canCastRituals called, TO BE ENHANCED!!!");
  if ([self isDeadOrUnconscious])
    {
      return NO;
    }
      
  if (self.specials)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (BOOL) canCastRitualWithName: (NSString *) name
{
  NSLog(@"DSACharacter canCastRitualWithName: %@", name);
  if ([self isDeadOrUnconscious])
    {
      return NO;
    }
  NSLog(@"DSACharacter canCastRitualWithName: %@ is not dead or unconscious", name);  
  if (self.specials && self.specials[name])
    {
      //NSLog(@"DSACharacter canCastRitualWithName: self.specials: %@", self.specials);
      DSASpell *ritual = [self.specials objectForKey: name];
      //NSLog(@"DSACharacter canCastRitualWithName: the ritual: %@", ritual);
      if (ritual)
        {
          if (ritual.aspCost > 0 && ritual.aspCost > self.currentAstralEnergy)
            {
              NSLog(@"DSACharacter canCastRitualWithName: %@ not enough AE", name);
              return NO;
            }
          if ([ritual isKindOfClass: [DSASpellMageRitual class]])
            { 
              DSAObject *target;          
              if ([ritual.category isEqualToString: _(@"Stabzauber")])
                {
                  target = [[DSAInventoryManager sharedManager] findItemWithName: _(@"Magierstab") inModel: self];
                }
              else if ([ritual.category isEqualToString: _(@"Schwertzauber")])
                {
                  target = [[DSAInventoryManager sharedManager] findItemWithName: _(@"Magierschwert") inModel: self];
                }
              else if ([ritual.category isEqualToString: _(@"Kugelzauber")])
                {
                  target = [[DSAInventoryManager sharedManager] findItemWithName: _(@"Kristallkugel") inModel: self];
                  NSLog(@"DSACharacter canCastRitualWithName: %@ found target!", name);
                }
              else if ([ritual.category isEqualToString: _(@"Schalenzauber")])
                {
                  target = [[DSAInventoryManager sharedManager] findItemWithName: _(@"Magierschale") inModel: self];
                  NSLog(@"DSACharacter canCastRitualWithName: %@ found target %@!", name, target);
                }
              if (!target) // we don't have a relevant target object in our inventory                            
                {
                  return NO;
                }
              if ([target.appliedSpells objectForKey: name])  // the spell is already applied on the target
                {
                  return NO;
                }               
              NSString *pattern = @"^([0-9])";
              NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                     options:0
                                                                                       error:nil];
              NSRange range = NSMakeRange(0, name.length);   
              NSTextCheckingResult *match = [regex firstMatchInString:name options:0 range:range];
              if (match)
                {
                  NSLog(@"IN MATCH");
                  NSRange matchRange = [match rangeAtIndex:1];
                  NSString *matchedNumber = [name substringWithRange:matchRange];
                  if ([matchedNumber isEqualToString: @"1"])  // Some spells have to be given in order, whereas the first one 
                    {                                         // makes the object a personal object
                      return YES;
                    }
                  else
                    {
                      if (![self.modelID isEqual: target.ownerUUID])  // higher order spells should only be applied to spells where we're owner of
                        {
                          return NO;
                        }
                      if ([target.name isEqualToString: _(@"Magierstab")] && [target.states containsObject: @(DSAObjectStateNoMoreStabzauber)])  // Stabzauber 5 can go wrong and prevent any further Stabzauber
                        {
                          return NO;
                        }
                      NSInteger decrementedNumber = [matchedNumber integerValue] - 1;
                      NSString *replacementString = [NSString stringWithFormat:@"%ld", (long)decrementedNumber];
                      NSString *resultString = [regex stringByReplacingMatchesInString:name
                                                                               options:0
                                                                                 range:range
                                                                          withTemplate:replacementString];
                      if (![target.appliedSpells objectForKey: resultString])  // check if the previous ordered spell is already applied
                        {
                          return NO;
                        }                                                                          
                    }
                  return YES;
                }
              else              
                {
                  NSLog(@"HERE IN ELSE of if (match), returning YES");
                  return YES;
                }
            }
          else if ([ritual isKindOfClass: [DSASpellDruidRitual class]])
            { 
              NSLog(@"DSACharacter canCastRitualWithName: %@ we have a DruidRitual", name);
              DSAObject *target;          
              if ([ritual.category isEqualToString: _(@"Dolchritual")])
                {
                  NSLog(@"DSACharacter canCastRitualWithName: %@ we have a Dolchritual", name);
                  target = [[DSAInventoryManager sharedManager] findItemWithName: _(@"Vulkanglasdolch") inModel: self];
                  if (!target) // we don't have a relevant target object in our inventory                            
                    {
                      NSLog(@"SELF CHARACTER: %@", self);
                      NSLog(@"DSACharacter canCastRitualWithName: %@ didn't find a Vulkanglasdolch.", name);
                      return NO;
                    }
                  if ([target.appliedSpells objectForKey: name])  // the spell is already applied on the target
                    {
                      NSLog(@"DSACharacter canCastRitualWithName: %@ is already applied on target!", name);
                      return NO;
                    }          
                  NSString *pattern = @"^([0-9])";
                  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                         options:0
                                                                                           error:nil];
                  NSRange range = NSMakeRange(0, name.length);   
                  NSTextCheckingResult *match = [regex firstMatchInString:name options:0 range:range];
                  if (match)
                    {
                      NSLog(@"IN MATCH Druidenritual");
                      NSRange matchRange = [match rangeAtIndex:1];
                      NSString *matchedNumber = [name substringWithRange:matchRange];
                      if ([matchedNumber isEqualToString: @"1"])  // Some spells have to be given in order, whereas the first one 
                        {                                         // makes the object a personal object
                          return YES;
                        }
                      else
                        {
                          if (![self.modelID isEqual: target.ownerUUID])  // higher order spells should only be applied to spells where we're owner of
                            {
                              return NO;
                            }
                          NSInteger decrementedNumber = [matchedNumber integerValue] - 1;
                          NSString *replacementString = [NSString stringWithFormat:@"%ld", (long)decrementedNumber];
                          NSString *resultString = [regex stringByReplacingMatchesInString:name
                                                                                   options:0
                                                                                     range:range
                                                                              withTemplate:replacementString];
                          if (![target.appliedSpells objectForKey: resultString])  // check if the previous ordered spell is already applied
                            {
                              return NO;
                            }                                                                          
                        }
                      return YES;
                  }
                else              
                  {
                    NSLog(@"HERE IN ELSE of if (match), returning YES");
                    return YES;
                  }                             
                }
              else
                {
                  NSLog(@"DSACharacter canCastRitualWithName: %@ we DO NOT have a Dolchritual", name);                
                }
              

            }    
          return YES;
        }
      else
        {
          // we didn't find the ritual we were looking for
          NSLog(@"DSACharacter: can't find ritual: %@", name);
          return NO;
        }
    }
  else
    {
      NSLog(@"HERE IN ELSE of if (self.specials), returning NO");
      return NO;
    }
}

- (DSASpellResult *) castRitual: (NSString *) ritualName
                      ofVariant: (NSString *) variant
              ofDurationVariant: (NSString *) durationVariant
                       onTarget: (id) target
                     atDistance: (NSInteger) distance
                    investedASP: (NSInteger) investedASP 
               currentAdventure: (DSAAdventure *) adventure                    
           spellOriginCharacter: (DSACharacter *) originCharacter
{
  NSLog(@"DSACharacter castRitual called for ritual name: %@ !!!", ritualName);

  DSASpell *spell = [self.currentSpecials objectForKey: ritualName];
  NSLog(@"DSACharacter castRitual: self.specials: %@", self.specials);
  NSLog(@"DSACharacter castRitual: self.currentSpecials: %@", self.currentSpecials); 
  NSLog(@"DSACharacter castRitual: the ritual: %@", spell);
  DSASpellResult *spellResult = [spell castOnTarget: target
                                          ofVariant: variant
                                  ofDurationVariant: durationVariant
                                         atDistance: distance
                                        investedASP: investedASP
                                   currentAdventure: adventure
                               spellOriginCharacter: originCharacter
                              spellCastingCharacter: self];

  return spellResult;
}          
// end of casting spells related methods

// Consume items, i.e. eat or drink
- (BOOL) consumeItem: (DSAObject *) item
{
  BOOL retval = NO;
  
  if ([item isKindOfClass: [DSAObjectFood class]])
    {
      DSAObjectFood *food = (DSAObjectFood *) item;
        
      if ([food.subCategory isEqualToString: _(@"Getränke")])
        {
          if (food.isAlcohol)
            {
              DSATalentResult *tresult = [self useTalent: @"Zechen"
                                             withPenalty: food.alcoholLevel];
              if (tresult.result == DSAActionResultFailure ||
                  tresult.result == DSAActionResultAutoFailure || 
                  tresult.result == DSAActionResultEpicFailure)
                {
                  NSInteger newDrunkenState = [[self.statesDict objectForKey: @(DSACharacterStateDrunken)] integerValue] + 1;
                  [self updateStatesDictState: @(DSACharacterStateDrunken)
                                    withValue: @(newDrunkenState)];
                }
            }
          CGFloat newThirst = [[self.statesDict objectForKey: @(DSACharacterStateThirst)] floatValue] + food.nutritionValue;
          NSLog(@"DSACharacter consumeItem: oldThirst %f newThirst %f", 
                  [[self.statesDict objectForKey: @(DSACharacterStateThirst)] floatValue], 
                  newThirst);
          [self updateStatesDictState: @(DSACharacterStateThirst)
                            withValue: @(newThirst)];
        }
      else
        {
          CGFloat newHunger = [[self.statesDict objectForKey: @(DSACharacterStateHunger)] floatValue] + food.nutritionValue;
          NSLog(@"DSACharacter consumeItem: oldHunger %f newHunger %f", 
                  [[self.statesDict objectForKey: @(DSACharacterStateHunger)] floatValue], 
                  newHunger);
          
          
          [self updateStatesDictState: @(DSACharacterStateHunger)
                            withValue: @(newHunger)];
        }
      retval = YES;
    }
  else
    {
      NSDictionary *userInfo = @{ @"severity": @(LogSeverityInfo),
                                   @"message": [NSString stringWithFormat: @"%@ kann man doch garnicht konsumieren.", item.name]
                                };
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];
    }
  return retval;
}


- (void) updateStatesDictState: (NSNumber *) DSACharacterState
                     withValue: (NSNumber *) value
{
  NSLog(@"DSACharacter updateStatesDictState %@ called with value: %@", DSACharacterState, value);
  switch ([DSACharacterState integerValue])
    {
      case DSACharacterStateHunger: 
        [self updateStateHungerWithValue: value];
        break;
      case DSACharacterStateThirst: 
        [self updateStateThirstWithValue: value];
        break;     
      case DSACharacterStateWounded: 
        [self updateStateWoundedWithValue: value];        
        break;    
      case DSACharacterStateSick: 
        [self updateStateSickWithValue: value];        
        break;    
      case DSACharacterStatePoisoned: 
        [self updateStatePoisonedWithValue: value];        
        break;                        
      case DSACharacterStateDrunken: 
        [self updateStateDrunkenWithValue: value];        
        break;
      case DSACharacterStateUnconscious: 
        [self updateStateUnconsciousWithValue: value
                                   withReason: nil];        
        break;  
      case DSACharacterStateDead: 
        [self updateStateDeadWithValue: value
                            withReason: nil]; 
        break; 
      case DSACharacterStateSpellbound: 
        [self updateStateSpellboundWithValue: value
                                  withReason: nil];                                   
        break;              
      default:
        NSLog(@"DSACharacter updateStatesDictState don't know how to handle state: %@", DSACharacterState);
    }
}                    

- (BOOL) hasAppliedCharacterEffectWithKey: (NSString *)key
{
  return [[self.appliedEffects allKeys] containsObject: key];
}

- (DSACharacterEffect *) appliedCharacterEffectWithKey: (NSString *) key
{
  return [self.appliedEffects objectForKey: key];
}

- (void)addEffect:(DSACharacterEffect *)effect
{
  [self.appliedEffects setObject: effect forKey: effect.uniqueKey];
}

- (BOOL) applyIllnessEffect: (DSAIllnessEffect *) illnessEffect
{
  NSLog(@"DSACharacter applyIllnessEffect called, illnessEffect: %@", illnessEffect);
  NSLog(@"DSACharacter applyIllnessEffect appliedEffects BEFORE: %@", self.appliedEffects);
  if ([[self.appliedEffects allKeys] containsObject: illnessEffect.uniqueKey])
    {
      NSLog(@"DSACharacter applyIllnessEffect: illness %@ already applied, skipping", illnessEffect.uniqueKey);
      return NO;
    }  
  [self.appliedEffects setObject: illnessEffect forKey: illnessEffect.uniqueKey];
  NSLog(@"DSACharacter applyIllnessEffect appliedEffects AFTER: %@", self.appliedEffects);
  return YES;
}

- (BOOL) applyPoisonEffect: (DSAPoisonEffect *) poisonEffect
{
  NSLog(@"DSACharacter applyPoisonEffect called, illnessEffect: %@", poisonEffect);
  NSLog(@"DSACharacter applyPoisonEffect appliedEffects BEFORE: %@", self.appliedEffects);
  if ([[self.appliedEffects allKeys] containsObject: poisonEffect.uniqueKey])
    {
      NSLog(@"DSACharacter applyPoisonEffect: poison %@ already applied, skipping", poisonEffect.uniqueKey);
      return NO;
    }
  [self.appliedEffects setObject: poisonEffect forKey: poisonEffect.uniqueKey];
  NSLog(@"DSACharacter applyPoisonEffect appliedEffects AFTER: %@", self.appliedEffects);
  return YES;
}

- (BOOL) applyMiracleEffect: (DSAMiracleResult *) miracleResult
{
  NSLog(@"DSACharacter applyMiracleEffect called!!!");
  BOOL applied = NO;
  switch (miracleResult.type) {
    case DSACharacterEffectTypeSatiation: {
      [self updateStatesDictState: [NSNumber numberWithInteger: DSACharacterStateHunger]
                        withValue: [NSNumber numberWithFloat: 1.0]];
      [self updateStatesDictState: [NSNumber numberWithInteger: DSACharacterStateThirst]
                        withValue: [NSNumber numberWithFloat: 1.0]];
      applied = YES;
      break;
    }
    case DSACharacterEffectTypeHeal: {
      NSInteger heal = [[miracleResult.statChanges objectForKey: @"LE"] integerValue];
      if (self.currentLifePoints < self.lifePoints)
        {
          self.currentLifePoints = MIN(self.lifePoints, self.currentLifePoints + heal);
          applied = YES;
        }
      break;
    }
    case DSACharacterEffectTypeNightPeace: {
      DSACharacterEffect *effect = [[DSACharacterEffect alloc] init];
      effect.uniqueKey = miracleResult.uniqueKey;
      effect.effectType = miracleResult.type;
      effect.expirationDate = miracleResult.expirationDate;
      [self.appliedEffects setObject: effect forKey: effect.uniqueKey];
      break;
    }
    case DSACharacterEffectTypeRevive: {
      [self updateStatesDictState: [NSNumber numberWithInteger: DSACharacterStateDead]
                        withValue: [NSNumber numberWithInteger: DSASeverityLevelNone]];
      self.currentLifePoints = 10;        // all should have more LE than 10
      applied = YES;
      break;    
    }
    case DSACharacterEffectTypeTraitBoost: {
      BOOL extendOnly = NO;
      if (miracleResult.expirationDate)
        {
          DSACharacterEffect *effect = [[DSACharacterEffect alloc] init];
          effect.effectType = miracleResult.type;
          effect.uniqueKey = miracleResult.uniqueKey;
          effect.expirationDate = miracleResult.expirationDate;
          effect.reversibleChanges = miracleResult.statChanges;
          if ([[self.appliedEffects allKeys] containsObject: miracleResult.uniqueKey])
            {
              extendOnly = YES;  // basically only want to extend the expiration date, values are already applied
            }
          [self.appliedEffects setObject: effect forKey: effect.uniqueKey];
        }
      if (!extendOnly)
        {
          for (NSString *key in miracleResult.statChanges)
            {
              if (self.currentPositiveTraits[key])
                {
                  self.currentPositiveTraits[key].level += [miracleResult.statChanges[key] integerValue];
                  continue;
                }
              else if (self.currentNegativeTraits[key])
                {
                  self.currentNegativeTraits[key].level += [miracleResult.statChanges[key] integerValue];
                  continue;
                }
              else
                {
                  NSLog(@"DSACharacter applyMiracleEffect DSAMiracleResultTypeTraitBoost Trait %@ not found", key);
                }
            }
        }
    }
    case DSACharacterEffectTypeMRBoost: {
      BOOL extendOnly = NO;
      if (miracleResult.expirationDate)
        {
          DSACharacterEffect *effect = [[DSACharacterEffect alloc] init];
          effect.effectType = miracleResult.type;
          effect.uniqueKey = miracleResult.uniqueKey;
          effect.expirationDate = miracleResult.expirationDate;
          effect.reversibleChanges = miracleResult.statChanges;
          if ([[self.appliedEffects allKeys] containsObject: miracleResult.uniqueKey])
            {
              extendOnly = YES;  // basically only want to extend the expiration date, values are already applied
            }          
          [self.appliedEffects setObject: effect forKey: effect.uniqueKey];
        }
      if (!extendOnly)
        {
          self.currentMrBonus += [miracleResult.statChanges[@"MR"] integerValue];
        }
    }
    case DSACharacterEffectTypeRemoveCurse: {
      NSLog(@"DSACharacter applyMiracleEffect of type: DSAMiracleResultTypeRemoveCurse not yet supported, have to support being cursed first (:");
    }
    case DSACharacterEffectTypeTalentBoost: {
      BOOL extendOnly = NO;
      if (miracleResult.expirationDate)
        {
          DSACharacterEffect *effect = [[DSACharacterEffect alloc] init];
          effect.effectType = miracleResult.type;
          effect.uniqueKey = miracleResult.uniqueKey;
          effect.expirationDate = miracleResult.expirationDate;
          effect.reversibleChanges = miracleResult.statChanges;
          if ([[self.appliedEffects allKeys] containsObject: miracleResult.uniqueKey])
            {
              extendOnly = YES;  // basically only want to extend the expiration date, values are already applied
            }          
          [self.appliedEffects setObject: effect forKey: effect.uniqueKey];
        }
      if (!extendOnly)
        {        
          for (NSString *key in miracleResult.statChanges)
            {
              if (self.currentTalents[key])
                {
                  DSATalent *talent = self.currentTalents[key];
                  talent.level += [miracleResult.statChanges[key] integerValue];
                  continue;
                }
              else
                {
                  NSLog(@"DSACharacter applyMiracleEffect DSAMiracleResultTypeTalentBoost Talent %@ not found", key);
                }
            }
        }
    }
    case DSACharacterEffectTypeMagicProtection: {
      if (miracleResult.expirationDate)
        {
          DSACharacterEffect *effect = [[DSACharacterEffect alloc] init];
          effect.effectType = miracleResult.type;
          effect.uniqueKey = miracleResult.uniqueKey;
          effect.expirationDate = miracleResult.expirationDate;
          effect.reversibleChanges = miracleResult.statChanges;          
          [self.appliedEffects setObject: effect forKey: effect.uniqueKey];
        }
    }
    case DSACharacterEffectTypeUpgradeWeaponToMagic: {
      NSLog(@"DSACharacter applyMiracleEffect DSAMiracleResultTypeUpgradeWeaponToMagic NOT YET IMPLEMENTED!");
    }             
    default:
      NSLog(@"DSACharacter applyMiracleEffect effect %ld not yet implemented", miracleResult.type);
      break;
  }
  return applied;
}

- (void)removeExpiredEffectsAtDate:(DSAAventurianDate *)currentDate {
    NSLog(@"DSACharacter removeExpiredEffectsAtDate called");
    NSArray *allKeys = [self.appliedEffects allKeys];
    for (NSString *key in allKeys) {
        DSACharacterEffect *effect = self.appliedEffects[key];
        NSLog(@"DSACharacter removeExpiredEffectsAtDate checking effect key: %@", key);
        if (effect.effectType == DSACharacterEffectTypeIllness)  // Handle them separately,...
          {
            NSLog(@"DSACharacter removeExpiredEffectsAtDate %@ found DSACharacterEffectTypeIllness, handing over to advanceIllnessEffect", self.name);
            [self advanceIllnessEffect: (DSAIllnessEffect *) effect atDate: currentDate];
            continue;
          }
        else if (effect.effectType == DSACharacterEffectTypePoison)  // Handle them separately,...
          {
            NSLog(@"DSACharacter removeExpiredEffectsAtDate %@ found DSACharacterEffectTypePoison, handing over to advancePoisonEffect", self.name);
            [self advancePoisonEffect: (DSAPoisonEffect *) effect atDate: currentDate];
            continue;
          }          
        if (effect.expirationDate && [effect.expirationDate isEarlierThanDate:currentDate]) {
            [self removeCharacterEffectForKey:key];
        }
    }
}

- (void) advancePoisonEffect: (DSAPoisonEffect *) poisonEffect atDate: (DSAAventurianDate *)currentDate
{
  DSAPoison *poison = [[DSAPoisonRegistry sharedRegistry] poisonWithUniqueID: poisonEffect.uniqueKey];
  NSLog(@"DSACharacter advancePoisonEffect the poison: %@", poison);
  
  if ([self isDead])
    {
      [self removeCharacterEffectForKey:poisonEffect.uniqueKey];
      return;
    }
  
  switch (poisonEffect.currentStage)
    {
      case DSAPoisonStageApplied: {
        BOOL immediatelyAdvanceStage = NO;
        if (!poisonEffect.expirationDate)
          {
            NSLog(@"DSAcharacter advancePoisonEffect in stage: DSAPoisonStageApplied, properly initializing poisonEffect"); 
            poisonEffect.expirationDate = [poison endDateOfStage: DSAPoisonStageApplied
                                                        fromDate: currentDate];
            if ([poisonEffect.expirationDate isEqualTo: currentDate])  // advance right away ...
              {
                immediatelyAdvanceStage = YES;
              }
          }
        else
          {
            if ([poisonEffect.expirationDate isEarlierThanDate: currentDate])
              {
                immediatelyAdvanceStage = YES;              
              }
            else
              {
                NSLog(@"DSAcharacter advancePoisonEffect in stage: DSAPoisonStageApplied, no need yet to advance to next stage");
              }
          }
        if (immediatelyAdvanceStage)
          {
              poisonEffect.currentStage = DSAPoisonStageActive;
              poisonEffect.expirationDate = [poison endDateOfStage: DSAPoisonStageActive
                                                          fromDate: currentDate];
              [self.statesDict setObject: @([poison dangerLevelToSeverityLevel]) forKey: @(DSACharacterStatePoisoned)];                                                          
              
              poisonEffect.oneTimeDamage = [poison oneTimeDamage];
              [self applyOneTimeDamage:poisonEffect revert:NO];
              poisonEffect.recurringDamage = [poison recurringDamage];  // we're advancing immediately, applying in active stage...

              NSDictionary *userInfo = @{ @"severity": @(LogSeverityWarning),
                                           @"message": [NSString stringWithFormat: @"%@ ist vergiftet.", self.name]
                                        };                
              [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                  object: self
                                                                userInfo: userInfo];
              NSLog(@"DSACharacter advancePoisonEffect in stage: DSAPoisonStageApplied, handing over to advancePoisonEffect: %@", poisonEffect);                                                                                                                                         
              [self advancePoisonEffect: poisonEffect atDate: currentDate];          
          }
        break;
      }
      case DSAPoisonStageActive: {
        // NSLog(@"DSACharacter advancePoison effect stage: DSAPoisonStageActive poisonEffect.expirationDate: %@ currentDate: %@", poisonEffect.expirationDate, currentDate);
        if ([poisonEffect.expirationDate isEarlierThanDate: currentDate])
          {
            // seems we're still alive at the end of poison
            [self applyOneTimeDamage:poisonEffect revert:YES];
            [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStatePoisoned)];
            [self removeCharacterEffectForKey: poisonEffect.uniqueKey];
            NSDictionary *userInfo = @{ @"severity": @(LogSeverityInfo),
                                         @"message": [NSString stringWithFormat: @"%@ hat die Vergiftung überstanden.", self.name]
                                      };
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                object: self
                                                              userInfo: userInfo];
            return; // good to jump out early                                           
          }
        if (poisonEffect.recurringDamage)
          {
            NSLog(@"DSACharacter advancePoisonEffect recurringDamageApplyNextDate: %@", poisonEffect.recurringDamageApplyNextDate);
          
            if (poisonEffect.recurringDamageApplyNextDate == nil || [poisonEffect.recurringDamageApplyNextDate isEarlierThanDate: currentDate])
              {
                NSLog(@"DSACharacter advancePoisonEffect in stage: %lu handling recurringDamage %@", poisonEffect.currentStage, poisonEffect);
                [self applyRegularDamageForCharacterEffect: poisonEffect atDate: currentDate];
              }
            else
              {
                NSLog(@"DSACharacter advancePoisonEffect in stage: %lu not yet handling recurringDamage again", poisonEffect.currentStage);
              }
          }
        else
          {
            NSLog(@"DSACharacter advancePoisonEffect in stage: DSAPoisonStageActive, but poison doesn't have recurringDamage");
          }
        break;
      }
      default: {
        NSLog(@"DSACharacter advancePoisonEffect not specially handling stage: %@ yet", @(poisonEffect.currentStage));
        break;
      }
    }
}

- (void) advanceIllnessEffect: (DSAIllnessEffect *) illnessEffect atDate: (DSAAventurianDate *)currentDate
{
  DSAIllness *illnessDescription = [[DSAIllnessRegistry sharedRegistry] illnessWithUniqueID: illnessEffect.uniqueKey];
  
  if ([self isDead])
    {
      [self removeCharacterEffectForKey: illnessEffect.uniqueKey];
      return;
    }  
  
  switch (illnessEffect.currentStage)
    {
      case DSAIllnessStageIncubation: {
        if (!illnessEffect.expirationDate)  // have to properly initialize incubation phase
          {
            illnessEffect.expirationDate = [illnessDescription endDateOfStage: DSAIllnessStageIncubation
                                                                     fromDate: currentDate];
            NSLog(@"DSACharacter advanceIllnessEffect in stage DSAIllnessStageIncubation initializing incubation phase");                                                                     
          }
        else
          {
            if ([illnessEffect.expirationDate isEarlierThanDate: currentDate]) // Advance to next stage!
              {
                NSLog(@"DSACharacter advanceIllnessEffect in stage DSAIllnessStageIncubation advancing to next stage!");
                illnessEffect.expirationDate = [illnessDescription endDateOfStage: DSAIllnessStageActiveUnknown
                                                                         fromDate: currentDate];
                illnessEffect.followUpIllnessChance = [illnessDescription.followUpIllnessChance copy];
                NSLog(@"DSACharacter advanceIllnessEffect, current date: %@ new expirationDate: %@", currentDate, illnessEffect.expirationDate);                                                                         
                illnessEffect.oneTimeDamage = [illnessDescription oneTimeDamage];
                [self applyOneTimeDamage:illnessEffect revert:NO];
     
                illnessEffect.recurringDamage = [illnessDescription recurringDamage];
                [self applyRegularDamageForCharacterEffect:illnessEffect atDate: currentDate];
                
                illnessEffect.currentStage = DSAIllnessStageActiveUnknown;     // finally push forward
                NSLog(@"DSACharacter advanceIllnessEffect goint to set severity level to: %@", @([illnessDescription dangerLevelToSeverityLevel]));
                [self.statesDict setObject: @([illnessDescription dangerLevelToSeverityLevel]) forKey: @(DSACharacterStateSick)];
                NSLog(@"DSACharacter advanceIllnessEffect in stage DSAIllnessStageIncubation new illness effect: %@", illnessEffect);
                
                NSDictionary *userInfo = @{ @"severity": @(LogSeverityWarning),
                                             @"message": [NSString stringWithFormat: @"%@ fühlt sich krank.", self.name]
                                          };                
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                    object: self
                                                                  userInfo: userInfo];                
              }
            else
              {
                NSLog(@"DSACharacter advanceIllnessEffect in stage DSAIllnessStageIncubation, no need to advance illness to next stage yet");
              }
          }
          break;
      }
      case DSAIllnessStageActiveUnknown:
      case DSAIllnessStageActiveIdentified:
      case DSAIllnessStageUnderTreatment:
      case DSAIllnessStageChronicActive: {
        NSLog(@"DSACharacter advanceIllnessEffect in stage: %lu", illnessEffect.currentStage);
        if ([illnessEffect.expirationDate isEarlierThanDate: currentDate])
          {
            // Seems we're still alive and overcome the illness
            [self applyOneTimeDamage:illnessEffect revert:YES];
            [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStateSick)];
            DSAIllnessEffect *savedIllnessEffect = illnessEffect;
            if (illnessEffect.currentStage == DSAIllnessStageChronicActive)
              {
                illnessEffect.currentStage = DSAIllnessStageChronicInactive;
                [self.statesDict setObject: @(DSASeverityLevelNone) forKey: @(DSACharacterStateSick)];
              }
            else
              {
                [self removeCharacterEffectForKey: illnessEffect.uniqueKey];
              }
            self.enduranceBaseValue = 0;  // just reset in case it was lowered
            NSDictionary *userInfo = @{ @"severity": @(LogSeverityInfo),
                                         @"message": [NSString stringWithFormat: @"%@ ist wieder genesen.", self.name]
                                      };
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                object: self
                                                              userInfo: userInfo];
            if (savedIllnessEffect.followUpIllnessChance)                                                            
              {
                for (NSString *illnessName in savedIllnessEffect.followUpIllnessChance)
                  {
                    NSInteger chance = [savedIllnessEffect.followUpIllnessChance[illnessName] integerValue];
                    NSInteger diceResult = [Utils rollDice: @"1W100"];
                    NSLog(@"DSACharacter advanceIllnessEffect checking if to apply follow up illness: %@", illnessName);
                    if (diceResult <= chance)
                      {
                        DSAIllness *followUpIllnessDescription = [[DSAIllnessRegistry sharedRegistry] illnessWithName: illnessName];
                        NSLog(@"DSACharacter advanceIllnessEffect applying follow up illness: %@", illnessName);
                        [self applyIllnessEffect: [followUpIllnessDescription generateEffectForCharacter: self]];
                        break;  // there should not be more than one anyways
                      }
                  }
              }
            return; // Good to jump out early (:       
          }
        if (illnessEffect.recurringDamage)
          {
            if (illnessEffect.recurringDamageApplyNextDate == nil || [illnessEffect.recurringDamageApplyNextDate isEarlierThanDate: currentDate])
              {
                NSLog(@"DSACharacter advanceIllnessEffect in stage: %lu handling recurringDamage", illnessEffect.currentStage);
                [self applyRegularDamageForCharacterEffect: illnessEffect atDate: currentDate];
              }
          }
        
        break;
      }
      case DSAIllnessStageChronicInactive: {
        NSLog(@"DSACharacter advanceIllnessEffect in stage: DSAIllnessStageChronicInactive");
        NSInteger restart = [Utils rollDice: @"1W100"];
        if (restart < 5)
          {
            NSLog(@"DSACharacter advanceIllnessEffect in stage: DSAIllnessStageChronicInactive, reactivating illness: %@", illnessEffect.uniqueKey);
            illnessEffect.currentStage = DSAIllnessStageChronicInactive;
            [self.statesDict setObject: @([illnessDescription dangerLevelToSeverityLevel]) forKey: @(DSACharacterStateSick)];
          }
        break;
      }
      default: {
        NSLog(@"DSACharacter advanceIllnessEffect in unhandled stage: %lu", illnessEffect.currentStage);
      }    
    }
}

- (void)applyOneTimeDamage:(DSACharacterEffect *)characterEffect
                    revert:(BOOL)shouldRevert
{
  NSLog(@"DSACharacter applyOneTimeDamage called!");
    
  for (NSString *who in [characterEffect.oneTimeDamage allKeys])
    {
      if ([who isEqualToString: @"Alle"] ||
          ([who isEqualToString: @"Zwerg"] && [self isKindOfClass: [DSACharacterHeroDwarf class]]) ||
          ([who isEqualToString: @"Mensch"] && [self isKindOfClass: [DSACharacterHeroHuman class]]) ||
          ([who isEqualToString: @"Elf"] && [self isKindOfClass: [DSACharacterHeroElf class]]))
        {
          NSDictionary *oneTimeDamage = characterEffect.oneTimeDamage[who];
          NSLog(@"DSACharacter applyOneTimeDamage going ahead with applying oneTimeDamage: %@", oneTimeDamage);          
          for (NSString *damageType in oneTimeDamage)
            {
              NSLog(@"DSACharacter applyOneTimeDamage going ahead with applying damageType: %@", damageType);
              if ([damageType isEqualToString:@"Eigenschaften"])
                {
                  NSDictionary *traitChanges = oneTimeDamage[damageType];
                  for (NSString *trait in traitChanges)
                    {
                       NSLog(@"DSACharacter applyOneTimeDamage applying one-time-damage to trait %@", trait);
                       NSDictionary *traitDict = traitChanges[trait];
                       [self applyOneTimeTraitChangesForTrait: trait
                                                     fromDict: traitDict
                                                       revert: shouldRevert];                                                                                        
                    }
                }
              else if ([damageType isEqualToString:@"AttackeParade"])
                {
                  NSDictionary *atpaChanges = oneTimeDamage[damageType];
                  for (NSString *atpa in atpaChanges)
                    {
                      NSDictionary *valueDict = atpaChanges[atpa];
                      NSNumber *modifierNumber = valueDict[@"Modifier"];
                      if (![modifierNumber isKindOfClass:[NSNumber class]])
                        {
                           NSLog(@"❗️Invalid Modifier value for atpa '%@': %@", atpa, modifierNumber);
                           continue;
                        }
                
                      NSInteger modifierValue = [modifierNumber integerValue];
                      if (shouldRevert)
                        {
                          modifierValue *= -1;
                        }
                  
                      if ([atpa isEqualToString: @"AT"])
                        {
                          self.attackBaseBaseValue += modifierValue;
                        }
                      else if ([atpa isEqualToString: @"PA"])
                        {
                          self.parryBaseBaseValue += modifierValue;
                        }
                      else
                        {
                          NSLog(@"DSACharacter applyOneTimeDamage unknown AttackeParade: %@", atpa);
                        }
                    }
                }
              else
                {
                  NSLog(@"⚠️ DSACharacter applyOneTimeDamage: unsupported damageType: %@", damageType);
                }
            }
       }
    }
}

-(void) applyOneTimeTraitChangesForTrait: (NSString *) trait
                                fromDict: (NSDictionary<NSString *, NSNumber*>*) traitDict 
                                  revert: (BOOL) shouldRevert
{
   NSNumber *modifierNumber = traitDict[@"Modifier"];
   if (![modifierNumber isKindOfClass:[NSNumber class]])
     {
        NSLog(@"❗️Invalid Modifier value for trait '%@': %@", trait, modifierNumber);
        return;
     }

   NSInteger traitValue = [modifierNumber integerValue];
   if (shouldRevert)
     {
        traitValue *= -1;
     }

   DSAPositiveTrait *positiveTrait = self.currentPositiveTraits[trait];
   if (positiveTrait)
     {
        positiveTrait.level += traitValue;
        return;
     }

   DSANegativeTrait *negativeTrait = self.currentNegativeTraits[trait];
   if (negativeTrait)
     {
        negativeTrait.level += traitValue;
        return;
     }

   NSLog(@"⚠️ DSACharacter applyOneTimeTraitChangesFromDict: unknown trait: %@", trait);
}                                 

-(void) applyRegularDamageForCharacterEffect: (DSACharacterEffect *) characterEffect atDate: (DSAAventurianDate *) currentDate
{
  NSString *recurringIntervalDescriptor = characterEffect.recurringDamage.allKeys.firstObject;
  NSLog(@"DSACharacter applyRegularDamageForCharacterEffect recurringIntervalDescriptor: %@", recurringIntervalDescriptor);
  NSDictionary *recurringDamageDict = characterEffect.recurringDamage[recurringIntervalDescriptor];
  
  for (NSString *who in [recurringDamageDict allKeys])
    {    
      if ([who isEqualToString: @"Alle"] ||
          ([who isEqualToString: @"Zwerg"] && [self isKindOfClass: [DSACharacterHeroDwarf class]]) ||
          ([who isEqualToString: @"Mensch"] && [self isKindOfClass: [DSACharacterHeroHuman class]]) ||
          ([who isEqualToString: @"Elf"] && [self isKindOfClass: [DSACharacterHeroElf class]]))
        {
          NSDictionary *recurringDamage = recurringDamageDict[who];
          for (NSString *damageType in [recurringDamage allKeys])
           {
              NSLog(@"DSACharacter applyRegularDamageForCharacterEffect damageType: %@", damageType);
              if ([damageType isEqualToString: @"Damage"])
                {
                  NSDictionary *damageDict = recurringDamage[@"Damage"];
                  NSLog(@"DSACharacter applyRegularDamageForCharacterEffect in Damage, damageDict: %@", damageDict);
                  for (NSString *damage in [damageDict allKeys])
                    {
                      if ([damage isEqualToString: @"SP"])
                        {
                          NSString *wuerfelString = [damageDict[damage] objectForKey: @"Wuerfel"];
                          NSInteger modifier = [[damageDict[damage] objectForKey: @"Modifier"] integerValue];
                          NSInteger sp = [Utils rollDice: wuerfelString] + modifier;
                          if (sp > 0)  // some modifiers are -2 or more negative, so sp could become < 0, which would be awkward if sick ;)
                            {
                              self.currentLifePoints -= sp;
                            }
                        }
                      else if ([damage isEqualToString: @"ASP"])
                        {
                          NSString *wuerfelString = [damageDict[damage] objectForKey: @"Wuerfel"];
                          NSInteger modifier = [[damageDict[damage] objectForKey: @"Modifier"] integerValue];
                          NSInteger sp = [Utils rollDice: wuerfelString] + modifier;
                          if (sp > 0)  // some modifiers are -2 or more negative, so sp could become < 0, which would be awkward if sick ;)
                            {
                              self.currentAstralEnergy = self.currentAstralEnergy - sp > 0 ? self.currentAstralEnergy - sp : 0;
                            }
                        }                        
                      else if ([damage isEqualToString: @"AU"])
                        {
                          NSString *wuerfelString = [damageDict[damage] objectForKey: @"Wuerfel"];
                          NSInteger modifier = [[damageDict[damage] objectForKey: @"Modifier"] integerValue];
                         
                          self.enduranceBaseValue -= ([Utils rollDice: wuerfelString] + modifier);                      
                        }
                      else
                        {
                          NSLog(@"DSACharacter advanceIllnessEffect in applyRegularDamageForCharacterEffect don't know how to handle damage: %@", damage);
                        }
                    }
                }
              else
                {
                   NSLog(@"DSACharacter advanceIllnessEffect applyRegularDamageForCharacterEffect don't know how to handle damageType: %@", damageType);
                }
            }
        }
   }
   if ([recurringIntervalDescriptor isEqualToString: @"KR"])  // handle seconds?
     {
       characterEffect.recurringDamageApplyNextDate = [currentDate dateByAddingYears:0 days:0 hours:0 minutes:1];
     }   
   else if ([recurringIntervalDescriptor isEqualToString: @"SR"] || [recurringIntervalDescriptor isEqualToString: @"Minuetlich"])
     {
       characterEffect.recurringDamageApplyNextDate = [currentDate dateByAddingYears:0 days:0 hours:0 minutes:1];
     }
   else if ([recurringIntervalDescriptor isEqualToString: @"Stuendlich"])
     {
       characterEffect.recurringDamageApplyNextDate = [currentDate dateByAddingYears:0 days:0 hours:1 minutes:1];
     }
   else if ([recurringIntervalDescriptor isEqualToString: @"Taeglich"])
     {
       characterEffect.recurringDamageApplyNextDate = [currentDate dateByAddingYears:0 days:1 hours:0 minutes:1];
     }
   else
     {
       NSLog(@"DSACharacter applyRegularDamageForCharacterEffect, do not know how to handle recurringIntervalDescriptor: %@", recurringIntervalDescriptor);
       abort();
     }
}

- (void)removeCharacterEffectForKey: (NSString *)key
{
  
  DSACharacterEffect *effect = self.appliedEffects[key];
  
  switch (effect.effectType) {
    case DSACharacterEffectTypeTraitBoost: {
      for (NSString *key in effect.reversibleChanges)
        {
          if (self.currentPositiveTraits[key])
            {
              self.currentPositiveTraits[key].level -= [effect.reversibleChanges[key] integerValue];
              continue;
            }
          else if (self.currentNegativeTraits[key])
            {
              self.currentNegativeTraits[key].level -= [effect.reversibleChanges[key] integerValue];
              continue;
            }
          else
            {
              NSLog(@"DSACharacter removeCharacterEffectForKey DSAMiracleResultTypeTraitBoost Trait %@ not found", key);
            }
        }
      break;
    }
    case DSACharacterEffectTypeMRBoost: {
     self.currentMrBonus -= [effect.reversibleChanges[@"MR"] integerValue];
     break;
    }
    case DSACharacterEffectTypeTalentBoost: {
      for (NSString *key in effect.reversibleChanges)
        {
          if (self.currentTalents[key])
            {
              DSATalent *talent = self.currentTalents[key];
              talent.level -= [effect.reversibleChanges[key] integerValue];
              continue;
            }
          else
            {
              NSLog(@"DSACharacter removeCharacterEffectForKey DSAMiracleResultTypeTalentBoost Talent %@ not found", key);
            }
        }
      break;
    }
    case DSACharacterEffectTypeMagicProtection: {
     NSLog(@"DSACharacter removeCharacterEffectForKey nothing to do for: DSAMiracleResultTypeMagicProtection besides removing myself");
     break;
    }           
    default: {
      NSLog(@"DSACharacter removeCharacterEffectForKey no special handling for effect with key: %@ implemented", key);
    }
  }
  // finally remove the key and object from the dictionary
  [self.appliedEffects removeObjectForKey:key];
}

- (void) updateStateHungerWithValue: (NSNumber*) value
{
  CGFloat newLevel = [value floatValue];
  CGFloat currentLevel = [[self.statesDict objectForKey: @(DSACharacterStateHunger)] floatValue];
  
  if (newLevel > currentLevel)
    {
       NSString  *notificationMessage = [NSString stringWithFormat: @"Hmm lecker, das stillt den Hunger."];
       NSInteger notificationSeverity = LogSeverityInfo;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo];      
    }
  else if (newLevel < currentLevel)
    {
      if (newLevel == 0)
        {
           NSString  *notificationMessage = [NSString stringWithFormat: @"%@ wird vor Hunger ohnmächtig.", self.name];
           NSInteger notificationSeverity = LogSeverityCritical;
    
           NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                        @"message": notificationMessage
                                     };
           [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                               object: self
                                                             userInfo: userInfo];
           [self.statesDict setObject: @(YES) forKey: @(DSACharacterStateUnconscious)];
           userInfo = @{ @"state": @(DSACharacterStateUnconscious),
                         @"value": @(YES)
                       };
           [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterStateChange"
                                                               object: self
                                                             userInfo: userInfo];                                                                        
              
        }
      else if (newLevel < 0.1)
        {
           NSString  *notificationMessage = [NSString stringWithFormat: @"%@ ist sehr hungrig.", self.name];
           NSInteger notificationSeverity = LogSeverityWarning;
    
           NSDictionary * userInfo = @{ @"severity": @(notificationSeverity),
                                         @"message": notificationMessage
                                      };
           [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                               object: self
                                                             userInfo: userInfo];        
        }
    }
  [self.statesDict setObject: value forKey: @(DSACharacterStateHunger)];
  NSDictionary *userInfo = @{ @"state": @(DSACharacterStateHunger),
                              @"value": value
                            };
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterStateChange"
                                                      object: self
                                                    userInfo: userInfo];  
}

- (void) updateStateThirstWithValue: (NSNumber*) value
{
  CGFloat newLevel = [value floatValue];
  CGFloat currentLevel = [[self.statesDict objectForKey: @(DSACharacterStateThirst)] floatValue];
  
  if (newLevel > currentLevel)
    {
       NSString  *notificationMessage = [NSString stringWithFormat: @"Hmm lecker, das stillt den Durst."];
       NSInteger notificationSeverity = LogSeverityInfo;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo];      
    }
  else if (newLevel < currentLevel)
    {
      if (newLevel == 0)
        {
           NSString  *reason = [NSString stringWithFormat: @"%@ wird vor Durst ohnmächtig.", self.name];          
           [self updateStateUnconsciousWithValue: @(YES)
                                      withReason: reason];
              
        }
      else if (newLevel < 0.1)
        {
           NSString  *notificationMessage = [NSString stringWithFormat: @"%@ ist sehr durstig.", self.name];
           NSInteger notificationSeverity = LogSeverityWarning;
    
           NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                        @"message": notificationMessage
                                 };
           [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                               object: self
                                                             userInfo: userInfo];        
        }
    }
  [self.statesDict setObject: value forKey: @(DSACharacterStateThirst)];
  NSDictionary *userInfo = @{ @"state": @(DSACharacterStateThirst),
                              @"value": value
                            };
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterStateChange"
                                                      object: self
                                                    userInfo: userInfo];
}

- (void) updateStateWoundedWithValue: (NSNumber*) value
{
  
  NSInteger newLevel = [value integerValue];
  NSInteger currentLevel = [[self.statesDict objectForKey: @(DSACharacterStateWounded)] integerValue];
  if (newLevel == currentLevel)
    {
      return; // nothing changed
    }
  NSLog(@"UPDATING WOUNDED STATE: CURRENT %@ NEW %@", [self.statesDict objectForKey: @(DSACharacterStateWounded)], value);
  if (currentLevel < newLevel && newLevel <= DSASeverityLevelSevere)
    {
       [self.statesDict setObject: value forKey: @(DSACharacterStateWounded)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@ ist verwundet worden.", self.name];
       NSInteger notificationSeverity = LogSeverityWarning;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo]; 
    }
  else if (newLevel> DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStateWounded)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@s Verwundungen heilen wieder.", self.name];
       NSInteger notificationSeverity = LogSeverityInfo;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo];      
    }
  else if (newLevel == DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStateWounded)];
      NSString  *notificationMessage = [NSString stringWithFormat: @"%@s Wunden sind wieder völlig verheilt.", self.name];
      NSInteger notificationSeverity = LogSeverityHappy;
    
      NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                   @"message": notificationMessage
                                };                               
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];      
    }
}

- (void) updateStateSickWithValue: (NSNumber*) value
{
  
  NSInteger newLevel = [value integerValue];
  NSInteger currentLevel = [[self.statesDict objectForKey: @(DSACharacterStateSick)] integerValue];
  if (newLevel == currentLevel)
    {
      return; // nothing changed
    }
  NSLog(@"UPDATING WOUNDED STATE: CURRENT %@ NEW %@", [self.statesDict objectForKey: @(DSACharacterStateSick)], value);
  if (currentLevel < newLevel && newLevel <= DSASeverityLevelSevere)
    {
       [self.statesDict setObject: value forKey: @(DSACharacterStateSick)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@ ist krank geworden.", self.name];
       NSInteger notificationSeverity = LogSeverityWarning;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo]; 
    }
  else if (newLevel> DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStateSick)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@s Krankheit wird wieder etwas besser.", self.name];
       NSInteger notificationSeverity = LogSeverityInfo;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo];      
    }
  else if (newLevel == DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStateSick)];
      NSString  *notificationMessage = [NSString stringWithFormat: @"%@ ist wieder völlig genesen.", self.name];
      NSInteger notificationSeverity = LogSeverityHappy;
    
      NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                   @"message": notificationMessage
                                };                               
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];      
    }
}

- (void) updateStatePoisonedWithValue: (NSNumber*) value
{
  
  NSInteger newLevel = [value integerValue];
  NSInteger currentLevel = [[self.statesDict objectForKey: @(DSACharacterStatePoisoned)] integerValue];
  if (newLevel == currentLevel)
    {
      return; // nothing changed
    }
  NSLog(@"UPDATING WOUNDED STATE: CURRENT %@ NEW %@", [self.statesDict objectForKey: @(DSACharacterStatePoisoned)], value);
  if (currentLevel < newLevel && newLevel <= DSASeverityLevelSevere)
    {
       [self.statesDict setObject: value forKey: @(DSACharacterStatePoisoned)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@ wurde vergiftet.", self.name];
       NSInteger notificationSeverity = LogSeverityWarning;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo]; 
    }
  else if (newLevel> DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStatePoisoned)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@s Vergiftungserscheinungen lassen etwas nach.", self.name];
       NSInteger notificationSeverity = LogSeverityInfo;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo];      
    }
  else if (newLevel == DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStatePoisoned)];
      NSString  *notificationMessage = [NSString stringWithFormat: @"%@s Vergiftung ist völlig vorüber.", self.name];
      NSInteger notificationSeverity = LogSeverityHappy;
    
      NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                   @"message": notificationMessage
                                };                               
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];      
    }
}

- (void) updateStateDrunkenWithValue: (NSNumber*) value
{
  
  NSInteger newLevel = [value integerValue];
  NSInteger currentLevel = [[self.statesDict objectForKey: @(DSACharacterStateDrunken)] integerValue];
  if (newLevel == currentLevel)
    {
      return; // nothing changed
    }  
  NSLog(@"UPDATING DRUNKEN STATE: CURRENT %@ NEW %@", [self.statesDict objectForKey: @(DSACharacterStateDrunken)], value);
  if (currentLevel < newLevel && newLevel <= DSASeverityLevelSevere)
    {
       [self.statesDict setObject: value forKey: @(DSACharacterStateDrunken)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@ hat wohl etwas über den Durst getrunken.", self.name];
       NSInteger notificationSeverity = LogSeverityWarning;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo]; 
    }
  else if (newLevel> DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStateDrunken)];
       NSString  *notificationMessage = [NSString stringWithFormat: @"%@ nüchtert langsam wieder aus.", self.name];
       NSInteger notificationSeverity = LogSeverityInfo;
    
       NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                    @"message": notificationMessage
                                 };
       [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                           object: self
                                                         userInfo: userInfo];      
    }
  else if (newLevel == DSASeverityLevelNone && newLevel < currentLevel)
    {
      [self.statesDict setObject: value forKey: @(DSACharacterStateDrunken)];
      NSString  *notificationMessage = [NSString stringWithFormat: @"%@ ist wieder ausgenüchtert.", self.name];
      NSInteger notificationSeverity = LogSeverityHappy;
    
      NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                                   @"message": notificationMessage
                                };                               
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: self
                                                        userInfo: userInfo];      
    }
}

- (void) updateStateUnconsciousWithValue: (NSNumber*) value
                              withReason: (NSString *) reason
{
  NSInteger notificationSeverity = LogSeverityInfo;
  NSString *notificationMessage = nil;
  NSLog (@"DSACharacter updateStateUnconsciousWithValue: %@ reason: %@", value, reason);
  
  BOOL currentState = [[self.statesDict objectForKey: @(DSACharacterStateUnconscious)] boolValue];
  
  if (currentState == [value boolValue])
    {
      return; // nothing changed...
    }
  
  [self.statesDict setObject: value forKey: @(DSACharacterStateUnconscious)];
  if (reason)
    {
      notificationSeverity = LogSeverityWarning;
      notificationMessage = reason;

    }
  else if ([value boolValue] == NO)
    {
      notificationSeverity = LogSeverityHappy;
      notificationMessage = [NSString stringWithFormat: @"%@'s Zustand der Bewußtlosigkeit ist beendet.", self.name];
     
    }
  else if ([value boolValue] == YES)
    {
      notificationSeverity = LogSeverityWarning;
      notificationMessage = [NSString stringWithFormat: @"%@ verliert das Bewußtsein.", self.name];
       
    }
  NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                               @"message": notificationMessage
                            };  
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                      object: self
                                                    userInfo: userInfo];
                                                    
  userInfo = @{ @"state": @(DSACharacterStateUnconscious),
                @"value": value
              };                                                     
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterStateChange"
                                                      object: self
                                                    userInfo: userInfo];
}

- (void) updateStateDeadWithValue: (NSNumber*) value
                       withReason: (NSString *) reason
{
  NSInteger notificationSeverity = LogSeverityInfo;
  NSString *notificationMessage = nil;

  BOOL currentState = [[self.statesDict objectForKey: @(DSACharacterStateDead)] boolValue];
  
  if (currentState == [value boolValue])
    {
      return; // nothing changed...
    }  
    
  [self.statesDict setObject: value forKey: @(DSACharacterStateDead)];
  if (reason)
    {
      notificationSeverity = LogSeverityWarning;
      notificationMessage = reason;

    }
  else if ([value integerValue] == DSASeverityLevelNone)
    {
      notificationSeverity = LogSeverityHappy;
      notificationMessage = [NSString stringWithFormat: @"%@ ist aus Borons Reich zurückgekehrt und weilt wieder unter den Lebenden.", self.name];
     
    }
  else if ([value integerValue] > DSASeverityLevelNone)
    {
      notificationSeverity = LogSeverityCritical;
      notificationMessage = [NSString stringWithFormat: @"%@'s Lebenslicht erlischt, sein Geist geht über ins Reich Borons.", self.name];
       
    }
  NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                               @"message": notificationMessage
                            };  
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                      object: self
                                                    userInfo: userInfo];
                                                    
  userInfo = @{ @"state": @(DSACharacterStateDead),
                @"value": value
              };                                                     
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterStateChange"
                                                      object: self
                                                    userInfo: userInfo];
}


- (void) updateStateSpellboundWithValue: (NSNumber*) value
                             withReason: (NSString *) reason
{
  NSInteger notificationSeverity = LogSeverityInfo;
  NSString *notificationMessage = nil;

  BOOL currentState = [[self.statesDict objectForKey: @(DSACharacterStateSpellbound)] boolValue];
  
  if (currentState == [value boolValue])
    {
      return; // nothing changed...
    }  
    
  [self.statesDict setObject: value forKey: @(DSACharacterStateSpellbound)];
  if (reason)
    {
      notificationSeverity = LogSeverityWarning;
      notificationMessage = reason;

    }
  else if ([value integerValue] == DSASeverityLevelNone)
    {
      notificationSeverity = LogSeverityHappy;
      notificationMessage = [NSString stringWithFormat: @"%@ ist nicht mehr von einem Zauber beherrscht.", self.name];
     
    }
  else if ([value integerValue] > DSASeverityLevelNone)
    {
      notificationSeverity = LogSeverityCritical;
      notificationMessage = [NSString stringWithFormat: @"%@ ist von einem Zauber beherrscht.", self.name];
       
    }
  NSDictionary *userInfo = @{ @"severity": @(notificationSeverity),
                               @"message": notificationMessage
                            };  
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                      object: self
                                                    userInfo: userInfo];
                                                    
  userInfo = @{ @"state": @(DSACharacterStateSpellbound),
                @"value": value
              };                                                     
  [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterStateChange"
                                                      object: self
                                                    userInfo: userInfo];
}
@end

@implementation DSACharacterHero
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.isNPC = NO;
      self.level = 0;
      self.adventurePoints = 0;
      self.specials = nil;    
      self.isLevelingUp = NO;  // even though we likely will level up soon, it shall be triggered by the user
      self.levelUpTalents = nil;
      self.levelUpSpells = nil;      
      self.levelUpProfessions = nil;
      self.firstLevelUpTalentTriesPenalty = 0; // this is also taken into account in the DSACharacterWindowController...
      self.maxLevelUpTalentsTries = 30;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 0;
      self.maxLevelUpTalentsTriesTmp = 0;      // this value is set in the DSACharacterWindowController, as there are characters out there, that might have variable tries
      self.maxLevelUpSpellsTriesTmp = 0;       // this value is set in the DSACharacterWindowController, as there are characters out there, that might have variable tries
      self.maxLevelUpVariableTries = 0;        // thats the value the DSACharacterWindowController checks if there ar variable tries
    }
  NSLog(@"DSACharacterHero init before returning self");
  return self;
}

- (void) prepareLevelUp
{
  // only taking care of the basics here
  // since we'd have to ask the user how much variable tries 
  // to distribute between spells and talents, and it 
  // doesn't fit into the flow
  // it's triggered from within the upgrade flow
  self.isLevelingUp = YES;

  NSMutableDictionary *tempLevelUpTalents = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *tempLevelUpSpells = [[NSMutableDictionary alloc] init];  
  NSMutableDictionary *tempLevelUpProfessions = [[NSMutableDictionary alloc] init];
  
  if (!self.levelUpTalents)
    {
      self.levelUpTalents = [[NSMutableDictionary alloc] init];
    }  
  NSLog(@"DSACharacterHero: prepareLevelUp: Number of talents: %lu", (unsigned long)[self.talents count]); 
  for (id key in self.talents)
    {
      id value = self.talents[key];
      // Check if the value conforms to NSCopying
      if ([value conformsToProtocol:@protocol(NSCopying)])
        {
          tempLevelUpTalents[key] = [value copy];
        }
      else
        {
          tempLevelUpTalents[key] = value; // Shallow copy
        }
    }
  NSLog(@"DSACharacterHero: prepareLevelUp: Number of spells: %lu", (unsigned long)[self.spells count]);    
  if ([self isMagicalDabbler])
    {
      NSLog(@"DSACharacterHero: prepareLevelUp: IM A MAGICAL DABBLER");
      for (id key in self.spells)
        {
          id value = self.spells[key];
          NSLog(@"DSACharacterHero: prepareLevelUp: spell: %@", value);
          // Check if the value conforms to NSCopying
          if ([value conformsToProtocol:@protocol(NSCopying)])
            {
              tempLevelUpTalents[key] = [value copy];
            }
          else
            {
              tempLevelUpTalents[key] = value; // Shallow copy
            }
          NSLog(@"DSACharacterHero: prepareLevelUp: added spell to tempLevelUpTalents: %@ for Key: %@", tempLevelUpTalents[key], key);
        }
    }
    
  // Update the original dictionary after the loop
  @synchronized(self) {
    self.levelUpTalents = [tempLevelUpTalents mutableCopy];
  }
  
  if (![self isMagicalDabbler]) // magical dabblers have spells, but they're just treated like normal talents
    {
      if (!self.levelUpSpells)
        {
          self.levelUpSpells = [[NSMutableDictionary alloc] init];
        }  
      NSLog(@"Number of spells: %lu", (unsigned long)[self.spells count]); 
      for (id key in self.spells)
        {
          id value = self.spells[key];
          // Check if the value conforms to NSCopying
          if ([value conformsToProtocol:@protocol(NSCopying)])
            {
              tempLevelUpSpells[key] = [value copy];
            }
          else
            {
              tempLevelUpSpells[key] = value; // Shallow copy
            }
        }
        
      SEL levelUpSpecialsWithSpellsSelector = @selector(levelUpSpecialsWithSpells);
      if ([self respondsToSelector:levelUpSpecialsWithSpellsSelector])
        {
          // Safely invoke the selector and store the result as a BOOL
          BOOL shouldLevelUpSpecialsWithSpells = ((BOOL (*)(id, SEL))[self methodForSelector:levelUpSpecialsWithSpellsSelector])(self, levelUpSpecialsWithSpellsSelector);

          if (shouldLevelUpSpecialsWithSpells)
            {
              for (id key in self.specials)
                {
                  id value = self.specials[key];

                  // Check if the value conforms to NSCopying
                  if ([value conformsToProtocol:@protocol(NSCopying)])
                    {
                      tempLevelUpSpells[key] = [value copy];
                    }
                  else
                    {
                      tempLevelUpSpells[key] = value; // Shallow copy
                    }
                }
            }
        }
      // Update the original dictionary after the loop
      @synchronized(self) {
        self.levelUpSpells = [tempLevelUpSpells mutableCopy];
      } 
    }
  // NSLog(@"THE SPELLS IN LEVEL UP SPELLS: %@", self.levelUpSpells);
        
  if (!self.levelUpProfessions)
    {
      self.levelUpProfessions = [[NSMutableDictionary alloc] init];
    }  
  // NSLog(@"Number of professions: %lu", (unsigned long)[self.professions count]); 
  for (id key in self.professions)
    {
      id value = self.professions[key];
      // Check if the value conforms to NSCopying
      if ([value conformsToProtocol:@protocol(NSCopying)])
        {
          tempLevelUpProfessions[key] = [value copy];
        }
      else
        {
          tempLevelUpProfessions[key] = value; // Shallow copy
        }
    }

  // Update the original dictionary after the loop
  @synchronized(self) {
    self.levelUpProfessions = [tempLevelUpProfessions mutableCopy];
  }  
}

- (void) finishLevelUp
{
  self.isLevelingUp = NO;
  self.levelUpTalents = nil;
  self.levelUpSpells = nil;  
  self.levelUpProfessions = nil;
  self.maxLevelUpTalentsTriesTmp = 0;
  self.maxLevelUpSpellsTriesTmp = 0;
  self.tempDeltaLpAe = 0;
  self.level += 1;
}

// for the most characters done here
// others with special constraints, it's done in subclasses
// lifePoints level up described in "Die Helden des schwarzen Auges" Regelbuch II, S. 13

- (NSDictionary *) levelUpBaseEnergies
{
  NSInteger result;
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  result = [Utils rollDice: @"1W6"];
  NSInteger tmp = self.lifePoints;
  self.lifePoints = result + tmp;
  self.currentLifePoints = result + tmp;
  
  [resultDict setObject: @(result) forKey: @"deltaLifePoints"];
  if ([self isMagic])
    {
      result = [Utils rollDice: @"1W6"];
      NSInteger tmp = self.astralEnergy;
      self.astralEnergy = result + tmp;
      self.currentAstralEnergy = result + tmp;
      [resultDict setObject: @(result) forKey: @"deltaAstralEnergy"];
    }

  if ([self isBlessedOne])
    {        
      NSLog(@"leveling up Karma not yet implemented!!!");
      [resultDict setObject: @(result) forKey: @"deltaKarmaPoints"];
    }
  return resultDict;
}

- (BOOL) levelUpPositiveTrait: (NSString *) trait
{
  NSLog(@"DSACharacterHero: BEFORE levelUpPositiveTrait %@", [self.positiveTraits objectForKey: trait]);
  BOOL result = [(DSAPositiveTrait *)[self.positiveTraits objectForKey: trait] levelUp];
  NSLog(@"DSACharacterHero: AFTER levelUpPositiveTrait %@", [self.positiveTraits objectForKey: trait]);
  if (result == YES)  // also bump current positive trait
    {
      [[self.currentPositiveTraits objectForKey: trait] setLevel: [[self.currentPositiveTraits objectForKey: trait] level] + 1];
    }
  return result;
}

- (BOOL) levelDownNegativeTrait: (NSString *) trait
{
  BOOL result = [(DSANegativeTrait *)[self.negativeTraits objectForKey: trait] levelDown];
  if (result == YES)  // also lower current positive trait
    {
      [[self.currentNegativeTraits objectForKey: trait] setLevel: [[self.currentNegativeTraits objectForKey: trait] level] - 1];
    }  
  return result;
}


// basic leveling up of a talent is handled within the talent
- (BOOL) levelUpTalent: (DSATalent *)talent
{
  BOOL result = NO;
  DSATalent *targetTalent = nil;
  DSATalent *tmpTalent = nil;

  targetTalent = talent;
  tmpTalent = [self.levelUpTalents objectForKey: talent.name];

  if (tmpTalent.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHero: levelUpTalent: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
  
  self.maxLevelUpTalentsTriesTmp = self.maxLevelUpTalentsTriesTmp - [talent levelUpCost];

  result = [targetTalent levelUp];
  if (result)
    {
      tmpTalent.maxUpPerLevel = tmpTalent.maxUpPerLevel - 1;
      tmpTalent.maxTriesPerLevelUp = tmpTalent.maxUpPerLevel * 3;
      tmpTalent.level = targetTalent.level;
      
      DSATalent *t = self.currentTalents[talent.name];
      NSLog(@"DSACharacter levelUpTalent: leveling up currentTalent as well currentTalent.level before: %@", @(t.level));
      t.level += 1;
      NSLog(@"DSACharacter levelUpTalent: leveling up currentTalent as well currentTalent.level after: %@", @(t.level));
DSATalent *t1 = self.currentTalents[talent.name];
DSATalent *t2 = self.currentTalents[talent.name];
NSLog(@"Pointers: t1=%p, t2=%p", t1, t2);      
    }
  else
    {
      tmpTalent.maxTriesPerLevelUp = tmpTalent.maxTriesPerLevelUp - 1;
      if ((tmpTalent.maxTriesPerLevelUp % 3) == 0)
        {
          tmpTalent.maxUpPerLevel = tmpTalent.maxUpPerLevel- 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpTalent: (DSATalent *) talent
{
  if (talent.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
    if (self.maxLevelUpTalentsTriesTmp < [talent levelUpCost])  // spells cost
      {
        return NO;
      }
 
  // below test shouldn't really be necessary, because of just last test above, just return YES!!!
  if ([[self.levelUpTalents objectForKey: [talent name]] maxUpPerLevel] <= 0) // actually should never be < 0
    {
      return NO;
    }
  else
    {
      return YES;
    }
}

- (BOOL) levelUpSpell: (DSASpell *)spell
{
  NSLog(@"NSLog DSACharacterHero lLevelUpSpell should be overridden by subclass!");
  return NO;
}
- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  NSLog(@"NSLog DSACharacterHero canLevelUpSpell should be overridden by subclass!");
  return NO;
}

- (BOOL) canLevelUp {
  if ([self isDeadOrUnconscious])
    {
      return NO;
    }

    int currentLevel = self.level;
    int nextLevel = currentLevel + 1;

    // Special case for level 0 to level 1
    if (currentLevel == 0) {
        // Transition from level 0 to level 1 requires 0 points
        return YES;
    }

    // Calculate cumulative adventure points required to reach the current level
    int requiredPoints = [self adventurePointsForNextLevel:nextLevel] - [self adventurePointsForNextLevel:currentLevel];
        
    return self.adventurePoints >= requiredPoints;
}

- (int)adventurePointsForNextLevel:(int)level {
    // Calculate total adventure points required to reach the given level
    // Points required to reach each level increases by 100 more than the previous level
    int totalPoints = 0;
    for (int i = 1; i < level; i++) {
        totalPoints += 100 * i;
    }
    return totalPoints;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
        
  [coder encodeObject:self.levelUpTalents forKey:@"levelUpTalents"];
  [coder encodeObject:self.levelUpSpells forKey:@"levelUpSpells"];  
  [coder encodeObject:self.levelUpProfessions forKey:@"levelUpProfessions"];
  [coder encodeInteger:self.tempDeltaLpAe forKey:@"tempDeltaLpAe"];
  [coder encodeBool:self.isLevelingUp forKey:@"isLevelingUp"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self)
    {                 
      self.levelUpTalents = [coder decodeObjectForKey:@"levelUpTalents"];
      self.levelUpSpells = [coder decodeObjectForKey:@"levelUpSpells"];      
      self.levelUpProfessions = [coder decodeObjectForKey:@"levelUpProfessions"];
      self.tempDeltaLpAe = [coder decodeIntegerForKey:@"tempDeltaLpAe"];
      self.isLevelingUp = [coder decodeBoolForKey:@"isLevelingUp"];     
    }
  return self;
}
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
  NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
  if ([key isEqualToString:@"endurance"])
    {
      keyPaths = [NSSet setWithObjects:@"lifePoints", @"currentPositiveTraits.KK.level", @"enduranceBaseValue", nil];
    }
  else if ([key isEqualToString:@"carryingCapacity"])
    {
      keyPaths = [NSSet setWithObject:@"currentPositiveTraits.KK.level"];
    }
  else if ([key isEqualToString:@"attackBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.MU.level", 
                                         @"currentPositiveTraits.GE.level", 
                                         @"currentPositiveTraits.KK.level", 
                                         @"attackBaseBaseValue", nil];        
    }
  else if ([key isEqualToString:@"parryBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.IN.level", 
                                         @"currentPositiveTraits.GE.level", 
                                         @"currentPositiveTraits.KK.level", 
                                         @"parryBaseBaseValue", nil];        
    }
  else if ([key isEqualToString:@"rangedCombatBaseValue"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.IN.level", 
                                         @"currentPositiveTraits.FF.level", 
                                         @"currentPositiveTraits.KK.level", nil];        
    }
  else if ([key isEqualToString:@"dodge"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.MU.level", 
                                         @"currentPositiveTraits.IN.level", 
                                         @"currentPositiveTraits.GE.level", nil];        
    }
  else if ([key isEqualToString:@"magicResistance"])
    {
        keyPaths = [NSSet setWithObjects:@"currentPositiveTraits.MU.level", 
                                         @"currentPositiveTraits.KL.level",
                                         @"currentNegativeTraits.AG.level",
                                         @"currentMrBonus",
                                         @"level", nil];        
    }                 
  return keyPaths;
}
@end

@implementation DSACharacterHeroElf
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 25;
      self.astralEnergy = 25;
      self.currentLifePoints = 25;
      self.currentAstralEnergy = 25;
      self.maxLevelUpTalentsTries = 25;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 25;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 0;
      self.isMagic = YES;         
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSInteger result;
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  result = [Utils rollDice: @"1W6"] + 2;
 
  self.tempDeltaLpAe = result;
  // we have to ask the user how to distribute these
  [resultDict setObject: @(result) forKey: @"deltaLpAe"];

  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  NSLog(@"DSACharacterHeroElf: the Spell: %@", spell);
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];
  NSLog(@"DSACharacterHeroElf: nr of spells in levelUpSpells: %@", self.levelUpSpells);
  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroElf: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;
      result = YES;
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

// Non-Elf spells can only be leveled up to 11
// See: "Dunkle Städte, Lichte Wälder", "Geheimnisse der Elfen", S. 68
- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (![@[ @"A", @"W", @"F" ] containsObject: spell.origin])
    {
      if (spell.level == 11 )
        {
          return NO;
        }
    }
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] == 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}

@end
// End of DSACharacterHeroElf

@implementation DSACharacterHeroElfSnow
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 30;
      self.currentLifePoints = 30;
      self.mrBonus = self.currentMrBonus = 3;          
    }
  return self;
}
@end
// End of DSACharacterHeroElfSnow

@implementation DSACharacterHeroElfWood
- (instancetype)init
{
  self = [super init];
  if (self)
    { 
      self.mrBonus = self.currentMrBonus = 3;          
    }
  return self;
}
@end
// End of DSACharacterHeroElfWood

@implementation DSACharacterHeroElfMeadow
- (instancetype)init
{
  self = [super init];
  if (self)
    { 
      self.mrBonus = self.currentMrBonus = 3;          
    }
  return self;
}
@end
// End of DSACharacterHeroElfMeadow

@implementation DSACharacterHeroElfHalf
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 30;
      self.astralEnergy = 20;
      self.currentLifePoints = 30;
      self.currentAstralEnergy = 20;
      self.maxLevelUpTalentsTries = 30;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 20; 
      self.mrBonus = self.currentMrBonus = 1;          
    }
  return self;
}
@end
// End of DSACharacterHeroElfHalf

@implementation DSACharacterHeroDwarf
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 40;
      self.astralEnergy = 0;
      self.currentLifePoints = 40;
      self.currentAstralEnergy = 0;
      self.maxLevelUpTalentsTries = 25;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 0;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 0;
      self.mrBonus = self.currentMrBonus = 2;                       // Die Helden des Schwarzen Auges, Regelbuch II S. 40           
    }
  return self;
}
@end
// End of DSACharacterHeroDwarf

@implementation DSACharacterHeroDwarfAngroschPriest
@end
// End of DSACharacterHeroDwarfAngroschPriest

@implementation DSACharacterHeroDwarfGeode
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.astralEnergy = 15;
      self.currentAstralEnergy = 15;
      self.maxLevelUpTalentsTries = 20;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 20;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 10;
      self.mrBonus = self.currentMrBonus = 3;                      // Die Magie des schwarzen Auges S. 49
      self.isMagic = YES;
    }
  return self;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroDwarfGeode: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel* 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
      result = YES;
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] == 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}
@end
// End of DSACharacterHeroDwarfGeode

@implementation DSACharacterHeroDwarfFighter
@end
// End of DSACharacterHeroDwarfFighter

@implementation DSACharacterHeroDwarfCavalier
@end
// End of DSACharacterHeroDwarfCavalier

@implementation DSACharacterHeroDwarfJourneyman
@end
// End of DSACharacterHeroDwarfJourneyman

@implementation DSACharacterHeroHuman
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Most of the human have 30 lifePoints at the start
      // as seen in the character descriptions in "Mit Mantel Schwert und Zauberstab", 
      // and "Die Helden des Schwarzen Auges", Regelbuch II
      self.lifePoints = 30;
      self.astralEnergy = 0;
      self.karmaPoints = 0;
      self.currentLifePoints = 30;
      self.currentAstralEnergy = 0;
      self.currentKarmaPoints = 0;
      self.mrBonus = self.currentMrBonus = 0;
    }
  NSLog(@"DSACharacterHeroHuman before returning self");
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"];
  
  if ([self isMagicalDabbler])  // as explained in "Die Magie des schwarzen Auges" S. 37
    {
      if (result == 1) // 1 point always has to go to the lifePoints
        {
          NSInteger tmp = self.lifePoints;
          self.lifePoints = result + tmp;
          self.currentLifePoints = result + tmp;
          [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaLifePoints"];
        }
      else
        {
          
          NSInteger remainder = result - 1;
          if ( remainder == 1 )
            {
              NSInteger tmp = self.lifePoints;
              self.lifePoints = 1 + tmp;
              self.currentLifePoints = 1 + tmp;
              self.tempDeltaLpAe = 1;
              // we have to ask the user how to distribute the remaining point
              [resultDict setObject: @1 forKey: @"deltaLpAe"];
              [resultDict setObject: @1 forKey: @"deltaLifePoints"];
              self.tempDeltaLpAe = 1;
            }
          else if (remainder > 1)
            {
              NSInteger tmp = self.lifePoints;
              self.lifePoints = result - 2 + tmp;
              self.currentLifePoints = result - 2  + tmp;            

              // we have to ask the user how to distribute remaining points
              [resultDict setObject: @2 forKey: @"deltaLpAe"];        // a maximum of 2 can be assigned to AstralEnergy
              [resultDict setObject: [NSNumber numberWithInteger: result - 2] forKey: @"deltaLifePoints"];
              self.tempDeltaLpAe = 2;
            }          
        }
    }
  else
    {
      NSInteger tmp = self.lifePoints;
      self.lifePoints = result + tmp;
      self.currentLifePoints = result + tmp;
  
      [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaLifePoints"];
      if ([self isMagic])
        {
          result = [Utils rollDice: @"1W6"];
          NSInteger tmp = self.astralEnergy;
          self.astralEnergy = result + tmp;
          self.currentAstralEnergy = result + tmp;
          [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaAstralEnergy"];
        }

      if ([self isBlessedOne])
        {        
          NSLog(@"leveling up Karma not yet implemented!!!");
          [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaKarmaPoints"];
        }
    }
  return resultDict;
}
@end
// End of DSACharacterHeroHuman

@implementation DSACharacterHeroHumanAlchemist
@end
// End of DSACharacterHeroHumanAlchemist

@implementation DSACharacterHeroHumanAmazon
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // see Mit Mantel, Schwert und Zauberstab S. 12
      self.lifePoints = 35;
      self.currentLifePoints = 35;  
    }
  return self;
}
@end
// End of DSACharacterHeroHumanAmazon

@implementation DSACharacterHeroHumanBard
@end
// End of DSACharacterHeroHumanBard

@implementation DSACharacterHeroHumanCharlatan
- (instancetype)init
{
  self = [super init];
  // see "Die Magie des Schwarzen Auges" S. 34
  if (self)
    {
      self.lifePoints = 25;
      self.currentLifePoints = 25;          
      self.astralEnergy = 25;
      self.currentAstralEnergy = 25;
      self.maxLevelUpTalentsTries = 25;        
      self.maxLevelUpSpellsTries = 20;
      self.maxLevelUpTalentsTriesTmp = 25;
      self.maxLevelUpSpellsTriesTmp = 20;      
      self.maxLevelUpVariableTries = 0;
      self.mrBonus = self.currentMrBonus = 2;       
      self.isMagic = YES;                        
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"] + 1;

  // at least 1 point always has to go to the lifePoints AND astralEnergy
  NSInteger tmp = self.lifePoints;
  self.lifePoints = 1 + tmp;
  self.currentLifePoints = 1 + tmp;
  [resultDict setObject: @(1) forKey: @"deltaLifePoints"];
  tmp = self.astralEnergy;
  self.astralEnergy = 1 + tmp;
  self.currentAstralEnergy = 1 + tmp;
  [resultDict setObject: @(1) forKey: @"deltaAstralEnergy"];  
    
  if (result > 2)
    {          
      // we have to ask the user how to distribute remaining points
      [resultDict setObject: @(result - 2) forKey: @"deltaLpAe"];
      self.tempDeltaLpAe = result - 2 ;
    }
  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroCharlatan: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}
@end
// End of DSACharacterHeroHumanCharlatan

@implementation DSACharacterHeroHumanDruid
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.astralEnergy = 25;
      self.currentAstralEnergy = 25;
      self.maxLevelUpTalentsTries = 20;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 25;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 10;
      self.mrBonus = self.currentMrBonus = 2;                      // Die Magie des schwarzen Auges S. 49
      self.isMagic = YES;
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"] + 2;
 
  self.tempDeltaLpAe = result;
  // we have to ask the user how to distribute these
  [resultDict setObject: @(result) forKey: @"deltaLpAe"];

  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroDruid: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}
@end
// End of DSACharacterHeroHumanDruid

@implementation DSACharacterHeroHumanHuntsman
@end
// End of DSACharacterHeroHumanHuntsman

@implementation DSACharacterHeroHumanJester
- (instancetype)init
{
  self = [super init];
  // see "Die Magie des Schwarzen Auges" S. 47
  if (self)
    {
      self.astralEnergy = 25;
      self.currentAstralEnergy = 25;
      self.maxLevelUpTalentsTries = 30;        
      self.maxLevelUpSpellsTries = 20;
      self.maxLevelUpTalentsTriesTmp = 30;
      self.maxLevelUpSpellsTriesTmp = 20;      
      self.maxLevelUpVariableTries = 0;
      self.mrBonus = self.currentMrBonus = 3;          
      self.isMagic = YES;                     
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  // see "Die Magie des Schwarzen Auges" S. 47
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"] + 2;
 
  self.tempDeltaLpAe = result;
  // we have to ask the user how to distribute these
  [resultDict setObject: @(result) forKey: @"deltaLpAe"];

  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroJester: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}
@end
// End of DSACharacterHeroHumanJester

@implementation DSACharacterHeroHumanJuggler
@end
// End of DSACharacterHeroHumanJuggler

@implementation DSACharacterHeroHumanMage
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 25;
      self.astralEnergy = 30;
      self.currentLifePoints = 25;
      self.currentAstralEnergy = 30; 
      self.maxLevelUpTalentsTries = 15;        // Talent und ZF Steigerungen lt. Compendium Salamandris S. 28      
      self.maxLevelUpSpellsTries = 40;
      self.maxLevelUpTalentsTriesTmp = 15;
      self.maxLevelUpSpellsTriesTmp = 40;      
      self.maxLevelUpVariableTries = 10;
      self.mrBonus = self.currentMrBonus = 3;
      self.isMagic = YES;      
    }
  NSLog(@"DSACharacterHeroHumanMage before returning self");
  return self;
}

- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  NSLog(@"DSACharacterHeroHumanMage: the Spell: %@", spell);
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];
  NSLog(@"DSACharacterHeroHumanMage: nr of spells in levelUpSpells: %@", self.levelUpSpells);
  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroHumanMage: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -=  1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
      result = YES;
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxTriesPerLevelUp - 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] == 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}
@end
// End of DSACharacterHeroHumanMage

@implementation DSACharacterHeroHumanMercenary
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // see Mit Mantel, Schwert und Zauberstab S. 53
      self.mrBonus = self.currentMrBonus = 1;
    }
  return self;
}
@end
// End of DSACharacterHeroHumanMercenary

@implementation DSACharacterHeroHumanMoha
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // as described in Mit Mantel Schwert und Zauberstab S. 43
      self.mrBonus = self.currentMrBonus = -3;      
    }
  return self;
}
@end
// End of DSACharacterHeroHumanMoha

@implementation DSACharacterHeroHumanNivese
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // see Mit Mantel, Schwert und Zauberstab S. 45
      self.mrBonus = self.currentMrBonus = -1;
    }
  return self;
}
@end
// End of DSACharacterHeroHumanNivese

@implementation DSACharacterHeroHumanNorbarde
@end
// End of DSACharacterHeroHumanNorbarde

@implementation DSACharacterHeroHumanNovadi
@end
// End of DSACharacterHeroHumanNovadi

@implementation DSACharacterHeroHumanPhysician
@end
// End of DSACharacterHeroHumanPhysician

@implementation DSACharacterHeroHumanRogue
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // as described in "Mit Mantel, Schwert und Zauberstab" S. 55
      self.mrBonus = self.currentMrBonus = 2;
    }
  return self;
}
@end
// End of DSACharacterHeroHumanRogue

@implementation DSACharacterHeroHumanSeafarer
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // as described in "Mit Mantel, Schwert und Zauberstab" S. 55
      self.mrBonus = self.currentMrBonus = 0;
    }
  return self;
}
// mrBonus is dynamic, as described in "Mit Mantel, Schwert und Zauberstab",
// S. 51
- (NSInteger) mrBonus
{
  if (self.level < 5)
    {
      return [super mrBonus] - 1;
    }
  return [super mrBonus];
}
- (NSInteger) currentMrBonus
{
  if (self.level < 5)
    {
      return [super currentMrBonus] - 1;
    }
  return [super currentMrBonus];
}
@end
// End of DSACharacterHeroHumanSeafarer

@implementation DSACharacterHeroHumanShaman
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.astralEnergy = 15;
      self.currentAstralEnergy = 15;
      self.maxLevelUpTalentsTries = 20;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 10;
      self.maxLevelUpTalentsTriesTmp = 20;
      self.maxLevelUpSpellsTriesTmp = 10;      
      self.maxLevelUpVariableTries = 10;
      self.mrBonus = self.currentMrBonus = 3;                      // Die Magie des schwarzen Auges S. 40
      self.isMagic = NO;                     // default to NO, but might be switched to YES for some in character generation
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  if (self.spells == nil || [self.spells count] == 0)  // standard shaman without druid spells
    {
      NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
      NSInteger result = [Utils rollDice: @"1W6"] + 1;

      // at least 1 point always has to go to the lifePoints AND astralEnergy
      NSInteger tmp = self.lifePoints;
      self.lifePoints = 1 + tmp;
      self.currentLifePoints = 1 + tmp;
      [resultDict setObject: @(1) forKey: @"deltaLifePoints"];
      tmp = self.astralEnergy;
      self.astralEnergy = 1 + tmp;
      self.currentAstralEnergy = 1 + tmp;
      [resultDict setObject: @(1) forKey: @"deltaAstralEnergy"];  
    
      if (result > 2)
        {          
          // we have to ask the user how to distribute remaining points
          [resultDict setObject: [NSNumber numberWithInteger: result - 2 ] forKey: @"deltaLpAe"];
          self.tempDeltaLpAe = result - 2;
        }
      return resultDict;
    }
  else
    {
      NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
      NSInteger result = [Utils rollDice: @"1W6"] + 2;
 
      self.tempDeltaLpAe = result;
      // we have to ask the user how to distribute these
      [resultDict setObject: @(result) forKey: @"deltaLpAe"];

      return resultDict;    
    }
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroHumanShaman: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{

  NSLog(@"checking if we can level up spell: %@, %lu", spell.name, (unsigned long)[[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel]);
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return YES;
}
@end
// End of DSACharacterHeroHumanShaman

@implementation DSACharacterHeroHumanSharisad
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 30;
      self.astralEnergy = 15;
      self.currentLifePoints = 30;
      self.currentAstralEnergy = 15;   
      // not setting: maxLevelUpSpellsTries, as it's dependent on origin
      self.isMagic = NO;                        // but will set it later to YES when assigning the magic dances
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"];
 
  if (self.astralEnergy + result > 30) // AstralEnergy can't go above 30
    {
      NSInteger diff = 30 - self.astralEnergy;
      self.lifePoints = self.lifePoints + diff;
      self.tempDeltaLpAe = result - diff;
      // we have to ask the user how to distribute these
      [resultDict setObject: @(self.tempDeltaLpAe) forKey: @"deltaLpAe"];  
      [resultDict setObject: @(diff) forKey: @"deltaLifePoints"];
    }
  else
    {
       self.tempDeltaLpAe = result;  
      // we have to ask the user how to distribute these
      [resultDict setObject: @(result) forKey: @"deltaLpAe"];         
    }

  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroSharisad: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return YES;
}
@end
// End of DSACharacterHeroHumanSharisad

@implementation DSACharacterHeroHumanSkald
@end
// End of DSACharacterHeroHumanSkald

@implementation DSACharacterHeroHumanThorwaler
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.origin = @"Thorwal";
      self.mrBonus = self.currentMrBonus = 0;
    }
  return self;
}

// mrBonus is dynamic, as described in "Die Helden des Schwarzen Auges",
// Regelbuch II, S. 59
- (NSInteger) mrBonus
{
  if (self.level < 5)
    {
      return [super mrBonus] - 1;
    }
  return [super mrBonus];
}
- (NSInteger) currentMrBonus
{
  if (self.level < 5)
    {
      return [super currentMrBonus] - 1;
    }
  return [super currentMrBonus];
}
@end
// End of DSACharacterHeroHumanThorwaler

@implementation DSACharacterHeroHumanWarrior
@end
// End of DSACharacterHeroHumanWarrior

@implementation DSACharacterHeroHumanWitch
- (instancetype)init
{
  self = [super init];
  // see "Die Magie des Schwarzen Auges" S. 43
  if (self)
    {
      self.lifePoints = 25;
      self.currentLifePoints = 25;          
      self.astralEnergy = 25;
      self.currentAstralEnergy = 25;
      self.maxLevelUpTalentsTries = 25;        
      self.maxLevelUpSpellsTries = 30;
      self.maxLevelUpTalentsTriesTmp = 25;
      self.maxLevelUpSpellsTriesTmp = 30;      
      self.maxLevelUpVariableTries = 0;
      self.mrBonus = self.currentMrBonus = 2;   
      self.isMagic = YES;                            
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"] + 2;
 
  self.tempDeltaLpAe = result;
  // we have to ask the user how to distribute these
  [resultDict setObject: @(result) forKey: @"deltaLpAe"];

  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroWitch: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      DSASpell *s = self.currentSpells[spell.name];
      s.level += 1;
      s.everLeveledUp = YES;      
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}
@end
// End of DSACharacterHeroHumanWitch

@implementation DSACharacterHeroBlessed
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Most of the human have 30 lifePoints at the start
      // as seen in the character descriptions in "Mit Mantel Schwert und Zauberstab", 
      // and "Die Helden des Schwarzen Auges", Regelbuch II
      self.lifePoints = 30;
      self.astralEnergy = 0;
      self.karmaPoints = 24;           // for Blessed ones of Gods, Halfgods only will have 12 Karma Points, See Kirchen, Kulte, Ordenskrieger S. 10
      self.currentLifePoints = 30;
      self.currentAstralEnergy = 0;
      self.currentKarmaPoints = 24;
      self.isBlessedOne = YES;
      self.mrBonus = self.currentMrBonus = 0;
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"];
  
  NSInteger tmp = self.lifePoints;
  self.lifePoints = result + tmp;
  self.currentLifePoints = result + tmp;
 
  [resultDict setObject: @(result) forKey: @"deltaLifePoints"];
       
  // See: Kirchen, Kulte, Ordenskrieger, S. 17 (Visionsqueste, 1x/Stufe), Blessed ones for half-gods, have different calculation
  result = [Utils rollDice: @"1W3"] + 4;
  tmp = self.karmaPoints;
  self.karmaPoints = result + tmp;
  self.currentKarmaPoints = result + tmp;
    
  [resultDict setObject: @(result) forKey: @"deltaKarmaPoints"];

  return resultDict;
}
@end
// End of DSACharacterHeroBlessed

@implementation DSACharacterHeroBlessedPraios
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 3; // see "Die Götter des schwarzen Auges" S. 36
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedPraios

@implementation DSACharacterHeroBlessedRondra
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 42
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedRondra

@implementation DSACharacterHeroBlessedEfferd
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 45
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedEfferd

@implementation DSACharacterHeroBlessedTravia
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 47
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedTravia

@implementation DSACharacterHeroBlessedBoron
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 52
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedBoron

@implementation DSACharacterHeroBlessedHesinde
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 2; // see "Die Götter des schwarzen Auges" S. 57
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedHesinde

@implementation DSACharacterHeroBlessedFirun
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 0; // see "Die Götter des schwarzen Auges" S. 59, nothing specifically mentioned??
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedFirun

@implementation DSACharacterHeroBlessedTsa
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 0; // see "Die Götter des schwarzen Auges" S. 61, nothing specifically mentioned??
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedTsa

@implementation DSACharacterHeroBlessedPhex
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 64
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedPhex

@implementation DSACharacterHeroBlessedPeraine
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 0; // see "Die Götter des schwarzen Auges" S. 66, nothing specifically mentioned??
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedPeraine

@implementation DSACharacterHeroBlessedIngerimm
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 69
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedIngerimm

@implementation DSACharacterHeroBlessedRahja
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.mrBonus = self.currentMrBonus = 1; // see "Die Götter des schwarzen Auges" S. 72
    }
  return self;
}
@end
// End of DSACharacterHeroBlessedRahja

@implementation DSACharacterHeroBlessedSwafnir
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.karmaPoints = 10;           // see "Die Götter des schwarzen Auges" S. 90
      self.currentKarmaPoints = 10;    
      self.mrBonus = self.currentMrBonus = 0;
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"];
  
  NSInteger tmp = self.lifePoints;
  self.lifePoints = result + tmp;
  self.currentLifePoints = result + tmp;
 
  [resultDict setObject: @(result) forKey: @"deltaLifePoints"];
       
  // See: Kirchen, Kulte, Ordenskrieger Swafnir is different than other Blessed Ones
  result = [Utils rollDice: @"1W6"] - 1;
  tmp = self.karmaPoints;
  self.karmaPoints = result + tmp;
  self.currentKarmaPoints = result + tmp;
    
  [resultDict setObject: @(result) forKey: @"deltaKarmaPoints"];

  return resultDict;
}
@end
// End of DSACharacterHeroBlessedSwafnir

@implementation DSACharacterNpc : DSACharacter

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.isNPC = YES;
    }
  return self;
}

// No wild calculations for NPCs, just return the mrBonus value...
- (NSInteger) magicResistance {
  return self.currentMrBonus;
}

- (NSInteger) attackBaseValue {
  return self.staticAttackBaseValue;
}

- (NSInteger) parryBaseValue {
  return self.staticParryBaseValue;
}

- (BOOL) canLevelUp
{
  return NO;
}

@end
// End of DSACharacterNpc

@implementation DSACharacterNpcHumanoid : DSACharacterNpc
@end
// End of DSACharacterNpcHumanoid

@implementation DSACharacterNpcHumanoidAchaz : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidAchaz

@implementation DSACharacterNpcHumanoidApeman : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidApeman

@implementation DSACharacterNpcHumanoidElf : DSACharacterNpcHumanoid
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.maxLevelUpTalentsTries = 25;
      self.maxLevelUpSpellsTries = 25;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 0;
      self.isMagic = YES;         
    }
  return self;
}
@end
// End of DSACharacterNpcHumanoidElf

@implementation DSACharacterNpcHumanoidFerkina : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidFerkina

@implementation DSACharacterNpcHumanoidFishman : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidFishman

@implementation DSACharacterNpcHumanoidGoblin : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidGoblin

@implementation DSACharacterNpcHumanoidKrakonier : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidKrakonier

@implementation DSACharacterNpcHumanoidMarus : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidMarus

@implementation DSACharacterNpcHumanoidOger : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidOger

@implementation DSACharacterNpcHumanoidOrk : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidOrk

@implementation DSACharacterNpcHumanoidRiese : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidRiese

@implementation DSACharacterNpcHumanoidTroll : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidTroll

@implementation DSACharacterNpcHumanoidYeti : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidYeti

@implementation DSACharacterNpcHumanoidZyklop : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidZyklop