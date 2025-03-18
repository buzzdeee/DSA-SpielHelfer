/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-02 20:21:50 +0100 by sebastia

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

#ifndef _DSACLOCKANIMATIONVIEW_H_
#define _DSACLOCKANIMATIONVIEW_H_

#import <AppKit/AppKit.h>
#import "DSAAdventureClock.h"
#import "DSAWeather.h"

@interface DSAClockAnimationView : NSImageView

@property (nonatomic, strong) DSAWeather *gameWeather;
@property (nonatomic, strong) DSAAdventureClock *gameClock;

// Method to update the animation based on the current time and moon phase
- (void)updateAnimationForHour:(NSUInteger)hour 
                        minute:(NSUInteger)minute 
                     moonPhase:(DSAMoonPhase)moonPhase;
// update animation based on current DSAAventurianCalendar
- (void)timerUpdate;
@end

#endif // _DSACLOCKANIMATIONVIEW_H_

