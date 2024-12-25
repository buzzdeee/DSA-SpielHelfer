/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-15 14:36:59 +0100 by sebastia

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

#import "DSAItemInspectionController.h"
#import "DSACharacter.h"
#import "DSAObject.h"
#import "DSAObjectWeaponHandWeapon.h"
#import "DSAObjectWeaponHandAndLongRangeWeapon.h"
#import "DSAObjectWeaponLongRange.h"
#import "DSAObjectArmor.h"
#import "DSAObjectShield.h"
#import "DSAObjectShieldAndParry.h"
#import "DSAObjectContainer.h"
#import "Utils.h"

@implementation DSAItemInspectionController

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"DSAItemInspectionController: awakeFromNib called");
//    NSLog(@"itemImageView: %@", self.itemImageView); // Should not be nil
//    NSLog(@"itemName: %@", self.itemName);           // Should not be nil
//    NSLog(@"itemInfoTextView: %@", self.itemInfoTextView); // Should not be nil
}

- (void)windowDidLoad {
    NSLog(@"DSAItemInspectionController: windowDidLoad called");
    [super windowDidLoad];
    

    // If there's an item to inspect, update the UI now
    if (self.itemToInspect) {
        [self updateUIForItem:self.itemToInspect];
        //self.itemToInspect = nil;  // Clear the stored item
    }
}

- (void)inspectItem:(DSAObject *)item {
    NSLog(@"DSAItemInspectionController inspectItem: %@", item);
    if (!item) return;

    // Store the item for deferred UI updates
    self.itemToInspect = item;
    NSLog(@"Window after load: %@", self.window);
    
    // Check if the window is already loaded
    if (self.isWindowLoaded) {
        // If the window is already loaded, update the UI immediately
        [self updateUIForItem:item];
    } else {
        // Otherwise, let windowDidLoad handle the update
        NSLog(@"DSAItemInspectionController: UI elements are not fully initialized yet. Waiting for windowDidLoad.");
    }

    // Show the window
    NSLog(@"DSAItemInspectionController: Showing window.");
    [[self window] makeKeyAndOrderFront:nil]; 
}

- (void)updateUIForItem:(DSAObject *)item {
    NSLog(@"DSAItemInspectionController updateUIForItem: %@", item);

    // Update the image
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-512x512", item.icon] ofType:@"webp"];
    NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    [self.itemImageView setImage:itemImage];

    // Update the name
    [self.itemName setStringValue:item.name];

    // Construct details
    NSLog(@"THE REGIONS: %@", item.regions);
    NSMutableString *details = [NSMutableString string];
    [details appendFormat:_(@"Kategorie: %@ / %@ / %@\n"), item.category, item.subCategory, item.subSubCategory ?: @"-"];
    [details appendFormat:_(@"Gewicht: %.2f\n"), item.weight];
    [details appendFormat:_(@"Preis: %.2f\n"), item.price];
    [details appendFormat:_(@"Handelsregionen: %@\n"), item.regions ? [item.regions componentsJoinedByString:@", "] : _(@"alle")];
    [details appendFormat:_(@"ist Magisch: %@\n"), item.spell ? _(@"Ja") : _(@"Nein")];
    if (item.spell)
      {
        [details appendFormat:_(@"Spruch: %@\n"), item.spell];
      }

    [details appendFormat:_(@"ist Vergiftet: %@\n"), item.isPoisoned ? _(@"Ja") : _(@"Nein")];
    [details appendFormat:_(@"ist Konsumierbar: %@\n"), item.isConsumable ? _(@"Ja") : _(@"Nein")];
    [details appendFormat:_(@"ist persönlicher Gegenstand: %@\n"), item.ownerUUID ? _(@"Ja") : _(@"Nein")];
    if (item.ownerUUID)
      {
        DSACharacter *owner = [DSACharacter characterWithModelID: item.ownerUUID];
        [details appendFormat:_(@"Besitzer: %@\n"), owner.name];
      }
    
    // Handle subclasses for additional details
    if ([item isKindOfClass:[DSAObjectContainer class]]) {
        DSAObjectContainer *container = (DSAObjectContainer *)item;
        [details appendFormat:_(@"Anzahl Slots: %ld\n"), [container.slots count]];
    } else if ([item isKindOfClass:[DSAObjectWeaponHandAndLongRangeWeapon class]]) {
        DSAObjectWeaponHandAndLongRangeWeapon *weapon = (DSAObjectWeaponHandAndLongRangeWeapon *)item;
        [details appendFormat:_(@"Länge: %f\n"), weapon.length];
        [details appendFormat:_(@"Trefferpunkte: %@\n"), weapon.hitPoints ? [weapon.hitPoints componentsJoinedByString:@" + "] : @"-"];
        [details appendFormat:_(@"TrefferpunkteKK: %ld\n"), (unsigned long) weapon.hitPointsKK];
        [details appendFormat:_(@"Bruchfaktor: %@\n"), weapon.breakFactor == -1 ? _(@"unzerstörbar") : [NSNumber numberWithInteger: weapon.breakFactor]];
        [details appendFormat:_(@"Waffenvergleichswert: %ld/%ld\n"), (unsigned long) weapon.attackPower, (unsigned long) weapon.parryValue];
        [details appendFormat:_(@"Trefferpunkte Distanz: %@\n"), weapon.hitPointsLongRange ? [weapon.hitPointsLongRange componentsJoinedByString:@" + "] : @"-"];
        [details appendFormat:_(@"Reichweite: %ld\n"), (unsigned long) weapon.maxDistance];
        [details appendFormat:_(@"Entfernungsmalus: %@\n"), [Utils formatTPEntfernung: weapon.distancePenalty]];        
    } else if ([item isKindOfClass:[DSAObjectWeaponHandWeapon class]]) {
        DSAObjectWeaponHandWeapon *weapon = (DSAObjectWeaponHandWeapon *)item;
        [details appendFormat:_(@"Länge: %f\n"), weapon.length];
        [details appendFormat:_(@"Trefferpunkte: %@\n"), weapon.hitPoints ? [weapon.hitPoints componentsJoinedByString:@" + "] : @"-"];
        [details appendFormat:_(@"TrefferpunkteKK: %ld\n"), (unsigned long) weapon.hitPointsKK];
        [details appendFormat:_(@"Bruchfaktor: %@\n"), weapon.breakFactor == -1 ? _(@"unzerstörbar") : [NSNumber numberWithInteger: weapon.breakFactor]];
        [details appendFormat:_(@"Waffenvergleichswert: %ld/%ld\n"), (unsigned long) weapon.attackPower, (unsigned long) weapon.parryValue];
    } else if ([item isKindOfClass:[DSAObjectShieldAndParry class]]) {
        DSAObjectShieldAndParry *weapon = (DSAObjectShieldAndParry *)item;
        [details appendFormat:_(@"Trefferpunkte: %@\n"), weapon.hitPoints ? [weapon.hitPoints componentsJoinedByString:@" + "] : @"-"];
        [details appendFormat:_(@"TrefferpunkteKK: %ld\n"), (unsigned long) weapon.hitPointsKK];
        [details appendFormat:_(@"Bruchfaktor: %@\n"), weapon.breakFactor == -1 ? _(@"unzerstörbar") : [NSNumber numberWithInteger: weapon.breakFactor]];
        [details appendFormat:_(@"Behinderung: %.0f\n"), weapon.penalty];
        [details appendFormat:_(@"Waffenvergleichswert: %ld/%ld\n"), (unsigned long) weapon.attackPower, (unsigned long) weapon.parryValue];
        [details appendFormat:_(@"Waffenvergleichswert Schild: %ld/%ld\n"), (unsigned long) weapon.shieldAttackPower, (unsigned long) weapon.shieldParryValue];
    } else if ([item isKindOfClass:[DSAObjectShield class]]) {
        DSAObjectShield *weapon = (DSAObjectShield *)item;
        [details appendFormat:_(@"Bruchfaktor: %@\n"), weapon.breakFactor == -1 ? _(@"unzerstörbar") : [NSNumber numberWithInteger: weapon.breakFactor]];
        [details appendFormat:_(@"Behinderung: %.0f\n"), weapon.penalty];
        [details appendFormat:_(@"Waffenvergleichswert Schild: %ld/%ld\n"), (unsigned long) weapon.shieldAttackPower, (unsigned long) weapon.shieldParryValue];
    } else if ([item isKindOfClass:[DSAObjectWeaponLongRange class]]) {
        DSAObjectWeaponLongRange *weapon = (DSAObjectWeaponLongRange *)item;
        [details appendFormat:_(@"Trefferpunkte: %@\n"), weapon.hitPointsLongRange ? [weapon.hitPointsLongRange componentsJoinedByString:@" + "] : @"-"];
        [details appendFormat:_(@"Reichweite: %ld\n"), (unsigned long) weapon.maxDistance];
        [details appendFormat:_(@"Entfernungsmalus: %@\n"), [Utils formatTPEntfernung: weapon.distancePenalty]];
    } else if ([item isKindOfClass:[DSAObjectArmor class]]) {
        DSAObjectArmor *armor = (DSAObjectArmor *)item;
        [details appendFormat:_(@"Rüstschutz: %ld\n"), (unsigned long)armor.protection];
        [details appendFormat:_(@"Behinderung: %.0f\n"), armor.penalty];
    }

    [self.itemInfoTextView setStringValue:details];
    NSLog(@"DSAItemInspectionController updateUIForItem: at the end");
}

-(IBAction) closeItemInspectorWindow: (id)sender
{
  NSLog(@"DSAItemInspectionController: closeWindow");
  // Notify the owning class (e.g., DSAActionIcon) that the controller can be released
  if ([self.delegate respondsToSelector:@selector(itemInspectionControllerDidClose:)]) {
      [self.delegate itemInspectionControllerDidClose:self];
  }  
  [self.window close];
}

@end