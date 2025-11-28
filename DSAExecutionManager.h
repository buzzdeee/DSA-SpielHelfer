/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-18 22:34:13 +0200 by sebastia

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

#ifndef _DSAEXECUTIONMANAGER_H_
#define _DSAEXECUTIONMANAGER_H_

#import <Foundation/Foundation.h>
#import "DSADefinitions.h"
@class DSACharacter;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Action Descriptor

@interface DSAActionDescriptor : NSObject <DSAExecutableDescriptor>

@property (nonatomic, assign) DSAActionType type;
@property (nonatomic, strong) NSDictionary<NSString *, id> *parameters;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) DSAActionScope scope;                          // default to group
@property (nonatomic, weak, nullable) DSACharacter *targetCharacter;         // nil by default, as above defaults to group

+ (instancetype)descriptorFromDictionary:(NSDictionary *)dict;

@end

@interface DSAActionDescriptor (Parsing)
+ (DSAActionType)actionTypeByName:(NSString *)name;
+ (DSAActionScope)actionScopeByName:(NSString *)name;
@end

#pragma mark - Event Descriptor

@interface DSAEventDescriptor : NSObject <DSAExecutableDescriptor>

@property (nonatomic, assign) DSAEventType type;
@property (nonatomic, strong) NSDictionary<NSString *, id> *parameters;
@property (nonatomic, assign) NSInteger order;

@end

#pragma mark - Execution Manager

@class DSAActionResult;

@interface DSAExecutionManager : NSObject

/// Verarbeitet alle FollowUps eines ActionResults.
/// Sortiert sie automatisch nach `order` und führt sie dann aus.
- (void)processActionResult:(DSAActionResult *)result;

/// Kann direkt einzelne Actions ausführen.
- (void)executeAction:(DSAActionDescriptor *)action;

/// Kann direkt einzelne Events triggern.
- (void)triggerEvent:(DSAEventDescriptor *)event;

@end

NS_ASSUME_NONNULL_END
#endif // _DSAEXECUTIONMANAGER_H_

