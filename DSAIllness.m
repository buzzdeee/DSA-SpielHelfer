/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-12 20:07:15 +0200 by sebastia

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

#import "DSAIllness.h"
#import "DSACharacter.h"
#import "Utils.h"

@implementation DSAIllnessDescription

- (instancetype)initWithName:(NSString *)name dictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = [name copy];
        _alternativeName = dict[@"Alternativer Name"];
        _recognition = dict[@"Erkennung"] ?: @{};
        _dangerLevel = [dict[@"Gefaehrlichkeit"] integerValue];
        _incubationPeriod = dict[@"Inkubationszeit"] ?: @[];
        _duration = dict[@"Dauer"] ?: @[];
        _treatment = dict[@"Behandlung"] ?: @{};
        _cause = dict[@"Ursache"] ?: @{};
        _remedies = dict[@"Gegenmittel"] ?: @{};
        _damage = dict[@"Schaden"] ?: @{};
        _followUpIllnessChance = dict[@"Folgekrankheiten"];
        _specialNotes = dict[@"Besonderheiten"];
    }
    return self;
}

- (nullable DSAIllnessEffect *)generateEffectForCharacter:(DSACharacter *)character
{
   NSLog(@"DSAIllnessDescription generateEffectForCharacter: illness: %@", self);
   DSAIllnessEffect *effect = [[DSAIllnessEffect alloc] init];
   effect.uniqueKey = [NSString stringWithFormat: @"Illness_%@", self.name];
   effect.effectType = DSACharacterEffectTypeIllness;
   effect.expirationDate = nil;
   effect.currentStage = DSAIllnessStageIncubation;
   
   return effect;
}

- (DSAAventurianDate *)endDateOfStage:(DSAIllnessStage)currentStage
                             fromDate:(DSAAventurianDate *)currentDate
{
    NSDictionary *durationDict;
    switch (currentStage) {
        case DSAIllnessStageIncubation:
            durationDict = self.incubationPeriod;
            break;
        default:
            durationDict = self.duration;
            break;
    }

    if (!durationDict) {
        NSLog(@"[DSAIllnessDescription] Keine Dauerdefinition für Krankheitsstufe %ld", (long)currentStage);
        return currentDate;
    }

    NSString *wuerfelString = durationDict[@"Wuerfel"];
    if (![wuerfelString isKindOfClass:[NSString class]]) {
        NSLog(@"[DSAIllnessDescription] Ungültiger Wuerfel-Eintrag in Dauerdefinition: %@", wuerfelString);
        return currentDate;
    }

    NSInteger baseDays = 0;

    // Prüfen, ob der String mit einem Buchstaben endet
    unichar lastChar = [wuerfelString characterAtIndex:wuerfelString.length - 1];
    if ([[NSCharacterSet letterCharacterSet] characterIsMember:lastChar]) {
        NSString *suffix = [NSString stringWithCharacters:&lastChar length:1];
        NSString *numberPart = [wuerfelString substringToIndex:wuerfelString.length - 1];

        if ([suffix isEqualToString:@"T"]) {
            // Feste Tageszahl
            baseDays = [numberPart integerValue];
        } else {
            NSLog(@"[DSAIllnessDescription] WARNUNG: Unbekannter Zeit-Suffix '%@' im WuerfelString: %@", suffix, wuerfelString);
            return currentDate;
        }
    } else {
        // Würfelangabe (z. B. "1W3")
        baseDays = [Utils rollDice:wuerfelString];
    }

    NSNumber *modifier = durationDict[@"Modifier"];
    if ([modifier isKindOfClass:[NSNumber class]]) {
        baseDays += [modifier integerValue];
    }

    return [currentDate dateByAddingYears:0 days:baseDays hours:0 minutes:0];
}

-(NSDictionary <NSString *, id>*) oneTimeDamage
{
  return [self.damage objectForKey: @"Einmalig"];
}

-(NSDictionary <NSString *, id>*) dailyDamage
{
  return [self.damage objectForKey: @"Taeglich"];
}

- (DSASeverityLevel) dangerLevelToSeverityLevel
{
  NSLog(@"DSAIllnessDescription dangerLevelToSeverityLevel dangerLevel: %@", @(self.dangerLevel));
  switch (self.dangerLevel)
    {
      case 0: return DSASeverityLevelNone;
      case 1 ... 3: return DSASeverityLevelMild;
      case 4 ... 7: return DSASeverityLevelModerate;
      case 8 ... 10: return DSASeverityLevelSevere;
      default: return DSASeverityLevelNone;
    }
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

// NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _alternativeName = [coder decodeObjectOfClass:[NSString class] forKey:@"alternativeName"];
        _recognition = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"recognition"];
        _dangerLevel = [coder decodeIntegerForKey:@"dangerLevel"];
        _incubationPeriod = [coder decodeObjectOfClass:[NSArray class] forKey:@"incubationPeriod"];
        _duration = [coder decodeObjectOfClass:[NSArray class] forKey:@"duration"];
        _treatment = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"treatment"];
        _cause = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"cause"];
        _remedies = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"remedies"];
        _damage = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"damage"];
        _specialNotes = [coder decodeObjectOfClass:[NSString class] forKey:@"specialNotes"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_alternativeName forKey:@"alternativeName"];
    [coder encodeObject:_recognition forKey:@"recognition"];
    [coder encodeInteger:_dangerLevel forKey:@"dangerLevel"];
    [coder encodeObject:_incubationPeriod forKey:@"incubationPeriod"];
    [coder encodeObject:_duration forKey:@"duration"];
    [coder encodeObject:_treatment forKey:@"treatment"];
    [coder encodeObject:_cause forKey:@"cause"];
    [coder encodeObject:_remedies forKey:@"remedies"];
    [coder encodeObject:_damage forKey:@"damage"];
    [coder encodeObject:_specialNotes forKey:@"specialNotes"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    DSAIllnessDescription *copy = [[[self class] allocWithZone:zone] init];
    copy->_name = [_name copyWithZone:zone];
    copy->_alternativeName = [_alternativeName copyWithZone:zone];
    copy->_recognition = [_recognition copyWithZone:zone];
    copy->_dangerLevel = _dangerLevel;
    copy->_incubationPeriod = [_incubationPeriod copyWithZone:zone];
    copy->_duration = [_duration copyWithZone:zone];
    copy->_treatment = [_treatment copyWithZone:zone];
    copy->_cause = [_cause copyWithZone:zone];
    copy->_remedies = [_remedies copyWithZone:zone];
    copy->_damage = [_damage copyWithZone:zone];
    copy->_specialNotes = [_specialNotes copyWithZone:zone];
    return copy;
}

@end


@implementation DSAIllnessRegistry {
    NSMutableDictionary<NSString *, DSAIllnessDescription *> *_illnesses;
    NSMutableDictionary<NSString *, DSAIllnessDescription *> *_alternateNames;
}

static DSAIllnessRegistry *_sharedInstance = nil;

+ (instancetype)sharedRegistry {
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] initPrivate];
            [_sharedInstance loadDefaultIllnessesIfNeeded];
        }
    }
    return _sharedInstance;
}

// Klassischer Private Initializer
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _illnesses = [[NSMutableDictionary alloc] init];
        _alternateNames = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[DSAIllnessRegistry sharedRegistry]"
                                 userInfo:nil];
    return nil;
}

#pragma mark - Automatischer JSON-Loader

- (void)loadDefaultIllnessesIfNeeded {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"Krankheiten" ofType:@"json"];
    if (!resourcePath) {
        NSLog(@"[DSAIllnessRegistry] Fehler: Krankheiten.json nicht gefunden.");
        return;
    }
    [self loadFromJSONFile:resourcePath];
}

- (void)loadFromJSONFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        NSLog(@"[DSAIllnessRegistry] Fehler beim Lesen von %@", path);
        return;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"[DSAIllnessRegistry] JSON Parsing Fehler: %@", error);
        return;
    }

    for (NSString *name in jsonDict) {
        NSDictionary *illnessData = jsonDict[name];
        DSAIllnessDescription *illness = [[DSAIllnessDescription alloc] initWithName:name dictionary:illnessData];
        if (illness) {
            _illnesses[name] = illness;

            NSString *altName = illnessData[@"Alternativer Name"];
            if ([altName isKindOfClass:[NSString class]]) {
                _alternateNames[altName] = illness;
            }
        }
    }
}

#pragma mark - Zugriff

- (nullable DSAIllnessDescription *)illnessWithName:(NSString *)name {
    DSAIllnessDescription *illness = _illnesses[name];
    if (!illness) {
        illness = _alternateNames[name];
    }
    if (!illness) {
        NSLog(@"DSAIllnessRegistry illnessWithName: illness %@ not found", name);
    }
    return illness;
}

- (nullable DSAIllnessDescription *)illnessWithUniqueID:(NSString *)uniqueID {
    if (![uniqueID hasPrefix:@"Illness_"]) {
        NSLog(@"DSAIllnessRegistry illnessWithUniqueID: unexpected format %@", uniqueID);
        return nil;
    }

    NSString *name = [uniqueID substringFromIndex:[@"Illness_" length]];
    return [self illnessWithName:name];
}

- (NSArray<NSString *> *)allIllnessNames {
    return _illnesses.allKeys;
}

@end