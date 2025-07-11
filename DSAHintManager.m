/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:00:22 +0200 by sebastia

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

#import "DSAHintManager.h"
#import "DSAHint.h"
#import "DSALocation.h"
#import "DSAMapCoordinate.h"

@implementation DSAHintManager

+ (instancetype)sharedInstance {
    static DSAHintManager *sharedInstance = nil;
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

- (nullable NSString *)randomHintForLocation:(NSString *)location {
    NSArray<DSAHint *> *hints = self.hintsByLocation[location];
    if (hints.count == 0) return nil;
    NSUInteger randomIndex = arc4random_uniform((uint32_t)hints.count);
    return hints[randomIndex].text;
}

- (instancetype)initWithResourceFilenames:(NSArray<NSString *> *)jsonFilenames {
    self = [super init];
    if (self) {
        _mutableHints = [NSMutableArray array];
        _collectedHintIDs = [NSMutableSet set];
        _hintIDToHintMap = [NSMutableDictionary dictionary];
        _hintsByID = [NSMutableDictionary dictionary];
        _hintsByLocation = [NSMutableDictionary dictionary];

       [self loadAllHintsFromResources];
    }
    return self;
}

- (void)loadAllHintsFromResources {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];

    NSError *error = nil;
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:resourcePath error:&error];
    if (error) {
        NSLog(@"Fehler beim Lesen des Resource-Verzeichnisses: %@", error);
        return;
    }

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^hint_(\\d+)_(\\d+)_(\\d+)\\.json$"
                                                                           options:0
                                                                             error:nil];

    for (NSString *filename in files) {
        NSTextCheckingResult *match = [regex firstMatchInString:filename options:0 range:NSMakeRange(0, filename.length)];
        if (match) {
            NSString *fullPath = [resourcePath stringByAppendingPathComponent:filename];
            NSArray<DSAHint *> *hintsFromFile = [self loadHintsFromFileAtPath:fullPath];
            for (DSAHint *hint in hintsFromFile) {
                [self registerHint:hint];
            }
        }
    }
}

- (NSArray<DSAHint *> *)loadHintsFromFileAtPath:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        NSLog(@"Konnte Datei nicht lesen: %@", path);
        return @[];
    }

    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![jsonArray isKindOfClass:[NSArray class]]) {
        NSLog(@"Fehler beim Parsen von %@: %@", path.lastPathComponent, error);
        return @[];
    }

    NSMutableArray<DSAHint *> *hints = [NSMutableArray array];
    for (NSDictionary *dict in jsonArray) {
        DSAHint *hint = [DSAHint hintFromDictionary:dict];
        if (hint) {
            [hints addObject:hint];
        }
    }

    return [hints copy];
}

- (void)registerHint:(DSAHint *)hint {
    if (!hint.hintID) return;

    _hintIDToHintMap[hint.hintID] = hint;
    [_mutableHints addObject:hint]; // wichtig: zum array hinzufügen

    if (hint.locationName) {
        NSMutableArray *array = _hintsByLocation[hint.locationName];
        if (!array) {
            array = [NSMutableArray array];
            _hintsByLocation[hint.locationName] = array;
        }
        [array addObject:hint];
    }
}

- (NSArray<DSAHint *> *)allHints {
    return [_mutableHints copy];
}

- (void)markHintAsCollected:(NSString *)hintID {
    if (hintID) {
        [self.collectedHintIDs addObject:hintID];
    }
}

- (BOOL)hasCollectedHint:(NSString *)hintID {
    return [self.collectedHintIDs containsObject:hintID];
}

- (NSArray<DSAHint *> *)collectedHints {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *hintID in self.collectedHintIDs) {
        DSAHint *hint = self.hintIDToHintMap[hintID];
        if (hint) {
            [result addObject:hint];
        }
    }
    return [result copy];
}

/// Filtere Hints, die am aktuellen Ort liegen und zum NPC passen
- (NSArray<DSAHint *> *)availableHintsForPosition:(DSAPosition *)position
                                         npcName:(nullable NSString *)npcName
                                         npcRole:(nullable NSString *)npcRole {
    NSMutableArray<DSAHint *> *result = [NSMutableArray array];
    for (DSAHint *hint in self.mutableHints) {
        if ([self hint:hint availableAtPosition:position npcName:npcName npcRole:npcRole]) {
            [result addObject:hint];
        }
    }
    return [result copy];
}

/// Filtere Hints nach Ort
- (NSArray<DSAHint *> *)hintsForLocation:(NSString *)locationName {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAHint *evaluatedHint, NSDictionary *bindings) {
        return [evaluatedHint.locationName isEqualToString:locationName];
    }];
    return [self.mutableHints filteredArrayUsingPredicate:predicate];
}

/// Filtere Hints nach Quest
- (NSArray<DSAHint *> *)hintsForQuest:(NSString *)questID {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAHint *evaluatedHint, NSDictionary *bindings) {
        return [evaluatedHint.questID isEqualToString:questID];
    }];
    return [self.mutableHints filteredArrayUsingPredicate:predicate];
}

- (BOOL)hint:(DSAHint *)hint availableAtPosition:(DSAPosition *)position
                          npcName:(nullable NSString *)npcName
                          npcRole:(nullable NSString *)npcRole {
    if (![hint.locationName isEqualToString:position.globalLocationName]) {
        return NO;
    }
    
    // Position prüfen, falls Koordinate gesetzt
    if (hint.coordinate) {
        CGFloat distance = [position.mapCoordinate euclideanDistanceTo:hint.coordinate];
        if (hint.range >= 0 && distance > hint.range) {
            return NO;
        }
    }
    // NPC Name prüfen
    if (hint.requiresNPC && ![hint.requiresNPC isEqualToString:npcName]) {
        return NO;
    }
    // NPC Rolle prüfen
    if (hint.requiresRole && ![hint.requiresRole isEqualToString:npcRole]) {
        return NO;
    }
    return YES;
}

@end
