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

static NSDictionary<NSString *, Class> *typeToClassMap = nil;

@implementation DSAPoison

+ (void)initialize
{
    if (self == [DSAPoison class]) {
        @synchronized(self) {
            if (!typeToClassMap) {
                typeToClassMap = @{
                    @"Angstgift": [DSAPoisonAngstgift class],
                    @"Arachnae": [DSAPoisonArachnae class],
                    @"Arax": [DSAPoisonArax class],
                    @"Bannstaub": [DSAPoisonBannstaub class],
                    @"Boabungaha": [DSAPoisonBoabungaha class],
                    @"Drachenspeichel": [DSAPoisonDrachenspeichel class],
                    @"Feuerzunge": [DSAPoisonFeuerzunge class],
                    @"Goldleim": [DSAPoisonGoldleim class],
                    @"Gonede": [DSAPoisonGonede class],
                    @"Halbgift": [DSAPoisonHalbgift class],
                    @"Kelmon": [DSAPoisonKelmon class],
                    @"Kukris": [DSAPoisonKukris class],
                    @"Mandragora": [DSAPoisonMandragora class],
                    @"Omrais": [DSAPoisonOmrais class],
                    @"Purpurblitz": [DSAPoisonPurpurblitz class],
                    @"Samthauch": [DSAPoisonSamthauch class],
                    @"Schlafgift": [DSAPoisonSchlafgift class],
                    @"Schwarzer Lotos": [DSAPoisonSchwarzerLotos class],
                    @"Sunsura": [DSAPoisonSunsura class],
                    @"Tinzal": [DSAPoisonTinzal class],
                    @"Tulmadron": [DSAPoisonTulmadron class],
                    @"Wurara": [DSAPoisonWurara class],
                };
            }
        }
    }
}

+ (instancetype)poisonWithName:(NSString *)name fromDictionary:(NSDictionary *)dict
{
    Class subclass = [typeToClassMap objectForKey:name];
    if (subclass) {
        return [[subclass alloc] initPoisonWithName:name fromDictionary:dict];
    } else {
        NSLog(@"DSAPoison: Unknown poison %@", name);
        return [[self alloc] initPoisonWithName:name fromDictionary:dict];
    }
}

- (instancetype)initPoisonWithName:(NSString *)name fromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = name;
        self.level = [dict[@"Stufe"] integerValue];
        self.types = dict[@"Typ"];
        self.onset = dict[@"Beginn"];
        self.duration = dict[@"Dauer"];
        self.shelfLife = dict[@"Haltbarkeit"];
        self.cost = [dict[@"Preis"] floatValue];
        self.crafting = dict[@"Herstellung"];
        self.states = [NSMutableSet setWithObject:@(DSAObjectStateIsPoisoned)];
    }
    return self;
}

- (void)applyEffectToTarget:(id)target
{
    // Default: no effect. Subclasses can override.
}

@end

#pragma mark - Subclasses

@implementation DSAPoisonAngstgift

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Angstgift poison: Induces intense fear.");
}

@end

@implementation DSAPoisonArachnae

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Arachnae poison: Causes paralysis.");
}

@end

@implementation DSAPoisonArax

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Arax poison: Delayed but lethal over time.");
}

@end

@implementation DSAPoisonBannstaub

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Bannstaub poison: Suppresses magic or spiritual energy.");
}

@end

@implementation DSAPoisonBoabungaha

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Boabungaha poison: Death after 5 combat rounds if not neutralized.");
}

@end

@implementation DSAPoisonDrachenspeichel

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Drachenspeichel poison: Potent dual-type magical venom.");
}

@end

@implementation DSAPoisonFeuerzunge

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Feuerzunge poison: Causes intense internal burning.");
}

@end

@implementation DSAPoisonGoldleim

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Goldleim poison: Sticky, paralyzing contact and weapon poison.");
}

@end

@implementation DSAPoisonGonede

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Gonede poison: Lethal after a longer delay.");
}

@end

@implementation DSAPoisonHalbgift

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Halbgift poison: Dual-type magic-induced disorientation.");
}

@end

@implementation DSAPoisonKelmon

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Kelmon poison: Slow-acting contact and weapon poison.");
}

@end

@implementation DSAPoisonKukris

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Kukris poison: Very potent and aggressive toxin.");
}

@end

@implementation DSAPoisonMandragora

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Mandragora poison: Paralyzing root extract.");
}

@end

@implementation DSAPoisonOmrais

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Omrais poison: Fast internal breakdown of vital systems.");
}

@end

@implementation DSAPoisonPurpurblitz

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Purpurblitz poison: Near-instant death.");
}

@end

@implementation DSAPoisonSamthauch

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Samthauch poison: Causes hallucinations and light-headedness.");
}

@end

@implementation DSAPoisonSchlafgift

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Schlafgift poison: Causes deep sleep after short delay.");
}

@end

@implementation DSAPoisonSchwarzerLotos

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Schwarzer Lotos poison: Rare and extremely deadly.");
}

@end

@implementation DSAPoisonSunsura

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Sunsura poison: Slow but persistent degeneration.");
}

@end

@implementation DSAPoisonTinzal

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Tinzal poison: Strong and volatile weapon toxin.");
}

@end

@implementation DSAPoisonTulmadron

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Tulmadron poison: Legendary, with eternal shelf life.");
}

@end

@implementation DSAPoisonWurara

- (void)applyEffectToTarget:(id)target
{
    NSLog(@"Wurara poison: Snake-like, fast and painful.");
}

@end

#pragma mark - Manager

@interface DSAPoisonManager ()
@property (nonatomic, strong) NSArray<DSAPoison *> *poisons;
@end

@implementation DSAPoisonManager

+ (instancetype)sharedManager {
    static DSAPoisonManager *sharedInstance = nil;
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[DSAPoisonManager alloc] init];
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
        DSAPoison *poison = [DSAPoison poisonWithName:name fromDictionary:dict];
        if (poison) {
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

- (DSAPoison *)poisonWithExactName:(NSString *)name {
    for (DSAPoison *poison in self.poisons) {
        if ([poison.name isEqualToString:name]) {
            return poison;
        }
    }
    return nil;
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
@end
