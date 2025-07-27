/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 23:01:49 +0200 by sebastia

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
#import "DSASpell.h"
#import "DSASpellResult.h"
#import "DSATrait.h"
#import "DSADefinitions.h"
#import "DSAActionParameterDescriptor.h"
#import "DSAAdventureGroup.h"

@implementation DSASpell

static NSDictionary<NSString *, Class> *typeToClassMap = nil;

+ (void)initialize
{
  if (self == [DSASpell class])
    {
      @synchronized(self)
        {
          if (!typeToClassMap)
            {
              typeToClassMap = @{
                _(@"Beherrschungen brechen"): [DSASpellBeherrschungenBrechen class],
                _(@"Bewegungen stören"): [DSASpellBewegungenStoeren class],
                _(@"Destructibo Arcanitas"): [DSASpellDestructiboArcanitas class],
                _(@"Balsam Salabunde"): [DSASpellBalsamSalabunde class],
                _(@"Klarum Purum Kräutersud"): [DSASpellKlarumPurum class],
                _(@"Analüs Arcanstruktur"): [DSASpellAnaluesArcanstruktur class],
                _(@"Odem Arcanum Senserei"): [DSASpellOdemArcanum class],                
              };
            }
        }
    }
}

+ (instancetype)spellWithName: (NSString *) name
                    ofVariant: (NSString *) variant
            ofDurationVariant: (NSString *) durationVariant
                   ofCategory: (NSString *) category 
                      onLevel: (NSInteger) level
                   withOrigin: (NSArray *) origin
                     withTest: (NSArray *) test
              withMaxDistance: (NSInteger) maxDistance          
                 withVariants: (NSArray *) variants
         withDurationVariants: (NSArray *) durationVariants
       withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
            withMaxUpPerLevel: (NSInteger) maxUpPerLevel
              withLevelUpCost: (NSInteger) levelUpCost
{
  Class subclass = [typeToClassMap objectForKey: name];
  if (subclass)
    {
      NSLog(@"DSASpell: spellWithName: %@ going to call initSpell...", name);
      return [[subclass alloc] initSpell: name
                               ofVariant: variant
                       ofDurationVariant: durationVariant
                              ofCategory: category
                                 onLevel: level
                              withOrigin: origin
                                withTest: test
                         withMaxDistance: (NSInteger) maxDistance                                
                            withVariants: variants
                    withDurationVariants: durationVariants
                  withMaxTriesPerLevelUp: maxTriesPerLevelUp
                       withMaxUpPerLevel: maxUpPerLevel
                         withLevelUpCost: levelUpCost];
    }
  // handle unknown type
  NSLog(@"DSASpell: spellWithName: %@ not found returning NIL", name);
  return nil;
}

- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.targetType = DSAActionTargetTypeNone;
      self.parameterValues = [[NSMutableDictionary alloc] init];
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;
      self.removalCostASP = 0;   
      self.penalty = 0;  
      self.casterLevel = -1;
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = maxDistance;
      self.canCastOnSelf = NO;
      self.allowedTargetTypes = @[];
      self.targetTypeRestrictions = @{}; 
      self.aspCost = 0;
      self.permanentASPCost = 0;
      self.lpCost = 0;
      self.permanentLPCost = 0;
    }
  return self;
}


-(void)setTargetType: (DSAActionTargetType) targetType
{
  _targetType = targetType;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.name = [coder decodeObjectForKey:@"name"];
      self.level = [coder decodeIntegerForKey:@"level"];
      self.targetType = [coder decodeIntegerForKey:@"targetType"];
      self.parameterDescriptors = [coder decodeObjectForKey:@"parameterDescriptors"];
      self.parameterValues = [coder decodeObjectForKey:@"parameterValues"];
      self.origin = [coder decodeObjectForKey:@"origin"];
      self.longName = [coder decodeObjectForKey:@"longName"];
      self.category = [coder decodeObjectForKey:@"category"];
      self.element = [coder decodeObjectForKey:@"element"];
      self.technique = [coder decodeObjectForKey:@"technique"];
      self.test = [coder decodeObjectForKey:@"test"];
      self.variants = [coder decodeObjectForKey:@"variants"];
      self.variant = [coder decodeObjectForKey:@"variant"];
      self.durationVariants = [coder decodeObjectForKey:@"durationVariants"];
      self.durationVariant = [coder decodeObjectForKey:@"durationVariant"];      
      
      self.allowedTargetTypes = [coder decodeObjectForKey:@"allowedTargetTypes"];
      self.targetTypeRestrictions = [coder decodeObjectForKey:@"targetTypeRestrictions"];
           
      self.spellDuration = [coder decodeIntegerForKey:@"spellDuration"];
      self.spellingDuration = [coder decodeIntegerForKey:@"spellingDuration"];
      self.maxDistance = [coder decodeIntegerForKey:@"maxDistance"];
      self.maxUpPerLevel = [coder decodeIntegerForKey:@"maxUpPerLevel"];
      self.maxTriesPerLevelUp = [coder decodeIntegerForKey:@"maxTriesPerLevelUp"];
      self.levelUpCost = [coder decodeIntegerForKey:@"levelUpCost"];  
      self.removalCostASP = [coder decodeIntegerForKey:@"removalCostASP"];   
      self.penalty = [coder decodeIntegerForKey:@"penalty"];
      self.casterLevel = [coder decodeIntegerForKey:@"casterLevel"]; 
      self.everLeveledUp = [coder decodeBoolForKey:@"everLeveledUp"];
      self.isTraditionSpell = [coder decodeBoolForKey:@"isTraditionSpell"];
      self.canCastOnSelf = [coder decodeBoolForKey:@"canCastOnSelf"];
      self.aspCost = [coder decodeIntegerForKey:@"aspCost"];
      self.permanentASPCost = [coder decodeIntegerForKey:@"permanentASPCost"];
      self.lpCost = [coder decodeIntegerForKey:@"lpCost"];
      self.permanentLPCost = [coder decodeIntegerForKey:@"permanentLPCost"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeInteger:self.targetType forKey:@"targetType"];
  [coder encodeObject:self.parameterDescriptors forKey:@"parameterDescriptors"];
  [coder encodeObject:self.parameterValues forKey:@"parameterValues"];
  if (!self.parameterValues)
    {
      self.parameterValues = [[NSMutableDictionary alloc] init];
    }
  [coder encodeObject:self.origin forKey:@"origin"];
  [coder encodeObject:self.longName forKey:@"longName"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeObject:self.element forKey:@"element"];
  [coder encodeObject:self.technique forKey:@"technique"];
  [coder encodeObject:self.test forKey:@"test"];
  [coder encodeObject:self.variants forKey:@"variants"];
  [coder encodeObject:self.variant forKey:@"variant"];
  [coder encodeObject:self.durationVariants forKey:@"durationVariants"];
  [coder encodeObject:self.durationVariant forKey:@"durationVariant"];
    
  [coder encodeObject:self.allowedTargetTypes forKey:@"allowedTargetTypes"];
  [coder encodeObject:self.targetTypeRestrictions forKey:@"targetTypeRestrictions"];
  
  [coder encodeInteger:self.spellDuration forKey:@"spellDuration"];
  [coder encodeInteger:self.spellingDuration forKey:@"spellingDuration"];
  [coder encodeInteger:self.maxDistance forKey:@"maxDistance"];
  [coder encodeInteger:self.maxUpPerLevel forKey:@"maxUpPerLevel"];
  [coder encodeInteger:self.maxTriesPerLevelUp forKey:@"maxTriesPerLevelUp"]; 
  [coder encodeInteger:self.levelUpCost forKey:@"levelUpCost"];
  [coder encodeInteger:self.removalCostASP forKey:@"removalCostASP"]; 
  [coder encodeInteger:self.penalty forKey:@"penalty"];
  [coder encodeInteger:self.casterLevel forKey:@"casterLevel"];
  [coder encodeBool:self.everLeveledUp forKey:@"everLeveledUp"];   
  [coder encodeBool:self.isTraditionSpell forKey:@"isTraditionSpell"];
  [coder encodeBool:self.canCastOnSelf forKey:@"canCastOnSelf"];
  [coder encodeInteger:self.aspCost forKey:@"aspCost"];
  [coder encodeInteger:self.permanentASPCost forKey:@"permanentASPCost"];
  [coder encodeInteger:self.lpCost forKey:@"lpCost"];
  [coder encodeInteger:self.permanentLPCost forKey:@"permanentLPCost"];
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
  DSASpell *copy = [[[self class] allocWithZone:zone] init];

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

- (BOOL) levelUp;
{
  NSInteger result = 0;
  
  if (self.level < 10)
    {
      result = [Utils rollDice:@"2W6"];
    }
  else
    {
      result = [Utils rollDice:@"3W6"];
    }
  if (result > self.level)
    {
      self.level += 1;
      self.everLeveledUp = YES;
      return YES;
    }
  else
    {
      return NO;
    }
}

// if the spell is active, or passive, as described in: 
// "Die Magie des Schwarzen Auges" S. 13
- (BOOL) isActiveSpell
{
  if (self.isTraditionSpell)
    {
      return YES;
    }
  if (self.everLeveledUp && self.level > -6)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

// spelling related methods
- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpell castOnTarget called!");
  DSASpellResult *result = [[DSASpellResult alloc] init];
  result.resultDescription = [NSString stringWithFormat: _(@"%@ ist noch nicht implementiert."), self.name];
  return result;
}

- (BOOL) applyEffectOnTarget: (id) target forOwner: (NSString *) ownerUUID
{
  NSLog(@"DSASpell applyEffectOnTarget called, not implemented in SubClass!");
  return YES;
}

// spelling related helper methods

- (BOOL) verifyDistance: (NSInteger) distance
{
  NSLog(@"DSASpell verifyDistance: maxDistance: %@ distance: %@", @(self.maxDistance), @(distance));
  return self.maxDistance >= distance ? YES : NO;
}



- (BOOL) verifyTarget: (id) target
            forCaster: (DSACharacter *) caster
{
      if ([target isKindOfClass: [DSACharacter class]])
        {
        
          if (![self.allowedTargetTypes containsObject: @"DSACharacter"])
            {
              return NO;
            }
          if (!self.canCastOnSelf)
            {
              if ([[(DSACharacter *)target modelID] isEqual: caster.modelID])
                {
                  return NO;
                }
            }
        }
      else if ([target isKindOfClass:[DSAObject class]])
        {
          if (![self.allowedTargetTypes containsObject: @"DSAObject"])
            {
              return NO;
            }        
          if ([self.targetTypeRestrictions count] > 0)
            {
              for (NSString *constraint in [self.targetTypeRestrictions allKeys])
                {
                  SEL selector = NSSelectorFromString(constraint);

                  if ([target respondsToSelector:selector]) // Check if the selector exists
                    { 
                      NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
                      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                      [invocation setSelector:selector];
                      [invocation setTarget:target];

                      // Invoke the method
                      [invocation invoke];

                      // Get the return value (assume it's an object, cast appropriately)
                      __unsafe_unretained NSString *returnValue = nil;
                      [invocation getReturnValue:&returnValue];

                      // Check if the return value is in the constraint list
                      if (![[self.targetTypeRestrictions objectForKey:constraint] containsObject:returnValue])
                        {
                          return NO;
                        }
                    }
                }
            }
        }
      else if ([target isKindOfClass:[DSAAdventureGroup class]])  
            if ([target isKindOfClass: [DSAAdventureGroup class]])
        {
        
          if (![self.allowedTargetTypes containsObject: @"DSAAdventureGroup"])
            {
              return NO;
            }
          DSAAdventureGroup *group = (DSAAdventureGroup *) target;
          if (![group.allMembers containsObject: caster.modelID])
            {
              return NO;
            }
        }
      return YES;
}

- (DSASpellResult *) verifyParametersForTarget: (id) target
                                   withVariant: (NSString *) variant
                           withDurationVariant: (NSString *) durationVariant
                                  withDistance: (NSInteger) distance
                                    withCaster: (DSACharacter *) castingCharacter
                                    withOrigin: (DSACharacter *) spellOriginCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  if (![self.variants containsObject: variant])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist eine unbekannte Variante des Zaubers."), variant];
      return spellResult;      
    }
  if (![self.durationVariants containsObject: durationVariant])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist eine unbekannte Zauberdauervariante des Zaubers."), durationVariant];
      return spellResult;      
    }     
  if (![self verifyTarget: target forCaster: castingCharacter])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ kann den Spruch %@ nicht auf das Ziel sprechen."), castingCharacter.name, self.name];
      return spellResult;      
    }
  if (![self verifyDistance: distance])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"Ziel ist zu weit entfernt.")];
      return spellResult;
    }
  
  return spellResult;  
}                                    
                               
                                  

- (DSASpellResult *) testTraitsWithSpellLevel: (NSInteger) level 
                             castingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  NSMutableArray *resultsArr = [[NSMutableArray alloc] init];
  NSInteger initialLevel = level;
  NSInteger oneCounter = 0;
  NSInteger twentyCounter = 0;
  BOOL earlyFailure = NO;
  NSInteger counter = 0;
  for (NSString *trait in self.test)
    {
      NSInteger traitLevel = [[castingCharacter.positiveTraits objectForKey: trait] level];
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
          if (result <= traitLevel)
            {
            
            }
          else
            {
              level = level - (result - traitLevel);
              if (level < 0)
                {
                  earlyFailure = YES;
                }
            }
        }
      else
        {
          if (result <= traitLevel)
            {
              level = level + (traitLevel - result);
              if (level < 0 && counter == 2)
                {
                  earlyFailure = YES;
                }
            }
          else
            {
              earlyFailure = YES;
            }
        }
      counter += 1;
    }
  if (oneCounter >= 2)
    {
      if (oneCounter == 2)
        {
          spellResult.result = DSAActionResultAutoSuccess;
          spellResult.resultDescription = @"Der Zauber ist gut gelungen!";
          spellResult.remainingSpellPoints = level;
        }
      else
        {
          spellResult.result = DSAActionResultEpicSuccess;
          spellResult.resultDescription = @"Der Zauber ist phänomenal gelungen!";
          spellResult.remainingSpellPoints = level;        
        }
    }
  else if (twentyCounter >= 2)
    {
      if (twentyCounter == 2)
        {
          spellResult.result = DSAActionResultAutoFailure;
          spellResult.resultDescription = @"Der Zauber ist ganz schön daneben gegangen!";
          spellResult.remainingSpellPoints = level;        
        }
      else
        {
          spellResult.result = DSAActionResultEpicFailure;
          spellResult.resultDescription = @"Der Zauber ist phänomenal fehlgeschlagen!";
          spellResult.remainingSpellPoints = level;          
        }
    }
  else
    {
      if (earlyFailure == YES)
        {
          spellResult.result = DSAActionResultFailure;
          spellResult.resultDescription = @"Der Zauber ist fehlgeschlagen!";
          spellResult.remainingSpellPoints = level;
        }
      else
        {
          spellResult.result = DSAActionResultSuccess;
          spellResult.resultDescription = @"Der Zauber hat geklappt!";
          spellResult.remainingSpellPoints = level;
        }
    }
  spellResult.diceResults = resultsArr;

  return spellResult;
}


// end of spelling related methods

+ (NSSet *)keyPathsForValuesAffectingIsActiveSpell
{

   return [NSSet setWithObjects:@"everLeveledUp",
                                @"level",
                                @"isTraditionSpell", nil];
}

/*+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
  NSLog(@"DSASpell keyPathsForValuesAffectingValueForKey: %@", key);
  NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
  if ([key isEqualToString:@"isActiveSpell"])
    {
      keyPaths = [NSSet setWithObjects:@"everLeveledUp",
                                       @"level",
                                       @"isTraditionSpell", nil];
    }
    return keyPaths;
} */

@end


// All the DSASpell spell subclasses go here

#pragma mark - Antimagie

@implementation DSASpellBeherrschungenBrechen
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.targetType = DSAActionTargetTypeHuman;
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;
      self.removalCostASP = 0;      
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 1;
      self.targetType = DSAActionTargetTypeHuman;
      self.allowedTargetTypes = @[ @"DSACharacter" ];
      self.spellDuration = -1;
      self.spellingDuration = 60;
    }
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellBeherrschungenBrechen called!");
  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];
  
  NSInteger costAE = (originCharacter.level - castingCharacter.level) * 4 >= 8 ? : 8 ;
  if (castingCharacter.currentAstralEnergy < costAE)  // not enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  NSInteger level = self.level - [(DSACharacter *)target mrBonus];
  spellResult = [self testTraitsWithSpellLevel: level castingCharacter: castingCharacter];

  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= costAE;
      NSLog(@"TODO implement spell effect on target.");
    }
  else
    {
      castingCharacter.currentAstralEnergy -= roundf(costAE/2);
    }
  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             

@end

@implementation DSASpellBewegungenStoeren
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;
      self.removalCostASP = 0;     
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 49;
      self.canCastOnSelf = YES;
      self.targetType = DSAActionTargetTypeAny;
      self.allowedTargetTypes = @[ @"DSACharacter", @"DSAObject" ];
      self.spellDuration = -1;
      self.spellingDuration = 2;      
    }
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant       
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellBewegungenStoeren called!");
  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];
  
  NSInteger costAE = (originCharacter.level - castingCharacter.level) * 3 >= 6 ? : 6 ;
  if (castingCharacter.currentAstralEnergy < costAE)  // not enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  NSInteger level = self.level;
  spellResult = [self testTraitsWithSpellLevel: level castingCharacter: castingCharacter];

  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= costAE;
      NSLog(@"TODO implement spell effect on target.");
    }
  else
    {
      castingCharacter.currentAstralEnergy -= roundf(costAE/2);
    }
  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             
@end

@implementation DSASpellDestructiboArcanitas
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;  
      self.removalCostASP = 0;    
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 1;
      self.canCastOnSelf = NO;
      self.targetType = DSAActionTargetTypeObject;
      self.allowedTargetTypes = @[ @"DSAObject" ];
      self.spellDuration = -1;
      self.spellingDuration = 60;      
    }
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDestructiboArcanitas called!");
  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];

  NSInteger totalRemovalCost = 0;
  for (DSASpell *spell in [[(DSAObject *)target appliedSpells] allValues])
    {
      totalRemovalCost += spell.removalCostASP;
    }      
  if (castingCharacter.currentAstralEnergy < totalRemovalCost)  // not enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  NSInteger level = self.level - [[(DSAObject *)target appliedSpells] count] * 5;
  spellResult = [self testTraitsWithSpellLevel: level castingCharacter: castingCharacter];
 
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= totalRemovalCost;
      castingCharacter.astralEnergy -= roundf(totalRemovalCost * 2 / 3);  // aufgewendete Astralenergie ist zu großen Teilen für immer verloren
      NSLog(@"TODO implement spell effect on target.");
    }
  else
    {
      castingCharacter.currentAstralEnergy -= roundf(totalRemovalCost/2);
    }
  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             
@end

#pragma mark - Heilung

@implementation DSASpellBalsamSalabunde
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;  
      self.removalCostASP = 0;    
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 1;             // has to be close by
      self.canCastOnSelf = YES;
      self.targetType = DSAActionTargetTypeAlly;
      self.allowedTargetTypes = @[ @"DSACharacter" ];
      self.spellDuration = -1;          // permanent
      self.spellingDuration = 300;      // seconds
      
      DSAActionParameterDescriptor *asp = [DSAActionParameterDescriptor descriptorWithKey:@"aspAmount"
                                                                                   label:@"wieviele LP heilen"
                                                                                helpText:@"1 ASP Kosten je LP, mindestens 7 ASP. Wenn weniger als 7 ASP vorhanden sind, dann alles was vorhanden ist. Mindestens 10 ASP um kürzlich Verstorbene zu erwecken."
                                                                                    type:DSAActionParameterTypeInteger];
      asp.minValue = 1;
      asp.maxValue = NSIntegerMax;
      self.parameterDescriptors = @[ asp ]; 
      
    }
  NSLog(@"DSASpellBalsamSalabunde initSpell returning self: %@", self);  
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP_unused
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellBalsamSalabunde castOnTarget called!");

  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];
  
  NSNumber *investedNumber = (NSNumber *)self.parameterValues[@"aspAmount"];
  NSInteger investedASP = [investedNumber integerValue];
  
  DSACharacter *targetCharacter = (DSACharacter *)target;
  if (targetCharacter.currentLifePoints <= 0)
    {
      if (investedASP < 10)
        {
          spellResult.result = DSAActionResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Es sind mindestens 10 ASP notwendig, um %@ wiederzuerwecken."), [(DSACharacter *)target name]];
          return spellResult;          
        }
    }

  NSInteger availableASP = castingCharacter.currentAstralEnergy;
  NSInteger minASP = MIN(7, availableASP);
  if (investedASP < minASP)
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"Mindestens %ld ASP erforderlich (bzw. alles was du hast)"), (long)minASP];
      return spellResult;
    }
    
  spellResult = [self testTraitsWithSpellLevel: self.level castingCharacter: castingCharacter];
 
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= investedASP;
      if (targetCharacter.currentLifePoints <= 0)
        {
          targetCharacter.currentLifePoints = 1;
          [targetCharacter updateStatesDictState: @(DSACharacterStateDead)
                                       withValue: @(NO)];
          [targetCharacter updateStatesDictState: @(DSACharacterStateUnconscious)
                                       withValue: @(YES)];
          spellResult.resultDescription = [NSString stringWithFormat: @"%@ %@ kann %@ aus dem Reich Borons zurückholen.", 
                                                                      spellResult.resultDescription,
                                                                      castingCharacter.name,
                                                                      targetCharacter.name];                                                                   
        }
      else
        {
          NSInteger oldLifePoints = targetCharacter.currentLifePoints;
          NSInteger newLifePoints = (targetCharacter.currentLifePoints  + investedASP) < targetCharacter.lifePoints 
                                         ? targetCharacter.currentLifePoints  + investedASP 
                                         : targetCharacter.lifePoints;
                                        
          targetCharacter.currentLifePoints = newLifePoints;
          spellResult.resultDescription = [NSString stringWithFormat: @"%@ %@ kann %@ LP bei %@ wiederherstellen.", 
                                                                      spellResult.resultDescription,
                                                                      castingCharacter.name,
                                                                      @(newLifePoints - oldLifePoints),
                                                                      targetCharacter.name];          
        }
    }
  else
    {
      castingCharacter.currentAstralEnergy -= roundf(investedASP/2);
    }
  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             
@end
@implementation DSASpellKlarumPurum
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;  
      self.removalCostASP = 0;    
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 1;             // has to be close by
      self.canCastOnSelf = YES;
      self.targetType = DSAActionTargetTypeAlly;
      self.allowedTargetTypes = @[ @"DSACharacter" ];
      self.spellDuration = -1;          // permanent
      self.spellingDuration = 7;      // seconds
      
      DSAActionParameterDescriptor *asp = [DSAActionParameterDescriptor descriptorWithKey:@"aspAmount"
                                                                                   label:@"wieviele ASP sollen investiert werden?"
                                                                                helpText:@"1 ASP je Stufe des Giftes nötig. ei Einsatz von zu wenigen ASP, wird der Zauber fehlschlagen."
                                                                                    type:DSAActionParameterTypeInteger];
      asp.minValue = 1;
      asp.maxValue = NSIntegerMax;
      self.parameterDescriptors = @[ asp ]; 
      
    }
  NSLog(@"DSASpellKlarumPurum initSpell returning self: %@", self);  
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP_unused
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellKlarumPurum castOnTarget called!");
  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];

  NSNumber *investedNumber = (NSNumber *)self.parameterValues[@"aspAmount"];
  NSInteger investedASP = [investedNumber integerValue];

  NSLog(@"DSASpellKlarumPurum castOnTarget not yet properly implemented");
  
  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             
@end

#pragma mark - Hellsicht

@implementation DSASpellAnaluesArcanstruktur
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.origin = origin;
      self.test = test;
      self.variants = variants;
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;  
      self.removalCostASP = 0;    
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 1;             // has to be close by
      self.canCastOnSelf = YES;
      self.targetType = DSAActionTargetTypeObject;  // kann aber theoretisch auch alles sein, Personen, Tiere, etc.
      self.allowedTargetTypes = @[ @"DSAObject" ];
      self.spellDuration = -1;          // permanent
      self.spellingDuration = 300;      // 10 Sekunden bis 10 Minuten :/
      
      DSAActionParameterDescriptor *asp = [DSAActionParameterDescriptor descriptorWithKey:@"aspAmount"
                                                                                   label:@"wieviele LP heilen"
                                                                                helpText:@"1 ASP Kosten je LP, mindestens 7 ASP. Wenn weniger als 7 ASP vorhanden sind, dann alles was vorhanden ist. Mindestens 10 ASP um kürzlich Verstorbene zu erwecken."
                                                                                    type:DSAActionParameterTypeInteger];
      asp.minValue = 1;
      asp.maxValue = NSIntegerMax;
      self.parameterDescriptors = @[ asp ]; 
      
    }
  NSLog(@"DSASpellBalsamSalabunde initSpell returning self: %@", self);  
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP_unused
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellBalsamSalabunde castOnTarget called!");
  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];

  NSNumber *investedNumber = (NSNumber *)self.parameterValues[@"aspAmount"];
  NSInteger investedASP = [investedNumber integerValue];

  DSACharacter *targetCharacter = (DSACharacter *) target;
  if (targetCharacter.currentLifePoints <= 0)
    {
      if (investedASP < 10)
        {
          spellResult.result = DSAActionResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Es sind mindestens 10 ASP notwendig, um %@ wiederzuerwecken."), [(DSACharacter *)target name]];
          return spellResult;          
        }
    }

  NSInteger availableASP = castingCharacter.currentAstralEnergy;
  NSInteger minASP = MIN(7, availableASP);
  if (investedASP < minASP)
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"Mindestens %ld ASP erforderlich (bzw. alles was du hast)"), (long)minASP];
      return spellResult;
    }
    
  spellResult = [self testTraitsWithSpellLevel: self.level castingCharacter: castingCharacter];
 
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= investedASP;
      if (targetCharacter.currentLifePoints <= 0)
        {
          targetCharacter.currentLifePoints = 1;
          [targetCharacter updateStatesDictState: @(DSACharacterStateDead)
                                       withValue: @(NO)];
          [targetCharacter updateStatesDictState: @(DSACharacterStateUnconscious)
                                       withValue: @(YES)];
          spellResult.resultDescription = [NSString stringWithFormat: @"%@ %@ kann %@ aus dem Reich Borons zurückholen.", 
                                                                      spellResult.resultDescription,
                                                                      castingCharacter.name,
                                                                      targetCharacter.name];                                                                   
        }
      else
        {
          NSInteger oldLifePoints = targetCharacter.currentLifePoints;
          NSInteger newLifePoints = (targetCharacter.currentLifePoints  + investedASP) < targetCharacter.lifePoints 
                                         ? targetCharacter.currentLifePoints  + investedASP 
                                         : targetCharacter.lifePoints;
                                        
          targetCharacter.currentLifePoints = newLifePoints;
          spellResult.resultDescription = [NSString stringWithFormat: @"%@ %@ kann %@ LP bei %@ wiederherstellen.", 
                                                                      spellResult.resultDescription,
                                                                      castingCharacter.name,
                                                                      @(newLifePoints - oldLifePoints),
                                                                      targetCharacter.name];          
        }
    }
  else
    {
      castingCharacter.currentAstralEnergy -= roundf(investedASP/2);
    }
  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             
@end
@implementation DSASpellOdemArcanum
- (instancetype)initSpell: (NSString *) name
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) category 
                  onLevel: (NSInteger) level
               withOrigin: (NSArray *) origin
                 withTest: (NSArray *) test
          withMaxDistance: (NSInteger) maxDistance                 
             withVariants: (NSArray *) variants
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) maxUpPerLevel
          withLevelUpCost: (NSInteger) levelUpCost
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.origin = origin;
      self.test = test;
      self.variants = @[ @"Umgebung" ];
      self.variant = variant;
      self.durationVariants = durationVariants;
      self.durationVariant = durationVariant;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.levelUpCost = levelUpCost;  
      self.removalCostASP = 0;    
      self.everLeveledUp = NO;
      self.isTraditionSpell = NO;
      self.maxDistance = 1;             // has to be close by
      self.canCastOnSelf = YES;
      self.targetType = DSAActionTargetTypeNone;
      self.allowedTargetTypes = @[ @"DSAAdventureGroup" ];   // we take the info from the 
      self.spellDuration = -1;          // eigentlich 20 sekunden
      self.spellingDuration = 30;       // eigentlich 10 sekunden, aber obige 20 sekunden hinzugefügt
      
      DSAActionParameterDescriptor *activeGroup = [DSAActionParameterDescriptor descriptorWithKey:@"activeGroup"
                                                                                            label:@"wieviele LP heilen"
                                                                                         helpText:@"Inhalt der Inventories der aktiven Gruppe werden auf Magie untersucht."
                                                                                    type:DSAActionParameterTypeActiveGroup];
      self.parameterDescriptors = @[ activeGroup ]; 
      
    }
  NSLog(@"DSASpellOdemArcanum initSpell returning self: %@", self);  
  return self;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP_unused
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellOdemArcanum castOnTarget called!");
  DSASpellResult *spellResult = [self verifyParametersForTarget: target
                                                    withVariant: variant
                                            withDurationVariant: durationVariant
                                                   withDistance: distance
                                                     withCaster: castingCharacter
                                                     withOrigin: originCharacter];
  if (spellResult == DSAActionResultNone)
    {
      return spellResult;
    }
  spellResult  = nil;
  spellResult = [[DSASpellResult alloc] init];
  
  NSInteger aspCost;
  NSInteger penalty;
  if ([variant isEqualToString: @"Umgebung"])
    {
      aspCost = 5;
      penalty = 3;
    }
  else
    {
      aspCost = 7;
      penalty = 0;
    }
    
  spellResult = [self testTraitsWithSpellLevel: (self.level - penalty) castingCharacter: castingCharacter];
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= aspCost;
      DSAAdventureGroup *adventureGroup = (DSAAdventureGroup *)target;
      for (DSACharacter *character in adventureGroup.allCharacters)
        {
          // look for all objects in the characters inventory where appliedSpells > 0
        }
    }
  else
    {
      castingCharacter.currentAstralEnergy -= roundf(aspCost/2);
    }  
  
  

  spellResult.spellingDuration = self.spellingDuration;
  return spellResult;
}             
@end
