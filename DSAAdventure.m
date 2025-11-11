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
#import "Utils.h"
#import "DSAPlant.h"
#import "DSARegion.h"
#import "DSAActionResult.h"

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
@property (nonatomic, assign) CGFloat encounterChancePerMile;
@property (nonatomic, assign) CGFloat milesUntilNextEncounterCheck;
@property (nonatomic, assign) CGFloat totalMilesTraveled;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContinueTravel:)
                                                 name:@"DSAContinueTravelNotification"
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
  
  [coder encodeObject:self.currentStartLocation forKey:@"currentStartLocation"];  
  [coder encodeObject:self.currentDestinationLocation forKey:@"currentDestinationLocation"];
  [coder encodeObject:self.routeResult forKey:@"routeResult"];
  [coder encodeInteger:self.currentSegmentIndex forKey:@"currentSegmentIndex"];
  [coder encodeDouble:(double)self.segmentProgress forKey:@"segmentProgress"];
  [coder encodeDouble:(double)self.segmentProgress forKey:@"segmentProgress"];
  [coder encodeDouble:(double)self.travelHoursToday forKey:@"travelHoursToday"];
  [coder encodeDouble:(double)self.encounterChancePerMile forKey:@"encounterChancePerMile"];
  [coder encodeDouble:(double)self.milesUntilNextEncounterCheck forKey:@"milesUntilNextEncounterCheck"];
  [coder encodeDouble:(double)self.totalMilesTraveled forKey:@"totalMilesTraveled"];
  [coder encodeBool:self.traveling forKey:@"traveling"];
  [coder encodeDouble:(double)self.travelProgress forKey:@"travelProgress"];
    
  [coder encodeBool:self.inEncounter forKey:@"inEncounter"];
  [coder encodeObject:self.encounterInfo forKey:@"encounterInfo"];
  
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
      _encounterChancePerMile = (CGFloat)[coder decodeDoubleForKey:@"encounterChancePerMile"];
      _milesUntilNextEncounterCheck = (CGFloat)[coder decodeDoubleForKey:@"milesUntilNextEncounterCheck"];
      _totalMilesTraveled = (CGFloat)[coder decodeDoubleForKey:@"totalMilesTraveled"];
      _traveling = [coder decodeBoolForKey:@"traveling"];
      _travelProgress = (CGFloat)[coder decodeDoubleForKey:@"travelProgress"];
            
      _inEncounter = [coder decodeBoolForKey:@"inEncounter"];
      _encounterInfo = [coder decodeObjectForKey:@"encounterInfo"];

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
      else if ([position.context isEqualToString: DSAActionContextEncounter])
        {
          DSAEncounterType encounterType = [self.encounterInfo[@"encounterType"] integerValue];
          switch (encounterType) {
            case DSAEncounterTypeMerchant: {
              NSString *merchantType = self.encounterInfo[@"subType"];
              retVal = [NSString stringWithFormat: @"Begegnung mit %@ auf Reise von %@ nach %@", merchantType, 
                                                                                                 self.currentStartLocation.name, 
                                                                                                 self.currentDestinationLocation.name];
              break;
            }  
            default:
              NSLog(@"DSAAdventure locationInfoForMainImageView unhandled encounterType: %@, aborting", @(encounterType));
              abort();
          }
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
           // should always be last kind of Building...
           else if ([currentTile isMemberOfClass: [DSALocalMapTileBuilding class]])
             {
               if ([(DSALocalMapTileBuildingShop *)currentTile npc])
                 {
                   retVal = [NSString stringWithFormat: @"%@ von \"%@\" in %@", 
                                                        currentTile.type, 
                                                        [(DSALocalMapTileBuildingShop *)currentTile npc], 
                                                        currentLocation.name];
                 }
               else
                 {
                   retVal = [NSString stringWithFormat: @"%@ in %@", 
                                                        currentTile.type, 
                                                        currentLocation.name];
                 }
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

- (NSArray<DSAPlant *> *)possiblePlantsForCurrentLocation
{
    NSMutableArray<DSAPlant *> *availablePlants = [NSMutableArray array];
    
    // 1️⃣ Aktuelle Position
    NSPoint currentWorldPoint = [self currentWorldPointAlongRoute];
    DSARegion *currentRegion = [[DSARegionManager sharedManager] regionForX: currentWorldPoint.x
                                                                         Y: currentWorldPoint.y];
    if (!currentRegion) {
        NSLog(@"possiblePlantsForCurrentLocation: Keine gültige Region gefunden (X: %@, Y: %@)", @(currentWorldPoint.x), @(currentWorldPoint.y));
        return @[];
    }

    // 2️⃣ Monat bestimmen
    NSString *currentMonth = [self.gameClock.currentDate monthName];

    // 3️⃣ Alle Pflanzen abrufen
    NSArray<DSAObject *> *allObjects = [[DSAObjectManager sharedManager] getAllDSAObjectsForCategory:@"Pflanzen"];
    NSMutableArray<DSAPlant *> *allPlants = [NSMutableArray array];
    for (DSAObject *obj in allObjects) {
        if ([obj isKindOfClass:[DSAPlant class]]) {
            [allPlants addObject:(DSAPlant *)obj];
        }
    }

    // 4️⃣ Filter nach Region und Monat
    for (DSAPlant *plant in allPlants) {
        // Prüfen, ob Pflanze in der aktuellen Region vorkommt
        if (![plant.regions containsObject:currentRegion.name]) continue;

        // Prüfen, ob sie aktuell geerntet werden kann
        NSArray *harvestMonths = plant.harvest[@"wann"];
        BOOL canHarvest = [harvestMonths containsObject:@"ganzjährig"] || [harvestMonths containsObject:currentMonth];
        if (!canHarvest) continue;

        [availablePlants addObject:plant];
    }

    NSLog(@"possiblePlantsForCurrentLocation: %lu mögliche Pflanzen gefunden in Region %@, Monat %@", 
          (unsigned long)availablePlants.count, currentRegion.name, currentMonth);

    return availablePlants;
}

@end


@implementation DSAAdventure (Travel)

#pragma mark - Encounter
- (BOOL)rollEncounter
{
    double r = (double)arc4random() / UINT32_MAX;
    return r < self.encounterChancePerMile;
}

- (void)triggerEncounterOfType:(DSAEncounterType)type
{
    NSLog(@"⚠️ Encounter triggered: %ld", (long)type);

    self.traveling = NO;
    [self.gameClock setTravelModeEnabled:NO];
    self.activeGroup.position.context = DSAActionContextEncounter;

    id subType; 
    switch (type) {
      case DSAEncounterTypeMerchant: subType = (NSString *)[self randomMerchantType]; break;
      case DSAEncounterTypeHerbs: subType = (DSAActionResult *)[self findRandomHerb]; break;
      default: subType = @"";
    }
    
    self.encounterInfo = @{
      @"encounterType": @(type),
      @"subType": subType
    };
    
    NSDictionary *info = @{
        @"adventure": self,
        @"encounterType": @(type),
        @"subType": subType
    };

    [[NSNotificationCenter defaultCenter] postNotificationName: DSAEncounterTriggeredNotification
                                                        object:self
                                                      userInfo:info];
}

- (NSString *)randomMerchantType
{
    NSArray *types = @[ @"Krämer", @"Waffenhändler", @"Kräuterhändler" ];
    NSUInteger idx = arc4random_uniform((uint32_t)types.count);
    return types[idx];
}

- (DSAActionResult *)findRandomHerb
{
    DSAActionResult *result = [DSAActionResult new];
    
    NSArray<DSAPlant *> *availablePlants = [self possiblePlantsForCurrentLocation];
    if (availablePlants.count == 0) {
        NSLog(@"DSAAdventure findRandomHerb: Keine Pflanzen in dieser Region verfügbar.");
        result.result = DSAActionResultFailure;
        result.resultDescription = @"Hier wächst keine verwertbare Pflanze.";
        return result;
    }

    // 1️⃣ Zufällige Pflanze auswählen
    NSUInteger idx = arc4random_uniform((uint32_t)availablePlants.count);
    DSAPlant *plant = availablePlants[idx];
    
    // 2️⃣ Besten Charakter mit Pflanzenkunde finden
    DSACharacter *character = [self.activeGroup characterWithBestTalentWithName:@"Pflanzenkunde" negate:NO];
    if (!character) {
        NSLog(@"DSAAdventure findRandomHerb: Kein Charakter mit Pflanzenkunde vorhanden.");
        result.result = DSAActionResultFailure;
        result.resultDescription = @"Niemand in der Gruppe kennt sich mit Pflanzen aus.";
        return result;
    }

    // 3️⃣ Penalty berechnen (hohe Bekanntheit = leichter)
    NSInteger penalty = 20 - plant.recognition;

    // 4️⃣ Talentprobe ausführen
    DSAActionResult *talentResult = [character useTalent:@"Pflanzenkunde" withPenalty:penalty];
    NSLog(@"DSAAdventure findRandomHerb: %@ versucht, %@ zu finden (Penalty %ld) → Ergebnis: %ld", 
          character.name, plant.name, (long)penalty, (long)talentResult.result);
    
    // 5️⃣ Erfolgsstufen auswerten
    NSInteger numberFound = 0;
    switch (talentResult.result) {
        case DSAActionResultEpicSuccess:
            numberFound = 3;
            break;
        case DSAActionResultAutoSuccess:
            numberFound = 2;
            break;
        case DSAActionResultSuccess:
            numberFound = 1;
            break;
        default:
            result.result = DSAActionResultFailure;
            result.resultDescription = [NSString stringWithFormat:@"%@ konnte keine Pflanzen entdecken.", character.name];
            return result;
    }

    // 6️⃣ Pflanze ins Inventar legen
    NSInteger actuallyAdded = [character addObjectToInventory:plant quantity:numberFound];
    
    // 7️⃣ DSAActionResult befüllen
    if (actuallyAdded > 0) {
        result.result = talentResult.result;
        result.actionDuration = 60; // ggf. 1 Minute
        result.resultDescription = [NSString stringWithFormat:@"%@ entdeckt am Wegesrand %ld× %@.",
                                    character.name, (long)actuallyAdded, plant.name];
        
    } else {
        result.result = DSAActionResultFailure;
        result.resultDescription = [NSString stringWithFormat:@"%@ findet zwar %@, hat aber keinen Platz mehr im Inventar.",
                                    character.name, plant.name];
    }
    
    return result;
}


- (void)endEncounter
{
    if (!self.inEncounter) return;

    self.inEncounter = NO;
    self.traveling = YES;
    self.activeGroup.position.context = DSAActionContextTravel;
    [self.gameClock setTravelModeEnabled:YES];

    NSLog(@"DSAAdventure endEncounter: ncounter beendet, Reise geht weiter!");

    // Optionale Notification
    NSDictionary *info = @{ @"adventure": self };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAEncounterEnded"
                                                        object:self
                                                      userInfo:info];
}

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

    // 🔔 Subscribe to clock
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleClockTick:)
                                                 name:@"DSAGameTimeAdvanced"
                                               object:nil];

    //
    // ✅ Schritt 5: Encounter-System vorbereiten
    //

    // Wahrscheinlichkeit pro Meile (Basis — kann später dynamisch werden)
    // Beispiel: 1 Encounter pro ~20 Meilen
    self.encounterChancePerMile = 1.0 / 20.0;

    // Distanz bis zur nächsten Wurf-Chance — gewürfelt!
    // macht die Welt organischer als feste Intervalle
    self.milesUntilNextEncounterCheck = (arc4random_uniform(10) + 5); // 5-14 miles
    self.totalMilesTraveled = 0;

    NSLog(@"🎲 Encounter system armed: first check in ~%.1f miles", self.milesUntilNextEncounterCheck);

    NSDictionary *info = @{
        @"adventure": self,
        @"startLoc": self.currentStartLocation,
        @"endLoc": self.currentDestinationLocation
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidBeginNotification
                                                        object:self
                                                      userInfo:info];
}

- (DSATravelEventType)rollTravelEventForEnvironment: (NSString *)environment
{

    NSLog(@"DSAAdventure rollTravelEventForEnvironment: TODO environment dependency missing!");
    // XXXXXXXXXXXXXXXXXX
    return DSATravelEventTraveler;
    // 2W6 + gewichtete Tabelle (DSA nah)
    int roll = [Utils rollDice: @"2W6"];
    switch (roll) {
        case 2:  return DSATravelEventCombat;           // selten, aber gefährlich
        case 3:  return DSATravelEventAnimal;
        case 4:  return DSATravelEventWeatherShift;
        case 5:  return DSATravelEventTrailSign;
        case 6:  return DSATravelEventTraveler;
        case 7:  return DSATravelEventScenery;
        case 8:  return DSATravelEventMerchant;
        case 9:  return DSATravelEventHerbs;
        case 10: return DSATravelEventRoadObstacle;
        case 11: return DSATravelEventLost;
        case 12: return DSATravelEventCombat;           // Lucky but bandits
        default: return DSATravelEventNone;
    }
}

#pragma mark - Handle Clock Tick

- (void)handleClockTick:(NSNotification *)note
{
    // when we're not traveling, or are in an encounter, get out of here
    if (!self.traveling || self.inEncounter) return;
    // when we're traveling, but resting, get out of here as well
    if (self.traveling && self.activeGroup.position.context == DSAActionContextResting) return;

    NSNumber *sec = note.userInfo[@"advancedSeconds"];
    double secondsPassed = sec.doubleValue;
    
    double hoursPassed = secondsPassed / 3600.0;
    self.travelHoursToday += hoursPassed;

    double maxHours = 12.0;
    if (self.travelHoursToday >= maxHours) {
        NSLog(@"🌙 travel day over, resting");
        [self rest];
        self.travelHoursToday = 0;
        return;
    }

    // advance segment & get miles
    double miles = [self progressSegmentByHours:hoursPassed];

    // track for encounter
    self.totalMilesTraveled += miles;
    self.milesUntilNextEncounterCheck -= miles;

    // ✅ Only roll encounter if we actually passed the check
    //if (self.milesUntilNextEncounterCheck <= 0) {
    // XXXXXXXXXXXXXXXXXX
    if ( 1 == 1) {
        // rollEncounter returns YES if encounter happens
        if ([self rollEncounter]) {
            self.milesUntilNextEncounterCheck = (arc4random_uniform(10) + 5);
            NSLog(@"DSAAdventure handleClockTick check environment and pass it on to rollTravelEventForEnvironment missing!");
            DSATravelEventType event = [self rollTravelEventForEnvironment: nil];
            [self triggerTravelEvent:event];
            return;
        }

        // always reset milesUntilNextEncounterCheck AFTER roll
        self.milesUntilNextEncounterCheck = (arc4random_uniform(10) + 5);
    }
}

- (void)handleContinueTravel:(NSNotification *)note
{
    NSLog(@"🧭 DSAAdventure received continueTravel notification");
    [self continueTravel];
}

- (void)triggerTravelEvent:(DSATravelEventType)event
{
    self.inEncounter = YES;
    self.traveling = NO;
    [self.gameClock setTravelModeEnabled:NO];
    self.activeGroup.position.context = DSAActionContextEncounter;

    NSString *name = @"Unknown";
    DSAEncounterType encounterType = DSAEncounterTypeUnknown;

    switch (event) {
        case DSATravelEventCombat:        name = @"Combat"; break;
        case DSATravelEventAnimal:        name = @"Wildlife"; break;
        case DSATravelEventMerchant:      name = @"Merchant"; encounterType = DSAEncounterTypeMerchant; break;
        case DSATravelEventTraveler:      name = @"Traveler"; break;
        case DSATravelEventTrailSign:     name = @"Trail Sign"; break;
        case DSATravelEventWeatherShift:  name = @"Weather Shift"; break;
        case DSATravelEventRoadObstacle:  name = @"Road Obstacle"; break;
        case DSATravelEventScenery:       name = @"Scenic Moment"; break;
        case DSATravelEventHerbs:         name = @"Herbs / Resources"; encounterType = DSAEncounterTypeHerbs; break;
        case DSATravelEventLost:          name = @"Lost / Navigation"; break;
        default: break;
    }
    
/*    NSDictionary *info = @{
        @"adventure": self,
        @"eventType": @(event),
    };
*/    
    // XXXXXXX
    NSDictionary *info = @{
        @"adventure": self,
        @"eventType": @(DSATravelEventHerbs),
    };
    NSLog(@"DSAAdventure triggerTravelEvent : Travel Event: %@", name);
    [[NSNotificationCenter defaultCenter] postNotificationName: DSATravelEventTriggeredNotification
                                                        object:self
                                                      userInfo:info];
    // XXXXXXX                                                      
    //[self triggerEncounterOfType: encounterType];  
    [self triggerEncounterOfType: DSAEncounterTypeHerbs];                                                     
}

#pragma mark - Travel Logic
- (double)progressSegmentByHours:(double)hours
{
    if (self.currentSegmentIndex >= self.routeResult.segments.count) {
        [self endTravel];
        return 0;
    }

    DSARouteSegment *seg = self.routeResult.segments[self.currentSegmentIndex];
    CGFloat mod = [self speedModifierForRouteType:seg.routeType];

    CGFloat baseMilesPerDay = 30.0;
    CGFloat milesPerHour = (baseMilesPerDay / 24.0) * mod;

    CGFloat milesThisTick = milesPerHour * hours;
    self.segmentMilesDone += milesThisTick;

    if (self.segmentMilesDone >= seg.distanceMiles) {
        self.segmentMilesDone = 0;
        self.currentSegmentIndex++;

        NSLog(@"➡️ finished segment %lu/%lu",
              (unsigned long)self.currentSegmentIndex,
              (unsigned long)self.routeResult.segments.count);
    }

    CGFloat segmentFraction = seg.distanceMiles > 0 ? (self.segmentMilesDone / seg.distanceMiles) : 1.0;
    CGFloat totalFraction = (self.currentSegmentIndex + segmentFraction)
                          / (CGFloat)self.routeResult.segments.count;

    [self updateTravelProgress:totalFraction];

    if (totalFraction >= 1.0) {
        [self endTravel];
    }

    return milesThisTick; // ✅ CRUCIAL
}

#pragma mark - Rest / Continue / Reverse

- (void)rest
{
    if (![self.activeGroup.position.context isEqualToString:DSAActionContextTravel])
        return;

    self.activeGroup.position.context = DSAActionContextResting;
    [self.gameClock setTravelModeEnabled:NO];

    NSDictionary *info = @{
        @"adventure": self,
        @"startLoc": self.currentStartLocation,
        @"endLoc": self.currentDestinationLocation
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelRestingNotification
                                                        object:self
                                                      userInfo:info];
}

- (void)continueTravel
{
    NSLog(@"DSAAdventure continueTravel: continue travel called!");
    if ([self.activeGroup.position.context isEqualToString: DSAActionContextTravel]) return;

    NSLog(@"DSAAdventure continueTravel: continue travel, going to set all variables to continue travelling");
    self.inEncounter = NO;
    self.traveling = YES;    
    self.activeGroup.position.context = DSAActionContextTravel;
    [self.gameClock setTravelModeEnabled:YES];

    NSDictionary *info = @{
        @"adventure": self,
        @"startLoc": self.currentStartLocation,
        @"endLoc": self.currentDestinationLocation
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:DSAAdventureTravelDidBeginNotification
                                                        object:self
                                                      userInfo:info];
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

    NSDictionary *u = @{
      @"adventure": self, 
      @"destination": self.currentDestinationLocation
    };
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

- (NSPoint)currentWorldPointAlongRoute
{
    if (!self.routeResult || self.currentSegmentIndex >= self.routeResult.segments.count) {
        DSALocation *loc = self.currentDestinationLocation ?: self.currentStartLocation;
        return NSMakePoint(loc.mapCoordinate.x, loc.mapCoordinate.y);
    }

    DSARouteSegment *seg = self.routeResult.segments[self.currentSegmentIndex];
    NSArray<NSValue *> *points = seg.points;
    if (points.count < 2) {
        return [points.firstObject pointValue];
    }

    // Fortschritt innerhalb des Segments in Meilen
    CGFloat remaining = self.segmentMilesDone;
    
    // Gesamtdistanz entlang der Punkte aufaddieren
    for (NSInteger i = 1; i < points.count; i++) {
        NSPoint p1 = [points[i - 1] pointValue];
        NSPoint p2 = [points[i] pointValue];

        double dx = p2.x - p1.x;
        double dy = p2.y - p1.y;
        double dist = sqrt(dx * dx + dy * dy);

        if (remaining <= dist) {
            double t = dist > 0 ? (remaining / dist) : 0;
            double lon = p1.x + (p2.x - p1.x) * t;
            double lat = p1.y + (p2.y - p1.y) * t;
            return NSMakePoint(lon, lat);
        }

        remaining -= dist;
    }

    // Falls über das Segment hinaus → letzter Punkt
    return [[points lastObject] pointValue];
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