/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:51:01 +0200 by sebastia

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

#ifndef _DSADIALOG_H_
#define _DSADIALOG_H_

#import "DSABaseObject.h"
@class DSADialogNode;
@class DSACharacter;

NS_ASSUME_NONNULL_BEGIN
@interface DSADialog : DSABaseObject

@property (nonatomic, strong) NSString *npcName; // z.B. "innkeeper"
@property (nonatomic, strong) NSString *thumbnailImageName;
@property (nonatomic, strong) NSString *mainImageName;
@property (nonatomic, strong) DSACharacter *actingCharacter; // the one doing skill check for example
@property (nonatomic, strong) NSDictionary<NSString *, DSADialogNode *> *nodes; // nodeID -> node
@property (nonatomic, strong) NSString *startNodeID;

+ (nullable instancetype)dialogFromDictionary:(NSDictionary *)dict;

- (DSADialogNode *)nodeForID:(NSString *)nodeID;

@end
NS_ASSUME_NONNULL_END
#endif // _DSADIALOG_H_

