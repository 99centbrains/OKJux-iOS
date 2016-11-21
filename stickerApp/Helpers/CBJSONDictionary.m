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
    
    NSLog(@"JSON Recieved %@", url);
    
    jsonURL = url;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *myUrl = [NSURL URLWithString:url];
    ////
    
    NSURLRequest *request = [NSURLRequest requestWithURL:myUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30.0f];
    
    
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    [self parseResponse:data];

    
    if ([data length] >0){

       
       
    } else if ([data length] == 0 && connectionError == nil){


    } else if (connectionError != nil){
        
        
    }
    
//    NSLog(@"this never runs");
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:jsonQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if ([data length] >0 && connectionError == nil){
//            
//            [self parseResponse:data];
//            
//        } else if ([data length] == 0 && connectionError == nil){
//            
//            
//        } else if (connectionError != nil){
//            
//            
//        }
//
//    }];
    
    ///

//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
//    [urlRequest setTimeoutInterval:30.0f];
//    [urlRequest setHTTPMethod:@"GET"];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    
//    [NSURLConnection
//     sendAsynchronousRequest:urlRequest
//     queue:queue
//     completionHandler:^(NSURLResponse *response,
//                         NSData *data,
//                         NSError *error) {
//         if ([data length] >0 && error == nil){
//             
//             [self parseResponse:data];
//             
//         } else if ([data length] == 0 && error == nil){
//             
//             AppPrints = NO;
//
//         } else if (error != nil){
//             
//            AppPrints = NO;
//
//         }
//         
//     
//     }];
    
}

- (void)parseResponse:(NSData *)data {
    
    NSLog(@"Parse Response Data");
    
    NSError *error = nil;
    
    if (data == nil){
        NSLog(@"NO JSON DATA");
        
        
        
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
            
            NSLog(@"NEW JSON");
            
            
            
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
    
    } else {
        
        //NSLog(@"Something Went Wrong %@", [error localizedDescription]);
        
    }
    
}

- (void)downloadJSON
{
    NSString *jsonFILEPATH;
    NSString  *documentsDirectory = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
    
    //live json data url
    NSString *stringURL = jsonURL;
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    //attempt to download live data
    if (urlData) {
        //NSLog(@"Download Data");
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"catwangscheme.json"];
        //NSLog(@"Download Data, %@",filePath);
        
        [urlData writeToFile:filePath atomically:YES];
        jsonFILEPATH = filePath;
        
    } else {
        //file to write to
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"catwangscheme.json"];;
        
        //file to copy from
        NSString *json = [ [NSBundle mainBundle] pathForResource:@"json" ofType:@"json" inDirectory:@"html/data" ];
        NSData *jsonData = [NSData dataWithContentsOfFile:json options:kNilOptions error:nil];
        // NSLog(@"JSON %@", json);
        
        //write file to device
        [jsonData writeToFile:filePath atomically:YES];
        jsonFILEPATH = filePath;
    }
    
    NSLog(@"JSON DOWNLOADED %@", jsonFILEPATH);
    // [self parseLocalJSON:jsonFILEPATH];
    
    
}

- (void)parseOBJECT:(id)jsonObject{
    
    NSLog(@"PARSE *************************************");

    if (jsonObject){
        
        //NSLog(@"Parse Object");
        
        NSMutableArray *jsonContainer = [[NSMutableArray alloc] init];
    
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        //SET ASSET DIRECTORY
        _CBAssetsURL = [jsonDict objectForKey:@"bundle_url"];
        
        //NSLog(@"BundlesURL: %@", [jsonDict objectForKey:@"bundle_url"]);
        //NSLog(@"version: %@", [jsonDict objectForKey:@"version"]);
        
        NSArray *stickerBundles = (NSArray *)[jsonDict objectForKey:@"bundles"];
        NSLog(@"Store Contains %lu Bundles", (unsigned long)[stickerBundles count]);
        
        for (NSDictionary *bundle in stickerBundles){
        
            //ONLY ADD BUNDLES THAT HAVE LIVE FLAG
            if ([[bundle objectForKey:@"bundle_live"] boolValue]){
                
                [jsonContainer addObject:bundle];
                //[self addBundleDirectory:[bundle objectForKey:@"bundle_DIR"]];
                
            } else {
                
                //[self removeOldBundleDirectory:[bundle objectForKey:@"bundle_DIR"]];
                
            }
            
            
            
        }
        
        //NSLog(@"Bundles Available %lu", (unsigned long)[jsonContainer count]);
        _array_bundles = [jsonContainer copy];
        
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OH NO!" message:@"Yo something is broken. Quick turn off your phone!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"X", nil];
        [alert show];
        //NSLog(@"JSON PARSING ERROR");
        
    }
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    //NSLog(@"BUNDLES %@", _array_bundles);
    
}

- (void) removeOldBundleDirectory:(NSString *)bundleName{
    
    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
    //NSLog(@"OLD BUNDLES %@", bundleName);
    
    
    if ([FCFileManager existsItemAtPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]]){
        //NSLog(@"Create Bundle DIR %@", bundleN];
        
        [FCFileManager removeItemAtPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]];
        
    }

}

#pragma DIRECTORYOPERATIONS
- (void) addBundleDirectory:(NSString *)bundleName{
    //NSLog(@"Bundle Name %@", bundleName);
    
    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
    
   // NSLog(@"Documents DIR %@", documentsDIR);
    if (![FCFileManager existsItemAtPath:[documentsDIR stringByAppendingString:@"assets"]]){
        //NSLog(@"Create Assets DIR");
        [FCFileManager createDirectoriesForPath:[documentsDIR stringByAppendingString:@"assets"]];
        
    }
    
    if (![FCFileManager existsItemAtPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]]){
        //NSLog(@"Create Bundle DIR %@", bundleName);
        [FCFileManager createDirectoriesForPath:[[documentsDIR stringByAppendingString:@"assets/"] stringByAppendingString:bundleName]];
        
    }
    
    
    
}

- (NSString *)pathForAssetsDirectory {
    
    
    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
    
     //NSLog(@"Documents DIR %@", documentsDIR);
    if (![FCFileManager existsItemAtPath:[documentsDIR stringByAppendingString:@"assets"]]){
        //NSLog(@"Create Assets DIR");
        [FCFileManager createDirectoriesForPath:[documentsDIR stringByAppendingString:@"assets"]];
        
    }
    
    NSString *assetesDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/assets"];
    
    //NSLog(@"ALL ITEMS %@", [FCFileManager listItemsInDirectoryAtPath:assetesDIR deep:YES]);
    
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
///
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

//    NSLog(@"GET SOCIAL LINKS");
//    NSLog(@"Bundle ID %@", bundleID);
//    NSLog(@"packID ID %@", packID);
    
    NSDictionary *socialDictionary;
    
    NSDictionary *bundle = [self getPackFromBundleID:bundleID byPackID:packID];
        
    //NSLog(@"******** BUNDLE : %@", bundle);
    
    if ([bundle objectForKey:@"pack_social"]){
       
        //NSLog(@"Found Social Links");
        socialDictionary = [bundle objectForKey:@"pack_social"];
        //NSLog(@"Social Dictionary %@", socialDictionary);
    
    }
        
    

    return socialDictionary;
    
    
}

- (NSArray *) getPackIDs:(NSString *)bundleID{
    
    //NSLog(@"******************************** %@", bundleID);
   // NSLog(@"BundlePacks %@", [self getBundlePacksById:bundleID]);
    
    NSMutableArray *packIDs = [[NSMutableArray alloc] init];
    for (NSDictionary *bundle in [self getPacksFromBundleID:bundleID]){

        [packIDs addObject:[bundle objectForKey:@"pack_id"]];
        //NSLog(@"Pack IDs %@", [bundle objectForKey:@"pack_id"]);
        
    }
    
    return [packIDs copy];
    
}

- (NSDictionary *) getPackFromBundleID:(NSString *)bundleID byPackID:(NSString*)packID{
    
    NSDictionary* returnDict;
    
    for (NSDictionary* pack in [self getPacksFromBundleID:bundleID]){
//        
//        NSLog(@"PACKID %@", packID);
//        NSLog(@"ID %@", [pack objectForKey:@"pack_id"]);
//        NSLog(@"PACK %@ ****************", pack);
        
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
    NSLog(@"GET HEROS");
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
    

    //[localBundlePath stringByAppendingString:@"/heroImage.png"];
    
    
    //KILL FILES WITH 0 BITES
    if ([FCFileManager sizeOfItemAtPath:heroItemPath] == [NSNumber numberWithInt:0]){
        //NSLog(@"Image %@", [localBundlePath stringByAppendingString:@"/heroImage.png"]);
        //NSLog(@"FILE %@", [FCFileManager sizeOfItemAtPath:[localBundlePath stringByAppendingString:@"/heroImage.png"]]);
        [FCFileManager removeItemAtPath:heroItemPath];
        //return nil;
    }
    
    
    //CHECK IF FILE EXISTS
    if ([FCFileManager isFileItemAtPath:heroItemPath]){
        
        heroImageURL = [FCFileManager urlForItemAtPath:heroItemPath];
        callback(heroImageURL);
    
    } else {
    
        //NSLog(@"Download HERO");
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSLog(@"DOWNLOAD HERO");
            NSError *error;
            NSData* heroImageData = [NSData dataWithContentsOfURL:heroImageURL options:NSDataReadingUncached error:&error];

            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"DOWNLOADED");
                
                //NSString *localBundlePath = [[self pathForAssetsDirectory] stringByAppendingString:bPath];
                //NSString *heroItemPath = [NSString stringWithFormat:@"%@/%@_heroimage.png", localBundlePath, bundleName];
                
                [FCFileManager createFileAtPath:heroItemPath withContent:heroImageData];
                
                heroImageURL = [FCFileManager urlForItemAtPath:heroItemPath];
                callback(heroImageURL);
            
            });
            
        });
        
    }
    
    
}

- (NSString *)getBundleDirectoryByBundleID:(NSString *)bundleID{

    NSString *bundleDIR;
    //NSLog(@"BUNDLE DIR %@", bundleID);
    for (NSDictionary *bundle in _array_bundles){
        
        if ([[bundle objectForKey:@"bundle_id"] isEqualToString:bundleID]){
            bundleDIR = [bundle objectForKey:@"bundle_DIR"];
            //NSLog(@"BUNDLE DIR %@", bundleDIR);
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
    
    NSLog(@"************************* READ STICKERS");
    NSLog(@"ITEM COUNT:  %ld", (long)itemCount);
    NSLog(@"PACK DIR: %@", packDIRBuild);
   
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
    
    NSString * homeDIR = [[[CBJSONDictionary shared] pathForAssetsDirectory] stringByAppendingString:@"/"];
    //NSString * parentDIR = [homeDIR stringByAppendingString:@"stickers"];
    //NSString * packDIRBuild = [parentDIR stringByAppendingString:[@"/" stringByAppendingString:_fileDIR]];
    
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
    NSLog(@"PATH URL %@", packDIRBuild);

//    
//    return;
    
    
    //WRITE STICKERS
    for (NSURL *sticker in items){
        
        dispatch_queue_t queue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(queue, ^{
            
            NSError *error;
            
            NSURL *stickerURL = sticker;
            NSData* stickerData = [NSData dataWithContentsOfURL:stickerURL options:NSDataReadingUncached error:&error];
            
            NSString *stickerName = [[sticker absoluteString] stringByReplacingOccurrencesOfString:[pack objectForKey:@"pack_path"] withString:@""];
            
            //NSLog(@"Sticker %@", stickerURL);
            dispatch_async(dispatch_get_main_queue(), ^{
                
           
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
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
   // NSString * packDIRBuild = ;
    
    for (NSDictionary *packDict in packs){
        
        
        NSString *packDIR = [packDict objectForKey:@"pack_dir"];
        //NSString *packPath = [parentDIR stringByAppendingString:[@"/" stringByAppendingString:packDIR]];
        NSLog(@"PARENT DIR %@", parentDIR);
        
        for (NSString *filePath in [FCFileManager listFilesInDirectoryAtPath:parentDIR]){
            NSLog(@"PATH %@", filePath);

        }
        
        
    }
    
//     //NSString *packDIR = [pack objectForKey:@"pack_dir"];
//    for (NSString *packDIR in [pack objectForKey:@"pack_dir"]){
//        
//        NSLog(@"PackDIR %@", packDIR);
//    }
    
//    if (![FCFileManager existsItemAtPath:packDIRBuild]){
//        
//        //NSLog(@"Create Pack DIR %@", packDIRBuild);
//        [FCFileManager createDirectoriesForPath:packDIRBuild];
//        
//    }

}


- (void)getPackListJson:(NSData *)data {
    
    NSLog(@"Parse Response Data");
    
    
    
}


//- (UIImage *) lastCatwangImage{
//    
//    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
//    NSString *lastImage = [documentsDIR stringByAppendingString:@"last_userImage.png"];
//    UIImage *lastCWImage;
//    
//    //KILL FILES WITH 0 BITES
//    if ([FCFileManager sizeOfItemAtPath:lastImage] == [NSNumber numberWithInt:0]){
//        [FCFileManager removeItemAtPath:lastImage];
//        
//        return nil;
//        //return nil;
//    }
//    
//    
//    if ([FCFileManager isFileItemAtPath:lastImage]){
//        
//        //kNSLog(@"Local UserImage");
//        lastCWImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FCFileManager urlForItemAtPath:lastImage]]];
//        
//        
//    } else {
//        
//        return nil;
//        
//    }
//    
//    return lastCWImage;
//    
//}
//
//
//- (void) saveLastCatwangImage:(UIImage *)image{
//    
//    
//    NSString *documentsDIR = [[FCFileManager pathForCachesDirectory] stringByAppendingString:@"/"];
//    NSString *lastImage = [documentsDIR stringByAppendingString:@"last_userImage.png"];
//    
//    
//    if ([FCFileManager isFileItemAtPath:lastImage]){
//        
//        [FCFileManager removeItemAtPath:lastImage];
//        
//    }
//    
//    
//    NSData *imageData = UIImagePNGRepresentation(image);
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [FCFileManager createFileAtPath:lastImage withContent:imageData];
//        
//    });
//    
//}





#pragma PARSE DATA
- (void) parse_trackAnalytic:(NSDictionary *)data forEvent:(NSString *)event {
    [PFAnalytics trackEvent:event dimensions:data];
}




@end
