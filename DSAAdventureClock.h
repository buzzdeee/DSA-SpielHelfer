/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-02 18:41:01 +0100 by sebastia

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

#ifndef _DSAADVENTURECLOCK_H_
#define _DSAADVENTURECLOCK_H_

#import "DSABaseObject.h"
#import "DSAAventurianDate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DSAMoonPhase) {
    DSAMoonPhaseNewMoon = 0,     
    DSAMoonPhaseWaxingCrescent,  
    DSAMoonPhaseFirstQuarter,    
    DSAMoonPhaseWaxingGibbous,   
    DSAMoonPhaseFullMoon,        
    DSAMoonPhaseWaningGibbous,   
    DSAMoonPhaseLastQuarter,     
    DSAMoonPhaseWaningCrescent   
};

/// Zeitfaktor im Verhältnis zur Echtzeit
static const double DSAGameSpeedNormal = 4.0;
static const double DSAGameSpeedTravel = 1800.0;

/// Zentrale Aventurien-Spieluhr (Zeit, Mond, Tag/Nacht)
@interface DSAAdventureClock : DSABaseObject <NSCoding>

@property (nonatomic, strong) DSAAventurianDate *currentDate;
@property (nonatomic, assign) NSTimeInterval gameSpeedMultiplier;
@property (nonatomic, assign) NSInteger residualSeconds;
@property (nonatomic, strong, nullable) NSTimer *gameTimer;
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

#pragma mark - Zeitsteuerung
- (void)startClock;
- (void)pauseClock;
- (void)setGameSpeedMultiplier:(double)newMultiplier;
- (void)setTravelModeEnabled:(BOOL)enabled;

#pragma mark - Zeitfortschritt
- (void)advanceTimeBySeconds:(NSUInteger)seconds sendNotification:(BOOL)notify;
- (void)advanceTimeByMinutes:(NSUInteger)minutes sendNotification:(BOOL)notify;
- (void)advanceTimeByHours:(NSUInteger)hours sendNotification:(BOOL)notify;
- (void)advanceTimeByDays:(NSUInteger)days sendNotification:(BOOL)notify;

#pragma mark - Abfragen
- (NSUInteger)currentMonth;
- (NSUInteger)currentDay;
- (NSUInteger)currentHour;
- (NSUInteger)currentMinute;

#pragma mark - Monde
- (DSAMoonPhase)currentMoonPhase;
- (NSString *)moonPhaseNameForPhase:(DSAMoonPhase)phase;

@end

NS_ASSUME_NONNULL_END


/*
#import "DSABaseObject.h"
#import "DSAAventurianDate.h"
#import "DSARoutePlanner.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DSAMoonPhase) {
    DSAMoonPhaseNewMoon = 0,     // Day 1
    DSAMoonPhaseWaxingCrescent,  // Days 2-7
    DSAMoonPhaseFirstQuarter,    // Day 8
    DSAMoonPhaseWaxingGibbous,   // Days 9-14
    DSAMoonPhaseFullMoon,        // Day 15
    DSAMoonPhaseWaningGibbous,   // Days 16-21
    DSAMoonPhaseLastQuarter,     // Day 22
    DSAMoonPhaseWaningCrescent   // Days 23-28
};

/// Geschwindigkeitseinstellungen in Bezug auf Echtzeit.
/// Beispiel: Bei 4.0 vergeht 1 Spielminute alle 15 Sekunden Echtzeit.
// Geschwindigkeit (Faktor gegenüber Echtzeit)
static const double DSAGameSpeedNormal = 4.0;      // Normal
//static const double DSAGameSpeedTravel = 2160.0;   // Reisegeschwindigkeit
static const double DSAGameSpeedTravel = 60.0;

/// Der zentrale Spielzeitgeber Aventuriens.
/// Steuert alle Zeitsysteme synchron (Reisen, Wetter, Tageszeit, etc.)
@interface DSAAdventureClock : DSABaseObject <NSCoding>

@property (nonatomic, strong) DSAAventurianDate *currentDate;
/// Multiplikator: Wie schnell vergeht Spielzeit gegenüber Echtzeit.
/// Beispiel: 4.0 = 4x schneller → 1 Spielminute = 15 Sekunden Echtzeit.
@property (nonatomic, assign) NSTimeInterval gameSpeedMultiplier;
/// Interner Timer, der regelmäßig "DSAGameTimeAdvanced" Notifications sendet.
@property (nonatomic, strong, nullable) NSTimer *gameTimer;
/// Gibt an, ob die Spieluhr aktuell läuft.
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

#pragma mark - Zeitsteuerung
- (void)startClock;
- (void)pauseClock;
- (void)setGameSpeedMultiplier:(double)newMultiplier;
- (void)setTravelModeEnabled:(BOOL)enabled;

#pragma mark - Zeitfortschritt
- (void)advanceTimeByMinutes:(NSUInteger)minutes;
- (void)advanceTimeByHours:(NSUInteger)hours;
- (void)advanceTimeByDays:(NSUInteger)days;

#pragma mark - Abfragen
//- (NSString *)monthNameForMonth:(DSAAventurianMonth)month;
//- (DSAAventurianMonth)monthForString:(NSString *)monthName;
- (NSUInteger)currentMonth;
- (NSUInteger)currentDay;
- (NSUInteger)currentHour;
- (NSUInteger)currentMinute;

#pragma mark - Monde
- (DSAMoonPhase)currentMoonPhase;
- (NSString *)moonPhaseNameForPhase:(DSAMoonPhase)phase;

@end

NS_ASSUME_NONNULL_END
*/
#endif // _DSAADVENTURECLOCK_H_

