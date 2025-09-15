/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-15 21:24:34 +0200 by sebastia

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

#ifndef _DSAEVENT_H_
#define _DSAEVENT_H_

#import "DSABaseObject.h"
#import "DSADefinitions.h"
@class DSAAventurianDate;
@class DSAPosition;

NS_ASSUME_NONNULL_BEGIN

@interface DSAEvent : DSABaseObject <NSSecureCoding>

@property (nonatomic, strong) DSAPosition *position;
@property (nonatomic, assign) DSAEventType eventType;
@property (nonatomic, strong, nullable) DSAAventurianDate *expiresAt;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *userInfo;

+ (instancetype)eventWithType:(DSAEventType)type
                     position:(DSAPosition *)position
                    expiresAt:(nullable DSAAventurianDate *)expiresAt
                     userInfo:(nullable NSDictionary<NSString *, id> *)userInfo;

- (BOOL)isActiveAtDate:(DSAAventurianDate *)date;

@end
NS_ASSUME_NONNULL_END

#endif // _DSAEVENT_H_

