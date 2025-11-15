/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:45:28 +0200 by sebastia

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

#ifndef _DSADIALOGACTION_H_
#define _DSADIALOGACTION_H_

#import "DSABaseObject.h"

typedef NS_ENUM(NSUInteger, DSADialogActionType) {
    DSADialogActionTypeNone,
    DSADialogActionTypeGiveHint,
    DSADialogActionTypeEndDialog,
    // weitere Aktionen nach Bedarf
};
NS_ASSUME_NONNULL_BEGIN
@interface DSADialogAction : DSABaseObject

@property (nonatomic, assign) DSADialogActionType type;
@property (nonatomic, strong, nullable) NSString *hintID; // für GiveHint

+ (nullable instancetype)actionFromDictionary:(NSDictionary *)dict;

@end
NS_ASSUME_NONNULL_END

#endif // _DSADIALOGACTION_H_

