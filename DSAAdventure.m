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
#import "DSALocations.h"
#import "DSAMapCoordinate.h"
#import "DSARoutePlanner.h"

DSAActionContext const DSAActionContextResting = @"Rasten";
DSAActionContext const DSAActionContextPrivateRoom = @"Zimmer";
DSAActionContext const DSAActionContextTavern = @"Taverne";
DSAActionContext const DSAActionContextMarket = @"Markt";
DSAActionContext const DSAActionContextOnTheRoad = @"Unterwegs";
DSAActionContext const DSAActionContextReception = @"Rezeption";
DSAActionContext const DSAActionContextTravel = @"Reisen";

NSString * const DSAAdventureTravelDidBeginNotification = @"DSAAdventureTravelDidBegin";
NSString * const DSAAdventureTravelDidProgressNotification = @"DSAAdventureTravelDidProgress";
NSString * const DSAAdventureTravelRestingNotification = @"DSAAdventureTravelResting";
NSString * const DSAAdventureTravelDidEndNotification = @"DSAAdventureTravelDidEnd";


static NSDictionary<DSAActionContext, NSArray<NSString *> *> *DefaultTalentsByContext(void)
{
    return @{
          DSAActionContextResting: @[@"Heilkunde Wunden", @"Heilkunde Gift", @"Heilkunde Krankheiten", @"Heilkunde Seele" ],
          DSAActionContextPrivateRoom: @[@"Heilkunde Wunden", @"Heilkunde Gift", @"Heilkunde Krankheiten", @"Heilkunde Seele" ],
          DSAActionContextTavern: @[@"Falschspiel", @"Taschendiebstahl", @"Musizieren", @"Singen", @"Tanzen", @"Akrobatik", @"Gaukeleien" ],
          DSAActionContextMarket: @[@"Falschspiel", @"Taschendiebstahl", @"Musizieren", @"Singen", @"Tanzen", @"Akrobatik", @"Gaukeleien" ]
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

@interface DSAAdventure ()
@property (nonatomic, strong) DSARouteResult *routeResult;
@property (nonatomic, assign) NSInteger currentSegmentIndex;
@property (nonatomic, assign) CGFloat segmentProgress;
@property (nonatomic, assign) CGFloat segmentMilesDone;
@property (nonatomic, assign) CGFloat travelHoursToday;
@end

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDSAAdventureTravelEndNotification:)
                                                 name:@"DSAAdventureTravelEnd"
                                               object:nil];                                               
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureTravelEnd" object:self];
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
  
  [coder encodeObject:self.currentStartLocation forKey:@"currentStartLocation"];  
  [coder encodeObject:self.currentDestinationLocation forKey:@"currentDestinationLocation"];
  [coder encodeObject:self.routeResult forKey:@"routeResult"];
  [coder encodeInteger:self.currentSegmentIndex forKey:@"currentSegmentIndex"];
  [coder encodeDouble:(double)self.segmentProgress forKey:@"segmentProgress"];
  [coder encodeDouble:(double)self.segmentProgress forKey:@"segmentProgress"];
  [coder encodeDouble:(double)self.travelHoursToday forKey:@"travelHoursToday"];
  
  [coder encodeBool:self.traveling forKey:@"traveling"];
  [coder encodeDouble:(double)self.travelProgress forKey:@"travelProgress"];
  
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
      _currentStartLocation = [coder decodeObjectForKey:@"currentStartLocation"];
      _currentDestinationLocation = [coder decodeObjectForKey:@"currentDestinationLocation"];
      _routeResult = [coder decodeObjectForKey:@"routeResult"];
      _currentSegmentIndex = [coder decodeIntegerForKey:@"currentSegmentIndex"];
      _segmentProgress = (CGFloat)[coder decodeDoubleForKey:@"segmentProgress"];
      _segmentMilesDone = (CGFloat)[coder decodeDoubleForKey:@"segmentMilesDone"];
      _travelHoursToday = (CGFloat)[coder decodeDoubleForKey:@"travelHoursToday"];
      _traveling = [coder decodeBoolForKey:@"traveling"];
      _travelProgress = (CGFloat)[coder decodeDoubleForKey:@"travelProgress"];
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

-(void)handleDSAAdventureTravelEndNotification:(NSNotification *)notification
{
  [self.gameClock setTravelModeEnabled: NO];
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


- (DSAAventurianDate *) now
{
  return self.gameClock.currentDate;
}

- (DSAPosition *) position
{
  return self.activeGroup.position;
}


- (NSString *) locationInfoForMainImageView
{
  NSString *retVal;
  DSAPosition *position = self.position;
  // check when traveling
  if (position.localLocationName == nil)
    {
      if ([position.context isEqualToString: DSAActionContextTravel])
        {
          retVal = [NSString stringWithFormat: @"Reise von %@ nach %@", self.currentStartLocation.name, self.currentDestinationLocation.name];
        }
      else if ([position.context isEqualToString: DSAActionContextResting])
        {
          retVal = [NSString stringWithFormat: @"Rast auf Reise von %@ nach %@", self.currentStartLocation.name, self.currentDestinationLocation.name];
        }
      else
        {
          NSLog(@"DSAAdventure locationInfoForMainImageView unknown DSAActionContext: %@ while outside local location, aborting.", position.context);
          abort();
        }      
    }
  else
    {
       DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: position.localLocationName ofType: @"local"];
        
       if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
         {
           DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
           DSALocalMapTile *currentTile = [lml tileAtCoordinate: position.mapCoordinate];
           if ([currentTile isKindOfClass: [DSALocalMapTileGreen class]] ||
               [currentTile isKindOfClass: [DSALocalMapTileStreet class]] ||
               [currentTile isKindOfClass: [DSALocalMapTileRoute class]])
             {
               retVal = [currentLocation.name copy];
             }
           else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingTemple class]])
             {
               retVal = [NSString stringWithFormat: @"%@ Tempel in %@", [(DSALocalMapTileBuildingTemple *)currentTile god], currentLocation.name];
             }
           else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingInn class]])
             {
               retVal = [NSString stringWithFormat: @"%@ \"%@\" in %@", currentTile.type, [(DSALocalMapTileBuildingInn *)currentTile name], currentLocation.name];                   
             }
           else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingHealer class]])
             {
               retVal = [NSString stringWithFormat: @"Heiler \"%@\" in %@", [(DSALocalMapTileBuilding *)currentTile npc], currentLocation.name];
             }              
           else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingSmith class]])
             {
               retVal = [NSString stringWithFormat: @"Schmied \"%@\" in %@", [(DSALocalMapTileBuilding *)currentTile npc], currentLocation.name];
             }
           else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingShop class]])
             {
               retVal = [NSString stringWithFormat: @"%@ \"%@\" in %@", currentTile.type, [(DSALocalMapTileBuildingShop *)currentTile npc], currentLocation.name];
             }
           else
             {
               NSLog(@"DSAAdventure locationInfoForMainImageView unhandled tile class: %@, aborting", [currentTile class]);
               abort();
             }                                  
         }      
    }
  
  return retVal;
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


@implementation DSAAdventure (Travel)

#pragma mark - Travel API

- (void)beginTravelFrom:(NSString *)startName to:(NSString *)destName
{
    if (self.traveling) {
        NSLog(@"⚠️ Already traveling");
        return;
    }

    self.currentStartLocation = [[DSALocations sharedInstance] locationWithName:startName ofType:@"global"];
    self.currentDestinationLocation = [[DSALocations sharedInstance] locationWithName:destName ofType:@"global"];

    DSARoutePlanner *planner = [DSARoutePlanner sharedRoutePlanner];
    self.routeResult = [planner findShortestPathFrom:startName to:destName];

    if (!self.currentStartLocation || !self.currentDestinationLocation || !self.routeResult) {
        NSLog(@"❌ Invalid travel call");
        return;
    }

    NSLog(@"🚀 BEGIN TRAVEL %@ → %@ (%.2f miles, %lu segments)",
          startName, destName, self.routeResult.routeDistance, self.routeResult.segments.count);

    self.traveling = YES;
    self.travelProgress = 0.0;
    self.currentSegmentIndex = 0;
    self.segmentProgress = 0;
    self.travelHoursToday = 0;
    
    self.activeGroup.position.localLocationName = nil;
    self.activeGroup.position.context = DSAActionContextTravel;

    [self.gameClock setTravelModeEnabled:YES];

    // subscribe to clock
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleClockTick:)
                                                 name:@"DSAGameTimeAdvanced"
                                               object:nil];

    NSDictionary *info = @{
        @"adventure": self,
        @"startLoc": self.currentStartLocation,
        @"endLoc": self.currentDestinationLocation
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidBeginNotification
                                                        object:self
                                                      userInfo:info];
}

#pragma mark - Handle Clock Tick

- (void)handleClockTick:(NSNotification *)note
{
    if (!self.traveling) return;

    NSNumber *sec = note.userInfo[@"advancedSeconds"];
    double secondsPassed = sec.doubleValue;
    
    // convert seconds → hours (1h per game-hour tick)
    double hoursPassed = secondsPassed / 3600.0;
    self.travelHoursToday += hoursPassed;

    // Rastbeginn?
    double maxHours = 12.0;
    if (self.travelHoursToday >= maxHours) {
        NSLog(@"🌙 travel day over, resting");
        [self rest];
        self.travelHoursToday = 0;
        return;
    }

    // ⏩ Segment vorantreiben
    [self progressSegmentByHours:hoursPassed];
}

#pragma mark - Travel Logic

- (void)progressSegmentByHours:(double)hours
{
    if (self.currentSegmentIndex >= self.routeResult.segments.count) {
        [self endTravel];
        return;
    }

    DSARouteSegment *seg = self.routeResult.segments[self.currentSegmentIndex];
    CGFloat mod = [self speedModifierForRouteType:seg.routeType];

    CGFloat baseMilesPerDay = 30.0;
    CGFloat milesPerHour = (baseMilesPerDay / 24.0) * mod;

    CGFloat milesThisTick = milesPerHour * hours;
    
    self.segmentMilesDone += milesThisTick;

    if (self.segmentMilesDone >= seg.distanceMiles) {
        // Segment fertig
        self.segmentMilesDone = 0;
        self.currentSegmentIndex++;

        NSLog(@"➡️ finished segment %lu/%lu",
              (unsigned long)self.currentSegmentIndex,
              (unsigned long)self.routeResult.segments.count);
    }

    // total progress (segment + global)
    CGFloat segmentFraction = seg.distanceMiles > 0 ? (self.segmentMilesDone / seg.distanceMiles) : 1.0;
    CGFloat totalFraction = (self.currentSegmentIndex + segmentFraction) / (CGFloat)self.routeResult.segments.count;

    [self updateTravelProgress:totalFraction];

    if (totalFraction >= 1.0) {
        [self endTravel];
    }
}

#pragma mark - Rest / Continue / Reverse

- (void)rest
{
    if (![self.activeGroup.position.context isEqualToString:DSAActionContextTravel])
        return;

    self.activeGroup.position.context = DSAActionContextResting;
    [self.gameClock setTravelModeEnabled:NO];

    NSDictionary *u = @{@"adventure": self};
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelRestingNotification
                                                        object:self
                                                      userInfo:u];
}

- (void)continueTravel
{
    if (![self.activeGroup.position.context isEqualToString:DSAActionContextResting]) return;

    NSLog(@"☀️ continue travel");
    self.activeGroup.position.context = DSAActionContextTravel;
    [self.gameClock setTravelModeEnabled:YES];

    NSDictionary *u = @{@"adventure": self};
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidBeginNotification
                                                        object:self
                                                      userInfo:u];
}

- (void)goBack
{
    // swap start & dest
    DSALocation *tmp = self.currentStartLocation;
    self.currentStartLocation = self.currentDestinationLocation;
    self.currentDestinationLocation = tmp;

    self.travelProgress = 1.0 - self.travelProgress;
    self.currentSegmentIndex = self.routeResult.segments.count - self.currentSegmentIndex;
    self.segmentMilesDone = 0;

    NSLog(@"↩️ reversing route, new target: %@", self.currentDestinationLocation.name);

    if ([self.activeGroup.position.context isEqualToString:DSAActionContextTravel]) {
        NSDictionary *info = @{
            @"adventure": self,
            @"startLoc": self.currentStartLocation,
            @"endLoc": self.currentDestinationLocation
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidBeginNotification
                                                            object:self
                                                          userInfo:info];
    }
}

#pragma mark - End Travel

- (void)endTravel
{
    if (!self.traveling) return;

    NSLog(@"🏁 ARRIVED at %@", self.currentDestinationLocation.name);

    self.traveling = NO;
    self.travelProgress = 1.0;
    [self.gameClock setTravelModeEnabled:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DSAGameTimeAdvanced" object:nil];

    DSAPosition *pos = [[DSALocations sharedInstance]
                        arrivalTileInLocalLocationWithDestinationName:self.currentDestinationLocation.name
                        fromOriginName:self.currentStartLocation.name];

    self.activeGroup.position = pos;

    NSDictionary *u = @{@"adventure": self, @"destination": self.currentDestinationLocation};
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidEndNotification
                                                        object:self
                                                      userInfo:u];

    self.currentStartLocation = nil;
    self.currentDestinationLocation = nil;
}

#pragma mark - Progress Notify

- (void)updateTravelProgress:(CGFloat)progress
{
    self.travelProgress = MIN(progress, 1.0);
    
    NSDictionary *u = @{ @"progress": @(self.travelProgress) };
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidProgressNotification
                                                        object:self
                                                      userInfo:u];
}

#pragma mark - Speed Modifier

- (CGFloat)speedModifierForRouteType:(DSARouteType)type
{
    switch (type) {
        case DSARouteTypeRS:                     return 1.10;
        case DSARouteTypeLS:                     return 1.00;
        case DSARouteTypeWeg:                    return 0.80;
        case DSARouteTypeOffenesGelaendePfad:    return 0.80;
        case DSARouteTypeOffenesGelaende:        return 0.75;        
        case DSARouteTypeLichterWaldPfad:        return 0.75;
        case DSARouteTypeLichterWald:            return 0.60;
        case DSARouteTypeWaldPfad:               return 0.60;
        case DSARouteTypeWald:                   return 0.50;
        case DSARouteTypeDichterWaldPfad:        return 0.50;
        case DSARouteTypeDichterWald:            return 0.20;
        case DSARouteTypeGebirgePassstrecke:     return 0.40;
        case DSARouteTypeGebirgePfad:            return 0.30;
        case DSARouteTypeGebirgeKeinKlettern:    return 0.20;
        case DSARouteTypeHochgebirgeMitKlettern: return 0.10;
        case DSARouteTypeRegenwaldPfad:          return 0.40;
        case DSARouteTypeRegenwald:              return 0.20;
        case DSARouteTypeRegenwaldGebirge:       return 0.10;
        case DSARouteTypeSumpfKnueppeldamm:      return 0.50;
        case DSARouteTypeSumpfPfad:              return 0.30;
        case DSARouteTypeSumpf:                  return 0.10;
        case DSARouteTypeEisgebietFreieFlaeche:  return 0.70;
        case DSARouteTypeEisgebietTiefschnee:    return 0.40;
        case DSARouteTypeEisgebietEisflaeche:    return 0.20;
        case DSARouteTypeEisgebirgeGletscher:    return 0.10;
        case DSARouteTypeGeroellwueste:          return 0.60;
        case DSARouteTypeSandwueste:             return 0.50;
        case DSARouteTypeFaehre:                 return 1.00;
        case DSARouteTypeSeeschiff:              return 1.50;
        case DSARouteTypeFlussschiff:            return 1.30;
    }
    return 1.0;
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