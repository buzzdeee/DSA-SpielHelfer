/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-13 19:41:12 +0200 by sebastia

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

#ifndef _DSAACTIONRESULT_H_
#define _DSAACTIONRESULT_H_

#import "DSABaseObject.h"
#import "DSADefinitions.h"

@interface DSAActionResult : DSABaseObject
@property (nonatomic, assign) DSAActionResultValue result;                         // the short form of the result value
@property (nonatomic, strong) NSString *resultDescription;                         // a wordy description of what happened
@property (nonatomic, strong) NSDictionary <NSString *, NSNumber *>*diceResults;   // a dict containing the dice results per talent
@property (nonatomic, assign) NSInteger remainingActionPoints;                     // i.e. spell or talent is at level 7, rolling dice used up 4 points, remainingActionPoints will be 3
@property (nonatomic, assign) NSInteger actionDuration;                            // in seconds
@property (nonatomic, assign) NSInteger costAE;                                    // specifically for spells, the used AE may be different depending on outcome of the action

// Alle Folge-Deskriptoren von actions/events in a list
@property (nonatomic, strong) NSArray<id<DSAExecutableDescriptor>> *followUps;

+(NSString *) resultNameForResultValue: (DSAActionResultValue) value;

@end

#endif // _DSAACTIONRESULT_H_

