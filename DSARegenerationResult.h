/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-12 21:00:06 +0100 by sebastia

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

#ifndef _DSAREGENERATIONRESULT_H_
#define _DSAREGENERATIONRESULT_H_

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DSARegenerationResultValue)
{
  DSARegenerationResultNone,             // no result yet
  DSARegenerationResultSuccess,          // normal success
  DSARegenerationResultFailure,          // normal failure
  DSARegenerationResultTimeTooShort,   // time to regenerate was too short
};

@interface DSARegenerationResult : NSObject

@property (nonatomic, assign) DSARegenerationResultValue result;
@property (nonatomic, assign) NSInteger regenAE;
@property (nonatomic, assign) NSInteger regenKE;
@property (nonatomic, assign) NSInteger regenLE;

+(NSString *) resultNameForResultValue: (DSARegenerationResultValue) value;

@end

#endif // _DSAREGENERATIONRESULT_H_
