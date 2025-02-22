/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-09 02:03:56 +0200 by sebastia

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

#ifndef _UTILS_H_
#define _UTILS_H_

#import <AppKit/AppKit.h>
#import "DSASlot.h"
#import "DSACharacter.h"

typedef NS_ENUM(NSInteger, LogSeverity) {
    LogSeverityInfo,
    LogSeverityHappy,
    LogSeverityWarning,
    LogSeverityCritical
};

typedef NS_ENUM(NSUInteger, DSASeverityLevel) {
    DSASeverityLevelNone = 0,
    DSASeverityLevelMild,
    DSASeverityLevelModerate,
    DSASeverityLevelSevere
};

@interface Utils : NSObject

+ (instancetype)sharedInstance;

+ (NSDictionary *) getDSAObjectInfoByName: (NSString *) name;

+ (NSDictionary *) parseDice: (NSString *) diceDefinition;
+ (NSDictionary *) parseConstraint: (NSString *) constraintDefinition;
+ (NSInteger) rollDice: (NSString *) diceDefinition;

+ (NSDictionary *) getDSAObjectsDict;
+ (NSDictionary *) getDSAObjectInfoByName: (NSString *) name;
+ (DSASlotType)slotTypeFromString:(NSString *)slotTypeString;
+ (NSString *)formatTPEntfernung:(NSDictionary *)tpEntfernung;

+ (NSDictionary *) getNamesDict;
+ (NSDictionary *) getNamesForRegion: (NSString *) region;

+ (NSDictionary *) getMagicalDabblerSpellsDict;

+ (NSDictionary *) getWitchCursesDict;

+ (NSDictionary *) getMischievousPranksDict;

+ (NSDictionary *) getMageRitualsDict;
+ (NSDictionary *) getMageRitualWithName: (NSString *) ritualName;

+ (NSDictionary *) getGeodeRitualsDict;

+ (NSDictionary *) getShamanRitualsDict;

+ (NSDictionary *) getDruidRitualsDict;
+ (NSDictionary *) getDruidRitualWithName: (NSString *) ritualName;

+ (NSDictionary *) getElvenSongsDict;

+ (NSDictionary *) getBirthdaysDict;

+ (NSDictionary *) getEyeColorsDict;

+ (NSDictionary *) getSpellsDict;
+ (NSDictionary *) getSpellWithName: (NSString *) ritualName;

+ (NSDictionary *) getSharisadDancesDict;

+ (NSDictionary *) getShamanOriginsDict;

+ (NSString *) findSpellOrRitualTypeWithName: (NSString *) name;

+ (NSDictionary *) getTalentsDict;
+ (NSDictionary *) getTalentsForCharacter: (DSACharacter *)character;

+ (NSDictionary *) getWarriorAcademiesDict;

+ (NSDictionary *) getArchetypesDict;
+ (NSArray *) getAllArchetypesCategories;
+ (NSArray *) getAllArchetypesForCategory: (NSString *) category;

+ (NSDictionary *) getOriginsDict;
+ (NSArray *) getOriginsForArchetype: (NSString *) archetype;

+ (NSDictionary *) getGodsDict;

+ (NSDictionary *) getMageAcademiesDict;
+ (NSArray *) getMageAcademiesAreasOfExpertise;
+ (NSArray *) getMageAcademiesOfExpertise: (NSString *) expertise;

+ (NSDictionary *) getProfessionsDict;
+ (NSArray *) getProfessionsForArchetype: (NSString *) archetype;

+ (NSDictionary *) getBlessedLiturgiesDict;

+ (NSColor *)colorForDSASeverity:(DSASeverityLevel)level;
+ (NSColor *)colorForBooleanState:(BOOL)state;

@end

#endif // _UTILS_H_

