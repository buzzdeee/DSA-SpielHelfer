/* 
   Project: DSA-SpielHelfer

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:14:39 +0200 by sebastia
   
   Application Controller
*/

#import "AppController.h"
#import "DSACharacterGenerationController.h"
#import "DSADocumentController.h"
#import "DSACharacterWindowController.h"
#import "DSACharacterDocument.h"
#import "DSACharacterHero.h"
#import "DSAMapViewController.h"
#import "DSAEquipmentListViewController.h"
#import "DSANameGenerationController.h"

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


@end
