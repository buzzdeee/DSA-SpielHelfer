/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-20 15:35:26 +0200 by sebastia

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

#ifndef _DSADEFINITIONS_H_
#define _DSADEFINITIONS_H_

#import <Foundation/Foundation.h>

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

// Used in various actions, i.e. talents, spells, rituals etc.
// to give a hint to the UI what are the relevant targets to present to the user
typedef NS_ENUM(NSInteger, DSAActionTargetType) {
    DSAActionTargetTypeNone = 0,             // Kein Ziel notwendig, der Spruch weiss selbst, worauf er abzielt
    DSAActionTargetTypeAny,                  // Kann jeglicher DSACharacter oder DSAObject sein...
    DSAActionTargetTypeSelf,                 // actor == target
    DSAActionTargetTypeEnemy,                // Gegner
    DSAActionTargetTypeAlly,                 // Gruppenmitglied oder Verbündeter
    DSAActionTargetTypeHuman,                // Menschen
    DSAActionTargetTypeAnimal,               // Tiere
    DSAActionTargetTypeObject,               // Allgemein einzelnes Objekt
    DSAActionTargetTypeObjects,              // alle Objekte im Inventory aller Gruppenmitglieder
    DSAActionTargetTypeObjectLock           // Schlösser von Türen oder Kisten etc.
};

typedef NS_ENUM(NSUInteger, DSAActionResultValue)
{
  DSAActionResultNone,             // no result yet
  DSAActionResultSuccess,          // normal success
  DSAActionResultAutoSuccess,      // two times 1 as dice result
  DSAActionResultEpicSuccess,      // three times 1 as dice result
  DSAActionResultFailure,          // normal failure
  DSAActionResultAutoFailure,      // two times 20 as dice result
  DSAActionResultEpicFailure       // three times 20 as dice result
};


// The following is used to steer the DSAActionViewController
typedef NS_ENUM(NSInteger, DSAActionViewMode) {
    DSAActionViewModeTalent,
    DSAActionViewModeSpell,
    DSAActionViewModeRitual
};

// This is used to parameterize talents, spells etc. to allow the UI to ask the user for specific parameters.
typedef NS_ENUM(NSUInteger, DSAActionParameterType) {
    DSAActionParameterTypeInteger,
    DSAActionParameterTypeBoolean,
    DSAActionParameterTypeChoice,
    DSAActionParameterTypeText,
    DSAActionParameterTypeActiveGroup          // no need to ask the user
};



NSArray<NSString *> *DSAShopGeneralStoreCategories(void);
NSArray<NSString *> *DSAShopWeaponStoreCategories(void);

#endif // _DSADEFINITIONS_H_

