/* 
   Project: DSA-SpielHelfer

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:14:39 +0200 by sebastia
   
   Application Controller
*/

#import "AppController.h"
#import "DSACharacterGenerationController.h"
#import "DSANPCGenerationController.h"
#import "DSAAdventureGenerationController.h"
#import "DSADocumentController.h"
#import "DSACharacterWindowController.h"
#import "DSAAdventureWindowController.h"
#import "DSACharacterDocument.h"
#import "DSAAdventureDocument.h"
#import "DSACharacter.h"
#import "DSAAdventure.h"
#import "DSAMapViewController.h"
#import "DSAEquipmentListViewController.h"
#import "DSANameGenerationController.h"
#import "DSALocations.h"
#import "DSABattleWindowController.h"
#import "DSALocalMapViewController.h"
#import "DSAAdventureGroup.h"
#import "DSAMapCoordinate.h"

@implementation AppController

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
  NSLog(@"AppController initialized!");
}

- (id) init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void) dealloc
{
}

- (void) showPrefPanel: (id)sender
{
  NSLog(@"AppController: showPrefPanel called!");
}

- (void)setupApplication
{
  // Setup global settings, preferences, or shared resources here
  NSLog(@"AppController: setupApplication was called");
}

- (IBAction)openMap:(id)sender
{
  NSLog(@"AppController openMap called!!!");
  // Initialize and retain the DSAMapViewController
  self.mapViewController = [[DSAMapViewController alloc] init];
    
  // Show the window
  [self.mapViewController showWindow:self];
}

- (IBAction)newBattle:(id)sender
{
  NSLog(@"AppController newBattle called!!!");
  // Initialize and retain the DSAMapViewController
  self.battleViewController = [[DSABattleWindowController alloc] init];
    
  // Show the window
  [self.battleViewController showWindow:self];
}

- (IBAction)showEquipmentList:(id)sender
{
  NSLog(@"AppController showEquipmentList called!!!");
  // Initialize and retain the DSAEquipmentListViewController
  self.equipmentListViewController = [[DSAEquipmentListViewController alloc] init];
    
  // Show the window
  [self.equipmentListViewController showWindow:self];
}

- (IBAction)showNameGenerator:(id)sender
{
  NSLog(@"AppController showNameGenerator called!!!");
  // Initialize and retain the DSANameGenerationController
  self.nameGenerationController = [[DSANameGenerationController alloc] init];
    
  // Show the window
  [self.nameGenerationController showWindow:self];
}

- (IBAction)showLocalMaps:(id)sender
{
  NSLog(@"AppController showLocalMaps called!!!");
  // Initialize and retain the DSANameGenerationController
  self.localMapViewController = [[DSALocalMapViewController alloc] initWithMode: DSALocalMapViewModeGameMaster adventure: nil];
    
  // Show the window
  [self.localMapViewController showWindow:self];
}

#pragma mark Character Generation

- (IBAction)newCharacterGeneration:(id)sender
{
  NSLog(@"AppController: newCharacterGeneration was called");
   // Instantiate the CharacterGenerationController when the menu item is clicked
  self.characterGenController = [[DSACharacterGenerationController alloc] init];
   // Set up the completion handler to transition to the character management document
  __weak typeof(self) weakSelf = self;
  self.characterGenController.completionHandler = ^(DSACharacter *newCharacter)
    {
      [weakSelf createNewCharacterDocument:newCharacter];
    };

  // Start character generation process
  [self.characterGenController startCharacterGeneration: sender];
}

- (void)createNewCharacterDocument:(DSACharacter *)newCharacter
{
  NSError *error = nil;
  DSADocumentController *docController = [DSADocumentController sharedDocumentController];
  // Create a new CharacterDocument with the generated character
  NSLog(@"AppController createNewCharacterDocument! calling makeUntitledDocumentOfType....");
  DSACharacterDocument *newDocument = [docController makeUntitledDocumentOfType:@"DSACharacter" error:&error];
    
  if (newDocument)
    {
      newDocument.model = newCharacter;
      [docController addDocument:newDocument];
      [newDocument makeWindowControllers];  // Create the window controller
      //[newDocument makeWindowControllersForNewDocument];  // Create the window controller      
      [newDocument showWindows];            // Show the document window
      // Mark the document as dirty
      [newDocument updateChangeCount:NSChangeDone];      
    }
}

#pragma mark NPC Generation
- (IBAction)newNPCGeneration:(id)sender
{
  NSLog(@"AppController: newNPCGeneration was called");
   // Instantiate the CharacterGenerationController when the menu item is clicked
  self.npcGenController = [[DSANPCGenerationController alloc] init];
   // Set up the completion handler to transition to the character management document
  __weak typeof(self) weakSelf = self;
  self.npcGenController.completionHandler = ^(DSACharacter *newCharacter)
    {
      [weakSelf createNewNpcDocument:newCharacter];
    };

  // Start character generation process
  [self.npcGenController startNpcGeneration: sender];
}

- (void)createNewNpcDocument:(DSACharacter *)newCharacter
{
  NSError *error = nil;
  DSADocumentController *docController = [DSADocumentController sharedDocumentController];
  // Create a new CharacterDocument with the generated character
  NSLog(@"AppController createNewNpcDocument! calling makeUntitledDocumentOfType....");
  DSACharacterDocument *newDocument = [docController makeUntitledDocumentOfType:@"DSACharacter" error:&error];
    
  if (newDocument)
    {
      newDocument.model = newCharacter;
      [docController addDocument:newDocument];
      [newDocument makeWindowControllers];  // Create the window controller
      //[newDocument makeWindowControllersForNewDocument];  // Create the window controller      
      [newDocument showWindows];            // Show the document window
      // Mark the document as dirty
      [newDocument updateChangeCount:NSChangeDone];      
    }
}

#pragma mark Adventure Generation

- (IBAction)newAdventureGeneration:(id)sender {
    NSLog(@"AppController: newAdventureGeneration was called");
    
    // Instantiate the adventure generation controller
    self.adventureGenController = [[DSAAdventureGenerationController alloc] init];

    // Set up completion handler to create the adventure document after selecting a location
    __weak typeof(self) weakSelf = self;
    self.adventureGenController.completionHandler = ^(NSString *selectedLocation) {
        if (selectedLocation) { // Only proceed if a valid selection was made
            [weakSelf createNewAdventureDocument:selectedLocation];
        } else {
            NSLog(@"Adventure generation was cancelled.");
        }
    };

    // Start adventure generation process
    [self.adventureGenController startAdventureGeneration:sender];
}

- (void)createNewAdventureDocument:(NSString *)selectedLocation {
    NSError *error = nil;
    DSADocumentController *docController = [DSADocumentController sharedDocumentController];
    NSLog(@"AppController createNewAdventureDocument! calling makeUntitledDocumentOfType....");
    
    DSAAdventureDocument *newDocument = [docController makeUntitledDocumentOfType:@"DSAAdventure" error:&error];
    DSALocations *locations = [DSALocations sharedInstance];

    NSLog(@"AppController createNewAdventureDocument selectedLocation: %@", selectedLocation);
    
    if (newDocument) {
        // Neue leere Gruppe erstellen
        DSAAdventureGroup *initialGroup = [[DSAAdventureGroup alloc] init];
        DSAPosition *startingPosition;
        if (selectedLocation)
          {
            DSALocation *location = [locations locationWithName:selectedLocation ofType:@"local"];
            NSLog(@"AppController createNewAdventureDocument got location: %@", location);
            if ([location isMemberOfClass:[DSALocalMapLocation class]]) {
                DSALocalMapLocation *localLocation = (DSALocalMapLocation *)location;
                DSALocalMapTile *startingTempleTile = [self getLocalMapTileOfStartingTempleForLocation:localLocation.locationMap];
                
                NSLog(@"AppController: createNewAdventureDocument: starting temple tile: %@", startingTempleTile);
                
                location.mapCoordinate = startingTempleTile.tileCoordinate;
                
                startingPosition = [DSAPosition positionWithMapCoordinate: startingTempleTile.tileCoordinate
                                                       globalLocationName: localLocation.globalLocationName
                                                        localLocationName: localLocation.name
                                                                  context: nil];
            }
            NSLog(@"AppController createNewAdventureDocument: startingPosition: %@", startingPosition);
            // Setze Location in der ersten Gruppe
            initialGroup.position = [startingPosition copy];
          }
        else
          {
            NSLog(@"AppController createNewAdventureDocument: selectedLocation was nil, aborting!");
            abort();
          }

        // Setze die Gruppenliste mit einer aktiven (leeren) Gruppe
        newDocument.model.groups = [NSMutableArray arrayWithObject:initialGroup];
        NSLog(@"AppController createNewAdventureDocument: activeGroup currentPosition: %@", newDocument.model.activeGroup.position);
        // Dokument öffnen
        [docController addDocument:newDocument];
        [newDocument makeWindowControllers];
        [newDocument showWindows];
        [newDocument updateChangeCount:NSChangeDone];
    }

    NSLog(@"AppController createNewAdventureDocument: newDocument.model: %@", newDocument.model);
    if (error) {
        NSLog(@"Error creating Document: %@", error);
    }
}

- (DSALocalMapTile *) getLocalMapTileOfStartingTempleForLocation: (DSALocalMap *) localMap
{
  for (NSString *god in @[@"Praios", @"Rondra", @"Efferd", @"Travia", @"Boron", @"Hesinde", @"Firun", @"Tsa", @"Phex", @"Peraine", @"Ingerimm", @"Rahja"])
    {
      NSLog(@"AppController getLocalMapTileOfStartingTempleForLocation: checking god %@", god);
      for (DSALocalMapLevel *mapLevel in localMap.mapLevels)
        {
          //NSLog(@"AppController getLocalMapTileOfStartingTempleForLocation: checking map level %@", mapLevel);
          NSArray *mapTiles = mapLevel.mapTiles;
          for (NSArray *mapRow in mapTiles)
            {
              for (DSALocalMapTile *tile in mapRow)
                {
                  //NSLog(@"AppController getLocalMapTileOfStartingTempleForLocation: checking map tile of type %@", tile.type);
                  if ([tile.type isEqualToString: @"Tempel"])
                    {
                      if ([[(DSALocalMapTileBuildingTemple *)tile god] isEqualToString: god])
                        {
                          return tile;
                        }
                    }
                }
            }
        }
    }
  return nil;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
//NSLog(@"AppController validateMenuItem %@ %lu", [menuItem title], (unsigned long)[menuItem tag]);
// TAGS: 200: create new adventure

      if ([menuItem tag] == 200)
        { // Tag for the "Level Up" menu item
          //NSLog(@"AppController validateMenuItem for menuItem tag 200");
          if ([DSAAdventureManager sharedManager].currentAdventure != nil)  // we already have an adventure loaded
            {
              //NSLog(@"AppController validateMenuItem for menuItem tag 200, returning NO");
              return NO;
            }
        }
  return YES; // [super validateMenuItem:menuItem];
}

@end
