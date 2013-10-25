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


@interface SSContactsViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, copy) NSArray *contacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

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
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", nil) maskType:SVProgressHUDMaskTypeClear];
        
        _firstAppearance = NO;
        [self.refreshControl beginRefreshing];
        [self refresh];
    }
}

- (void)refresh
{
    [self.sDataManager loadContactsWithCompletion:^(NSArray *contacts, NSError *error) {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error", nil)];
        }
        else
        {
            self.contacts = contacts;
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return self.filteredContacts.count;
    }
    
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSContactOverviewCell *cell = (SSContactOverviewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    
    SSContact *contact = self.contacts[indexPath.row];
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        contact = self.filteredContacts[indexPath.row];
    }
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

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@", @keypath(((SSContact *)nil), name), searchText];
    self.filteredContacts = [self.contacts filteredArrayUsingPredicate:searchPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:controller.searchBar.scopeButtonTitles[controller.searchBar.selectedScopeButtonIndex]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:controller.searchBar.text scope:controller.searchBar.scopeButtonTitles[searchOption]];
    
    return YES;
}

@end
