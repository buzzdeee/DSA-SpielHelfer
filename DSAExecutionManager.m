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
#import "DSAAdventure.h"
#import "DSAEvent.h"
#import "DSAAdventureGroup.h"
#import "DSALocations.h"
#import "DSAInventoryManager.h"


#pragma mark - Action Descriptor Implementation

@implementation DSAActionDescriptor
@end

#pragma mark - Event Descriptor Implementation

@implementation DSAEventDescriptor
@end

#pragma mark - Execution Manager Implementation

@implementation DSAExecutionManager

- (void)processActionResult:(DSAActionResult *)result {
    NSLog(@"DSAExecutionManager processActionResult called with result: %@", result);
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
            NSLog(@"DSAExecutionManager executeAction: Gain item: %@", action.parameters);
            [self executeGainItemAction: (DSAActionDescriptor *) action];
            break;
        case DSAActionTypeGainMoney:
            NSLog(@"DSAExecutionManager executeAction: Gain money: %@", action.parameters);
            [self executeGainMoneyAction: action];
            break;            
        case DSAActionTypeLeaveLocation:
            NSLog(@"DSAExecutionManager executeAction: Leave location: %@", action.parameters);
            [self executeLeaveLocationAction: (DSAActionDescriptor *) action];
            break;
        case DSAActionTypeGainFood:
            NSLog(@"DSAExecutionManager executeAction: Gain Food: %@", action.parameters);
            [self executeGainFoodAction: (DSAActionDescriptor *) action];
            break;
        case DSAActionTypeGainWater:
            NSLog(@"DSAExecutionManager executeAction: Gain Water: %@", action.parameters);
            [self executeGainWaterAction: (DSAActionDescriptor *) action];
            break;                        
        default:
            NSLog(@"DSAExecutionManager Unknown action type: %ld aborting!", (long)action.type);
            abort();
            break;
    }
}

- (void)executeGainMoneyAction: (DSAActionDescriptor *)action
{
  DSAAdventureGroup *activeGroup = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
  NSInteger silver = [action.parameters[@"amount"] integerValue];
  [activeGroup addSilber: silver];
}

- (void)executeGainFoodAction: (DSAActionDescriptor *)action
{
  DSAAdventureGroup *activeGroup = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
  for (DSACharacter *character in activeGroup.allCharacters)
    {
      [character updateStateHungerWithValue: @1.0];
    }
}

- (void)executeGainWaterAction: (DSAActionDescriptor *)action
{
  DSAAdventureGroup *activeGroup = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
  DSAObject *water = [[DSAObject alloc] initWithName: @"Wasser" forOwner: nil];
  for (DSACharacter *character in activeGroup.allCharacters)
    {
      [character updateStateThirstWithValue: @1.0];
      NSArray *waterBuckets = [[DSAInventoryManager sharedManager] findItemsBySubCategory: @"Wasserbehälter"
                                                                                  inModel: character];
      for (DSAObjectContainer *waterBucket in waterBuckets)
        {
          NSInteger slots = [waterBucket countEmptySlots];
          [waterBucket storeItem: [water copy] ofQuantity: slots];
        }
    }
}

- (void)executeGainItemAction: (DSAActionDescriptor *)action
{
  NSInteger amount = [action.parameters[@"amount"] integerValue];
  DSAObject *item = [[DSAObject alloc] initWithName: action.parameters[@"type"] forOwner: nil];
  DSAAdventureGroup *activeGroup = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
  [activeGroup distributeItems: item count: amount];
}

- (void) executeLeaveLocationAction: (DSAActionDescriptor *)action
{
  DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
  DSAAdventureGroup *activeGroup = adventure.activeGroup;
  
  [activeGroup leaveLocation];
}

- (void)triggerEvent:(DSAEventDescriptor *)event {
    switch (event.type) {
        case DSAEventTypeLocationBan:
            NSLog(@"DSAExecutionManager triggerEvent: Location ban: %@", event.parameters);
            [self triggerLocationBan: event];
            break;
        default:
            NSLog(@"DSAExecutionManager triggerEvent: Unknown event type: %ld aborting!", (long)event.type);
            abort();
            break;
    }
}

-(void)triggerLocationBan: (DSAEventDescriptor *)event {
  NSLog(@"DSAEventManager triggerLocationBan: Location ban: %@", event.parameters);

  DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
  
  DSAPosition<NSCopying> *position = event.parameters[@"position"];
  NSNumber *durationDays = event.parameters[@"durationDays"];

  if (!position || !durationDays) {
      NSLog(@"DSAEventManager triggerLocationBan: LocationBan missing parameters!");
      abort();
  }

  // Ablaufdatum setzen
  DSAAventurianDate *expiresAt = durationDays ? [[adventure now]
                                                 dateByAddingYears: 0
                                                              days: [durationDays integerValue]
                                                             hours: 0
                                                           minutes: 0] 
                                               : nil;

  // Event erzeugen
  DSAEvent *banEvent = [DSAEvent eventWithType:DSAEventTypeLocationBan
                                      position:position
                                     expiresAt:expiresAt
                                      userInfo:nil];

  // Event ins Adventure eintragen
  if (!adventure.eventsByPosition[position]) {
      adventure.eventsByPosition[position] = [NSMutableArray array];
  }
  [adventure addEvent:banEvent];
  NSLog(@"DSAEventManager triggerLocationBan: Added LocationBan for %@ until %@", position, expiresAt);
  NSLog(@"DSAEventManager triggerLocationBan: eventsByPosition in adventure: %@", adventure.eventsByPosition);
  

}  


@end