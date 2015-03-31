//
//  ParseInterface.h
//  agora
//
//  Created by Cang Truong on 3/16/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface ParseInterface : NSObject
    + (NSArray*) browseKeyArray;
    + (void) saveNewPostToParse: (Post*) post;
    + (void) updateParsePost: (Post*) post;
    + (void) getFromParseIndividual: (NSString*) object_id completion:(void (^)(Post* result))block;
    + (void) getFromParse: (NSString*) parameter withSkip: (NSInteger) skip completion:(void (^)(NSArray* result))block;

@end