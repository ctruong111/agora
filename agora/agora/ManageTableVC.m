//
//  ManageTableVC.m
//  agora
//
//  Created by Ethan Gates on 4/5/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import "ManageTableVC.h"
#import "ManageTableViewCell.h"

#import "DetailedPostViewController.h"
#import "ParseInterface.h"
#import "RootVC.h"
#import "UIColor+AGColors.h"

@interface ManageTableVC()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* postsArray;

@end

@implementation ManageTableVC

-(void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [ParseInterface getFromParse:@"USER" withSkip:0 completion:^(NSArray *result) {
        self.postsArray = [[NSMutableArray alloc]initWithArray:result];
        [[self tableView] reloadData];
    }];
    
}

- (IBAction)clickMenu:(id)sender {
    
    RootVC * root = (RootVC*)self.parentViewController.parentViewController;
    [root snapOpen];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.postsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ManageTableViewCell* tableCell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    
    Post* postForCell = [self.postsArray
                         objectAtIndex:indexPath.row];
        
    //[[tableCell image] setImage:[postForCell thumbnail]];
    tableCell.categoryBar.backgroundColor = [UIColor catColor:postForCell.category];
    tableCell.image.image = [postForCell thumbnail];
    tableCell.image.contentMode = UIViewContentModeScaleAspectFill;
    tableCell.image.clipsToBounds = YES;
    tableCell.title.text = [postForCell title];
    
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    DetailedPostViewController* detailPostView = [story instantiateViewControllerWithIdentifier:@"DetailedVC"];
    Post* postForPath = [[self postsArray] objectAtIndex:indexPath.row];
    
    postForPath = [ParseInterface getFromParseIndividual:postForPath.objectId];
    [detailPostView setPost:postForPath];
    
    [[self navigationController] pushViewController:detailPostView animated:YES];
}

@end
