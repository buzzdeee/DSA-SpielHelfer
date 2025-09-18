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

#import "DSAExecutionManager.h"
#import "DSAActionResult.h"

#pragma mark - Action Descriptor Implementation

@implementation DSAActionDescriptor
@end

#pragma mark - Event Descriptor Implementation

@implementation DSAEventDescriptor
@end

#pragma mark - Execution Manager Implementation

@implementation DSAExecutionManager

- (void)processActionResult:(DSAActionResult *)result {
    NSArray<id<DSAExecutableDescriptor>> *sorted =
        [result.followUps sortedArrayUsingComparator:^NSComparisonResult(id<DSAExecutableDescriptor> a,
                                                                         id<DSAExecutableDescriptor> b) {
        if (a.order < b.order) return NSOrderedAscending;
        if (a.order > b.order) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    NSInteger currentOrder = NSNotFound;
    for (id<DSAExecutableDescriptor> descriptor in sorted) {
        if (descriptor.order != currentOrder) {
            currentOrder = descriptor.order;
            NSLog(@"--- Step %ld ---", (long)currentOrder);
        }

        if ([descriptor isKindOfClass:[DSAActionDescriptor class]]) {
            [self executeAction:(DSAActionDescriptor *)descriptor];
        } else if ([descriptor isKindOfClass:[DSAEventDescriptor class]]) {
            [self triggerEvent:(DSAEventDescriptor *)descriptor];
        }
    }
}

- (void)executeAction:(DSAActionDescriptor *)action {
    switch (action.type) {
        case DSAActionTypeGainItem:
            NSLog(@"[Action] Gain item: %@", action.parameters);
            break;
        case DSAActionTypeLeaveLocation:
            NSLog(@"[Action] Leave location: %@", action.parameters);
            break;
        default:
            NSLog(@"[Action] Unknown action type: %ld", (long)action.type);
            break;
    }
}

- (void)triggerEvent:(DSAEventDescriptor *)event {
    switch (event.type) {
        case DSAEventTypeLocationBan:
            NSLog(@"[Event] Tavern ban: %@", event.parameters);
            break;
        default:
            NSLog(@"[Event] Unknown event type: %ld", (long)event.type);
            break;
    }
}

@end