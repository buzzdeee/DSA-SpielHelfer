/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-19 22:19:06 +0100 by sebastia

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

#import "DSARoutePlanner.h"
#import "DSALocations.h"
#import "DSALocation.h"
#import "DSAMapCoordinate.h"

#define SCALE_FACTOR 0.2787

@implementation DSARouteSegment
@end

@implementation DSARouteResult

- (instancetype)initWithPoints:(NSArray<NSValue *> *)points
                  instructions:(NSArray<NSString *> *)instructions
                  airDistance:(CGFloat)airDistance
                routeDistance:(CGFloat)routeDistance
{
    self = [super init];
    if (self) {
        _routePoints = points;
        _instructions = instructions;
        _airDistance = airDistance;
        _routeDistance = routeDistance;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:
        @"<DSARouteResult: airDistance=%.2f mi, routeDistance=%.2f mi>\n",
        self.airDistance, self.routeDistance];
    for (NSString *line in self.instructions) {
        [desc appendFormat:@"%@\n", line];
    }
    return desc;
}

@end


@interface DSARoutePlanner ()

//@property (nonatomic, strong) NSDictionary *routesData;
@property (nonatomic, strong) NSMutableArray *routesData;
//@property (nonatomic, strong) NSDictionary *locationsData;
//@property (nonatomic, strong) NSMutableDictionary *graph;

@end

@implementation DSARoutePlanner

static DSARoutePlanner *_sharedRoutePlanner = nil;

+ (instancetype)sharedRoutePlanner {
    @synchronized(self) {
        if (_sharedRoutePlanner == nil) {
            _sharedRoutePlanner = [[self alloc] initWithBundleFiles];
        }
    }
    return _sharedRoutePlanner;
}

+ (DSARouteType)routeTypeFromString:(NSString *)typeString {
    static NSDictionary<NSString *, NSNumber *> *mapping = nil;
    if (!mapping) {
        mapping = @{
            @"RS": @(DSARouteTypeRS),
            @"LS": @(DSARouteTypeLS),                    
            @"Weg": @(DSARouteTypeWeg),
            @"Offenes Gelände, Pfad": @(DSARouteTypeOffenesGelaendePfad),
            @"Offenes Gelände": @(DSARouteTypeOffenesGelaende),
            @"Lichter Wald, Pfad": @(DSARouteTypeLichterWaldPfad),
            @"Lichter Wald": @(DSARouteTypeLichterWald),
            @"Wald, Pfad": @(DSARouteTypeWaldPfad),
            @"Wald": @(DSARouteTypeWald),
            @"Dichter Wald, Pfad": @(DSARouteTypeDichterWaldPfad),
            @"Dichter Wald": @(DSARouteTypeDichterWald),
            @"Gebirgspass": @(DSARouteTypeGebirgePassstrecke),
            @"Gebirge, Pfad": @(DSARouteTypeGebirgePfad),                                                         
            @"Gebirge, kein Klettern": @(DSARouteTypeGebirgeKeinKlettern),                                                                     
            @"Hochgebirge, mit Klettern": @(DSARouteTypeHochgebirgeMitKlettern),  
            @"Regenwald, Pfad": @(DSARouteTypeRegenwaldPfad),                                                                   
            @"Regenwald": @(DSARouteTypeRegenwald),                                                                               
            @"Regenwald, Gebirge": @(DSARouteTypeRegenwaldGebirge),
            @"Sumpf, Knüppeldamm": @(DSARouteTypeSumpfKnueppeldamm),                                                                               
            @"Sumpf, Pfad": @(DSARouteTypeSumpfPfad),            
            @"Sumpf": @(DSARouteTypeSumpf),
            @"Eisgebiet, freie Fläche": @(DSARouteTypeEisgebietFreieFlaeche),
            @"Eisgebiet, Tiefschnee": @(DSARouteTypeEisgebietTiefschnee),
            @"Eisgebiet, Eisfläche": @(DSARouteTypeEisgebietEisflaeche),
            @"Eisgebirge, Gletscher": @(DSARouteTypeEisgebirgeGletscher),
            @"Geröllwüste": @(DSARouteTypeGeroellwueste),
            @"Sandwüste": @(DSARouteTypeSandwueste),
            @"Fähre": @(DSARouteTypeFaehre),
            @"Seeschiff": @(DSARouteTypeSeeschiff),
            @"Flussschiff": @(DSARouteTypeFlussschiff),
        };
    }
    
    NSNumber *typeNumber = mapping[typeString];
    if (!typeNumber) {
        NSLog(@"DSARoutePlanner routeTypeFromString: error unknown route type: %@", typeString);
        abort();
    }
    
    return typeNumber.integerValue;
}


- (instancetype)initWithBundleFiles {
    self = [super init];
    if (self) {
        NSString *routesPath = [[NSBundle mainBundle] pathForResource:@"Strassen" ofType:@"geojson"];
        if (routesPath) {
            [self loadRoutesData:routesPath];
        } else {
            NSLog(@"DSARoutePlanner initWithBundleFiles: 'Strassen.geojson' not found in bundle!");
        }
    }
    return self;
}

#pragma mark - Data Loading

- (void)loadRoutesData:(NSString *)filePath {
    NSLog(@"DSARoutePlanner loadRoutesData: Loading routes data from: %@", filePath);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"DSARoutePlanner loadRoutesData: ERROR: Could not load routes data.");
        return;
    }
    
    NSError *jsonError = nil;
    NSDictionary *geojson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        NSLog(@"DSARoutePlanner loadRoutesData: ERROR: JSON parsing failed: %@", jsonError);
        return;
    }
    
    NSArray *features = geojson[@"features"];
    if (!features) {
        NSLog(@"DSARoutePlanner loadRoutesData: ERROR: No features found in GeoJSON.");
        return;
    }
    
    // Neue Mutable Kopie der Features, damit wir die Enum-Werte einfügen können
    NSMutableArray *processedFeatures = [NSMutableArray arrayWithCapacity:features.count];
    
    for (NSDictionary *feature in features) {
        NSMutableDictionary *mutableFeature = [feature mutableCopy];
        NSDictionary *properties = mutableFeature[@"properties"];
        NSString *typeString = properties[@"type"];
        
        // Enum-Wert aus String
        DSARouteType routeType = [DSARoutePlanner routeTypeFromString:typeString];
        
        // Enum im Feature speichern
        mutableFeature[@"routeTypeEnum"] = @(routeType);
        
        [processedFeatures addObject:mutableFeature];
    }
    
    // Ganze GeoJSON-Kopie erstellen und Features ersetzen
    //NSMutableDictionary *mutableGeoJSON = [geojson mutableCopy];
    //mutableGeoJSON = processedFeatures;
    self.routesData = processedFeatures;
    
    NSLog(@"DSARoutePlanner loadRoutesData: Routes data loaded successfully with %lu features.", (unsigned long)processedFeatures.count);
}


- (DSARouteResult *)findShortestPathFrom:(NSString *)startName to:(NSString *)destinationName {
    if (!self.routesData || self.routesData.count == 0) return nil;

    // 1. Graph aufbauen
    NSMutableDictionary<NSString *, NSMutableArray *> *graph = [NSMutableDictionary dictionary];

    for (NSDictionary *feature in self.routesData) {
        NSDictionary *props = feature[@"properties"];
        NSString *begin = props[@"begin"];
        NSString *end = props[@"end"];

        NSArray *coordsArray = feature[@"geometry"][@"coordinates"][0]; // MultiLineString
        double length = 0;
        for (NSInteger i = 1; i < coordsArray.count; i++) {
            NSArray *p1 = coordsArray[i-1];
            NSArray *p2 = coordsArray[i];
            double dx = [p2[0] doubleValue] - [p1[0] doubleValue];
            double dy = [p2[1] doubleValue] - [p1[1] doubleValue];
            length += sqrt(dx*dx + dy*dy);
        }

        NSNumber *typeEnumNumber = feature[@"routeTypeEnum"];
        if (!typeEnumNumber) typeEnumNumber = @(DSARouteTypeWeg); // fallback

        // beidseitig
        if (!graph[begin]) graph[begin] = [NSMutableArray array];
        [graph[begin] addObject:@{@"target": end,
                                  @"length": @(length),
                                  @"coords": coordsArray,
                                  @"typeEnum": typeEnumNumber}];

        if (!graph[end]) graph[end] = [NSMutableArray array];
        NSArray *reversed = [[coordsArray reverseObjectEnumerator] allObjects];
        [graph[end] addObject:@{@"target": begin,
                                @"length": @(length),
                                @"coords": reversed,
                                @"typeEnum": typeEnumNumber}];
    }

    // 2. Dijkstra vorbereiten
    NSMutableDictionary<NSString *, NSNumber *> *distances = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSString *> *previous = [NSMutableDictionary dictionary];
    NSMutableSet<NSString *> *visited = [NSMutableSet set];
    NSMutableArray<NSString *> *queue = [NSMutableArray array];

    for (NSString *node in graph) {
        distances[node] = @(INFINITY);
        [queue addObject:node];
    }
    distances[startName] = @(0);

    while (queue.count > 0) {
        NSString *current = nil;
        double minDist = INFINITY;
        for (NSString *node in queue) {
            if ([distances[node] doubleValue] < minDist) {
                minDist = [distances[node] doubleValue];
                current = node;
            }
        }
        if (!current) break;

        [queue removeObject:current];
        [visited addObject:current];

        if ([current isEqualToString:destinationName]) break;

        for (NSDictionary *neighbor in graph[current]) {
            NSString *target = neighbor[@"target"];
            double edgeLength = [neighbor[@"length"] doubleValue];
            if ([visited containsObject:target]) continue;

            double newDist = [distances[current] doubleValue] + edgeLength;
            if (newDist < [distances[target] doubleValue]) {
                distances[target] = @(newDist);
                previous[target] = current;
            }
        }
    }

    // 3. Route rekonstruieren
    NSMutableArray<NSString *> *routeNodes = [NSMutableArray array];
    NSString *node = destinationName;
    while (node) {
        [routeNodes insertObject:node atIndex:0];
        node = previous[node];
    }

    if (routeNodes.count < 2) {
        NSLog(@"Keine Route von %@ nach %@ gefunden.", startName, destinationName);
        return nil;
    }

    // 4. Punkte, Typen und Segmente sammeln
    NSMutableArray<NSValue *> *routePoints = [NSMutableArray array];
    NSMutableArray<NSString *> *instructions = [NSMutableArray array];
    NSMutableArray<DSARouteSegment *> *segments = [NSMutableArray array];

    for (NSInteger i = 0; i < routeNodes.count - 1; i++) {
        NSString *from = routeNodes[i];
        NSString *to = routeNodes[i+1];
        NSArray *edges = graph[from];
        NSDictionary *edge = nil;
        for (NSDictionary *e in edges) {
            if ([e[@"target"] isEqualToString:to]) {
                edge = e;
                break;
            }
        }
        if (!edge) continue;

        NSArray *coords = edge[@"coords"];
        NSMutableArray<NSValue *> *segmentPoints = [NSMutableArray array];
        for (NSArray *coord in coords) {
            NSPoint point = NSMakePoint([coord[0] doubleValue], [coord[1] doubleValue]);
            [routePoints addObject:[NSValue valueWithPoint:point]];
            [segmentPoints addObject:[NSValue valueWithPoint:point]];
        }

        CGFloat miles = [self routeDistanceWithPoints:segmentPoints];
        DSARouteType typeEnum = [edge[@"typeEnum"] integerValue];

        // Segment erzeugen
        DSARouteSegment *segment = [[DSARouteSegment alloc] init];
        segment.from = from;
        segment.to = to;
        segment.distanceMiles = miles;
        segment.routeType = typeEnum;
        segment.points = [segmentPoints copy];
        [segments addObject:segment];

        // Anweisungstext
        NSString *typeName = nil;
        switch (typeEnum) {
            case DSARouteTypeRS: typeName = @"der Reichsstraße"; break;
            case DSARouteTypeLS: typeName = @"der Landstraße"; break;
            case DSARouteTypeWeg: typeName = @"dem Weg"; break;
            case DSARouteTypeOffenesGelaendePfad: typeName = @"dem Pfad durchs offene Gelände"; break;
            case DSARouteTypeOffenesGelaende: typeName = @"das offene Gelände"; break;
            case DSARouteTypeLichterWaldPfad: typeName = @"dem Pfad durch den lichten Wald"; break;
            case DSARouteTypeLichterWald: typeName = @"den lichten Wald"; break;
            case DSARouteTypeWaldPfad: typeName = @"dem Pfad durch den Wald"; break;
            case DSARouteTypeWald: typeName = @"den Wald"; break;
            case DSARouteTypeDichterWaldPfad: typeName = @"dem Pfad durch den dichten Wald"; break;
            case DSARouteTypeDichterWald: typeName = @"den dichten Wald"; break;
            case DSARouteTypeGebirgePassstrecke: typeName = @"dem Paß durchs Gebirge"; break;
            case DSARouteTypeGebirgePfad: typeName = @"dem Pfad durchs Gebirge"; break;
            case DSARouteTypeGebirgeKeinKlettern: typeName = @"das Gebirge"; break;
            case DSARouteTypeHochgebirgeMitKlettern: typeName = @"das Hochgebirge"; break;
            case DSARouteTypeRegenwaldPfad: typeName = @"dem Pfad durch den Regenwald"; break;
            case DSARouteTypeRegenwald: typeName = @"den Regenwald"; break;
            case DSARouteTypeRegenwaldGebirge: typeName = @"den gebirgigen Regenwald"; break;
            case DSARouteTypeSumpfKnueppeldamm: typeName = @"dem Knüppeldamm durch den Sumpf"; break;
            case DSARouteTypeSumpfPfad: typeName = @"dem Pfad durch den Sumpf"; break;
            case DSARouteTypeSumpf: typeName = @"den Sumpf"; break;
            case DSARouteTypeEisgebietFreieFlaeche: typeName = @"die freie Fläche im Eisgebiet"; break;
            case DSARouteTypeEisgebietTiefschnee: typeName = @"den Tiefschnee im Eisgebiet"; break;         
            case DSARouteTypeEisgebietEisflaeche: typeName = @"die Eisflaeche im Eisgebiet"; break;
            case DSARouteTypeEisgebirgeGletscher: typeName = @"den Gletscher"; break;            
            case DSARouteTypeFaehre: typeName = @"die Fähre"; break;
            case DSARouteTypeSeeschiff: typeName = @"das Schiff"; break;
            case DSARouteTypeFlussschiff: typeName = @"das Schiff"; break;            
            default: NSLog(@"DSARoutePlanner findShortestPathFrom: unknown path type while creating typeName, aborting"); abort();break;
        }
        NSString *instruction;
        switch (typeEnum) {
            case DSARouteTypeRS:
            case DSARouteTypeLS:
            case DSARouteTypeWeg:
            case DSARouteTypeOffenesGelaendePfad:
            case DSARouteTypeLichterWaldPfad:    
            case DSARouteTypeWaldPfad:
            case DSARouteTypeDichterWaldPfad:
            case DSARouteTypeGebirgePassstrecke:
            case DSARouteTypeGebirgePfad:
            case DSARouteTypeRegenwaldPfad:
            case DSARouteTypeSumpfKnueppeldamm:
            case DSARouteTypeSumpfPfad:
                     instruction = [NSString stringWithFormat:@"Folge %@ für %.2f Meilen bis %@.", typeName, miles, to];
                     break;
                    
            case DSARouteTypeOffenesGelaende:
            case DSARouteTypeLichterWald:
            case DSARouteTypeWald:
            case DSARouteTypeDichterWald:
            case DSARouteTypeGebirgeKeinKlettern:
            case DSARouteTypeHochgebirgeMitKlettern:
            case DSARouteTypeRegenwald:
            case DSARouteTypeRegenwaldGebirge:
            case DSARouteTypeSumpf:
            case DSARouteTypeEisgebietTiefschnee:     
            
                     instruction = [NSString stringWithFormat:@"Bahnt euch einen Weg durch %@ für %.2f Meilen bis %@.", typeName, miles, to];
                     break;

            case DSARouteTypeEisgebietFreieFlaeche:
            case DSARouteTypeEisgebietEisflaeche:
            case DSARouteTypeEisgebirgeGletscher:
                     instruction = [NSString stringWithFormat:@"Bahnt euch einen Weg über %@ für %.2f Meilen bis %@.", typeName, miles, to];
                     break;
                                         
            case DSARouteTypeFaehre:
            case DSARouteTypeSeeschiff:
            case DSARouteTypeFlussschiff:
                     instruction = [NSString stringWithFormat:@"Nehmt %@ für %.2f Meilen nach %@.", typeName, miles, to];
                     break;
                                            
            default: NSLog(@"DSARoutePlanner findShortestPathFrom: unknown path type while creating instructions, aborting"); abort();break;
        }        
        [instructions addObject:instruction];
    }

    // 5. Distanzwerte berechnen
    CGFloat airDistance = [self airDistanceFrom:startName to:destinationName];
    CGFloat routeDistance = [self routeDistanceWithPoints:routePoints];

    // 6. Ergebnis erstellen
    DSARouteResult *result = [[DSARouteResult alloc] initWithPoints:routePoints
                                                       instructions:instructions
                                                        airDistance:airDistance
                                                      routeDistance:routeDistance];
    result.segments = [segments copy];

    return result;
}
/*
- (DSARouteResult *)findShortestPathFrom:(NSString *)startName to:(NSString *)destinationName {
    if (!self.routesData || self.routesData.count == 0) return nil;

    // 1. Graph aufbauen
    NSMutableDictionary<NSString *, NSMutableArray *> *graph = [NSMutableDictionary dictionary];

    for (NSDictionary *feature in self.routesData) {
        NSDictionary *props = feature[@"properties"];
        NSString *begin = props[@"begin"];
        NSString *end = props[@"end"];

        NSArray *coordsArray = feature[@"geometry"][@"coordinates"][0]; // MultiLineString
        double length = 0;
        for (NSInteger i = 1; i < coordsArray.count; i++) {
            NSArray *p1 = coordsArray[i-1];
            NSArray *p2 = coordsArray[i];
            double dx = [p2[0] doubleValue] - [p1[0] doubleValue];
            double dy = [p2[1] doubleValue] - [p1[1] doubleValue];
            length += sqrt(dx*dx + dy*dy);
        }

        // Enum-Wert aus Feature
        NSNumber *typeEnumNumber = feature[@"routeTypeEnum"];
        if (!typeEnumNumber) typeEnumNumber = @(DSARouteTypeWeg); // fallback

        // beidseitig
        if (!graph[begin]) graph[begin] = [NSMutableArray array];
        [graph[begin] addObject:@{@"target": end,
                                  @"length": @(length),
                                  @"coords": coordsArray,
                                  @"typeEnum": typeEnumNumber}];

        if (!graph[end]) graph[end] = [NSMutableArray array];
        NSArray *reversed = [[coordsArray reverseObjectEnumerator] allObjects];
        [graph[end] addObject:@{@"target": begin,
                                @"length": @(length),
                                @"coords": reversed,
                                @"typeEnum": typeEnumNumber}];
    }

    // 2. Dijkstra vorbereiten
    NSMutableDictionary<NSString *, NSNumber *> *distances = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSString *> *previous = [NSMutableDictionary dictionary];
    NSMutableSet<NSString *> *visited = [NSMutableSet set];
    NSMutableArray<NSString *> *queue = [NSMutableArray array];

    for (NSString *node in graph) {
        distances[node] = @(INFINITY);
        [queue addObject:node];
    }
    distances[startName] = @(0);

    while (queue.count > 0) {
        NSString *current = nil;
        double minDist = INFINITY;
        for (NSString *node in queue) {
            if ([distances[node] doubleValue] < minDist) {
                minDist = [distances[node] doubleValue];
                current = node;
            }
        }
        if (!current) break;

        [queue removeObject:current];
        [visited addObject:current];

        if ([current isEqualToString:destinationName]) break;

        for (NSDictionary *neighbor in graph[current]) {
            NSString *target = neighbor[@"target"];
            double edgeLength = [neighbor[@"length"] doubleValue];
            if ([visited containsObject:target]) continue;

            double newDist = [distances[current] doubleValue] + edgeLength;
            if (newDist < [distances[target] doubleValue]) {
                distances[target] = @(newDist);
                previous[target] = current;
            }
        }
    }

    // 3. Route rekonstruieren
    NSMutableArray<NSString *> *routeNodes = [NSMutableArray array];
    NSString *node = destinationName;
    while (node) {
        [routeNodes insertObject:node atIndex:0];
        node = previous[node];
    }

    if (routeNodes.count < 2) {
        NSLog(@"Keine Route von %@ nach %@ gefunden.", startName, destinationName);
        return nil;
    }

    // 4. Punkte und Typen sammeln
    NSMutableArray<NSValue *> *routePoints = [NSMutableArray array];
    NSMutableArray<NSNumber *> *routeTypes = [NSMutableArray array];

    for (NSInteger i = 0; i < routeNodes.count - 1; i++) {
        NSString *from = routeNodes[i];
        NSString *to = routeNodes[i+1];
        NSArray *edges = graph[from];
        NSDictionary *edge = nil;
        for (NSDictionary *e in edges) {
            if ([e[@"target"] isEqualToString:to]) {
                edge = e;
                break;
            }
        }
        if (!edge) continue;

        for (NSArray *coord in edge[@"coords"]) {
            NSPoint point = NSMakePoint([coord[0] doubleValue], [coord[1] doubleValue]);
            [routePoints addObject:[NSValue valueWithPoint:point]];
        }

        DSARouteType typeEnum = [edge[@"typeEnum"] integerValue];
        [routeTypes addObject:@(typeEnum)];
    }

    // 5. Distanzwerte berechnen
    CGFloat airDistance = [self airDistanceFrom:startName to:destinationName];
    CGFloat routeDistance = [self routeDistanceWithPoints:routePoints];

    // 6. Weganweisungen erstellen
    NSMutableArray<NSString *> *instructions = [NSMutableArray array];

    for (NSInteger i = 0; i < routeNodes.count - 1; i++) {
        NSString *to = routeNodes[i+1];
        NSArray *edges = graph[routeNodes[i]];
        NSDictionary *edge = nil;
        for (NSDictionary *e in edges) {
            if ([e[@"target"] isEqualToString:to]) {
                edge = e;
                break;
            }
        }
        if (!edge) continue;

        NSArray *coords = edge[@"coords"];
        NSMutableArray<NSValue *> *segmentPoints = [NSMutableArray array];
        for (NSArray *coord in coords) {
            NSPoint point = NSMakePoint([coord[0] doubleValue], [coord[1] doubleValue]);
            [segmentPoints addObject:[NSValue valueWithPoint:point]];
        }

        CGFloat miles = [self routeDistanceWithPoints:segmentPoints];

        // Enum in String übersetzen
        DSARouteType typeEnum = [edge[@"typeEnum"] integerValue];
        NSString *typeName = nil;
        switch (typeEnum) {
            case DSARouteTypeRS: typeName = @"der Reichsstraße"; break;
            case DSARouteTypeLS: typeName = @"der Landstraße"; break;
            case DSARouteTypeFaehre: typeName = @"der Fähre"; break;
            case DSARouteTypeGebirgspass: typeName = @"dem Gebirgspass"; break;
            case DSARouteTypeOffenesGelaende: typeName = @"dem offenen Gelände"; break;
            case DSARouteTypeWald: typeName = @"dem Wald"; break;
            case DSARouteTypeWeg: typeName = @"dem Weg"; break;
            default:
                NSLog(@"DSARoutePlanner findShortestPathFrom: error unknown DSARouteType aborting.");
                abort();
                break;
        }

        NSString *instruction = [NSString stringWithFormat:@"Folge %@ für %.2f Meilen bis %@.", typeName, miles, to];
        [instructions addObject:instruction];
    }

    // 7. Ergebnis erstellen
    DSARouteResult *result = [[DSARouteResult alloc] initWithPoints:routePoints
                                                       instructions:instructions
                                                        airDistance:airDistance
                                                      routeDistance:routeDistance];

    return result;
}
*/
-(CGFloat) airDistanceFrom: (NSString *) start to: (NSString *) destination
{
    DSALocation *startLocation = [[DSALocations sharedInstance] locationWithName: start ofType: @"global"];
    DSALocation *destinationLocation = [[DSALocations sharedInstance] locationWithName: destination ofType: @"global"];
  
    // Sicherstellen, dass beide Locations existieren
    if (!startLocation || !destinationLocation) {
        return 0.0;
    }
    
    // Pixelkoordinaten extrahieren
    NSInteger x1 = startLocation.mapCoordinate.x;
    NSInteger y1 = startLocation.mapCoordinate.y;
    
    NSInteger x2 = destinationLocation.mapCoordinate.x;
    NSInteger y2 = destinationLocation.mapCoordinate.y;
    
    // Abstand in Pixeln berechnen (Pythagoras)
    CGFloat deltaX = x2 - x1;
    CGFloat deltaY = y2 - y1;
    CGFloat distanceInPixels = sqrt(deltaX * deltaX + deltaY * deltaY);
    
    // Skalierung von Pixeln zu Meilen (basierend auf deinen Daten)
    CGFloat pixelsToMiles = SCALE_FACTOR; // mi/px
    
    CGFloat distanceInMiles = distanceInPixels * pixelsToMiles;
    
    NSLog(@"DSARoutePlanner airDistanceFrom: %@ to %@ in Miles: %.2f", start, destination, (float)distanceInMiles);
    
    return distanceInMiles;
}

-(CGFloat) routeDistanceWithPoints:(NSArray<NSValue *> *)routePoints
{
    if (!routePoints || routePoints.count < 2) {
        return 0.0;
    }
    
    CGFloat totalDistanceInPixels = 0.0;
    
    for (NSInteger i = 0; i < routePoints.count - 1; i++) {
        NSPoint p1 = [routePoints[i] pointValue];
        NSPoint p2 = [routePoints[i+1] pointValue];
        
        CGFloat deltaX = p2.x - p1.x;
        CGFloat deltaY = p2.y - p1.y;
        
        CGFloat segmentDistance = sqrt(deltaX * deltaX + deltaY * deltaY);
        totalDistanceInPixels += segmentDistance;
    }
    
    // Skalierung von Pixeln zu Meilen (wie bei der Luftlinie)
    CGFloat pixelsToMiles = SCALE_FACTOR; // mi/px
    CGFloat totalDistanceInMiles = totalDistanceInPixels * pixelsToMiles;
    NSLog(@"DSARoutePlanner routeDistanceWithPoints: in Miles: %.2f", (float) totalDistanceInMiles);
    return totalDistanceInMiles;
}

@end