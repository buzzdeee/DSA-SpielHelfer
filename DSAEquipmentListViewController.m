/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-22 21:53:43 +0100 by sebastia

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

#import "DSAEquipmentListViewController.h"
#import "Utils.h"

#define ICON_SIZE 32

@implementation DSAEquipmentListViewController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSAEquipmentListViewer"];
  if (self)
    {
      NSError *e = nil;
      NSString *filePath;
            
      filePath = [[NSBundle mainBundle] pathForResource:@"Ausruestung" ofType:@"json"];
      _equipmentDict = [NSJSONSerialization 
        JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                   options: NSJSONReadingMutableContainers
                     error: &e];    
    }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  self.tableView.delegate = self;  
  self.fieldSearch.delegate = self;
  [self loadData];
  [self.tableView setUsesAlternatingRowBackgroundColors:YES]; // the delegate above with method below doesn't do anything :(
  [self.tableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

}


// NSTableViewDelegate to prevent editing table cells
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return NO; // Prevent editing
}

// Delegate method to set alternating row colors -> NOT WORKING AT ALL
- (void)XXXtableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx");
    if (row % 2 == 0) {
        //[cell setBackgroundColor:[NSColor colorWithCalibratedWhite:0.95 alpha:0.5]]; // Light color for even rows
        [cell setBackgroundColor: [NSColor greenColor]];
        
    } else {
            [cell setBackgroundColor: [NSColor redColor]];
        //[cell setBackgroundColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]]; // Dark color for odd rows
    }
}

- (NSArray *)flattenEquipmentData:(NSDictionary *)data {
    NSMutableArray *flatData = [NSMutableArray array];
    [self traverseData:data parentKeys:@[] intoArray:flatData];
    
    // Sort the flattened data
    NSSortDescriptor *sortOberkategorie = [NSSortDescriptor sortDescriptorWithKey:@"Oberkategorie" ascending:YES];
    NSSortDescriptor *sortKategorie = [NSSortDescriptor sortDescriptorWithKey:@"Kategorie" ascending:YES];
    NSSortDescriptor *sortUnterkategorie = [NSSortDescriptor sortDescriptorWithKey:@"Unterkategorie" ascending:YES];
    NSSortDescriptor *sortName = [NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES];

    return [flatData sortedArrayUsingDescriptors:@[sortOberkategorie, sortKategorie, sortUnterkategorie, sortName]];
}

- (void)traverseData:(NSDictionary *)data parentKeys:(NSArray *)keys intoArray:(NSMutableArray *)flatData {
    for (NSString *key in data) {
        id value = data[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            BOOL isTerminal = NO;

            // Extract general fields
            row[@"Name"] = value[@"Name"];
            row[@"Gewicht"] = value[@"Gewicht"];
            row[@"Preis"] = value[@"Preis"];
            row[@"Regionen"] = value[@"Regionen"] ? value[@"Regionen"] : @"";            

            // Add the icon (if available)
            NSArray *icons = value[@"Icon"];
            if (icons.count > 0) {
                NSString *iconName = icons[0]; // Only use the first icon
                row[@"Icon"] = iconName;
            }            
            
            // Determine category flags and add respective fields
            if ([value[@"isHandWeapon"] isEqual: @YES]) {
                row[@"TP"] = [value[@"Trefferpunkte"] componentsJoinedByString:@", "];
                row[@"TP+"] = value[@"TrefferpunkteKK"];
                row[@"BF"] = value[@"Bruchfaktor"];
                row[@"WV"] = value[@"Waffenvergleichswert"];
                row[@"isHandWeapon"] = @YES;
                isTerminal = YES;
            }
            if ([value[@"isDistantWeapon"] isEqual: @YES]) {
                row[@"Reichweite"] = value[@"Reichweite"];
                row[@"TP Fern"] = [value[@"Trefferpunkte Fernwaffe"] componentsJoinedByString:@", "];
                row[@"TP Entfernung"] = value[@"TP Entfernung Formatted"];
                row[@"isDistantWeapon"] = @YES;
                isTerminal = YES;
            }
            if ([value[@"isArmor"] isEqual: @YES]) {
                row[@"Rüstschutz"] = value[@"Rüstschutz"];
                row[@"Behinderung"] = value[@"Behinderung"];
                row[@"isArmor"] = @YES;
                isTerminal = YES;
            }
            // If this is a terminal node (has specific properties), add to the flat data
            if (isTerminal || value[@"Gewicht"] != nil) {
                row[@"Oberkategorie"] = keys.count > 0 ? keys[0] : @"";
                row[@"Kategorie"] = keys.count > 1 ? keys[1] : @"";
                row[@"Unterkategorie"] = keys.count > 2 ? keys[2] : @"";
                row[@"Maßgeschneidert"] = value[@"Maßgeschneidert"] ? value[@"Maßgeschneidert"] : @"";
                NSLog(@"going to add the row to the flat data: %@", row);
                [flatData addObject:row];
            } else {
                // Recurse deeper if not terminal
                [self traverseData:value parentKeys:[keys arrayByAddingObject:key] intoArray:flatData];
            }
           
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.tableData.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *rowData = self.tableData[row];
    NSString *identifier = tableColumn.identifier;
    
    if ([identifier isEqualToString:@"Icon"]) {
        // Retrieve the icon name from the row data
        NSString *iconName = [NSString stringWithFormat: @"%@-%@x%@", rowData[@"Icon"], @ICON_SIZE, @ICON_SIZE];
        
        if (iconName) {
            // Construct the image path from the resource bundle
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"webp"];
            
            if (imagePath) {
                // Load the image and scale it to defined ICON_SIZE
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
                if (image) {
                    return image;  // Return the image for the "Icon" column
                }
            }
        }
        return nil;  // Return nil if no icon is available
    }
    
    // For other columns, return the corresponding value from rowData
    return rowData[identifier];
}


- (void)loadData {
    NSArray *flattenedData = [self flattenEquipmentData: [Utils getDSAObjectsDict]];
    self.tableDataOriginal = flattenedData; // Store the unfiltered data
    self.tableData = [flattenedData mutableCopy]; // Initialize the table data

    [self configureTableForGeneralView];
}

- (void) configureTableForGeneralView {
    [self.tableView.tableColumns enumerateObjectsUsingBlock:^(NSTableColumn * _Nonnull column, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView removeTableColumn:column];
    }];

    NSArray<NSString *> *columnOrder = @[@"Icon", @"Oberkategorie", @"Kategorie", @"Unterkategorie", @"Name", @"Gewicht", @"Preis", @"Maßgeschneidert"];
    NSDictionary<NSString *, NSString *> *columns = @{
        @"Icon": @"Icon",
        @"Oberkategorie": @"Oberkategorie",
        @"Kategorie": @"Kategorie",
        @"Unterkategorie": @"Unterkategorie",
        @"Name": @"Name",
        @"Gewicht": @"Gewicht",
        @"Preis": @"Preis",
        @"Maßgeschneidert": @"Maßgeschneidert"
    };

    for (NSString *key in columnOrder) {
        NSString *header = columns[key];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        column.title = header;
        if ([column.identifier isEqualToString: @"Icon"])
          {
            [column setDataCell:[[NSImageCell alloc] init]];
          }
        column.resizingMask = NSTableColumnUserResizingMask;
        [self.tableView setRowHeight: ICON_SIZE];
        [self.tableView addTableColumn:column];
    }

    self.tableData = self.tableDataOriginal;
    [self.tableView reloadData];
    [self resizeColumnsToFit];
}

- (void)configureTableForArmor {
    [self.tableView.tableColumns enumerateObjectsUsingBlock:^(NSTableColumn * _Nonnull column, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView removeTableColumn:column];
    }];

    NSArray<NSString *> *columnOrder = @[@"Icon", @"Name", @"Rüstschutz", @"Behinderung", @"Gewicht", @"Preis", @"Regionen"];
    NSDictionary<NSString *, NSString *> *columns = @{
        @"Icon": @"Icon",
        @"Name": @"Name",
        @"Rüstschutz": @"RS",
        @"Behinderung": @"BE",
        @"Gewicht": @"Gewicht",
        @"Preis": @"Preis",
        @"Regionen": @"Regionen"
    };

    for (NSString *key in columnOrder) {
        NSString *header = columns[key];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        column.title = header;
        if ([column.identifier isEqualToString: @"Icon"])
          {
            [column setDataCell:[[NSImageCell alloc] init]];
          }        
        column.resizingMask = NSTableColumnUserResizingMask;
        [self.tableView addTableColumn:column];
    }        

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *entry, NSDictionary *bindings) {
        return [entry[@"isArmor"] boolValue];
    }];
    self.tableData = [self.tableDataOriginal filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
    [self.tableView setRowHeight: ICON_SIZE];
    [self resizeColumnsToFit];
}

- (void)configureTableForHandWeapons {
    [self.tableView.tableColumns enumerateObjectsUsingBlock:^(NSTableColumn * _Nonnull column, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView removeTableColumn:column];
    }];

    NSArray<NSString *> *columnOrder = @[@"Icon", @"Name", @"TP", @"TP+", @"BF", @"WV", @"Gewicht", @"Preis", @"Regionen"];
    NSDictionary<NSString *, NSString *> *columns = @{
        @"Icon": @"Icon",
        @"Name": @"Name",
        @"TP": @"TP",
        @"TP+": @"TP+",
        @"BF": @"BF",
        @"WV": @"WV",
        @"Gewicht": @"Gewicht",
        @"Preis": @"Preis",
        @"Regionen": @"Regionen"
    };

    for (NSString *key in columnOrder) {
        NSString *header = columns[key];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        column.title = header;
        if ([column.identifier isEqualToString: @"Icon"])
          {
            [column setDataCell:[[NSImageCell alloc] init]];
          }        
        column.resizingMask = NSTableColumnUserResizingMask;
        [self.tableView addTableColumn:column];
    }  
        
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *entry, NSDictionary *bindings) {
        return [entry[@"isHandWeapon"] boolValue];
    }];
    self.tableData = [self.tableDataOriginal filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
    [self.tableView setRowHeight: ICON_SIZE];
    [self resizeColumnsToFit];
}

- (void)configureTableForDistantWeapons {
    [self.tableView.tableColumns enumerateObjectsUsingBlock:^(NSTableColumn * _Nonnull column, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView removeTableColumn:column];
    }];

    NSArray<NSString *> *columnOrder = @[@"Icon", @"Name", @"TP Fern", @"TP Entfernung", @"Gewicht", @"Preis", @"Regionen"];
    NSDictionary<NSString *, NSString *> *columns = @{
        @"Icon": @"Icon",
        @"Name": @"Name",
        @"TP Fern": @"TP",
        @"TP Entfernung": @"TP+",
        @"Gewicht": @"Gewicht",
        @"Preis": @"Preis",
        @"Regionen": @"Regionen"
    };

    for (NSString *key in columnOrder) {
        NSString *header = columns[key];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        column.title = header;
        if ([column.identifier isEqualToString: @"Icon"])
          {
            [column setDataCell:[[NSImageCell alloc] init]];
          }        
        column.resizingMask = NSTableColumnUserResizingMask;
        [self.tableView addTableColumn:column];
    } 
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *entry, NSDictionary *bindings) {
        return [entry[@"isDistantWeapon"] boolValue];
    }];
    self.tableData = [self.tableDataOriginal filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
    [self.tableView setRowHeight: ICON_SIZE];
    [self resizeColumnsToFit];
}

- (IBAction) selectView: (id) sender
{
  if ([[[sender selectedItem] title] isEqualToString: @"Allgemeine Übersicht"])
    {
      [self configureTableForGeneralView];
    }
  else if ([[[sender selectedItem] title] isEqualToString: @"Handwaffen"])
    {
      [self configureTableForHandWeapons];
    }
  else if ([[[sender selectedItem] title] isEqualToString: @"Fernwaffen"])
    {
      [self configureTableForDistantWeapons];
    }
  else if ([[[sender selectedItem] title] isEqualToString: @"Rüstung"])
    {
      [self configureTableForArmor];
    }
  else
    {
      NSLog(@"DSAEquipmentListViewController selectView: don't know how to handle: %@", [[sender selectedItem] title]);
    }
}

- (void)XXXresizeColumnsToFit {
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};

    for (NSTableColumn *column in self.tableView.tableColumns) {
        NSString *identifier = column.identifier;

        // Calculate header width
        CGFloat maxWidth = [column.title sizeWithAttributes:attributes].width + 20; // Padding for the header

        // Calculate maximum row width
        for (NSDictionary *row in self.tableData) {
            id value = row[identifier];
            if ([value isKindOfClass:[NSString class]]) {
                CGFloat rowWidth = [value sizeWithAttributes:attributes].width + 20; // Padding for row values
                if (rowWidth > maxWidth) {
                    maxWidth = rowWidth;
                }
            } else if ([value isKindOfClass:[NSArray class]]) {
                NSString *joinedValue = [(NSArray *)value componentsJoinedByString:@", "];
                CGFloat rowWidth = [joinedValue sizeWithAttributes:attributes].width + 20;
                if (rowWidth > maxWidth) {
                    maxWidth = rowWidth;
                }
            }
        }

        // Update column width
        column.minWidth = maxWidth;
        column.maxWidth = maxWidth;
    }
}

- (void)resizeColumnsToFit {
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};

    for (NSTableColumn *column in self.tableView.tableColumns) {
        NSString *identifier = column.identifier;

        CGFloat maxWidth = [column.title sizeWithAttributes:attributes].width + 20; // Padding for header

        for (NSDictionary *row in self.tableData) {
            id value = row[identifier];
            
            if ([identifier isEqualToString:@"Icon"]) {
               maxWidth = ICON_SIZE + 10; // Add padding
            } else if ([value isKindOfClass:[NSString class]]) {
                // For other columns, calculate based on string length
                CGFloat rowWidth = [value sizeWithAttributes:attributes].width + 20; // Padding
                maxWidth = MAX(maxWidth, rowWidth);
            } else if ([value isKindOfClass:[NSArray class]]) {
                // For array values (like joined strings)
                NSString *joinedValue = [(NSArray *)value componentsJoinedByString:@", "];
                CGFloat rowWidth = [joinedValue sizeWithAttributes:attributes].width + 20; // Padding
                maxWidth = MAX(maxWidth, rowWidth);
            }
        }

        // Update column width to fit the calculated maximum width
        column.minWidth = maxWidth;
        column.maxWidth = maxWidth;
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = notification.object;
    if (textField == self.fieldSearch) {
        [self filterList:textField];
    }
}

- (void)filterList:(id)sender {
    NSString *searchText = [self.fieldSearch stringValue];
    NSString *selectedView = self.popupViewSelector.selectedItem.title;

    // Determine columns to filter and additional property to check based on the selected view
    NSArray<NSString *> *columnsToSearch;
    NSString *requiredProperty = nil;

    if ([selectedView isEqualToString:@"Allgemeine Übersicht"]) {
        columnsToSearch = @[@"Oberkategorie", @"Kategorie", @"Unterkategorie", @"Name"];
    } else if ([selectedView isEqualToString:@"Handwaffen"]) {
        columnsToSearch = @[@"Name"];
        requiredProperty = @"isHandWeapon";
    } else if ([selectedView isEqualToString:@"Rüstung"]) {
        columnsToSearch = @[@"Name"];
        requiredProperty = @"isArmor";
    } else if ([selectedView isEqualToString:@"Fernwaffen"]) {
        columnsToSearch = @[@"Name"];
        requiredProperty = @"isDistantWeapon";
    }

    if (searchText.length == 0) {
        // If search text is empty, reset to the context-specific subset
        if (requiredProperty) {
            NSPredicate *contextPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *row, NSDictionary *bindings) {
                return [row[requiredProperty] boolValue];
            }];
            self.tableData = [[self.tableDataOriginal filteredArrayUsingPredicate:contextPredicate] mutableCopy];
        } else {
            // For "Allgemeine Übersicht," reset to the original unfiltered data
            self.tableData = [self.tableDataOriginal mutableCopy];
        }
    } else {
        // Filter the data based on the search text
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *row, NSDictionary *bindings) {
            // Check if the row matches the required property
            if (requiredProperty && ![row[requiredProperty] boolValue]) {
                return NO; // Skip rows that do not meet the required type
            }

            // Search in the specified columns
            for (NSString *column in columnsToSearch) {
                NSString *value = row[column];
                if (value && [value rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    return YES; // Match found
                }
            }
            return NO; // No match
        }];
        self.tableData = [[self.tableDataOriginal filteredArrayUsingPredicate:predicate] mutableCopy];
    }

    // Reload the table view with the updated data
    [self.tableView reloadData];
    [self resizeColumnsToFit];
}

@end
