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

- (void)createNewAdventureDocument:(NSString *) selectedLocation {
    NSError *error = nil;
    DSADocumentController *docController = [DSADocumentController sharedDocumentController];
    NSLog(@"AppController createNewAdventureDocument! calling makeUntitledDocumentOfType....");
    
    DSAAdventureDocument *newDocument = [docController makeUntitledDocumentOfType:@"DSAAdventure" error:&error];
    DSALocations *locations = [DSALocations sharedInstance];

    if (newDocument) {
        if (selectedLocation) {
            newDocument.model.currentLocation = [locations locationWithName:selectedLocation];
        }
        [docController addDocument:newDocument];
        [newDocument makeWindowControllers];
        [newDocument showWindows];
        [newDocument updateChangeCount:NSChangeDone];
    }

    if (error) {
        NSLog(@"Error creating Document: %@", error);
    }
}

@end
