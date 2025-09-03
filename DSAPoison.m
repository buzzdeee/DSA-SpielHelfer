/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-27 19:17:06 +0200 by sebastia

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

#import "DSAPoison.h"
#import "DSACharacter.h"
#import "Utils.h"
#import "DSADefinitions.h"

static NSDictionary<NSString *, Class> *typeToClassMap = nil;

@implementation DSAPoison
- (instancetype)initWithName:(NSString *)name fromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = name;
        self.dangerLevel = [dict[@"Stufe"] integerValue];
        self.types = dict[@"Typ"];
        self.onset = dict[@"Beginn"];
        self.duration = dict[@"Dauer"];
        self.damage = dict[@"Schaden"];
        self.shelfLife = dict[@"Haltbarkeit"];
        self.price = [dict[@"Preis"] floatValue];
        self.weight = [dict[@"Gewicht"] floatValue];
        self.crafting = dict[@"Herstellung"];
        self.icon = dict[@"Icon"] ? [dict[@"Icon"] objectAtIndex: arc4random_uniform([dict[@"Icon"] count])]: nil;
        self.states = [NSMutableSet setWithObject:@(DSAObjectStateIsPoisoned)];
    }
    return self;
}

- (nullable DSAPoisonEffect *)generateEffectForCharacter:(DSACharacter *)character
{
   NSLog(@"DSAPoison generateEffectForCharacter: poison: %@", self);
   DSAPoisonEffect *effect = [[DSAPoisonEffect alloc] init];
   effect.uniqueKey = [NSString stringWithFormat: @"Poison_%@", self.name];
   effect.effectType = DSACharacterEffectTypePoison;
   effect.expirationDate = nil;
   effect.currentStage = DSAPoisonStageApplied;
   
   return effect;
}

- (DSAAventurianDate *)endDateOfStage:(DSAPoisonStage)currentStage
                             fromDate:(DSAAventurianDate *)currentDate
{
    NSDictionary *durationDict;
    switch (currentStage) {
        case DSAPoisonStageApplied:
            durationDict = self.onset;
            break;
        default:
            durationDict = self.duration;
            break;
    }

    NSLog(@"DSAPoison endDateOfStage durationDict: %@", durationDict);
    
    if (!durationDict) {
        NSLog(@"[DSAPoison] Keine Dauerdefinition für Poison Stufe %ld", (long)currentStage);
        return currentDate;
    }
    
    if (currentStage == DSAPoisonStageApplied)
      {
        if ([[durationDict objectForKey: @"Sofort"] boolValue] == YES)
          {
            NSLog(@"[DSAPoison] We're in stage DSAPoisonStageApplied and it has to start immediately");
            return currentDate;
          }
      }
    
    if (durationDict[@"KR"] != nil)
      {
        // rounding up or down to next closest minute
        NSNumber *krNumber = durationDict[@"KR"];
        NSInteger kr = krNumber.integerValue;
        NSInteger randomValue = durationDict[@"Wuerfel"] ? [Utils rollDice: durationDict[@"Wuerfel"]] : 0;        
        NSInteger seconds = (kr + randomValue) * 5;
        NSInteger minutes = (seconds + 30) / 60;  // minutes may be 0, but that's OK
        NSLog(@"DSAPoison endDateOfStage durationDict: in KR applying %@ minutes", @(minutes));
        return [currentDate dateByAddingYears:0 days:0 hours:0 minutes: minutes];
      }
    else if (durationDict[@"SR"] != nil || durationDict[@"Minuten"] != nil)
      {
        NSInteger minutes = durationDict[@"SR"] ? [durationDict[@"SR"] integerValue] : [durationDict[@"Minuten"] integerValue];
        NSInteger randomValue = durationDict[@"Wuerfel"] ? [Utils rollDice: durationDict[@"Wuerfel"]] : 0;
        NSLog(@"DSAPoison endDateOfStage durationDict: in SR/Minuten applying %@ minutes", @(minutes + randomValue));        
        return [currentDate dateByAddingYears:0 days:0 hours:0 minutes: minutes + randomValue];
      }
    else if (durationDict[@"Stunden"] != nil)
      {
        NSInteger hours = durationDict[@"Stunden"] ? [durationDict[@"Stunden"] integerValue] : 0;
        NSInteger randomValue = durationDict[@"Wuerfel"] ? [Utils rollDice: durationDict[@"Wuerfel"]] : 0;
        NSLog(@"DSAPoison endDateOfStage durationDict: in Stunden applying %@ hours", @(hours + randomValue));                
        return [currentDate dateByAddingYears:0 days:0 hours: hours + randomValue minutes: 0];
      }
    else if (durationDict[@"Tage"] != nil)
      {
        NSInteger days = durationDict[@"Tage"] ? [durationDict[@"Tage"] integerValue] : 0;
        NSInteger randomValue = durationDict[@"Wuerfel"] ? [Utils rollDice: durationDict[@"Wuerfel"]] : 0;
        NSLog(@"DSAPoison endDateOfStage durationDict: in Tage applying %@ days", @(days + randomValue));                
        return [currentDate dateByAddingYears:0 days: days + randomValue hours: 0 minutes: 0];
      }      
    else if ([durationDict[@"Bis zum Tode"] boolValue])
      {
        // until eternity ;)
        NSLog(@"DSAPoison endDateOfStage durationDict: in Bis zum Tode applying 1000 years");                
        
        return [currentDate dateByAddingYears:1000 days:0 hours: 0 minutes: 0];
      }
    else
      {
        NSLog(@"DSAPoison endDateOfStage no end date interval description found in durationDict!");
      }
    return nil;
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
  NSLog(@"DSAPoison dangerLevelToSeverityLevel dangerLevel: %@", @(self.dangerLevel));
  switch (self.dangerLevel)
    {
      case 0: return DSASeverityLevelNone;
      case 1 ... 6: return DSASeverityLevelMild;
      case 7 ... 12: return DSASeverityLevelModerate;
      case 13 ... 20: return DSASeverityLevelSevere;
      default: return DSASeverityLevelNone;
    }
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder]; // falls DSAObject ebenfalls NSCoding unterstützt

    [coder encodeInteger:self.dangerLevel forKey:@"dangerLevel"];
    [coder encodeObject:self.types forKey:@"types"];
    [coder encodeObject:self.onset forKey:@"onset"];
    [coder encodeObject:self.duration forKey:@"duration"];
    [coder encodeObject:self.damage forKey:@"damage"];
    [coder encodeObject:self.shelfLife forKey:@"shelfLife"];
    [coder encodeObject:self.crafting forKey:@"crafting"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder]; // falls DSAObject ebenfalls NSCoding unterstützt
    if (self) {
        _dangerLevel = [coder decodeIntegerForKey:@"dangerLevel"];
        _types = [coder decodeObjectOfClass:[NSArray class] forKey:@"types"];
        _onset = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"onset"];
        _duration = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"duration"];
        _damage = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"damage"];
        _shelfLife = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"shelfLife"];
        _crafting = [coder decodeObjectOfClass:[NSArray class] forKey:@"crafting"];
    }
    return self;
}

+ (NSSet<Class> *)supportsSecureCodingClassesForKeys {
    return [NSSet setWithObjects:
        [NSArray class], [NSDictionary class], [NSNumber class], [NSString class], nil];
}

@end

#pragma mark - Manager

@interface DSAPoisonRegistry ()
@property (nonatomic, strong) NSArray<DSAPoison *> *poisons;
@end

@implementation DSAPoisonRegistry

+ (instancetype)sharedRegistry {
    static DSAPoisonRegistry *sharedInstance = nil;
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[DSAPoisonRegistry alloc] init];
            [sharedInstance loadPoisonsFromJSON];
        }
    }
    
    return sharedInstance;
}

+ (DSAPoisonType)poisonTypeFromString:(NSString *)typeString {
    static NSDictionary<NSString *, NSNumber *> *mapping = nil;

    @synchronized(self) {
        if (!mapping) {
            mapping = @{
                @"Einnahmegift": @(DSAPoisonTypeOral),
                @"Kontaktgift": @(DSAPoisonTypeContact),
                @"Waffengift": @(DSAPoisonTypeWeapon),
                @"Atemgift": @(DSAPoisonTypeInhalation),
            };
        }
    }

    NSNumber *enumValue = mapping[typeString.lowercaseString];
    if (enumValue) {
        return enumValue.integerValue;
    } else {
        return DSAPoisonTypeUnknown;
    }
}

+ (NSString *)stringFromPoisonType:(DSAPoisonType)type {
    switch (type) {
        case DSAPoisonTypeOral: return @"Einnahmegift";
        case DSAPoisonTypeContact: return @"Kontaktgift";
        case DSAPoisonTypeWeapon: return @"Waffengift";
        case DSAPoisonTypeInhalation: return @"Atemgift";
        default: return @"Unbekannter Gift Typ";
    }
}

- (void)loadPoisonsFromJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Gifte" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"DSAPoisonManager: Could not read Gifte.json");
        self.poisons = @[];
        return;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSDictionary class]]) {
        NSLog(@"DSAPoisonManager: Error parsing JSON: %@", error.localizedDescription);
        self.poisons = @[];
        return;
    }

    NSMutableArray *loadedPoisons = [NSMutableArray array];

    for (NSString *name in json) {
        NSDictionary *dict = json[name];
        DSAPoison *poison = [[DSAPoison alloc] initWithName:name fromDictionary:dict];
        if (poison) {
            poison.category = @"Gift";
            poison.validSlotTypes = @[@(DSASlotTypeGeneral)];
            [loadedPoisons addObject:poison];
        } else {
            NSLog(@"DSAPoisonManager: Unknown poison class for name %@", name);
        }
    }

    self.poisons = [loadedPoisons copy];
}

- (NSArray<DSAPoison *> *)allPoisons {
    return self.poisons ?: @[];
}

- (NSArray<DSAPoison *> *)sortedPoisonsByName {
    return [[self allPoisons] sortedArrayUsingComparator:^NSComparisonResult(DSAPoison *a, DSAPoison *b) {
        return [a.name compare:b.name];
    }];
}

- (NSArray<DSAPoison *> *)poisonsWithType:(DSAPoisonType)type {
    NSMutableArray<DSAPoison *> *filteredPoisons = [NSMutableArray array];
    
    for (DSAPoison *poison in [self allPoisons]) {
        for (NSNumber *poisonTypeNum in poison.types) {
            if ([poisonTypeNum integerValue] == type) {
                [filteredPoisons addObject:poison];
                break;
            }
        }
    }
    
    return [filteredPoisons copy];
}

- (nullable DSAPoison *)poisonWithName:(NSString *)name {
    for (DSAPoison *poison in self.poisons) {
        if ([poison.name isEqualToString:name]) {
            return poison;
        }
    }
    return nil;
}

- (nullable DSAPoison *)poisonWithUniqueID:(NSString *)uniqueID
{
    if (![uniqueID hasPrefix:@"Poison_"]) {
        NSLog(@"DSAPoisonRegistry poisonWithUniqueID: unexpected format %@", uniqueID);
        return nil;
    }

    NSString *name = [uniqueID substringFromIndex:[@"Poison_" length]];
    return [self poisonWithName:name];
}

- (NSDictionary<NSNumber *, NSArray<DSAPoison *> *> *)groupedByPoisonType {
    NSMutableDictionary<NSNumber *, NSMutableArray<DSAPoison *> *> *groups = [NSMutableDictionary dictionary];

    for (DSAPoison *poison in [self allPoisons]) {
        for (NSNumber *typeNum in poison.types) {
            if (!groups[typeNum]) {
                groups[typeNum] = [NSMutableArray array];
            }
            [groups[typeNum] addObject:poison];
        }
    }

    NSMutableDictionary<NSNumber *, NSArray<DSAPoison *> *> *immutableGroups = [NSMutableDictionary dictionary];
    for (NSNumber *key in groups) {
        immutableGroups[key] = [groups[key] copy];
    }

    return [immutableGroups copy];
}

- (NSArray<NSString *> *)allPoisonNames {
    NSMutableArray *poisonNames = [[NSMutableArray alloc] init]; 
    for (DSAPoison *poison in _poisons)
      {
        [poisonNames addObject: poison.name];
      }
    return [poisonNames copy];
}
@end
