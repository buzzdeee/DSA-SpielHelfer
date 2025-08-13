/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-08-11 20:58:22 +0200 by sebastia

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

#ifndef _DSACONSUMPTION_H_
#define _DSACONSUMPTION_H_

#import "DSADefinitions.h"
@class DSAAventurianDate;
@class DSAAdventure;

@interface DSAConsumption : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) DSAConsumptionType type;

// Für Nutzungs-basierten Verbrauch
@property (nonatomic, assign) NSInteger maxUses;
@property (nonatomic, assign) NSInteger remainingUses;

// Für Ablauf-basierten Verbrauch
@property (nonatomic, strong) DSAAventurianDate *manufactureDate;
@property (nonatomic, assign) NSInteger shelfLifeDays;

// Letzter Zustand für Depleted-Check
@property (nonatomic, assign) NSInteger previousUses;

- (instancetype)initWithType:(DSAConsumptionType)type;

/// Versucht, das Objekt zu benutzen.
/// @param currentDate the current adventure time
/// @param reason Optionaler Pointer auf den Grund, warum es nicht funktioniert.
/// @return YES, wenn Nutzung erfolgreich, NO sonst.
- (BOOL)useOnceWithDate:(DSAAventurianDate *)currentDate
                 reason:(DSAConsumptionFailReason *)reason;

/// Ob das Objekt (seit letztem Aufruf) gerade von >0 auf 0 Nutzungen gefallen ist.
/// Nur relevant bei UseMany.
- (BOOL)justDepleted;

/// Ablaufdatum überschritten? Nur bei Expiry.
- (BOOL)isExpiredAtDate:(DSAAventurianDate *)currentDate;

/// to be called when in an adventure, once item "spawned"
- (void)activateExpiryForAdventure:(DSAAdventure *)adventure;

/// to check if expiration for adventure is active
- (BOOL)isExpiryActive;

/// Kann aktuell genutzt werden?
- (BOOL)canUseAtDate: (DSAAventurianDate *) currentDate;

@end

#endif // _DSACONSUMPTION_H_

