/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-11-04 20:35:14 +0100 by sebastia

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

#import "DSAEncounterManager.h"
#import "DSADefinitions.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"

@interface DSAEncounterManager ()
@property (nonatomic, assign) double terrainModifier; // e.g. forest = 1.2
@end

@implementation DSAEncounterManager

- (instancetype)initWithAdventure:(DSAAdventure *)adventure {
    if (self = [super init]) {
        _adventure = adventure;
        _terrainKey = @"road";
        _baseChancePerHour = 0.05; // default 5%/h
        _terrainModifier = 1.0;
        _accumulatedMinutes = 0.0;
        _enabled = YES;
        // Optionally load default encounterTables from bundle here
        _encounterTables = nil;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Begegnungen" ofType:@"json"];
        NSData *d = [NSData dataWithContentsOfFile:path];
        NSError *err = nil;
        NSDictionary *tables = [NSJSONSerialization JSONObjectWithData:d options:0 error:&err];
        if (!err) _encounterTables = tables;

    }
    return self;
}

- (void)dealloc {
    [self unsubscribeFromClock];
}

- (void)subscribeToClock {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGameTimeAdvanced:)
                                                 name:@"DSAGameTimeAdvanced"
                                               object:nil];
}

- (void)unsubscribeFromClock {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DSAGameTimeAdvanced"
                                                  object:nil];
}

- (void)setTerrainKey:(NSString*)terrainKey withModifier:(double)modifier {
    if (!terrainKey) return;
    _terrainKey = [terrainKey copy];
    _terrainModifier = modifier;
    NSDictionary *ui = @{ @"terrain": _terrainKey, @"modifier": @(_terrainModifier) };
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAEncounterManagerDidChangeTerrain
                                                        object:self
                                                      userInfo:ui];
}

#pragma mark - Clock handler

- (void)handleGameTimeAdvanced:(NSNotification *)note {
    if (!self.enabled) return;
    NSDictionary *ui = note.userInfo ?: @{};
    NSNumber *advancedSeconds = ui[@"advancedSeconds"];
    double seconds = advancedSeconds ? [advancedSeconds doubleValue] : 0.0;
    // Convert seconds -> minutes
    double minutes = seconds / 60.0;
    if (minutes <= 0.0) return;
    [self processMinutes:minutes];
}

- (void)processMinutes:(double)minutes {
    if (!self.enabled) return;
    self.accumulatedMinutes += minutes;

    // For each full hour in accumulatedMinutes, roll once
    while (self.accumulatedMinutes >= 60.0) {
        self.accumulatedMinutes -= 60.0;
        [self rollForEncounterOneHour];
    }
}

#pragma mark - Rolling logic

- (double)encounterChanceForCurrentTerrain {
    // base * terrainModifier * groupModifier * weatherModifier
    double base = self.baseChancePerHour;
    double tmod = self.terrainModifier;
    double groupMod = [self groupEncounterModifier];
    double weatherMod = [self weatherEncounterModifier];
    double chance = base * tmod * groupMod * weatherMod;
    // clamp
    if (chance < 0.0) chance = 0.0;
    if (chance > 1.0) chance = 1.0;
    return chance;
}

- (double)groupEncounterModifier {
    // simple example: larger parties attract more attention
    NSInteger members = self.adventure.activeGroup.membersCount;
    if (members <= 1) return 1.0;
    if (members <= 4) return 1.0 + (members - 1) * 0.05; // +5% per extra
    return 1.2; // cap
}

- (double)weatherEncounterModifier {
    // placeholder: if weather present in adventure, modify chance
    // e.g. storm reduces chance for bandits but increases animal encounters
    // For now return 1.0
    return 1.0;
}

- (void)rollForEncounterOneHour {
    double chance = [self encounterChanceForCurrentTerrain];
    double r = (double)arc4random() / (double)UINT32_MAX;
    if (r < chance) {
        [self triggerEncounter];
    } else {
        // Optional debug log:
        // NSLog(@"[Encounter] No encounter (chance=%.3f, roll=%.5f) terrain=%@", chance, r, self.terrainKey);
    }
}

#pragma mark - Trigger

- (void)triggerEncounter {
    // Determine encounter type and payload.
    NSDictionary *enc = [self selectEncounterForTerrain:self.terrainKey];
    if (!enc) {
        // fallback minimal encounter
        enc = @{ @"type": @"none", @"description": @"Ein routinemäßiger, ereignisloser Abschnitt." };
    }

    // Build userInfo: include adventure, terrain, group info, and chosen encounter
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        @"terrain": self.terrainKey ?: @"unknown",
        @"encounter": enc
    }];

    // Pre-notify (UI can prepare / pause travel)
    NSLog(@"DSAEncounterManager triggerEncounter going to post: DSAEncounterWillStartNotification");
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAEncounterWillStartNotification
                                                        object:self
                                                      userInfo:userInfo];

    // Post the actual triggered notification
    NSLog(@"DSAEncounterManager triggerEncounter going to post: DSAEncounterTriggeredNotification");
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAEncounterTriggeredNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Encounter selection (weighted)

- (NSDictionary *)selectEncounterForTerrain:(NSString *)terrain {
    // If user provided tables, look them up
    NSDictionary *tables = self.encounterTables;
    NSDictionary *terrainTable = nil;
    if (tables) {
        terrainTable = tables[terrain];
    }

    if (!terrainTable) {
        // fallback to basic built-in tables
        terrainTable = [self defaultTableForTerrain:terrain];
    }

    NSArray *entries = terrainTable[@"entries"];
    if (!entries || entries.count == 0) return nil;

    // Each entry: @{ @"type": @"animal", @"weight": @10, @"severity": @"minor", @"id": @"wolf_pack", @"params": {...} }
    double totalWeight = 0.0;
    for (NSDictionary *e in entries) {
        totalWeight += [e[@"weight"] doubleValue];
    }
    if (totalWeight <= 0.0) return entries.firstObject;

    double r = ((double)arc4random() / (double)UINT32_MAX) * totalWeight;
    double cumulative = 0.0;
    for (NSDictionary *e in entries) {
        cumulative += [e[@"weight"] doubleValue];
        if (r <= cumulative) {
            return e;
        }
    }
    return entries.lastObject;
}

- (NSDictionary *)defaultTableForTerrain:(NSString *)terrain {
    // Minimal examples. Expand as needed or load from JSON.
    if ([terrain isEqualToString:@"forest"]) {
        return @{
            @"entries": @[
                @{@"type": @"animal", @"id": @"deer", @"weight": @40, @"severity": @(DSAEncounterSeverityTrivial)},
                @{@"type": @"animal", @"id": @"wolf_pack", @"weight": @20, @"severity": @(DSAEncounterSeverityMinor)},
                @{@"type": @"npc", @"id": @"traveling_merchant", @"weight": @10, @"severity": @(DSAEncounterSeverityTrivial)},
                @{@"type": @"monster", @"id": @"forest_spirit", @"weight": @5, @"severity": @(DSAEncounterSeverityMajor)},
            ]
        };
    } else if ([terrain isEqualToString:@"road"]) {
        return @{
            @"entries": @[
                @{@"type": @"npc", @"id": @"merchant_caravan", @"weight": @30, @"severity": @(DSAEncounterSeverityTrivial)},
                @{@"type": @"npc", @"id": @"highwaymen", @"weight": @5, @"severity": @(DSAEncounterSeverityMajor)},
                @{@"type": @"animal", @"id": @"stray_dog", @"weight": @20, @"severity": @(DSAEncounterSeverityTrivial)}
            ]
        };
    } else if ([terrain isEqualToString:@"swamp"]) {
        return @{
            @"entries": @[
                @{@"type": @"monster", @"id": @"swamp_worm", @"weight": @25, @"severity": @(DSAEncounterSeverityMajor)},
                @{@"type": @"animal", @"id": @"bog_boar", @"weight": @25, @"severity": @(DSAEncounterSeverityMinor)},
                @{@"type": @"discovery", @"id": @"bog_ruins", @"weight": @5, @"severity": @(DSAEncounterSeverityTrivial)}
            ]
        };
    } else {
        // default wild
        return @{
            @"entries": @[
                @{@"type": @"animal", @"id": @"wild_beast", @"weight": @50, @"severity": @(DSAEncounterSeverityMinor)},
                @{@"type": @"npc", @"id": @"lost_traveler", @"weight": @10, @"severity": @(DSAEncounterSeverityTrivial)}
            ]
        };
    }
}

@end