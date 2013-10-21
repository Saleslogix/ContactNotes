//
//  SSViewController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/15/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SSSDataManager.h"
#import "SSContactOverviewCell.h"
#import "SSContact.h"
#import "SSContactDetailViewController.h"


@interface SSViewController ()

@property (nonatomic, copy) NSArray *contacts;

@end


@implementation SSViewController
{
    BOOL _firstAppearance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = UIRefreshControl.new;
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(downloadCompleted:) name:SSDataManagerDownloadDidComplete object:SSSDataManager.sharedManager];
    _firstAppearance = YES;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:SSDataManagerDownloadDidComplete object:nil];
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
    [SSSDataManager.sharedManager downloadContacts];
}

- (void)downloadCompleted:(NSNotification *)note
{
    self.contacts = note.userInfo[SSDataManagerContactsKey];
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"details"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        SSContactDetailViewController *detailController = (SSContactDetailViewController *)segue.destinationViewController;
        detailController.contact = self.contacts[indexPath.row];
    }
}

@end
