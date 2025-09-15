/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-01 23:26:05 +0100 by sebastia

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

#import "DSAAdventure.h"
#import "DSAAdventureClock.h"
#import "DSAAdventureGroup.h"
#import "DSAGod.h"
#import "DSAEvent.h"
#import "DSALocation.h"

DSAActionContext const DSAActionContextResting = @"Rasten";
DSAActionContext const DSAActionContextPrivateRoom = @"Zimmer";
DSAActionContext const DSAActionContextTavern = @"Taverne";
DSAActionContext const DSAActionContextMarket = @"Markt";
DSAActionContext const DSAActionContextOnTheRoad = @"Unterwegs";
DSAActionContext const DSAActionContextReception = @"Rezeption";

static NSDictionary<DSAActionContext, NSArray<NSString *> *> *DefaultTalentsByContext(void)
{
    return @{
          DSAActionContextResting: @[@"Heilkunde Wunden", @"Heilkunde Gift", @"Heilkunde Krankheiten", @"Heilkunde Seele" ],
          DSAActionContextPrivateRoom: @[@"Heilkunde Wunden", @"Heilkunde Gift", @"Heilkunde Krankheiten", @"Heilkunde Seele" ],
          DSAActionContextTavern: @[@"Falschspiel", @"Taschendiebstahl", @"Musizieren", @"Singen", @"Tanzen", @"Gaukeleien" ],
          DSAActionContextMarket: @[@"Falschspiel", @"Taschendiebstahl", @"Musizieren", @"Singen", @"Tanzen", @"Gaukeleien"]
    };
}
static NSDictionary<DSAActionContext, NSArray<NSString *> *> *DefaultSpellsByContext(void)
{
    return @{
          DSAActionContextResting: @[ @"Balsam Salabunde", @"Hexenspeichel", @"Klarum Purum Kräutersud", @"Analüs Arcanstruktur", @"Odem Arcanum Senserei" ],
          DSAActionContextPrivateRoom: @[ @"Balsam Salabunde", @"Hexenspeichel", @"Klarum Purum Kräutersud", @"Analüs Arcanstruktur", @"Odem Arcanum Senserei" ]
    };
}
static NSDictionary<DSAActionContext, NSArray<NSString *> *> *DefaultRitualsByContext(void)
{
    return @{
          DSAActionContextResting: @[ @"1. Stabzauber", 
                                      @"2. Stabzauber",
                                      @"3. Stabzauber",
                                      @"4. Stabzauber",
                                      @"5. Stabzauber",
                                      @"6. Stabzauber",
                                      @"7. Stabzauber",
                                      @"1. Kugelzauber",
                                      @"2. Kugelzauber",
                                      @"3. Kugelzauber",
                                      @"4. Kugelzauber",
                                      @"5. Kugelzauber",
                                      @"Schwertzauber",
                                      @"Schalenzauber" ],
          DSAActionContextPrivateRoom: @[ @"1. Stabzauber", 
                                          @"2. Stabzauber",
                                          @"3. Stabzauber",
                                          @"4. Stabzauber",
                                          @"5. Stabzauber",
                                          @"6. Stabzauber",
                                          @"7. Stabzauber",
                                          @"1. Kugelzauber",
                                          @"2. Kugelzauber",
                                          @"3. Kugelzauber",
                                          @"4. Kugelzauber",
                                          @"5. Kugelzauber",
                                          @"Schwertzauber",
                                          @"Schalenzauber" ]
    };
}

@implementation DSAAdventure

- (instancetype)init {
    if (self = [super init]) {
        _groups = [NSMutableArray array];
        _discoveredCoordinates = [NSMutableDictionary dictionary];
        _eventsByPosition = [NSMutableDictionary dictionary];
        NSLog(@"DSAAdventure init before _gameClock");
        _gameClock = [[DSAAdventureClock alloc] init];
        
        _gods = [self initializeGods];
        NSMutableDictionary *byType = [NSMutableDictionary dictionary];
        NSMutableDictionary *byName = [NSMutableDictionary dictionary];

        for (DSAGod *god in _gods) {
            byType[@(god.godType)] = god;
            if (god.name) {
                byName[god.name] = god;
            }
        }
        _godsByType = [byType copy];
        _godsByName = [byName copy];     
        
        _availableTalentsByContext = DefaultTalentsByContext();
        _availableSpellsByContext = DefaultSpellsByContext();
        _availableRitualsByContext = DefaultRitualsByContext();
        
        NSLog(@"DSAAdventure init after _gameClock: %@", _gameClock.currentDate);        
        _gameWeather = [[DSAWeather alloc] init];
        NSLog(@"DSAAdventure init after _gameWeather: %@", _gameWeather);
        _characterFilePaths = [[NSMutableDictionary alloc] init];
        NSLog(@"DSAAdventure init after _characterFilePaths");
        NSLog(@"DSAAdventure init after starting clock");
        [self finalizeInitialization];
    }
    
    
    NSLog(@"DSAAdventure init: returning self: %@", self);
    return self;
}

- (void)finalizeInitialization {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGameTimeAdvancedNotification:)
                                                 name:@"DSAGameTimeAdvanced"
                                               object:nil];
    [_gameClock startClock];                                               
}

- (NSArray<DSAGod *> *)initializeGods {
  NSMutableArray *gods = [NSMutableArray array];
  for (NSInteger i = 1; i < DSAGodTypeLast; i++) {
      DSAGod *god = [DSAGod godWithType:(DSAGodType)i];
      if (god) {
          [gods addObject:god];
      }
  }
  return gods;
}

- (void)dealloc
{
  NSLog(@"DSAAdventure is being deallocated.");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  NSLog(@"DSAAdventure finished dealloc.");  
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  NSLog(@"DSAAdventure encodeWithCoder called!");
  [coder encodeObject:self.groups forKey:@"groups"];
  NSLog(@"DSAAdventure encodeWithCoder: encoded self.groups: %@", self.groups);
  [coder encodeObject:self.discoveredCoordinates forKey:@"discoveredCoordinates"];
  [coder encodeObject:self.eventsByPosition forKey:@"eventsByPosition"];
  [coder encodeObject:self.gameClock forKey:@"gameClock"];
  [coder encodeObject:self.gods forKey:@"gods"];
  NSLog(@"DSAAdventure encodeWithCoder called, saved gameClock: %@", self.gameClock);
  [coder encodeObject:self.gameWeather forKey:@"gameWeather"];
  
  [coder encodeObject:self.characterFilePaths forKey:@"characterFilePaths"];
 }

- (instancetype) initWithCoder:(NSCoder *)coder
{
  NSLog(@"DSAAdventure initWithCoder called!");
  self = [super init];
  if (self)
    {
      _availableTalentsByContext = DefaultTalentsByContext();
      _availableSpellsByContext = DefaultSpellsByContext();
      _availableRitualsByContext = DefaultRitualsByContext();
      _groups = [coder decodeObjectForKey:@"groups"];
      NSLog(@"DSAAdventure initWithCoder: decoded self.groups: %@", _groups);
      _discoveredCoordinates = [coder decodeObjectForKey:@"discoveredCoordinates"];
      _eventsByPosition = [coder decodeObjectForKey:@"eventsByPosition"];
      _gameClock = [coder decodeObjectForKey:@"gameClock"];
      // load the gods, and build up the lookup caches
      _gods = [coder decodeObjectForKey:@"gods"];
      NSMutableDictionary *byType = [NSMutableDictionary dictionary];
      NSMutableDictionary *byName = [NSMutableDictionary dictionary];      
      for (DSAGod *god in _gods) {
          byType[@(god.godType)] = god;
          if (god.name) {
              byName[god.name] = god;
          }
      }
      _godsByType = [byType copy];
      _godsByName = [byName copy];
      
      NSLog(@"DSAAdventure initWithCoder called, loaded _gameClock: %@", _gameClock);
      _gameWeather = [coder decodeObjectForKey:@"gameWeather"];
      
      _characterFilePaths = [coder decodeObjectForKey:@"characterFilePaths"] ?: [NSMutableArray array];
      NSLog(@"DSAAdventure initWithCoder, going to start gameClock");
      [self finalizeInitialization];
    }
  NSLog(@"DSAAdventure loaded groups: %@ and characterFilePaths: %@", _groups, _characterFilePaths);
  [DSAAdventureManager sharedManager].currentAdventure = self;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
  return self;
}

- (void)handleGameTimeAdvancedNotification:(NSNotification *)notification {
    DSAAventurianDate *currentDate = notification.userInfo[@"currentDate"];
    //NSLog(@"DSAAdventure handleGameTimeAdvancedNotification called");
    for (DSAAdventureGroup *group in self.groups) {
      //NSLog(@"DSAAdventure handleGameTimeAdvancedNotification checking group");
      for (DSACharacter *character in group.allCharacters) {
        //NSLog(@"DSAAdventure handleGameTimeAdvancedNotification iterating characters in group, character: %@", character.name);
        [character removeExpiredEffectsAtDate:currentDate];
      }
    }
}

- (DSAAdventureGroup *)activeGroup {
    return self.groups.firstObject;
}

- (void)switchToGroupAtIndex:(NSUInteger)index {
    if (index < self.groups.count && index != 0) {
        [self.groups exchangeObjectAtIndex:0 withObjectAtIndex:index];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
    }
}

- (void)addCharacterToActiveGroup:(NSUUID *)characterUUID {
    if (characterUUID && ![self.activeGroup.partyMembers containsObject:characterUUID]) {
        [self.activeGroup.partyMembers addObject:characterUUID];
        NSLog(@"DSAAdventure addCharacterToActiveGroup: after adding UUID");
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
    }
        NSLog(@"DSAAdventure addCharacterToActiveGroup: after adding UUID at the very end!");    
}

- (void)moveCharacter: (NSUUID *) characterUUID toGroup: (DSAAdventureGroup *) targetGroup
{

    NSLog(@"DSAAdventure moveCharacter: %@", characterUUID);
    if (characterUUID && [self.activeGroup.partyMembers containsObject:characterUUID]) {
        [self.activeGroup.partyMembers removeObject:characterUUID];
        if (!targetGroup.partyMembers)
          {
            targetGroup.partyMembers = [NSMutableArray array];
          }
        [targetGroup.partyMembers addObject: characterUUID];
    }
    if (characterUUID && [self.activeGroup.npcMembers containsObject:characterUUID]) {
        [self.activeGroup.npcMembers removeObject:characterUUID];
        if (!targetGroup.npcMembers)
          {
            targetGroup.npcMembers = [NSMutableArray array];
          }        
        [targetGroup.npcMembers addObject: characterUUID];
    }    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
}

- (void)removeCharacterFromActiveGroup:(NSUUID *)characterUUID {
    NSLog(@"DSAAdventure removeCharacterFromActiveGroup: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX %@", [characterUUID UUIDString]);
    [self.activeGroup.partyMembers removeObject:characterUUID];
    [self.characterFilePaths removeObjectForKey: [characterUUID UUIDString]];
    NSLog(@"DSAAdventure removeCharacterFromActiveGroup after removal %@", self.activeGroup.partyMembers);
    for (NSUUID *uuid in self.activeGroup.partyMembers)
      {
    NSLog(@"DSAAdventure removeCharacterFromActiveGroup after removal %@", [uuid UUIDString]);      
      }
    
    // Optional: leere Gruppen löschen?
    if (self.activeGroup.partyMembers.count == 0) {
        [self.groups removeObjectAtIndex:0];
    }
}

- (void)discoverCoordinate:(DSAMapCoordinate *)coord forLocation:(NSString *)location {
    NSMutableSet *discoveredSet = self.discoveredCoordinates[location];
    if (!discoveredSet) {
        discoveredSet = [NSMutableSet set];
        self.discoveredCoordinates[location] = discoveredSet;
    }
    [discoveredSet addObject:coord];
}

- (BOOL)isCoordinateDiscovered:(DSAMapCoordinate *)coord forLocation:(NSString *)location {
    return [self.discoveredCoordinates[location] containsObject:coord];
}

// Saved events related 
- (void)addEvent:(DSAEvent *)event {
    if (!event.position) return;

    NSMutableArray<DSAEvent *> *eventsAtPosition = self.eventsByPosition[event.position];
    if (!eventsAtPosition) {
        eventsAtPosition = [NSMutableArray array];
        self.eventsByPosition[event.position] = eventsAtPosition;
    }

    [eventsAtPosition addObject:event];
}

- (NSArray<DSAEvent *> *)activeEventsAtPosition:(DSAPosition *)position forDate:(DSAAventurianDate *)date {
    NSMutableArray<DSAEvent *> *eventsAtPosition = self.eventsByPosition[position];
    if (!eventsAtPosition) return @[];

    NSMutableArray<DSAEvent *> *activeEvents = [NSMutableArray array];
    for (DSAEvent *event in eventsAtPosition) {
        if ([event isActiveAtDate:date]) {
            [activeEvents addObject:event];
        }
    }
    return activeEvents;
}

- (void)removeExpiredEventsAtPosition:(DSAPosition *)position forDate:(DSAAventurianDate *)date {
    NSMutableArray<DSAEvent *> *eventsAtPosition = self.eventsByPosition[position];
    if (!eventsAtPosition) return;

    NSIndexSet *expiredIndexes = [eventsAtPosition indexesOfObjectsPassingTest:^BOOL(DSAEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
        return ![event isActiveAtDate:date];
    }];
    [eventsAtPosition removeObjectsAtIndexes:expiredIndexes];

    if (eventsAtPosition.count == 0) {
        [self.eventsByPosition removeObjectForKey:position];
    }
}

- (void)removeAllExpiredEventsForDate:(DSAAventurianDate *)date {
    NSArray<DSAPosition<NSCopying> *> *allPositions = [self.eventsByPosition allKeys];
    for (DSAPosition *pos in allPositions) {
        [self removeExpiredEventsAtPosition:pos forDate:date];
    }
}

@end


@implementation DSAAdventureManager
static DSAAdventureManager *sharedInstance = nil;
+ (instancetype)sharedManager {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(instancetype) init
{
  self = [super init];
  if (self)
    {
      _currentAdventure = nil;
    }
  return self;
}

@end