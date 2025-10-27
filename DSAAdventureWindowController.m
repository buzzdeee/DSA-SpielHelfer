/* All rights reserved */

#import "DSAAdventureWindowController.h"
#import "DSAAdventureDocument.h"
#import "DSACharacterDocument.h"
#import "DSACharacterPortraitView.h"
#import "DSACharacter.h"
#import "DSAAventurianDate.h"
#import "DSAAventurianCalendar.h"
#import "DSAAdventureClock.h"
#import "DSAClockAnimationView.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"
#import "Utils.h"
#import "DSAActionIcon.h"
#import "DSALocation.h"
#import "DSALocations.h"
#import "DSAPricingEngine.h"
#import "DSADialog.h"
#import "DSADialogManager.h"
#import "DSAConversationDialogSheetController.h"
#import "DSAActionChoiceQuestionController.h"
#import "DSAMapViewController.h"
#import "DSAMapCoordinate.h"

extern NSString * const DSACharacterHighlightedNotification;

extern NSString * const DSALocalMapTileBuildingInnTypeHerberge;
extern NSString * const DSALocalMapTileBuildingInnTypeHerbergeMitTaverne;
extern NSString * const DSALocalMapTileBuildingInnTypeTaverne;

@implementation DSAAdventureWindowController

- (DSAAdventureWindowController *)init
{
  NSLog(@"DSAAdventureWindowController: init called");    
  self = [super init];
  if (self)
    {
    }
  return self;
}

- (void)dealloc {
    NSLog(@"DSAAdventureWindowController is being deallocated.");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"removing observer of DSAAdventureDocument!");
    [(DSAAdventureDocument *)self.document removeObserver:self forKeyPath:@"selectedCharacterDocument"];  
  
    NSLog(@"DSAAdventureWindowController finished with dealloc");  
}

- (void)close {
    NSLog(@"Window is being closed manually, cleaning up.");
    [self.window close];  // This ensures the window is properly closed
    [self.clockAnimationView removeFromSuperview];  // Manually remove the view
    self.clockAnimationView = nil;  // Set the reference to nil
}

- (void)windowWillClose:(NSNotification *)notification {
    // Remove observer before window closes
    NSLog(@"DSAAdventureWindowController windowWillClose: removing observer of DSAAdventureDocument!");
    if (self.document) {
        [self.document removeObserver:self forKeyPath:@"selectedCharacterDocument"];
    }
    [self.clockAnimationView removeFromSuperview];
    [self.clockAnimationView.gameClock.gameTimer invalidate];
    self.clockAnimationView.gameClock.gameTimer = nil;
    [self.clockAnimationView.updateTimer invalidate];
    self.clockAnimationView.updateTimer = nil;    
    self.clockAnimationView = nil;
    [self.clockAnimationView removeFromSuperview];
    self.window.contentView = nil;  // Force the window to release views

    //[super windowWillClose:notification];
}

- (DSAAdventureWindowController *)initWithWindowNibName:(NSString *)nibNameOrNil
{
  NSLog(@"DSAAdventureWindowController initWithWindowNibName %@", nibNameOrNil);
  self = [super initWithWindowNibName:nibNameOrNil];
  if (self)
    {
      NSLog(@"DSAAdventureWindowController initialized with nib: %@", nibNameOrNil);
    }
  else
    {
      NSLog(@"DSAAdventureWindowController had trouble initializing");
    }
    
  return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"DSAAdventureWindowController: awakeFromNib called, Adding observers...");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCharacterChanges)
                                                 name:@"DSAAdventureCharactersUpdated"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActionIcons:)
                                                 name:@"DSAAdventureLocationUpdated"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTravelDidBegin)
                                                 name:DSAAdventureTravelDidBeginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTravelResting)
                                                 name:DSAAdventureTravelRestingNotification
                                               object:nil];                                                                                           
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActionIcons:)
                                                 name:DSAAdventureTravelDidEndNotification
                                               object:nil];                                                                                             
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLogsMessage:)
                                                 name:@"DSACharacterEventLog"
                                               object:nil];
                                               
    DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)self.document;
    [adventureDoc addObserver:self 
                   forKeyPath:@"selectedCharacterDocument" 
                      options:NSKeyValueObservingOptionNew 
                      context:nil];  
                                                                                              
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Ranke_1" ofType:@"jpg"];                                               
    NSImage *image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageHorizontalRuler0.image = image;
    self.imageHorizontalRuler1.image = image;   
    [self.imageHorizontalRuler0 setImageScaling:NSImageScaleAxesIndependently];
    [self.imageHorizontalRuler1 setImageScaling:NSImageScaleAxesIndependently];
    imagePath = [[NSBundle mainBundle] pathForResource:@"Ranke_2" ofType:@"jpg"];
    image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageVerticalRuler0.image = image;
    [self.imageVerticalRuler0 setImageScaling:NSImageScaleAxesIndependently]; 
    imagePath = [[NSBundle mainBundle] pathForResource:@"DSA-Fanprojekt-Logo-gross" ofType:@"png"];
    image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageLogo.image = image;    
    [self.imageLogo setImageScaling:NSImageScaleAxesIndependently];
    CGFloat width = self.imageHorizontalRuler0.frame.size.width;
    CGFloat height = self.imageHorizontalRuler0.frame.size.height;
    NSLog(@"imageHorizontalRuler0 dimensions: %.2f x %.2f", width, height);
    width = self.imageVerticalRuler0.frame.size.width;
    height = self.imageVerticalRuler0.frame.size.height;
    NSLog(@"imageVerticalRuler0 dimensions: %.2f x %.2f", width, height);
    [self updateMainImageView: nil];
    [self handleCharacterChanges];
    [self setupActionIcons: nil];
    [self updateActionIcons: nil];
     
}

- (DSAActionIcon *)clearActionIcon:(DSAActionIcon *)oldIcon {
    NSRect frame = oldIcon.frame;
    DSAActionIcon *emptyIcon = [[DSAActionIcon alloc] initWithFrame:frame];
    [emptyIcon setImageFrameStyle:NSImageFramePhoto];
    [self replaceView:oldIcon withView:emptyIcon];
    
    return emptyIcon;
}

- (void) setupActionIcons: (DSAPosition *) position
{
  DSAPosition *currentPosition;
  if (position)
    {
      currentPosition = position;
    }
  else
    {
      DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
      DSAAdventureGroup *activeGroup = adventure.activeGroup;
      currentPosition = activeGroup.position;
    }

    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType:@"local"];
    DSALocation *globalLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.globalLocationName ofType:@"global"];
    NSLog(@"DSAAdventureWindowController setupActionIcons called!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if (!currentLocation && !globalLocation)
      {
        NSLog(@"DSAAdventureWindowController setupActionIcons : Fehlende Location-Daten");
        return;
      }
    
    if (!currentLocation)  // we only have a global location
      {       
        if ([currentPosition.context isEqualToString: DSAActionContextTravel])
          {
            NSLog(@"DSAAdventureWindowController setupActionIcons for global location in travel context not yet implemented!");
            if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconRest class]])
              {
                [self.imageActionIcon0 updateAppearance];
              }
            else
              {
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"rest" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon0 withView:newIcon];
                self.imageActionIcon0 = newIcon;
                [self.imageActionIcon0 updateAppearance];
              }
            if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconMap class]])
              {
                [self.imageActionIcon1 updateAppearance];
              }                       
            else
              {          
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"map" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon1 withView:newIcon];
                self.imageActionIcon1 = newIcon;
                [self.imageActionIcon1 updateAppearance];
              }
            if ([self.imageActionIcon2 isKindOfClass: [DSAActionIconChangeRoute class]])
              {
                [self.imageActionIcon2 updateAppearance];
              }                       
            else
              {          
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"changeRoute" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon2 withView:newIcon];
                self.imageActionIcon2 = newIcon;
                [self.imageActionIcon2 updateAppearance];
              }              
            self.imageActionIcon3 = [self clearActionIcon:self.imageActionIcon3];
            self.imageActionIcon4 = [self clearActionIcon:self.imageActionIcon4];
            self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5];
            self.imageActionIcon6 = [self clearActionIcon:self.imageActionIcon6];
            self.imageActionIcon7 = [self clearActionIcon:self.imageActionIcon7];
            self.imageActionIcon8 = [self clearActionIcon:self.imageActionIcon8];                                        
          }
        else if ([currentPosition.context isEqualToString: DSAActionContextResting])
          {
            if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconChat class]])
              {
                [self.imageActionIcon0 updateAppearance];
              }
            else
              {
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"chat" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon0 withView:newIcon];
                self.imageActionIcon0 = newIcon;
                [self.imageActionIcon0 updateAppearance];
              }
            if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconGuardSelection class]])
              {
                [self.imageActionIcon1 updateAppearance];
              }
            else
              {          
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"selectGuards" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon1 withView:newIcon];
                self.imageActionIcon1 = newIcon;
                [self.imageActionIcon1 updateAppearance];
              }
            if ([self.imageActionIcon2 isKindOfClass: [DSAActionIconSleep class]])
              {
                [self.imageActionIcon2 updateAppearance];
              }
            else
              {                     
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"sleep" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon2 withView:newIcon];
                self.imageActionIcon2 = newIcon;
                [self.imageActionIcon2 updateAppearance];
              }
            if ([self.imageActionIcon3 isKindOfClass: [DSAActionIconTalent class]])
              {
                [self.imageActionIcon3 updateAppearance];
              }
            else
              {                     
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"useTalent" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon3 withView:newIcon];
                self.imageActionIcon3 = newIcon;
                [self.imageActionIcon3 updateAppearance];
              } 
            if ([self.imageActionIcon4 isKindOfClass: [DSAActionIconMagic class]])
              {
                [self.imageActionIcon4 updateAppearance];
              }
            else
              {                     
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"useMagic" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon4 withView:newIcon];
                self.imageActionIcon4 = newIcon;
                [self.imageActionIcon4 updateAppearance];
              }
            if ([self.imageActionIcon5 isKindOfClass: [DSAActionIconRitual class]])
              {
                [self.imageActionIcon5 updateAppearance];
              }
            else
              {                     
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"useRitual" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon5 withView:newIcon];
                self.imageActionIcon5 = newIcon;
                [self.imageActionIcon5 updateAppearance];
              }                                    
            if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
              {
                [self.imageActionIcon6 updateAppearance];
              }
            else
              {            
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon6 withView:newIcon];
                self.imageActionIcon6 = newIcon;
                [self.imageActionIcon6 updateAppearance];
              }
            if ([self.imageActionIcon7 isKindOfClass: [DSAActionIconHunt class]])
              {
                [self.imageActionIcon7 updateAppearance];
              }
            else
              {            
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"hunt" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon7 withView:newIcon];
                self.imageActionIcon7 = newIcon;
                [self.imageActionIcon7 updateAppearance];
              }
            if ([self.imageActionIcon8 isKindOfClass: [DSAActionIconCollectHerbs class]])
              {
                [self.imageActionIcon8 updateAppearance];
              }
            else
              {            
                DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"collectHerbs" andSize:@"128x128"];
                [self replaceView:self.imageActionIcon8 withView:newIcon];
                self.imageActionIcon8 = newIcon;
                [self.imageActionIcon8 updateAppearance];
              }                            
          }
        else
          {
            NSLog(@"DSAAdventure setupActionIcons: unknown global position context: %@, aborting", currentPosition.context);
            abort();
          }
        return;                                                   
      }
  // Local map tiles related action icons
  if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
    {
      DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
      DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
      if ([currentTile isKindOfClass: [DSALocalMapTileBuildingShop class]])
        {
          if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconChat class]])
            {
              [self.imageActionIcon0 updateAppearance];
            }
          else
            {
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"chat" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon0 withView:newIcon];
              self.imageActionIcon0 = newIcon;
              [self.imageActionIcon0 updateAppearance];
            }
          if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconBuy class]])
            {
              [self.imageActionIcon1 updateAppearance];
            }
          else
            {          
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"buy" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon1 withView:newIcon];
              self.imageActionIcon1 = newIcon;
              [self.imageActionIcon1 updateAppearance];
            }

          if ([self.imageActionIcon2 isKindOfClass: [DSAActionIconSell class]])
            {
              [self.imageActionIcon2 updateAppearance];
            }
          else
            {                     
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"sell" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon2 withView:newIcon];
              self.imageActionIcon2 = newIcon;
              [self.imageActionIcon2 updateAppearance];
            }
          self.imageActionIcon3 = [self clearActionIcon:self.imageActionIcon3];
          self.imageActionIcon4 = [self clearActionIcon:self.imageActionIcon4];
          self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5];
          if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon6 updateAppearance];
            }
          else
            {            
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon6 withView:newIcon];
              self.imageActionIcon6 = newIcon;
              [self.imageActionIcon6 updateAppearance];
            }
          self.imageActionIcon7 = [self clearActionIcon:self.imageActionIcon7];
          if ([self.imageActionIcon8 isKindOfClass: [DSAActionIconLeave class]])
            {
              [self.imageActionIcon8 updateAppearance];
            }
          else
            {                     
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"leave" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon8 withView:newIcon];
              self.imageActionIcon8 = newIcon;  
              [self.imageActionIcon8 updateAppearance];                           
            }
        }
      else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingInn class]])
        {
          NSString *tileType = [(DSALocalMapTileBuildingInn*)currentTile type];
          NSLog(@"DSAAdventureWindowController setupActionIcons: I'm on DSALocalMapTileBuildingInn: currentPosition: %@", currentPosition);
          if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconChat class]])
            {
              [self.imageActionIcon0 updateAppearance];
            }
          else
            {         
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"chat" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon0 withView:newIcon];
              self.imageActionIcon0 = newIcon;
              [self.imageActionIcon0 updateAppearance];
            }
          if ([tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerberge] ||
              [tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerbergeMitTaverne])
            {
              if ([currentPosition.context isEqualToString: DSAActionContextReception])
                {
                  if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconRoom class]])
                    {
                      [self.imageActionIcon1 updateAppearance];
                    }
                  else
                    {             
                      DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"rentRoom" andSize:@"128x128"];
                      [self replaceView:self.imageActionIcon1 withView:newIcon];
                      self.imageActionIcon1 = newIcon;
                      [self.imageActionIcon1 updateAppearance];          
                    }
                }
              else if ([currentPosition.context isEqualToString: DSAActionContextPrivateRoom])
                {
                  if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconSleep class]])
                    {
                      [self.imageActionIcon1 updateAppearance];
                    }
                  else
                    {             
                      DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"sleep" andSize:@"128x128"];
                      [self replaceView:self.imageActionIcon1 withView:newIcon];
                      self.imageActionIcon1 = newIcon;
                      [self.imageActionIcon1 updateAppearance];          
                    }                 
                }
              else
                {
                  NSLog(@"DSAAdventureWindowController setupActionIcons current tile class: DSALocalMapTileBuildingInn unknown context: %@", currentPosition.context);
                }
            }
          else
            {
              self.imageActionIcon1 = [self clearActionIcon:self.imageActionIcon1];
            }
          if ([self.imageActionIcon2 isKindOfClass: [DSAActionIconMeal class]])
            {
              [self.imageActionIcon2 updateAppearance];
            }
          else
            {             
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"orderMeal" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon2 withView:newIcon];
              self.imageActionIcon2 = newIcon;
              [self.imageActionIcon2 updateAppearance];          
            }
            
          if (([tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerberge] ||
              [tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerbergeMitTaverne]) &&
              [currentPosition.context isEqualToString: DSAActionContextPrivateRoom])
            {
              if ([self.imageActionIcon3 isKindOfClass: [DSAActionIconRitual class]])
                {
                  [self.imageActionIcon3 updateAppearance];
                }
              else
                {             
                  DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"useRitual" andSize:@"128x128"];
                  [self replaceView:self.imageActionIcon3 withView:newIcon];
                  self.imageActionIcon3 = newIcon;
                  [self.imageActionIcon3 updateAppearance];          
                }            
            }
          else
            {
              self.imageActionIcon3 = [self clearActionIcon:self.imageActionIcon3];
            }
          if ((([tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerberge] ||
              [tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerbergeMitTaverne]) &&
              [currentPosition.context isEqualToString: DSAActionContextPrivateRoom]) ||
              [tileType isEqualToString: DSALocalMapTileBuildingInnTypeTaverne] ||
              ([tileType isEqualToString: DSALocalMapTileBuildingInnTypeHerbergeMitTaverne] && 
              [currentPosition.context isEqualToString: DSAActionContextTavern]))
            {
              if ([self.imageActionIcon4 isKindOfClass: [DSAActionIconTalent class]])
                {
                  [self.imageActionIcon4 updateAppearance];
                }
              else
                {             
                  DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"useTalent" andSize:@"128x128"];
                  [self replaceView:self.imageActionIcon4 withView:newIcon];
                  self.imageActionIcon4 = newIcon;
                  [self.imageActionIcon4 updateAppearance];          
                }
              if ([self.imageActionIcon5 isKindOfClass: [DSAActionIconMagic class]])
                {
                  [self.imageActionIcon5 updateAppearance];
                }
              else
                {             
                  DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"useMagic" andSize:@"128x128"];
                  [self replaceView:self.imageActionIcon5 withView:newIcon];
                  self.imageActionIcon5 = newIcon;
                  [self.imageActionIcon5 updateAppearance];          
                }                          
            }
          else
            {
              self.imageActionIcon4 = [self clearActionIcon:self.imageActionIcon4];
              self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5];
            }            
     
          if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon6 updateAppearance];
            }
          else
            {             
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon6 withView:newIcon];
              self.imageActionIcon6 = newIcon;
              [self.imageActionIcon6 updateAppearance];          
            }
          self.imageActionIcon7 = [self clearActionIcon:self.imageActionIcon7];
          if ([self.imageActionIcon8 isKindOfClass: [DSAActionIconLeave class]])
            {
              [self.imageActionIcon8 updateAppearance];
            }
          else
            {             
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"leave" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon8 withView:newIcon];
              self.imageActionIcon8 = newIcon; 
              [self.imageActionIcon8 updateAppearance];                            
            }
        }
      else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingHealer class]])
        {
          if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconChat class]])
            {
              [self.imageActionIcon0 updateAppearance];
            }
          else
            {         
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"chat" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon0 withView:newIcon];
              self.imageActionIcon0 = newIcon;
              [self.imageActionIcon0 updateAppearance];
            }
          self.imageActionIcon1 = [self clearActionIcon:self.imageActionIcon1];  
          self.imageActionIcon2 = [self clearActionIcon:self.imageActionIcon2];
          self.imageActionIcon3 = [self clearActionIcon:self.imageActionIcon3];
          self.imageActionIcon4 = [self clearActionIcon:self.imageActionIcon4];
          self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5];
          if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon6 updateAppearance];
            }
          else
            {            
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon6 withView:newIcon];
              self.imageActionIcon6 = newIcon;
              [self.imageActionIcon6 updateAppearance];
            }
          self.imageActionIcon7 = [self clearActionIcon:self.imageActionIcon7];
          if ([self.imageActionIcon8 isKindOfClass: [DSAActionIconLeave class]])
            {
              [self.imageActionIcon8 updateAppearance];
            }
          else
            {                    
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"leave" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon8 withView:newIcon];
              self.imageActionIcon8 = newIcon;
              [self.imageActionIcon8 updateAppearance];                            
            }
        }
      else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingSmith class]])
        {
          if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconChat class]])
            {
              [self.imageActionIcon0 updateAppearance];
            }
          else
            {         
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"chat" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon0 withView:newIcon];
              self.imageActionIcon0 = newIcon;
              [self.imageActionIcon0 updateAppearance];
            }
          self.imageActionIcon1 = [self clearActionIcon:self.imageActionIcon1];  
          self.imageActionIcon2 = [self clearActionIcon:self.imageActionIcon2];
          self.imageActionIcon3 = [self clearActionIcon:self.imageActionIcon3];
          self.imageActionIcon4 = [self clearActionIcon:self.imageActionIcon4];
          self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5];       
          if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon6 updateAppearance];
            }
          else
            {            
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon6 withView:newIcon];
              self.imageActionIcon6 = newIcon;
              [self.imageActionIcon6 updateAppearance];
            }
          self.imageActionIcon7 = [self clearActionIcon:self.imageActionIcon7];
          if ([self.imageActionIcon8 isKindOfClass: [DSAActionIconLeave class]])
            {
              [self.imageActionIcon8 updateAppearance];
            }
          else
            {                    
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"leave" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon8 withView:newIcon];
              self.imageActionIcon8 = newIcon;
              [self.imageActionIcon8 updateAppearance];                             
            }
        }
      else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingTemple class]])
        {
          if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconChat class]])
            {
              [self.imageActionIcon0 updateAppearance];
            }
          else
            {         
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"chat" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon0 withView:newIcon];
              self.imageActionIcon0 = newIcon;
              [self.imageActionIcon0 updateAppearance];
            }

          if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconAddToGroup class]])
            {
              [self.imageActionIcon1 updateAppearance];
            }
          else
            {                       
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"donate" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon1 withView:newIcon];
              self.imageActionIcon1 = newIcon;
              [self.imageActionIcon1 updateAppearance];
            }
              
          if ([self.imageActionIcon2 isKindOfClass: [DSAActionIconAddToGroup class]])
            {
              [self.imageActionIcon2 updateAppearance];
            }
          else
            {                       
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"pray" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon2 withView:newIcon];
              self.imageActionIcon2 = newIcon;
              [self.imageActionIcon2 updateAppearance];
            }
                                  
          if ([self.imageActionIcon3 isKindOfClass: [DSAActionIconAddToGroup class]])
            {
              [self.imageActionIcon3 updateAppearance];
            }
          else
            {                       
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"addToGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon3 withView:newIcon];
              self.imageActionIcon3 = newIcon;
              [self.imageActionIcon3 updateAppearance];
            }

          if ([self.imageActionIcon4 isKindOfClass: [DSAActionIconRemoveFromGroup class]])
            {
              [self.imageActionIcon4 updateAppearance];
            }
          else
            {                 
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"removeFromGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon4 withView:newIcon];
              self.imageActionIcon4 = newIcon;
              [self.imageActionIcon4 updateAppearance];          
            }
          self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5]; 
          if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon6 updateAppearance];
            }
          else
            {            
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon6 withView:newIcon];
              self.imageActionIcon6 = newIcon;
              [self.imageActionIcon6 updateAppearance];
            }          
          self.imageActionIcon7 = [self clearActionIcon:self.imageActionIcon7];
          if ([self.imageActionIcon8 isKindOfClass: [DSAActionIconLeave class]])
            {
              [self.imageActionIcon8 updateAppearance];
            }
          else
            {                    
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"leave" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon8 withView:newIcon];
              self.imageActionIcon8 = newIcon;
              [self.imageActionIcon8 updateAppearance];                             
            }                             
        }
      else if ([currentTile isMemberOfClass: [DSALocalMapTileStreet class]] || 
               [currentTile isMemberOfClass: [DSALocalMapTileGreen class]])
        {
          if ([self.imageActionIcon0 isKindOfClass: [DSAActionIconSplitGroup class]])
            {
              [self.imageActionIcon0 updateAppearance];
            }
          else
            {         
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"splitGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon0 withView:newIcon];
              self.imageActionIcon0 = newIcon;
              [self.imageActionIcon0 updateAppearance];    
            }

          if ([self.imageActionIcon1 isKindOfClass: [DSAActionIconJoinGroups class]])
            {
              [self.imageActionIcon1 updateAppearance];
            }
          else
            {                
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"joinGroups" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon1 withView:newIcon];
              self.imageActionIcon1 = newIcon;
              [self.imageActionIcon1 updateAppearance];
            }
          self.imageActionIcon2 = [self clearActionIcon:self.imageActionIcon2];  
          self.imageActionIcon3 = [self clearActionIcon:self.imageActionIcon3];
          self.imageActionIcon4 = [self clearActionIcon:self.imageActionIcon4];
          self.imageActionIcon5 = [self clearActionIcon:self.imageActionIcon5];
          if ([self.imageActionIcon6 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon6 updateAppearance];
            }
          else
            {            
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"switchActiveGroup" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon6 withView:newIcon];
              self.imageActionIcon6 = newIcon;
              [self.imageActionIcon6 updateAppearance];
            }          
          
          if ([self.imageActionIcon7 isKindOfClass: [DSAActionIconSwitchActiveGroup class]])
            {
              [self.imageActionIcon7 updateAppearance];
            }
          else
            {             
              DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"map" andSize:@"128x128"];
              [self replaceView:self.imageActionIcon7 withView:newIcon];
              self.imageActionIcon7 = newIcon; 
              [self.imageActionIcon7 updateAppearance];                                               
            }
          self.imageActionIcon8 = [self clearActionIcon:self.imageActionIcon8];
        }               
    }
}

- (void) handleTravelDidBegin
{
  NSLog(@"DSAAdventureWindowController handleTravelDidBegin called");
  [self updateMainImageView: nil];
  [self setupActionIcons: nil];
}

- (void) handleTravelResting
{
  NSLog(@"DSAAdventureWindowController handleTravelResting called");
  [self updateMainImageView: nil];
  [self setupActionIcons: nil];
}

- (void) updateActionIcons: (NSNotification *)notification
{
    NSLog(@"DSAAdventureWindowController updateActionIcons called!!!!");
    NSDictionary *userInfo = notification.userInfo;
    DSAPosition *position = userInfo[@"position"];
    [self setupActionIcons: position];
    
    [self updateMainImageView: position];
}

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView {
    NSView *superview = oldView.superview;
    NSRect frame = oldView.frame;
    newView.frame = frame;
    [oldView removeFromSuperview];
    [superview addSubview:newView positioned:NSWindowAbove relativeTo:nil];
}

- (void) handleCharacterChanges {
    // Ensure we have a valid adventure document
    NSLog(@"DSAAdventureWindowController updatePartyPortraits called!!!");
    DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)self.document;
    if (!adventureDoc) return;
    //NSLog(@"DSAAdventureWindowController updatePartyPortraits before the NSArray imageViews!!!");
    NSArray *imageViews = @[
        self.imagePartyMember0,
        self.imagePartyMember1,
        self.imagePartyMember2,
        self.imagePartyMember3,
        self.imagePartyMember4,
        self.imagePartyMember5
    ];

    NSArray *characters = adventureDoc.characterDocuments;
    
    // Loop through up to 6 characters and assign portraits
    for (NSInteger i = 0; i < imageViews.count; i++) {
        DSACharacterPortraitView *imageView = imageViews[i];

        if (i < characters.count) {
            DSACharacterDocument *charDoc = characters[i];
            DSACharacter *character = charDoc.model;
            imageView.characterDocument = charDoc;
            imageView.image = [character portrait]; // Get portrait from model
            if ([adventureDoc.model.activeGroup.partyMembers containsObject: character.modelID])
              {
                imageView.alphaValue = 1.0;

                [imageView setNeedsDisplay:YES];
              }
            else
              {
                imageView.alphaValue = 0.4;
                [imageView setNeedsDisplay:YES];
              }
            imageView.toolTip = [imageView toolTip];
        } else {
            imageView.image = nil; // Clear unused slots
            imageView.characterDocument = nil;
            imageView.toolTip = @"";
        }
    }
    [self updateActionIcons: nil];
}

- (void)updateMainImageView: (DSAPosition *)position
{
    BOOL showBuildingDialog = NO;
    BOOL showRouteDialog = NO;
    DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)self.document;
    DSAAdventureGroup *activeGroup = adventureDoc.model.activeGroup;    
    DSAPosition *currentPosition;
    if (position)
      {
        currentPosition = position;
      }
    else
      {
        currentPosition = activeGroup.position;
      }
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType:@"local"];
    DSALocation *globalLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.globalLocationName ofType:@"global"];
    NSLog(@"DSAAdventureWindowController updateMainImageView called!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if (!currentLocation && !globalLocation) {
        NSLog(@"DSAAdventureWindowController updateMainImageView : Fehlende Location-Daten");
        return;
    }
    
    if (!currentLocation)  // we only have a global location
      {
        NSString *selectedKey;
        NSString *seed;        
        if ([currentPosition.context isEqualToString: DSAActionContextTravel])
          {
            selectedKey = @"Reisen_Strasse";
          }
        else if ([currentPosition.context isEqualToString: DSAActionContextResting])
          {
            selectedKey = @"Lagerfeuer";
          }
        else
          {
            NSLog(@"DSAAdventure updateMainImageView: unknown global position context: %@, aborting", currentPosition.context);
            abort();
          }
        seed = currentPosition.mapCoordinate.description;
        NSString *imageName = [Utils randomImageNameForKey:selectedKey
                                            withSizeSuffix: nil
                                                seedString:seed];   
        // ️ Bild laden und anzeigen
        if (imageName) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
            if (imagePath) {
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
                [self.imageMain setImage:image];
            } else {
                NSLog(@"DSAAdventureWindowController updateMainImageView: image not found in Bundle: %@", imageName);
            }
        } else {
            NSLog(@"DSAAdventureWindowController updateMainImageView: no image found for Key: %@", selectedKey);
        }
        return;                                                   
      }

    DSALocalMapLocation *localMapLocation = (DSALocalMapLocation *)currentLocation;
    DSALocalMapTile *currentTile = [localMapLocation tileAtCoordinate:currentPosition.mapCoordinate];
    
    NSString *selectedKey = nil;
    NSString *seed;
    // 📌 1. Tempel (nach Gott benannt)
    if ([currentTile isMemberOfClass:[DSALocalMapTileBuildingTemple class]]) {
        NSString *god = [(DSALocalMapTileBuildingTemple *)currentTile god];
        selectedKey = [NSString stringWithFormat:@"%@_Tempel", god];
        NSLog(@"DSAAdventureWindowController updateMainImageView selectedKey: %@", selectedKey);
        seed = currentPosition.description;
    // 📌 2. Gebäude mit Typ (Herberge, Taverne etc.), group may be at the reception, up at the room, or in a tavern
    } else if ([currentTile isKindOfClass: [DSALocalMapTileBuildingInn class]]) {
        NSString *buildingType = [(DSALocalMapTileBuilding *)currentTile type];
        NSString *context = currentPosition.context;
        
        NSString *roomKey = [currentPosition roomKey];
        NSLog(@"DSAAdventureWindowController updateMainImageView for DSALocalMapTileBuildingInn buildingType: %@ context: %@, roomKey: %@", buildingType, context, roomKey);
        DSAGlobalMapLocation *gl = (DSAGlobalMapLocation *)globalLocation;
        NSString *regionType;
        NSString *noRegionType;
        if ([buildingType isEqualToString: @"Taverne"] || [context isEqualToString: DSAActionContextTavern])
          {
            regionType = [NSString stringWithFormat:@"%@_Taverne", gl.region];
            noRegionType = @"Taverne";
          }
        else if ([context isEqualToString: DSAActionContextReception])
          {
            regionType = [NSString stringWithFormat:@"%@_Herberge", gl.region];
            noRegionType = @"Herberge";
          }
        else
          {
            DSACharacterEffect *appliedRentEffect = [[[activeGroup allCharacters] objectAtIndex: 0] appliedCharacterEffectWithKey: roomKey];
            DSARoomType roomType = [[[appliedRentEffect.reversibleChanges allValues] objectAtIndex: 0] integerValue];
            NSString *roomTypeName;
            switch (roomType) {
              case DSARoomTypeDormitory: {
                roomTypeName = @"Schlafsaal";
                break;
              }
              case DSARoomTypeSingle: {
                roomTypeName = @"Einzelzimmer";
                break;
              }
              case DSARoomTypeSuite: {
                roomTypeName = @"Suite";
                break;
              }
              case DSARoomTypeUnknown: {
                roomTypeName = @"Unknown";
                break;
              }              
            }
            if (roomType == DSARoomTypeUnknown)
              {
                NSLog(@"DSAAdventureWindowController updateMainImageView: unknown DSARoomType!");
                regionType = [NSString stringWithFormat:@"%@_Herberge", gl.region];
                noRegionType = @"Herberge";                
              }
            else
              {
                regionType = [NSString stringWithFormat:@"%@_Herberge_%@", gl.region, roomTypeName];
                noRegionType = [NSString stringWithFormat:@"Herberge_%@", roomTypeName];
              }
          }
        NSLog(@"DSAAdventureWindowController updateMainImageView for DSALocalMapTileBuildingInn regionType: %@, noRegionType: %@", regionType, noRegionType);
        if ([Utils getImagesIndexDict][regionType]) {
            selectedKey = regionType;
        } else if ([Utils getImagesIndexDict][buildingType]) {
            selectedKey = noRegionType;
        }
        seed = currentPosition.description;        
    //  2. other buildings ...
    } else if ([currentTile isKindOfClass:[DSALocalMapTileBuilding class]] ||
               [currentTile isKindOfClass:[DSALocalMapTileRoute class]]) {
        NSString *buildingType = [(DSALocalMapTileBuilding *)currentTile type];
        
        if ([currentTile isMemberOfClass:[DSALocalMapTileBuilding class]])
          {
            showBuildingDialog = YES;
          }
        else if ([currentTile isKindOfClass:[DSALocalMapTileRoute class]]) 
          {
            showRouteDialog = YES;
          }
        
        // 👉 Umlaute ersetzen
        NSDictionary *replacements = @{ @"ä": @"ae", @"ö": @"oe", @"ü": @"ue",
                                        @"Ä": @"Ae", @"Ö": @"Oe", @"Ü": @"Ue" };
        for (NSString *key in replacements) {
            buildingType = [buildingType stringByReplacingOccurrencesOfString:key withString:replacements[key]];
        }
        NSLog(@"DSAAdventureWindowController updateMainImageView buildingType: %@", buildingType);
        DSAGlobalMapLocation *gl = (DSAGlobalMapLocation *)globalLocation;
        NSString *regionType = [NSString stringWithFormat:@"%@_%@", gl.region, buildingType];
        NSLog(@"DSAAdventureWindowController updateMainImageView regionType: %@", regionType);
        // Erst Region_Type, dann nur Type
        if ([Utils getImagesIndexDict][regionType]) {
            selectedKey = regionType;
        } else if ([Utils getImagesIndexDict][buildingType]) {
            selectedKey = buildingType;
        }
        NSLog(@"DSAAdventureWindowController updateMainImageView selectedKey: %@", selectedKey);
        seed = currentPosition.description;
    // 📌 3. Straßen oder Grünflächen
    } else if ([currentTile isMemberOfClass:[DSALocalMapTileStreet class]] ||
               [currentTile isMemberOfClass:[DSALocalMapTileGreen class]]) {       
        DSAGlobalMapLocation *gl = (DSAGlobalMapLocation *)globalLocation;
        NSString *regionType = [NSString stringWithFormat:@"%@_%@", gl.region, gl.type];
        seed = currentPosition.localLocationName;
        if ([Utils getImagesIndexDict][regionType]) {
            selectedKey = regionType;
        } else if ([Utils getImagesIndexDict][gl.type]) {
            selectedKey = gl.type;
        }
    }

    // 🔀 Pseudo-zufällige Auswahl nach DSAPosition
    //NSString *seed = currentPosition.description;
    NSString *imageName = [Utils randomImageNameForKey:selectedKey
                                        withSizeSuffix: nil
                                            seedString:seed];

    // 🖼️ Bild laden und anzeigen
    if (imageName) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        if (imagePath) {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
            [self.imageMain setImage:image];
        } else {
            NSLog(@"Bild nicht gefunden im Bundle: %@", imageName);
        }
    } else {
        NSLog(@"Keine passenden Bilder gefunden für Key: %@", selectedKey);
    }
    
    if (showBuildingDialog)
      {
        [self showBuildingDialogSheet];        
      }
    else if (showRouteDialog)
      {
        NSLog(@"DASAdventureWindowController updateMainImageView: showing route dialog.");        
        [self showRouteDialogSheet];
      }
}

- (void)showBuildingDialogSheet
{
        NSLog(@"DASAdventureWindowController showBuildingDialogSheet: showing building dialog.");
        // Dialog laden
        DSADialogManager *manager = [[DSADialogManager alloc] init];
        NSString *dialogFileName = @"dialogue_general_building";
        if (![manager loadDialogFromFile: dialogFileName]) {
            NSLog(@"DASAdventureWindowController showBuildingDialogSheet: DSAActionIconChat handleEvent: unable to load dialog file: %@", dialogFileName);
            return;
        }

        manager.currentNodeID = manager.currentDialog.startNodeID;

        // Dialog UI anzeigen als Sheet
        DSAConversationDialogSheetController *dialogController = [[DSAConversationDialogSheetController alloc] initWithDialogManager:manager];

        // Present dialogController.window as sheet attached to main window
        [self.window beginSheet:dialogController.window completionHandler:^(NSModalResponse returnCode) {
            // Optional: handle sheet dismissal here
            NSLog(@"DASAdventureWindowController showBuildingDialogSheet: Dialog sheet closed");
        }];
}

- (void)showRouteDialogSheet
{
  DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
  DSAAdventureGroup *activeGroup = adventure.activeGroup;
  DSAPosition *currentPosition = activeGroup.position;
  DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
  DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
  DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
      
   DSAActionChoiceQuestionController *choiceWindow =
       [[DSAActionChoiceQuestionController alloc] initWithWindowNibName:@"DSAActionChoiceQuestionView"];
   [choiceWindow window];

   self.globalMapViewController = [DSAMapViewController sharedMapController];
   [self.globalMapViewController.fieldLocationSearch setStringValue:currentPosition.localLocationName];
   DSALocation *startLoc = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"global"];
   NSPoint startPoint = startLoc.mapCoordinate.asPoint;
   [self.globalMapViewController jumpToLocationWithCoordinates: startPoint];
   
   choiceWindow.fieldHeadline.stringValue = @"Reisen";
   choiceWindow.fieldQuestion.stringValue = @"Wohin soll die Reise gehen?";
   choiceWindow.buttonCancel.title = @"Abbrechen";
   choiceWindow.buttonConfirm.title = @"Bestätigen";
   choiceWindow.notificationName = @"DSARouteDestinationChanged";
   [choiceWindow.popupChoice removeAllItems];
   [choiceWindow.popupChoice addItemsWithTitles: [(DSALocalMapTileRoute *)currentTile destinations]];
   
   __weak typeof(choiceWindow) weakWindow = choiceWindow;
   choiceWindow.completionHandler = ^(BOOL result) {
       if (!result) {
           return;
       }
       NSMenuItem *destination = (NSMenuItem *)weakWindow.popupChoice.selectedItem;
       NSLog(@"DSAAdventureWindowController showRouteDialogSheet: selected destionation: %@", destination.title);

       
       [adventure beginTravelFrom: currentPosition.localLocationName to: destination.title];
   };

   [self.window beginSheet:choiceWindow.window completionHandler:nil];
}

- (void)characterHighlighted:(DSACharacterDocument *) selectedCharacter {
    if (selectedCharacter) {

        NSLog(@"DSAAdventureWindowController characterHighlighted: %@", selectedCharacter.model.name);
    } else {
        // No character is selected
        NSLog(@"DSAAdventureWindowController characterHighlighted: deselected Character %@", selectedCharacter.model.name);
    }
}

- (void)handleLogsMessage:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) return;
    
    LogSeverity severity = [userInfo[@"severity"] integerValue];
    NSString *message = userInfo[@"message"];
    
    if (!message) return;

    //NSLog(@"DSAAdventureWindowController handleLogsMessage: Got message: %@", message);
    // Get timestamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];

    // Format log entry with bold timestamp
    NSMutableAttributedString *logEntry = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", timestamp, message]];
    
    // Apply bold font to timestamp
    [logEntry addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12] range:NSMakeRange(0, timestamp.length)];

    // Apply color based on severity
    NSColor *textColor;
    switch (severity) {
        case LogSeverityInfo:
            textColor = [NSColor blackColor];
            break;
        case LogSeverityHappy:
            textColor = [NSColor blueColor];
            break;            
        case LogSeverityWarning:
            textColor = [NSColor brownColor];
            break;
        case LogSeverityCritical:
            textColor = [NSColor redColor];
            break;
    }
    
    [logEntry addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(timestamp.length + 1, message.length)];

    // Append to existing logs, ensuring we don't exceed the field’s capacity
    // NSLog(@"DSAAdventureWindowController handleLogsMessage: That's the log entry: %@", logEntry);
    [self appendLogMessage:logEntry];
}

- (void)appendLogMessage:(NSAttributedString *)newLog {
    NSMutableAttributedString *existingLogs = [[NSMutableAttributedString alloc] initWithAttributedString:self.fieldLogs.attributedStringValue];

    // Store log entries as attributed strings
    NSMutableArray<NSAttributedString *> *logEntries = [NSMutableArray array];

    // Define regex pattern for timestamps (e.g., "12:34:56")
    NSString *timestampPattern = @"\\b\\d{2}:\\d{2}:\\d{2}\\b";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:timestampPattern options:0 error:nil];

    __block NSInteger lastMatchLocation = 0;
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:existingLogs.string options:0 range:NSMakeRange(0, existingLogs.length)];

    // Extract log messages based on timestamp locations
    for (NSTextCheckingResult *match in matches) {
        if (match.range.location > lastMatchLocation) {
            NSRange entryRange = NSMakeRange(lastMatchLocation, match.range.location - lastMatchLocation);
            NSAttributedString *logEntry = [existingLogs attributedSubstringFromRange:entryRange];
            [logEntries addObject:logEntry];
        }
        lastMatchLocation = match.range.location; // Update last match location
    }

    // Add the last entry if not already added
    if (lastMatchLocation < existingLogs.length) {
        NSAttributedString *lastLog = [existingLogs attributedSubstringFromRange:NSMakeRange(lastMatchLocation, existingLogs.length - lastMatchLocation)];
        [logEntries addObject:lastLog];
    }

    // Add the new log entry
    [logEntries addObject:newLog];

    // Define max number of log entries allowed
    NSInteger maxEntries = 6; // Adjust as needed

    // Remove oldest entries if exceeding max
    while (logEntries.count > maxEntries) {
        [logEntries removeObjectAtIndex:0];
    }

    // Rebuild the attributed string **with newline checks**
    NSMutableAttributedString *updatedLogs = [[NSMutableAttributedString alloc] init];
    for (NSInteger i = 0; i < logEntries.count; i++) {
        // Append the log entry
        [updatedLogs appendAttributedString:logEntries[i]];

        // Only add a newline if the previous entry didn't end with one
        if (i < logEntries.count - 1) { // Avoid adding a newline after the last entry
            NSString *lastEntryString = [logEntries[i] string];
            if (![lastEntryString hasSuffix:@"\n"]) {
                [updatedLogs appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
        }
    }

    // Update NSTextField while preserving formatting
    self.fieldLogs.attributedStringValue = updatedLogs;
}


- (void)observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                        context:(void *)context {
    
    if ([keyPath isEqualToString:@"selectedCharacterDocument"]) {
        DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)object;
        DSACharacterDocument *selectedCharacter = adventureDoc.selectedCharacterDocument;
        [self characterHighlighted: selectedCharacter];
    }
}
@end
