//
//  ParseInterface.m
//  agora
//
//  Created by Cang Truong on 3/16/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import <Parse/Parse.h>
#import "ParseInterface.h"

@implementation ParseInterface

+ (NSArray*) browseKeyArray {
    return @[@"objectId", @"title", @"category", @"price", @"createdBy", @"description"];
}

+ (void) saveNewPostToParse: (Post*) post completion:(void (^)(BOOL succeeded))block{
    //Saving an image to Parse
    
    PFObject *parsePost = [PFObject objectWithClassName:@"Posts"];
    
    //Changing header image to PFFile for storage in Parse
    NSData *imageData = UIImageJPEGRepresentation(post.headerPhoto, 1.0);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    
    //Converting secondary photos to PFFile
    NSMutableArray *PFFileArray = [NSMutableArray array];
    for (UIImage *image in post.photosArray) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
        [PFFileArray addObject:[PFFile fileWithData: imageData]];
    }
    
    parsePost[@"picture"] = imageFile;
    parsePost[@"pictures"] = PFFileArray;
    parsePost[@"createdBy"] = [PFUser currentUser];
    parsePost[@"title"] = post.title;
    parsePost[@"description"] = post.itemDescription;
    parsePost[@"category"] = post.category;
    if (post.stringTags != nil) {
        parsePost[@"tags"] = post.stringTags;
    }
    if (post.price != nil) {
        parsePost[@"price"] = post.price;
    }
    
    [parsePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(block)
            block(succeeded);
    }];
}

+ (void) updateParsePost: (Post*) post completion:(void (^)(BOOL succeeded))block{
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    
    [query whereKey:@"objectId" equalTo: post.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSLog(@"OBJECT FOUND");
            NSData *image = UIImageJPEGRepresentation(post.headerPhoto, 1.0);
            PFFile *imageFile = [PFFile fileWithData:image];
            
            [object setObject: post.title forKey:@"title"];
            [object setObject: post.title forKey:@"description"];
            [object setObject: post.title forKey:@"category"];
            [object setObject: imageFile forKey:@"photo"];
            [object setObject: post.stringTags forKey:@"tags"];
            [object setObject: post.price forKey:@"price"];
            [object setObject: [PFUser currentUser] forKey:@"createdBy"];
            
            [object saveInBackground];
            NSLog(@"OBJECT UPDATED!");
            if(block)
                block(YES);
        } else {
            NSLog(@"UPDATE: NO OBJECT FOUND");
            if(block)
                block(NO);
        }
    }];
}

+ (Post*) getFromParseIndividual: (NSString*) object_id {
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    Post *post = [[Post alloc]init];
    
    [query includeKey:@"createdBy"];
    
    PFObject *object = [query getObjectWithId:object_id];
    
    NSLog(@"Retrieved Data");
    
    PFUser *user = [object objectForKey:@"createdBy"];
    
    post.title = [object objectForKey:@"title"];
    post.itemDescription = [object objectForKey:@"description"];
    post.category = [object objectForKey:@"category"];
    post.price = [object objectForKey:@"price"];
    post.objectId = [object objectId];
    post.creatorFacebookId = [user objectForKey:@"facebookId"];
    
    return post;
}

+ (void) getFromParse: (NSString*) parameter withSkip: (NSInteger) skip completion:(void (^)(NSArray* result))block;{
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    NSMutableArray *postArray = [NSMutableArray array];

    if ([parameter isEqual: @"RECENTS"]) { //Getting most recent posts
        [query setSkip:skip];
        [query setLimit:20];
        [query includeKey:@"createdBy"];
        [query selectKeys: [ParseInterface browseKeyArray]];
        [query orderByAscending:@"createdAt"];
        
    } else if ([parameter isEqual:@"USER"]) { //Getting the user's posts
        [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
        [query selectKeys: [ParseInterface browseKeyArray]];
        [query includeKey:@"createdBy"];
        
    } else { //Getting the post by category
        [query setSkip:skip];
        [query setLimit:20];
        [query includeKey:@"createdBy"];
        [query selectKeys: [ParseInterface browseKeyArray]];
        [query whereKey:@"category" equalTo:parameter];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_group_async(group, bg_queue, ^{
            for(PFObject* object in objects) {
                Post *post = [[Post alloc] init];
                PFUser *user = [object objectForKey:@"createdBy"];

                post.title = [object objectForKey:@"title"];
                post.price = [object objectForKey:@"price"];
                post.itemDescription = [object objectForKey:@"description"];
                post.category = [object objectForKey:@"category"];
                post.objectId = object.objectId;
                post.creatorFacebookId = [user objectForKey:@"facebookId"];
                
                [postArray addObject:post];
            }
        });
        //when done do this
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if(block)
                block(postArray);
        });
    }];
}

+ (void) deleteFromParse: (NSString*) object_id {
    PFObject *object = [PFObject objectWithoutDataWithClassName:@"Posts" objectId: object_id];
    
    [object deleteEventually];
}

// http://orion98mc.blogspot.com/2012/08/on-ios-uiimage-decompression-nightmare.html
NS_INLINE void forceImageDecompression(UIImage *image) {
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, CGImageGetWidth(imageRef) * 4, colorSpace,kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context) { NSLog(@"Could not create context for image decompression"); return; }
    CGContextDrawImage(context, (CGRect){{0.0f, 0.0f}, {CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}}, imageRef);
    CFRelease(context);
}

+(void) getHeaderPhoto: (NSString*) object_id completion: (void(^)(UIImage* result))block; {
    PFQuery* query = [PFQuery queryWithClassName:@"Posts"];
    [query selectKeys:@[@"picture"]];
    
    [query getObjectInBackgroundWithId:object_id block:^(PFObject *object, NSError *error) {
        PFFile* file = [object objectForKey:@"picture"];
        NSMutableArray* container = [[NSMutableArray alloc] init];
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_group_async(group, bg_queue, ^{
            if(block){
                UIImage* image = [UIImage imageWithData:[file getData]];
                forceImageDecompression(image);
                [container addObject:image];
            }
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if(block)
                block([container objectAtIndex:0]);
        });
    }];
}

+ (void) getThumbnail: (NSString*) object_id completion: (void (^)(UIImage* result))block; {
    PFQuery* query = [PFQuery queryWithClassName:@"Posts"];
    [query selectKeys:@[@"thumbnail" ]];
    
    [query getObjectInBackgroundWithId:object_id block:^(PFObject *object, NSError *error) {
        PFFile* file = [object objectForKey:@"thumbnail"];
        NSMutableArray* container = [[NSMutableArray alloc] init];
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_group_async(group, bg_queue, ^{
            if(block){
                UIImage* image = [UIImage imageWithData:[file getData]];
                forceImageDecompression(image);
                [container addObject:image];
            }
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if(block)
                block([container objectAtIndex:0]);
        });
    }];
}

+ (void) getPhotosArrayWithObjectID:(NSString*)objectID completion:(void (^)(NSArray* result))block{
    NSMutableArray *photosArray = [[NSMutableArray alloc] init];
    
    PFQuery* query = [PFQuery queryWithClassName:@"Posts"];
    [query selectKeys:@[@"pictures"]];
    [query getObjectInBackgroundWithId:objectID block:^(PFObject *object, NSError *error) {
        NSArray* picturesPFFileArray = [object objectForKey:@"pictures"];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_group_async(group, bg_queue, ^{
            for (PFFile *picture in picturesPFFileArray) {
                [photosArray addObject:[UIImage imageWithData:[picture getData]]];
            }
        });
        //when done do this
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if(block)
                block(photosArray);
        });
    }];
}
@end
