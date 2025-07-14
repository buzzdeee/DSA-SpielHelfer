/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-20 21:56:38 +0200 by sebastia

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

#import "DSAGod.h"
#import "Utils.h"
#import "DSAAdventureGroup.h"
#import "DSAAventurianDate.h"

@implementation DSAGod

+ (instancetype)godWithType:(DSAGodType)type {
    switch (type) {
        case DSAGodTypePraios: return [[DSAGodPraios alloc] init];
        case DSAGodTypeRondra: return [[DSAGodRondra alloc] init];
        case DSAGodTypeEfferd: return [[DSAGodEfferd alloc] init];
        case DSAGodTypeTravia: return [[DSAGodTravia alloc] init];
        case DSAGodTypeBoron: return [[DSAGodBoron alloc] init];
        case DSAGodTypeHesinde: return [[DSAGodHesinde alloc] init];
        case DSAGodTypeFirun: return [[DSAGodFirun alloc] init];
        case DSAGodTypeTsa: return [[DSAGodTsa alloc] init];
        case DSAGodTypePhex: return [[DSAGodPhex alloc] init];
        case DSAGodTypePeraine: return [[DSAGodPeraine alloc] init];
        case DSAGodTypeIngerimm: return [[DSAGodIngerimm alloc] init];
        case DSAGodTypeRahja: return [[DSAGodRahja alloc] init];
        case DSAGodTypeSwafnir: return [[DSAGodSwafnir alloc] init];
        case DSAGodTypeIfirn: return [[DSAGodIfirn alloc] init];
        default: return nil;
    }
}

+ (DSAGodType)godTypeByName:(NSString *)name {
    static NSDictionary<NSString *, NSNumber *> *nameToTypeMap = nil;

    if (nameToTypeMap == nil) {
        nameToTypeMap = @{
            @"Praios": @(DSAGodTypePraios),
            @"Rondra": @(DSAGodTypeRondra),
            @"Efferd": @(DSAGodTypeEfferd),
            @"Travia": @(DSAGodTypeTravia),
            @"Boron": @(DSAGodTypeBoron),
            @"Hesinde": @(DSAGodTypeHesinde),
            @"Firun": @(DSAGodTypeFirun),
            @"Tsa": @(DSAGodTypeTsa),
            @"Phex": @(DSAGodTypePhex),
            @"Peraine": @(DSAGodTypePeraine),
            @"Ingerimm": @(DSAGodTypeIngerimm),
            @"Rahja": @(DSAGodTypeRahja),
            @"Swafnir": @(DSAGodTypeSwafnir),
            @"Ifirn": @(DSAGodTypeIfirn)
        };
    }

    NSNumber *typeNumber = [nameToTypeMap objectForKey:name];
    if (typeNumber != nil) {
        return [typeNumber integerValue];
    }

    return DSAGodTypeUnknown;
}

+ (NSString *)nameForGodType:(DSAGodType)type {
    static NSArray<NSString *> *typeNames = nil;

    if (typeNames == nil) {
        typeNames = @[
            @"Unknown",   // DSAGodTypeUnknown = 0
            @"Praios",
            @"Rondra",
            @"Efferd",
            @"Travia",
            @"Boron",
            @"Hesinde",
            @"Firun",
            @"Tsa",
            @"Phex",
            @"Peraine",
            @"Ingerimm",
            @"Rahja",
            @"Swafnir",
            @"Ifirn"
        ];
    }

    if (type >= 0 && type < typeNames.count) {
        return typeNames[type];
    }

    return @"Unknown";
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"Unbekannt";
        _reputation = 0;
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeUnknown;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *) group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult {
    // Basisimplementierung – soll in Subklassen überschrieben werden
    return NO;
}

#pragma mark - Reputation Management

- (void)increaseReputationBy:(NSInteger)amount {
    if (amount > 0) {
        _reputation += amount;
    }
}

- (void)decreaseReputationBy:(NSInteger)amount {
    if (amount > 0) {
        _reputation -= amount;
        if (_reputation < 0) {
            _reputation = 0;
        }
    }
}

- (void)forceDecreaseReputationBy:(NSInteger)amount {
    if (amount > 0) {
        _reputation -= amount;
    }
}

- (NSString *)reputationLevelDescription {
    if (_reputation < -10) {
        return @"Verflucht und geächtet";
    } else if (_reputation < -1) {
        return @"Verhasst";
    } else if (_reputation == 0) {
        return @"Gleichgültig";
    } else if (_reputation <= 10) {
        return @"Geduldet";
    } else if (_reputation <= 20) {
        return @"Wohlwollend";
    } else if (_reputation <= 30) {
        return @"Gesegnet";
    } else if (_reputation <= 50) {
        return @"Auserwählt";
    } else {
        return [NSString stringWithFormat: @"Lieblinge von %@", self.name];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.godType forKey:@"godType"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.reputation forKey:@"reputation"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DSAGodType type = [coder decodeIntegerForKey:@"godType"];
    DSAGod *god = [DSAGod godWithType:type];
    god->_name = [coder decodeObjectForKey:@"name"];
    god->_reputation = [coder decodeIntegerForKey:@"reputation"];
    return god;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAGod *copy = [[[self class] allocWithZone:zone] init];
    copy->_name = [_name copyWithZone:zone];
    copy->_reputation = _reputation;
    return copy;
}

@end

@implementation DSAGodPraios
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Praios";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypePraios;
}
- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    // Praios hasst Magie: wenn Magier in der Gruppe sind, keine Wunder
    if ([group hasMageInGroup]) {
        return NO;
    }

    NSInteger baseChance = MIN(10, fame); // Optional: Fame capped bei 10
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W9"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 5: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 3
                                                                         hours: 0
                                                                       minutes: 0];
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTraitBoost
                                              description:@"MU +1 (Gruppe) für 3 Tage"
                                           expirationDate: expirationDate
                                              statChanges:@{@"MU": @1}
                                                   target:@"group"
                                                uniqueKey:DSAMiracleKeyPraiosTempMUBoost];
        }
        case 6: case 7: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 1
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeMRBoost
                                              description:@"MR +1 (Gruppe) für 1 Tag"
                                           expirationDate: expirationDate
                                              statChanges:@{@"MR": @1}
                                                   target:@"group"
                                                uniqueKey:DSAMiracleKeyPraiosTempMRBoost];
        }
        case 8:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRemoveCurse
                                              description:@"Ein Fluch wird gelöst (ein Held)"
                                           expirationDate: nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        case 9:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate: nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodRondra
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Rondra";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeRondra;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W9"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 5: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentBoost
                                              description:@"Schwerter +1 (Gruppe) für 4 Tage"
                                           expirationDate: expirationDate
                                              statChanges:@{@"Schwerter": @1}
                                                   target:@"group"
                                                uniqueKey:DSAMiracleKeyRondraTempSwordBoost];
        }
        case 6: case 7: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 1
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeMagicProtection
                                              description:@"Schutz vor Magie (Gruppe) für 1 Tag"
                                           expirationDate: expirationDate
                                              statChanges:@{}
                                                   target:@"group"
                                                uniqueKey:DSAMiracleKeyRondraTempMagicProtection];
        }
        case 8:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeUpgradeWeaponToMagic
                                              description:@"Eine normale Waffe wird zu einer magischen Waffe erhoben"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        case 9:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodEfferd
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Efferd";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeEfferd;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W10"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 5: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentAutoSuccess
                                              description:@"Jede Wildnisleben-Probe auf Wassersuche gelingt automatisch"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Wildnisleben": @4}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 6 ... 8: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];         
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeSeaProtection
                                              description:@"Schutz auf See (Gruppe)"
                                           expirationDate:expirationDate
                                              statChanges:@{}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 9: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 5
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentBoost
                                              description:@"Schwimmen +2 (Gruppe)"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Schwimmen": @2}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 10:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodTravia
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Travia";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeTravia;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W17"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 10:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeSatiation
                                              description:@"Die gesamte Gruppe ist satt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"group"
                                                uniqueKey:nil];

        case 11 ... 15: {
            NSInteger healed = [Utils rollDice:@"1W6"] + 2;
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeHeal
                                              description:[NSString stringWithFormat:@"Ein Held erhält %ld LE zurück", (long)healed]
                                           expirationDate:nil
                                              statChanges:@{@"LE": [NSNumber numberWithInteger: healed]}
                                                   target:@"individual"
                                                uniqueKey:nil];
        }

        case 16: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 8
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeNightPeace
                                              description:@"Keine Überfälle in der Nacht"
                                           expirationDate:expirationDate
                                              statChanges:@{}
                                                   target:@"group"
                                                uniqueKey: DSAMiracleKeyTraviaNightPeace];
        }
        case 17:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodBoron
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Boron";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeBoron;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W6"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 4: {
            BOOL alreadyReceived = [group hasCharacterWithoutUniqueMiracle: DSAMiracleKeyBoronPermanentSchutzVorUntoten];
            if (alreadyReceived) {
                // Schutz bereits einmalig vergeben -> stattdessen Wiederbelebung
                return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                                  description:@"Ein Held wird wiederbelebt (statt Schutz vor Untoten)"
                                               expirationDate:nil
                                                  statChanges:@{}
                                                       target:@"individual"
                                                    uniqueKey:nil];
            } else {           
                return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeProtectionAgainstUndead
                                                  description:@"Schutz vor Untoten (Gruppe)"
                                               expirationDate:nil
                                                  statChanges:@{}
                                                       target:@"group"
                                                    uniqueKey: DSAMiracleKeyBoronPermanentSchutzVorUntoten];
            }
        }

        case 5: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTraitBoost
                                              description:@"Totenangst (TA) -1 für die Gruppe (4 Tage)"
                                           expirationDate:expirationDate
                                              statChanges:@{@"TA": @-1}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 6:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodHesinde
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Hesinde";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeHesinde;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W10"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 3: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 5
                                                                         hours: 0
                                                                       minutes: 0];         
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeMagicBoost
                                              description:@"Analüs +1 für die Gruppe (5 Tage)"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Analüs": @1}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 4 ... 6:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRemoveCurse
                                              description:@"Ein Fluch wird entfernt (einzelner Held)"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        case 7: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];         
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeMRBoost
                                              description:@"MR +5 für die Gruppe (4 Tage)"
                                           expirationDate:expirationDate
                                              statChanges:@{@"MR": @5}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 8:
        case 9:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypePlaceholder
                                              description:@"Kein Wunder – Hesinde schweigt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"none"
                                                uniqueKey:nil];

        case 10:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodFirun
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Firun";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeFirun;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W10"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 8: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentAutoSuccess
                                              description:@"Jede Fährtensuchenprobe auf Jagen gelingt automatisch (Gruppe)"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Fährtensuchen": @4}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 9: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 9
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeNoHungerThirst
                                              description:@"Kein Hunger und Durst (Gruppe)"
                                           expirationDate:expirationDate
                                              statChanges:@{}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 10:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodTsa
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Tsa";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeTsa;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W18"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 10: {
            NSInteger healed = [Utils rollDice:@"2W6"];
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeHeal
                                              description:[NSString stringWithFormat:@"Heilung: %ld LE (einzelner Held)", (long)healed]
                                           expirationDate:nil
                                              statChanges:@{@"LE": [NSNumber numberWithInteger: healed]}
                                                   target:@"individual"
                                                uniqueKey:nil];
        }

        case 11 ... 15:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeFullHeal
                                              description:@"Alle Gruppenmitglieder werden vollständig geheilt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"group"
                                                uniqueKey:nil];

        case 16 ... 18:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodPhex
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Phex";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypePhex;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W10"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 5: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentBoost
                                              description:@"Schlösser öffnen und Taschendiebstahl +1 (Gruppe), Dauer: 4 Tage"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Schlösser knacken": @1, @"Taschendiebstahl": @1}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 6 ... 8: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentBoost
                                              description:@"Feilschen +1 (Gruppe), Dauer: 4 Tage"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Feilschen": @1}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 9: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 4
                                                                         hours: 0
                                                                       minutes: 0];        
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTraitBoost
                                              description:@"Fingerfertigkeit (FF) +1 (Gruppe), Dauer: 4 Tage"
                                           expirationDate:expirationDate
                                              statChanges:@{@"FF": @1}
                                                   target:@"group"
                                                uniqueKey:nil];
        }
        case 10:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodPeraine
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Peraine";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypePeraine;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W19"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 10: {
            NSInteger healed = [Utils rollDice:@"1W6"];
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeHeal
                                              description:[NSString stringWithFormat:@"Heilung: %ld LE (einzelner Held)", (long)healed]
                                           expirationDate:nil
                                              statChanges:@{@"LE": [NSNumber numberWithInteger: healed]}
                                                   target:@"individual"
                                                uniqueKey:nil];
        }
        case 11 ... 16: {
            NSInteger healed = [Utils rollDice:@"2W6"];
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeHeal
                                              description:[NSString stringWithFormat:@"Heilung: %ld LE (einzelner Held)", (long)healed]
                                           expirationDate:nil
                                              statChanges:@{@"LE": [NSNumber numberWithInteger: healed]}
                                                   target:@"individual"
                                                uniqueKey:nil];
        }
        case 17 ... 18:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeCureDisease
                                              description:@"Krankheit wird geheilt (einzelner Held)"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];
        case 19:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodIngerimm
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Ingerimm";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeIngerimm;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *)group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W8"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll 
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    switch (miracleRoll) {
        case 1 ... 5:       
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeWeaponBlessing
                                              description:@"Segnung der Waffen (Gruppe). Entspricht der Anwendung des Schleifsteins"
                                           expirationDate:nil
                                              statChanges:@{@"breakFactor": @-1}
                                                   target:@"group"
                                                uniqueKey: nil];

        case 6:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeEnchantWeapon
                                              description:@"Erhebung einer normalen Waffe zu einer magischen Waffe (einzelner Held)"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey: nil];

        case 7:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRepairAndEnchant
                                              description:@"Waffenreparatur und Erhebung dieser Waffe zu einer magischen Waffe (einzelner Held)"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey: nil];
        case 8:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey: nil];

        default:
            return nil;
    }
}
@end
@implementation DSAGodRahja
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Rahja";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeRahja;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *) group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
    NSInteger baseChance = MIN(10, fame);
    NSInteger roll = [Utils rollDice:@"1W100"];

    if (roll <= baseChance) {
        NSInteger miracleRoll = [Utils rollDice:@"1W15"];
        DSAMiracleResult *resultObj = [self miracleResultWithRoll:miracleRoll
                                                          inGroup:group
                                                           atDate:currentDate];

        if (resultObj && outResult) {
            *outResult = resultObj;
        }

        return resultObj != nil;
    }

    return NO;
}

- (nullable DSAMiracleResult *)miracleResultWithRoll:(NSInteger)miracleRoll
                                             inGroup:(DSAAdventureGroup *)group
                                              atDate:(DSAAventurianDate *) currentDate
{
    // Hilfsmethode, um alle Charaktere zu finden, die das permanente Wunder NOCH NICHT haben
    NSArray<DSACharacter *> *eligibleForDancing = [group charactersWithoutUniqueMiracle: DSAMiracleKeyRahjaPermanentTanzenBetören];
    
    switch (miracleRoll) {
        case 1 ... 8: {
            if (eligibleForDancing.count == 0) {
                // Permanent schon vergeben, oder alle haben das Wunder schon
                return nil;
            }
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 7
                                                                         hours: 0
                                                                       minutes: 0];             
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentBoost
                                              description:@"Tanzen und Betören +2 (Gruppe), Dauer 7 Tage"
                                           expirationDate:expirationDate
                                              statChanges:@{@"Tanzen": @2, @"Betören": @2}
                                                   target:@"group"
                                                uniqueKey:nil];
        }    
        case 9 ... 13: {
            DSAAventurianDate *expirationDate = [currentDate dateByAddingYears: 0
                                                                          days: 3
                                                                         hours: 0
                                                                       minutes: 0];         
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTraitBoost
                                              description:@"Charisma +1 (Gruppe), Dauer 3 Tage"
                                           expirationDate:expirationDate
                                              statChanges:@{@"CH": @1}
                                                   target:@"group"
                                                uniqueKey:nil];
        }    
        case 14:
            if (eligibleForDancing.count == 0) {
                // Permanente Steigerung schon vergeben
                return nil;
            }
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeTalentBoost
                                              description:@"Tanzen und Betören permanent +2 (Gruppe)"
                                           expirationDate:nil
                                              statChanges:@{@"Tanzen": @2, @"Betören": @2}
                                                   target:@"group"
                                                uniqueKey: DSAMiracleKeyRahjaPermanentTanzenBetören];
            
        case 15:
            return [[DSAMiracleResult alloc] initWithType:DSACharacterEffectTypeRevive
                                              description:@"Ein Held wird wiederbelebt"
                                           expirationDate:nil
                                              statChanges:@{}
                                                   target:@"individual"
                                                uniqueKey:nil];
            
        default:
            return nil;
    }
}
@end
@implementation DSAGodSwafnir
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Swafnir";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeSwafnir;
}

- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *) group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult
{
  return NO;  // Swafnir is half-god only, so no miracles ...
}
@end
// Ifirn has same miracles like Firun, so inherits those methods...
@implementation DSAGodIfirn
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"Ifirn";
    }
    return self;
}

- (DSAGodType)godType {
    return DSAGodTypeIfirn;
}
@end

// Praios
NSString * const DSAMiracleKeyPraiosTempMUBoost = @"Praios_Temporary_MU_Boost";
NSString * const DSAMiracleKeyPraiosTempMRBoost = @"Praios_Temporary_MR_Boost";

// Rondra
NSString * const DSAMiracleKeyRondraTempSwordBoost = @"Rondra_Temporary_Sword_Boost";
NSString * const DSAMiracleKeyRondraTempMagicProtection = @"Rondra_Temporary_Magic_Protection";

// Rahja
NSString * const DSAMiracleKeyRahjaPermanentTanzenBetören = @"Rahja_Permanent_TanzenBetörenPlus2";

// Boron
NSString * const DSAMiracleKeyBoronPermanentSchutzVorUntoten = @"Boron_Permanent_SchutzVorUntoten";

// Ingerimm
NSString * const DSAMiracleKeyIngerimmMagischeWaffe = @"Ingerimm_Erhebung_Zu_Magischer_Waffe";
NSString * const DSAMiracleKeyIngerimmWaffenreparaturUndMagie = @"Ingerimm_Waffenreparatur_und_Erhebung";

// Tsa
NSString * const DSAMiracleKeyTsaJungbrunnen = @"Tsa_Jungbrunnen";

// Efferd
NSString * const DSAMiracleKeyEfferdSeefahrtSegen = @"Efferd_Seefahrt_Segen";

// Travia
NSString * const DSAMiracleKeyTraviaNightPeace = @"Travia_Night_Peace";

// Phex
NSString * const DSAMiracleKeyPhexGlücksdiebSegen = @"Phex_Glücksdieb_Segen";

// Hesinde
NSString * const DSAMiracleKeyHesindeWissenDerGötter = @"Hesinde_Wissen_der_Götter";

// Firun
NSString * const DSAMiracleKeyFirunEwigerFrostschutz = @"Firun_Ewiger_Frostschutz";


@implementation DSAMiracleResult

- (instancetype)initWithType:(DSACharacterEffectType)type
                 description:(NSString *)desc
              expirationDate:(DSAAventurianDate *)expirationDate
                statChanges:(NSDictionary<NSString *, NSNumber *> *)statChanges
                      target:(NSString *)target
                   uniqueKey:(NSString *) uniqueKey;
{
    self = [super init];
    if (self) {
        _type = type;
        _effectDescription = [desc copy];
        _expirationDate = expirationDate;
        _statChanges = [statChanges copy];
        _target = [target copy];
        _uniqueKey = [uniqueKey copy];
    }
    return self;
}

@end
