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

@implementation DSAIllness

- (instancetype)initWithName:(NSString *)name fromDictionary:(NSDictionary *)dict {
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
   NSLog(@"DSAIllness generateEffectForCharacter: illness: %@", self);
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

    NSLog(@"DSAIllness endDateOfStage durationDict: %@", durationDict);
    
    if (!durationDict) {
        NSLog(@"[DSAIllness] Keine Dauerdefinition für Krankheitsstufe %ld", (long)currentStage);
        return currentDate;
    }

    NSInteger baseDays = 0;
    NSString *wuerfelString = durationDict[@"Wuerfel"];
    if (![wuerfelString isKindOfClass:[NSString class]])
      {
        NSLog(@"[DSAIllness] Kein Wuerfel-Eintrag in Dauerdefinition.");
      }
    else
      {
        NSLog(@"[DSAIllness] Wuerfel-Eintrag in Dauerdefinition gefunden.");
        baseDays = [Utils rollDice:wuerfelString];
      }
    NSNumber *days = durationDict[@"Tage"];
    if ([days isKindOfClass:[NSNumber class]])
      {
        NSLog(@"[DSAIllness] Statischen Tage Eintrag in Dauerdefinition gefunden.");    
        baseDays += [days integerValue];
      }
    
    NSNumber *modifier = durationDict[@"Modifier"];
    if ([modifier isKindOfClass:[NSNumber class]])
      {
        NSLog(@"[DSAIllness] Statischen Modifier Eintrag in Dauerdefinition gefunden.");    
        baseDays += [modifier integerValue];
      }

    return [currentDate dateByAddingYears:0 days:baseDays hours:0 minutes:0];
}

-(NSDictionary <NSString *, id>*) oneTimeDamage
{
  return [self.damage objectForKey: @"Einmalig"];
}

-(NSDictionary <NSString *, id>*) recurringDamage
{
  return [self.damage objectForKey: @"Regelmaessig"];
}

- (DSASeverityLevel) dangerLevelToSeverityLevel
{
  NSLog(@"DSAIllness dangerLevelToSeverityLevel dangerLevel: %@", @(self.dangerLevel));
  switch (self.dangerLevel)
    {
      case 0: return DSASeverityLevelNone;
      case 1 ... 3: return DSASeverityLevelMild;
      case 4 ... 7: return DSASeverityLevelModerate;
      case 8 ... 10: return DSASeverityLevelSevere;
      default: return DSASeverityLevelNone;
    }
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

@end


@implementation DSAIllnessRegistry {
    NSMutableDictionary<NSString *, DSAIllness *> *_illnesses;
    NSMutableDictionary<NSString *, DSAIllness *> *_alternateNames;
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
        DSAIllness *illness = [[DSAIllness alloc] initWithName:name fromDictionary:illnessData];
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

- (nullable DSAIllness *)illnessWithName:(NSString *)name {
    DSAIllness *illness = _illnesses[name];
    if (!illness) {
        illness = _alternateNames[name];
    }
    if (!illness) {
        NSLog(@"DSAIllnessRegistry illnessWithName: illness %@ not found", name);
    }
    return illness;
}

- (nullable DSAIllness *)illnessWithUniqueID:(NSString *)uniqueID {
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