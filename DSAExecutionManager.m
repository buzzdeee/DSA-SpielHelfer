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
#import "DSACharacter.h"
#import "DSAWallet.h"


#pragma mark - Action Descriptor Implementation

@implementation DSAActionDescriptor
- (instancetype)init
{
    if (self = [super init]) {
        _scope = DSAActionScopeGroup;      // default
        _targetCharacter = nil;
    }
    return self;
}
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
        case DSAActionTypeLooseHealthPoints:
            NSLog(@"DSAExecutionManager executeAction: loose health points: %@", action.parameters);
            [self executeLooseHealthPointsAction: (DSAActionDescriptor *) action];
            break; 
        case DSAActionTypeGainHealthPoints:
            NSLog(@"DSAExecutionManager executeAction: gain health points: %@", action.parameters);
            [self executeGainHealthPointsAction: (DSAActionDescriptor *) action];
            break;   
        case DSAActionTypeGainAdventurePoints:
            NSLog(@"DSAExecutionManager executeAction: gain health points: %@", action.parameters);
            [self executeGainAdventurePointsAction: (DSAActionDescriptor *) action];
            break;                                                     
        default:
            NSLog(@"DSAExecutionManager Unknown action type: %ld aborting!", (long)action.type);
            abort();
            break;
    }
}

- (NSArray<DSACharacter *> *)resolvedTargetsForAction:(DSAActionDescriptor *)action
{
    if (action.scope == DSAActionScopeCharacter && action.targetCharacter) {
        return @[action.targetCharacter];
    }

    DSAAdventureGroup *group = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
    return group.allCharacters;
}


- (void)executeGainMoneyAction: (DSAActionDescriptor *)action
{
  if (action.scope == DSAActionScopeCharacter && action.targetCharacter)
    {
      DSACharacter *character = action.targetCharacter;
      NSInteger silver = [action.parameters[@"amount"] integerValue];
      [character.wallet addSilber: silver];
    }
  else
    {
      DSAAdventureGroup *activeGroup = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
      NSInteger silver = [action.parameters[@"amount"] integerValue];
      [activeGroup addSilber: silver];
    }
}

- (void)executeGainFoodAction: (DSAActionDescriptor *)action
{
  NSArray *targets = [self resolvedTargetsForAction:action];
  for (DSACharacter *character in targets)
    {
      [character updateStateHungerWithValue: @1.0];
    }
}

- (void)executeGainWaterAction: (DSAActionDescriptor *)action
{
  NSArray *targets = [self resolvedTargetsForAction:action];
  DSAObject *water = [[DSAObject alloc] initWithName: @"Wasser" forOwner: nil];
  for (DSACharacter *character in targets)
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
  if (action.scope == DSAActionScopeCharacter && action.targetCharacter)
    {
        DSACharacter *character = action.targetCharacter;
        NSInteger added = [character addObjectToInventory:item quantity:amount];
        NSLog(@"DSAExecutionManager executeGainItemAction: bulk adding %@ to Character: %@", item.name, character.name);
        if (added == amount)
          {
            [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: character targetModel: character];
            return; // Done
          }
        if (added > 0) {
            [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: character targetModel: character];
            amount -= added;
        }
        if (amount <= 0) return;  // should not happen, right?
        while (amount > 0)
          {
            NSInteger added = [character addObjectToInventory:[item copy] quantity:1];
            NSLog(@"DSAExecutionManager executeGainItemAction: single adding %@ to Character: %@", item.name, character.name);
            if (added == 1)
              {
                amount -= 1;
                if (amount == 0)
                  {
                    break;  // nothing more to distribute
                  }
              }
            else  // character inventory is full
              {
                NSLog(@"DSAExecutionManager executeGainItemAction: inventory of %@ is full, can't add item: %@", character.name, item.name);
                break;
              }
          }
        [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: character targetModel: character];              
    }  
  else
    {
      DSAAdventureGroup *activeGroup = [DSAAdventureManager sharedManager].currentAdventure.activeGroup;
      [activeGroup distributeItems: item count: amount];
    }
}

- (void)executeLooseHealthPointsAction: (DSAActionDescriptor *)action
{
  NSLog(@"DSAExecutionManager executeLooseHealthPointsAction NOT YET IMPLEMENTED");
}

- (void)executeGainHealthPointsAction: (DSAActionDescriptor *)action
{
  NSLog(@"DSAExecutionManager executeGainHealthPointsAction NOT YET IMPLEMENTED");
}

- (void)executeGainAdventurePointsAction: (DSAActionDescriptor *)action
{
  NSLog(@"DSAExecutionManager executeGainAdventurePointsAction NOT YET IMPLEMENTED");
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