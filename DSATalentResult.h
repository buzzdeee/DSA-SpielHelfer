/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-27 21:11:28 +0100 by sebastia

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

#ifndef _DSATALENTRESULT_H_
#define _DSATALENTRESULT_H_

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DSATalentResultValue)
{
  DSATalentResultNone,             // no result yet
  DSATalentResultSuccess,          // normal success
  DSATalentResultAutoSuccess,      // two times 1 as dice result
  DSATalentResultEpicSuccess,      // three times 1 as dice result
  DSATalentResultFailure,          // normal failure
  DSATalentResultAutoFailure,      // two times 20 as dice result
  DSATalentResultEpicFailure       // three times 20 as dice result
};

@interface DSATalentResult : NSObject

@property (nonatomic, assign) DSATalentResultValue result;
@property (nonatomic, strong) NSArray *diceResults;
@property (nonatomic, assign) NSInteger remainingTalentPoints;

+(NSString *) resultNameForResultValue: (DSATalentResultValue) value;

@end

#endif // _DSATALENTRESULT_H_

