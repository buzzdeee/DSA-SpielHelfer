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

#import "DSAEvent.h"
#import "DSAAventurianDate.h"
#import "DSALocation.h"

@implementation DSAEvent

+ (instancetype)eventWithType:(DSAEventType)type
                     position:(DSAPosition *)position
                    expiresAt:(nullable DSAAventurianDate *)expiresAt
                     userInfo:(nullable NSDictionary<NSString *, id> *)userInfo
{
    DSAEvent *event = [[self alloc] init];
    event.eventType = type;
    event.position = position;
    event.expiresAt = expiresAt;
    event.userInfo = userInfo;
    return event;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.position forKey:@"position"];
    [coder encodeInteger:self.eventType forKey:@"eventType"];
    [coder encodeObject:self.expiresAt forKey:@"expiresAt"];
    [coder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _position = [coder decodeObjectOfClass:[DSAPosition class] forKey:@"position"];
        _eventType = [coder decodeIntegerForKey:@"eventType"];
        _expiresAt = [coder decodeObjectOfClass:[DSAAventurianDate class] forKey:@"expiresAt"];
        _userInfo = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"userInfo"];
    }
    return self;
}

#pragma mark - Logic

- (BOOL)isActiveAtDate:(DSAAventurianDate *)date {
    if (!self.expiresAt) {
        return YES; // unbefristet
    }
    return [self.expiresAt isLaterThanDate:date];
}

@end
