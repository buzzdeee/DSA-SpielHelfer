/* 
   Project: DSA-SpielHelfer

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:14:39 +0200 by sebastia
   
   Application Controller
*/
 
#ifndef _PCAPPPROJ_APPCONTROLLER_H
#define _PCAPPPROJ_APPCONTROLLER_H

#import <AppKit/AppKit.h>

@class DSACharacterGenerationController;
@class DSANPCGenerationController;
@class DSAAdventureGenerationController;
@class DSAMapViewController;
@class DSAEquipmentListViewController;
@class DSANameGenerationController;
@class DSABattleWindowController;
@class DSALocalMapViewController;

@interface AppController : NSObject <NSComboBoxDataSource, NSComboBoxDelegate>



@property (strong) DSACharacterGenerationController *characterGenController;
@property (strong) DSANPCGenerationController *npcGenController;
@property (strong) DSAAdventureGenerationController *adventureGenController;
@property (nonatomic, strong) DSAMapViewController *mapViewController; // Retain the map view controller
@property (nonatomic, strong) DSABattleWindowController *battleViewController; // Retain the map view controller
@property (nonatomic, strong) DSAEquipmentListViewController *equipmentListViewController; // Retain the equipment view controller
@property (nonatomic, strong) DSANameGenerationController *nameGenerationController; // Retain the equipment view controller
@property (nonatomic, strong) DSALocalMapViewController *localMapViewController;  // retain the local map view controller
@property (nonatomic, weak) IBOutlet NSMenuItem *levelUpMenuItem;


+ (void)  initialize;

- (id) init;
- (void) dealloc;

- (void) showPrefPanel: (id)sender;

// called by the AppDelegate on startup
- (void)setupApplication;



@end

#endif
