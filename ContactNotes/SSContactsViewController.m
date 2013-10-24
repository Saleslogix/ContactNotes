//
//  SSViewController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/15/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSContactsViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SSSDataManager.h"
#import "SSContactOverviewCell.h"
#import "SSContact.h"
#import "SSContactDetailsViewController.h"
#import "SSAppController.h"
#import "SSUserDefaults.h"


@interface SSContactsViewController ()

@property (nonatomic, copy) NSArray *contacts;

@end


@implementation SSContactsViewController
{
    BOOL _firstAppearance;
}

@synthesize applicationController, sDataManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = UIRefreshControl.new;
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    _firstAppearance = YES;
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_firstAppearance)
    {
        _firstAppearance = NO;
        [self.refreshControl beginRefreshing];
        [self refresh];
    }
}

- (void)refresh
{
    [self.sDataManager loadContactsWithCompletion:^(NSArray *contacts, NSError *error) {
        if (!error)
        {
            self.contacts = contacts;
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSContactOverviewCell *cell = (SSContactOverviewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    SSContact *contact = self.contacts[indexPath.row];
    cell.contactNameLabel.text = contact.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.applicationController showDetailsForContact:self.contacts[indexPath.row]];
}

- (IBAction)logOff:(id)sender
{
    [self.applicationController logOff];
}

@end
