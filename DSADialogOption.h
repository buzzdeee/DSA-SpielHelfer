/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:46:58 +0200 by sebastia

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

#ifndef _DSADIALOGOPTION_H_
#define _DSADIALOGOPTION_H_

#import "DSABaseObject.h"
@class DSADialogAction;

NS_ASSUME_NONNULL_BEGIN
@interface DSADialogOption : DSABaseObject

@property (nonatomic, strong) NSArray<NSString *> *textVariants;
@property (nonatomic, strong) NSString *nextNodeID;
@property (nonatomic, strong, nullable) DSADialogAction *action;
@property (nonatomic, strong, nullable) NSString *hintCategory;
@property (nonatomic) NSInteger duration;  // in minutes
@property (nonatomic, strong, nullable) NSDictionary *skillCheck;

+ (nullable instancetype)optionFromDictionary:(NSDictionary *)dict;

- (NSString *)randomText;



@end
NS_ASSUME_NONNULL_END
#endif // _DSADIALOGOPTION_H_

