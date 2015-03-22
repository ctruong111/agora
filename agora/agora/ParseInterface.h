//
//  ParseInterface.h
//  agora
//
//  Created by Cang Truong on 3/16/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseInterface : NSObject
    + (NSArray*) browseKeyArray;
    - (void) saveNewPostToParse: (Post*) post;
    - (Post*) getFromParseIndividual: (NSString*) object_id;
    - (NSArray*) getFromParseListByCategory: (NSString*) category AndSkipBy: (NSInteger) skip;
    - (NSArray*) getFromParseListRecents: (NSInteger) skip;
@end