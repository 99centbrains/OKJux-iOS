//
//  CBAppConfig.m
//  ShellSticker
//
//  Created by Philip Ybay on 5/8/14.
//  Copyright (c) 2014 99centbrains. All rights reserved.
//

#import "CBJSONDictionary.h"
#import "FCFileManager.h"

@implementation CBJSONDictionary

@synthesize jsonURL;

static CBJSONDictionary * _shared;

+ (CBJSONDictionary *)shared {
    if (_shared != nil) {
        return _shared;
    }
    _shared = [[CBJSONDictionary alloc] init];
    
    return _shared;
}


- (void)getJSON:(NSString *)url {
    jsonURL = url;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *myUrl = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:myUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30.0f];
    
    
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    [self parseResponse:data];
}

- (void)parseResponse:(NSData *)data {
    NSError *error = nil;
    
    if (data == nil){
        NSString  *documentsDirectory = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"catwangscheme.json"];
        NSData *jsonDownloadedData = [NSData dataWithContentsOfFile:filePath];
        
        if (jsonDownloadedData){
            id jsonObjecter = [NSJSONSerialization
                               JSONObjectWithData:jsonDownloadedData
                               options:NSJSONReadingAllowFragments
                               error:&error];
            [self parseOBJECT:jsonObjecter];
        } else {
            //SET Json Versions
            [[NSUserDefaults standardUserDefaults] setFloat:0.0f forKey:@"JSONVERSIONS"];
            [self parseResponse:data];
        }
        return ;
    }

    //JSON OBJECT
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:NSJSONReadingAllowFragments
                     error:&error];

    if (jsonObject != nil && error == nil){
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSLog(@"JSON Version %@", [jsonDict objectForKey:@"version"]);
        
        //CHECK if Version is NEW
        if ([[jsonDict objectForKey:@"version"] floatValue] >
            [[NSUserDefaults standardUserDefaults] floatForKey:@"JSONVERSIONS"] ||
            ![[NSUserDefaults standardUserDefaults] floatForKey:@"JSONVERSIONS"]) {
            
            //NSLog(@"New Json File");
            [self parseOBJECT:jsonObject];
            [self removeHEROImagesALL];
            
            //SET Json Versions
            [[NSUserDefaults standardUserDefaults]
             setFloat:[[jsonDict objectForKey:@"version"] floatValue]
             forKey:@"JSONVERSIONS"];
            
            NSLog(@"FLOAT %@", [jsonDict objectForKey:@"version"]);
            
            //Download
            [self downloadJSON];
        //USE OLD JSON
        } else {
            NSLog(@"Use Old Json");
            NSString  *documentsDirectory = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"catwangscheme.json"];
            NSData *jsonDownloadedData = [NSData dataWithContentsOfFile:filePath];

            if (jsonDownloadedData){
                id jsonObjecter = [NSJSONSerialization
                                   JSONObjectWithData:jsonDownloadedData
                                   options:NSJSONReadingAllowFragments
                                   error:&error];
                [self parseOBJECT:jsonObjecter];
                
            } else {
                //SET Json Versions
                [[NSUserDefaults standardUserDefaults] setFloat:0.0f forKey:@"JSONVERSIONS"];
                [self parseResponse:data];
            }
        }
    }
}

- (void)downloadJSON {
    NSString *jsonFILEPATH;
    NSString  *documentsDirectory = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
    
    //live json data url
    NSString *stringURL = jsonURL;
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    //attempt to download live data
    if (urlData) {
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"catwangscheme.json"];
        
        [urlData writeToFile:filePath atomically:YES];
        jsonFILEPATH = filePath;
        
    } else {
        //file to write to
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"catwangscheme.json"];;
        
        //file to copy from
        NSString *json = [ [NSBundle mainBundle] pathForResource:@"json" ofType:@"json" inDirectory:@"html/data" ];
        NSData *jsonData = [NSData dataWithContentsOfFile:json options:kNilOptions error:nil];

        //write file to device
        [jsonData writeToFile:filePath atomically:YES];
        jsonFILEPATH = filePath;
    }
}

- (void)parseOBJECT:(id)jsonObject{
    if (jsonObject){
        NSMutableArray *jsonContainer = [[NSMutableArray alloc] init];
    
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        //SET ASSET DIRECTORY
        _CBAssetsURL = [jsonDict objectForKey:@"bundle_url"];
        
        NSArray *stickerBundles = (NSArray *)[jsonDict objectForKey:@"bundles"];
        NSLog(@"Store Contains %lu Bundles", (unsigned long)[stickerBundles count]);
        
        for (NSDictionary *bundle in stickerBundles){
            //ONLY ADD BUNDLES THAT HAVE LIVE FLAG
            if ([[bundle objectForKey:@"bundle_live"] boolValue]){
                [jsonContainer addObject:bundle];
            }
        }

        _array_bundles = [jsonContainer copy];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OH NO!" message:@"Yo something is broken. Quick turn off your phone!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"X", nil];
        [alert show];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) removeOldBundleDirectory:(NSString *)bundleName{
    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
    
    if ([FCFileManager existsItemAtPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]]){
        [FCFileManager removeItemAtPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]];
    }
}

#pragma DIRECTORYOPERATIONS
- (void) addBundleDirectory:(NSString *)bundleName{
    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];

    if (![FCFileManager existsItemAtPath:[documentsDIR stringByAppendingString:@"assets"]]){
        [FCFileManager createDirectoriesForPath:[documentsDIR stringByAppendingString:@"assets"]];
    }
    
    if (![FCFileManager existsItemAtPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]]){
        [FCFileManager createDirectoriesForPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]];
    }
}

- (NSString *)pathForAssetsDirectory {
    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];

    if (![FCFileManager existsItemAtPath:[documentsDIR stringByAppendingString:@"assets"]]){
        [FCFileManager createDirectoriesForPath:[documentsDIR stringByAppendingString:@"assets"]];
    }
    
    NSString *assetesDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/assets"];

    return assetesDIR;
}

#pragma IAP IDS

- (NSArray *) getAllPackIDs{
    NSMutableArray *bundleMeta = [[NSMutableArray alloc] init];
    for (NSDictionary *bundle in _array_bundles){
        NSArray *packIDs = [self getPackIDs:[bundle objectForKey:@"bundle_id"]];
        [bundleMeta addObjectsFromArray:packIDs];
    }

    return [bundleMeta copy];
}

#pragma OPERATIONS
- (NSDictionary *)getBundleNameID{
    NSMutableDictionary *bundledict = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *b in _array_bundles){
        [bundledict setObject:[b objectForKey:@"bundle_name"] forKey:[b objectForKey:@"bundle_id"]];
    }
    
    return [bundledict copy];
}

- (NSArray *) getBundleIDs{
    NSMutableArray *bundleMeta = [[NSMutableArray alloc] init];
    for (NSDictionary *bundle in _array_bundles){
        [bundleMeta addObject:[bundle objectForKey:@"bundle_id"]];
    }
    
    return [bundleMeta copy];
}

- (NSArray *) getPacksFromBundleID:(NSString *)bundleID{
    NSMutableArray *packs = [[NSMutableArray alloc] init];
    for (NSDictionary *bundle in _array_bundles){
        if ([[bundle objectForKey:@"bundle_id"] isEqualToString:bundleID]){
            packs = [bundle objectForKey:@"bundle_packs"];
        }
    }
    
    return [packs copy];
}



#pragma PACK Info


- (NSDictionary *) getSocialLinksFromPackID:(NSString *)bundleID byPackID:(NSString*)packID{
    NSDictionary *socialDictionary;
    
    NSDictionary *bundle = [self getPackFromBundleID:bundleID byPackID:packID];
    
    if ([bundle objectForKey:@"pack_social"]){
        socialDictionary = [bundle objectForKey:@"pack_social"];
    }

    return socialDictionary;
}

- (NSArray *) getPackIDs:(NSString *)bundleID{
    NSMutableArray *packIDs = [[NSMutableArray alloc] init];
    for (NSDictionary *bundle in [self getPacksFromBundleID:bundleID]){
        [packIDs addObject:[bundle objectForKey:@"pack_id"]];
    }
    return [packIDs copy];
}

- (NSDictionary *) getPackFromBundleID:(NSString *)bundleID byPackID:(NSString*)packID{
    NSDictionary* returnDict;
    
    for (NSDictionary* pack in [self getPacksFromBundleID:bundleID]){
        if ([[pack objectForKey:@"pack_id"] isEqualToString:packID]){
            returnDict = pack;
        }
    }
    return returnDict;
}

- (void) removeHEROImagesALL{
    NSString *bPath = [@"/" stringByAppendingString:@"bundles"];
    NSString *localBundlePath = [[self pathForAssetsDirectory] stringByAppendingString:bPath];
    
    NSLog(@"REMOVE DIR %@", localBundlePath);
    //CHECK IF FILE EXISTS
    if ([FCFileManager isDirectoryItemAtPath:localBundlePath]){
        [FCFileManager removeItemAtPath:localBundlePath];
    }
}

- (void) getBundleHeroImageFromID:(NSString *)bundleID withReturn:(void (^)(NSURL * heroURL))callback{
    // GET URL
    __block NSURL *heroImageURL;
    NSString *bPath;
    NSString *bundleName;
   
    for (NSDictionary *bundle in _array_bundles){
        if ([[bundle objectForKey:@"bundle_id"] isEqualToString:bundleID]){
            heroImageURL = [NSURL URLWithString:[bundle objectForKey:@"bundle_hero"]];
            bundleName = [bundle objectForKey:@"bundle_DIR"];
            bPath = [@"/" stringByAppendingString:@"bundles"];
        }
    }
    
    //BUILD PATH
    NSString *localBundlePath = [[self pathForAssetsDirectory] stringByAppendingString:bPath];
    NSString *heroItemPath = [NSString stringWithFormat:@"%@/%@_heroimage.png", localBundlePath, bundleName];

    if (![FCFileManager isDirectoryItemAtPath:localBundlePath]){
        NSLog(@"Make DIR for Bundle %@", localBundlePath);
        [FCFileManager createDirectoriesForPath:localBundlePath];
    }

    //KILL FILES WITH 0 BITES
    if ([FCFileManager sizeOfItemAtPath:heroItemPath] == [NSNumber numberWithInt:0]){
        [FCFileManager removeItemAtPath:heroItemPath];
    }
    
    //CHECK IF FILE EXISTS
    if ([FCFileManager isFileItemAtPath:heroItemPath]){
        heroImageURL = [FCFileManager urlForItemAtPath:heroItemPath];
        callback(heroImageURL);
    } else {
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSError *error;
            NSData* heroImageData = [NSData dataWithContentsOfURL:heroImageURL options:NSDataReadingUncached error:&error];

            dispatch_sync(dispatch_get_main_queue(), ^{
                [FCFileManager createFileAtPath:heroItemPath withContent:heroImageData];
                
                heroImageURL = [FCFileManager urlForItemAtPath:heroItemPath];
                callback(heroImageURL);
            });
        });
    }
}

- (NSString *)getBundleDirectoryByBundleID:(NSString *)bundleID{
    NSString *bundleDIR;
    for (NSDictionary *bundle in _array_bundles){
        if ([[bundle objectForKey:@"bundle_id"] isEqualToString:bundleID]){
            bundleDIR = [bundle objectForKey:@"bundle_DIR"];
        }
    }
    return bundleDIR;
}

    
- (NSArray *) getPackForPackID:(NSDictionary *)pack withID:(NSString *)packID byBundleID:(NSString *)bundleID{
    NSMutableArray *stickerPackList = [[NSMutableArray alloc] init];
    
    NSString *packDIR = [pack objectForKey:@"pack_dir"];
    
    NSString * homeDIR = [[self pathForAssetsDirectory] stringByAppendingString:@"/"];
    NSString * parentDIR = [homeDIR stringByAppendingString:@"stickers"];
    NSString * packDIRBuild = [parentDIR stringByAppendingString:[@"/" stringByAppendingString:packDIR]];

    NSString *packCount = [packID stringByAppendingString:@"_count"];
    NSInteger itemCount = [[NSUserDefaults standardUserDefaults] integerForKey:packCount];
    
    if (kJsonDebug){
        itemCount = 0;
    }

    if (itemCount == 0){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:packCount];
    }
   
    if (itemCount != [[FCFileManager listFilesInDirectoryAtPath:packDIRBuild] count]){
        NSLog(@"ERROR: storage count %lu", (unsigned long)[[FCFileManager listFilesInDirectoryAtPath:packDIRBuild] count]);
        [FCFileManager removeItemAtPath:packDIRBuild];
        return nil;
    } else {
        //For items in Directory
        for (NSString *item in [FCFileManager listFilesInDirectoryAtPath:packDIRBuild]){
            NSLog(@"Image %@", [FCFileManager sizeOfItemAtPath:item]);
            
            if ([FCFileManager sizeOfItemAtPath:item] <= [NSNumber numberWithInteger:0]){
                NSLog(@"Image DEAD %@", item);
                NSLog(@"SIZE: %@", [FCFileManager sizeOfItemAtPath:item]);
                [FCFileManager removeItemAtPath:item];
                return nil;
            } else {
                [stickerPackList addObject:[FCFileManager urlForItemAtPath:item]];
            }
        }
        
        if ([[FCFileManager listFilesInDirectoryAtPath:packDIRBuild] count] < itemCount){
            return nil;
        }
    }
    return [stickerPackList copy];
}

- (void) writeImageData:(NSData *)imgData toDirectory:(NSString *)directory{
    NSLog(@"FILE WRITE %@", directory);
    [FCFileManager createFileAtPath:directory withContent:imgData];
}

- (void) writeStickersPack:(NSDictionary *)pack fromBundle:(NSString *)bundleID withSticker:(NSArray *)items{
    NSLog(@"************************* WRITE STICKERS");
    NSString *packDIR = [pack objectForKey:@"pack_dir"];

    //BUILD DIRECTORY FOR DOWNLOAD
    NSString * homeDIR = [[self pathForAssetsDirectory] stringByAppendingString:@"/"];
    NSString * parentDIR = [homeDIR stringByAppendingString:@"stickers"];
    NSString * packDIRBuild = [parentDIR stringByAppendingString:[@"/" stringByAppendingString:packDIR]];

    //IF NO DIR MAKE ONE
    if (![FCFileManager existsItemAtPath:packDIRBuild]){
        [FCFileManager createDirectoriesForPath:packDIRBuild];
    }

    //WRITE STICKERS
    for (NSURL *sticker in items){

        dispatch_queue_t queue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(queue, ^{
            NSError *error;
            NSURL *stickerURL = sticker;
            NSData* stickerData = [NSData dataWithContentsOfURL:stickerURL options:NSDataReadingUncached error:&error];
            NSString *stickerName = [[sticker absoluteString] stringByReplacingOccurrencesOfString:[pack objectForKey:@"pack_path"] withString:@""];
            dispatch_async(dispatch_get_main_queue(), ^{
                [FCFileManager createFileAtPath:[packDIRBuild stringByAppendingString:[NSString
                                                                                       stringWithFormat:@"/%@", stickerName]] withContent:stickerData];
                NSLog(@"wrote item to %@", packDIRBuild);
            });
        });

        NSInteger itemCount = [items count];

        NSString *packCount = [[pack objectForKey:@"pack_id"] stringByAppendingString:@"_count"];
        [[NSUserDefaults standardUserDefaults] setInteger:itemCount forKey:packCount];
    }
}

- (void) removeOldPackDIRS:(NSString *)bundle{


    NSArray *packs = [self getPacksFromBundleID:bundle];

    NSString * homeDIR = [[self pathForAssetsDirectory] stringByAppendingString:@"/"];
    NSString * parentDIR = [homeDIR stringByAppendingString:[self getBundleDirectoryByBundleID:bundle]];

    for (NSDictionary *packDict in packs){
        NSString *packDIR = [packDict objectForKey:@"pack_dir"];
        NSLog(@"PARENT DIR %@", parentDIR);

        for (NSString *filePath in [FCFileManager listFilesInDirectoryAtPath:parentDIR]){
            NSLog(@"PATH %@", filePath);
        }
    }
}


- (void)getPackListJson:(NSData *)data {
    
    NSLog(@"Parse Response Data");
    
    
    
}


@end
