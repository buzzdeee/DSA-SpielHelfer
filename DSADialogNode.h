/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:49:11 +0200 by sebastia

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

#ifndef _DSADIALOGNODE_H_
#define _DSADIALOGNODE_H_

#import <Foundation/Foundation.h>
@class DSADialogOption;

NS_ASSUME_NONNULL_BEGIN
@interface DSADialogNode : NSObject

@property (nonatomic, strong) NSString *nodeID;
@property (nonatomic, strong) NSArray<NSString *> *texts;
@property (nonatomic, strong) NSArray<DSADialogOption *> *playerOptions;
@property (nonatomic, strong, nullable) NSString *hintCategory;

+ (nullable instancetype)nodeFromDictionary:(NSDictionary *)dict;

- (NSString *)randomText;

@end
NS_ASSUME_NONNULL_END
#endif // _DSADIALOGNODE_H_

