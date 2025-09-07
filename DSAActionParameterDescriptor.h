/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-22 21:17:13 +0200 by sebastia

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

#ifndef _DSAACTIONPARAMETERDESCRIPTOR_H_
#define _DSAACTIONPARAMETERDESCRIPTOR_H_

#import "DSABaseObject.h"
#import "DSADefinitions.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSAActionParameterDescriptor : DSABaseObject <NSSecureCoding>

@property (nonatomic, copy) NSString *key;              // Interner Schlüssel, z.B. @"aspAmount"
@property (nonatomic, copy) NSString *label;            // Nutzerfreundlicher UI-Text, z.B. @"Wie viele ASP einsetzen?"
@property (nonatomic, copy, nullable) NSString *helpText;  // z.B.: Mindestens 7 ASP (sofern verfügbar), jeder ASP heilt 1 LP.
@property (nonatomic, assign) DSAActionParameterType type;

// Optional für .choice
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *choices;  // keys are popupTitles, values are represented objects

// Optional für .integer
@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, assign) NSInteger maxValue;        // if set to NSIntegerMax, then the max value is context dependent, i.e. current value of spell casting character currentAstralEnergy

// Convenience initializer
+ (instancetype)descriptorWithKey:(NSString *)key
                            label:(NSString *)label
                         helpText:(NSString *)helpText
                             type:(DSAActionParameterType)type;

@end

NS_ASSUME_NONNULL_END

#endif // _DSAACTIONPARAMETERDESCRIPTOR_H_

