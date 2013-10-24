//
//  SSContactDetailViewController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/17/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSContactDetailsViewController.h"
#import "SSContact.h"
#import "SSAddress.h"
#import "SSNote.h"
#import <AddressBookUI/AddressBookUI.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import "SSContactNotesViewController.h"
#import "SSSDataManager.h"
#import "SSAppController.h"
#import "UIView+SSHelpers.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>


typedef NS_ENUM(NSUInteger, SSDetailSection)
{
    SSDetailSectionDetails = 0,
    SSDetailSectionNotes,
    SSDetailSectionCount
};

typedef NS_ENUM(NSUInteger, SSDetailRow)
{
    SSDetailRowName = 0,
    SSDetailRowPhone,
    SSDetailRowEmail,
    SSDetailRowAddress,
    SSDetailRowCount
};


@interface SSContactDetailsViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end


@implementation SSContactDetailsViewController
{
    NSInteger _detailRowCount;
    NSUInteger _detailRowMap[SSDetailRowCount];
}

@synthesize applicationController, sDataManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateContent];
    [self.sDataManager loadNotesForContact:self.contact completion:nil];
}

- (void)dealloc
{
    [self.contact removeObserver:self forKeyPath:@keypath(self.contact, notes)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@keypath(self.contact, notes)])
    {
        NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        
        if (kind == NSKeyValueChangeSetting)
        {
            [self.tableView reloadData];
        }
        else
        {
            NSMutableArray *insertIndexes = NSMutableArray.array;
            NSMutableArray *deleteIndexes = NSMutableArray.array;
            NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
            if (kind == NSKeyValueChangeInsertion)
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:SSDetailSectionNotes];
                    if (kind == NSKeyValueChangeInsertion)
                    {
                        [insertIndexes addObject:indexPath];
                    }
                    else if (kind == NSKeyValueChangeRemoval)
                    {
                        [deleteIndexes addObject:indexPath];
                    }
                    else if (kind == NSKeyValueChangeReplacement)
                    {
                        [insertIndexes addObject:indexPath];
                        [deleteIndexes addObject:indexPath];
                    }
                }];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:deleteIndexes withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView insertRowsAtIndexPaths:insertIndexes withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
    }
}

- (void)setContact:(SSContact *)contact
{
    [self.contact removeObserver:self forKeyPath:@keypath(self.contact, notes)];
    _contact = contact;
    [self.contact addObserver:self forKeyPath:@keypath(self.contact, notes) options:NSKeyValueObservingOptionOld context:NULL];
    [self updateContent];
}

- (void)updateContent
{
    if (!self.contactNameLabel) return;
    
    self.contactNameLabel.text = [self.contact.name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    self.addressLabel.text = [self stringFromAddress];
    self.emailLabel.text = [self.contact.email stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    
    NSError *error = nil;
    NBPhoneNumber *phone = [NBPhoneNumberUtil.sharedInstance parse:self.contact.mobile defaultRegion:@"US" error:&error];
    self.phoneLabel.text = phone ? [NBPhoneNumberUtil.sharedInstance format:phone numberFormat:NBEPhoneNumberFormatNATIONAL error:&error] : nil;
    
    [self updateDetailsMap];
}

- (void)updateDetailsMap
{
    unsigned logicalRowIndex = 0;
    for (unsigned physicalRowIndex = 0; physicalRowIndex < SSDetailRowCount; ++physicalRowIndex)
    {
        if (physicalRowIndex == SSDetailRowEmail && !self.emailLabel.text.length) continue;
        if (physicalRowIndex == SSDetailRowPhone && !self.phoneLabel.text.length) continue;
        _detailRowMap[logicalRowIndex++] = physicalRowIndex;
    }
    _detailRowCount = logicalRowIndex;
    
    [self.tableView reloadData];
}

- (NSIndexPath *)adjustIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != SSDetailSectionDetails)
    {
        return indexPath;
    }
    
    return [NSIndexPath indexPathForRow:_detailRowMap[indexPath.row] inSection:indexPath.section];
}

- (NSString *)stringFromAddress
{
    return ABCreateStringWithAddressDictionary(self.addressDictionary, NO);
}

- (NSDictionary *)addressDictionary
{
    NSMutableDictionary *mutableAddressComponents = [NSMutableDictionary dictionary];
    
    if (self.contact.address.address1) {
        [mutableAddressComponents setValue:self.contact.address.address1 forKey:(__bridge NSString *)kABPersonAddressStreetKey];
    }
    
    if (self.contact.address.city) {
        [mutableAddressComponents setValue:self.contact.address.city forKey:(__bridge NSString *)kABPersonAddressCityKey];
    }
    
    if (self.contact.address.state) {
        [mutableAddressComponents setValue:self.contact.address.state forKey:(__bridge NSString *)kABPersonAddressStateKey];
    }
    
    if (self.contact.address.postalCode) {
        [mutableAddressComponents setValue:self.contact.address.postalCode forKey:(__bridge NSString *)kABPersonAddressZIPKey];
    }
    
    [mutableAddressComponents setValue:[NSLocale.currentLocale objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
    
    return mutableAddressComponents;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SSDetailSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SSDetailSectionDetails)
    {
        return _detailRowCount;
    }
    else if (section == SSDetailSectionNotes)
    {
        return self.contact.notes.count;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != SSDetailSectionNotes)
    {
        return [super tableView:tableView cellForRowAtIndexPath:[self adjustIndexPath:indexPath]];
    }
    
    static NSString *notesCellId = @"notesCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notesCellId];
    if (!cell)
    {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:notesCellId];
    }
    
    SSNote *note = self.contact.notes[indexPath.row];
    cell.textLabel.text = note.text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SSDetailSectionNotes)
    {
        return tableView.rowHeight;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:[self adjustIndexPath:indexPath]];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SSDetailSectionNotes)
    {
        return 0;
    }
    
    return [super tableView:tableView indentationLevelForRowAtIndexPath:[self adjustIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SSDetailSectionDetails && indexPath.row == SSDetailRowName) return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == SSDetailSectionNotes)
    {
        SSNote *note = self.contact.notes[indexPath.row];
        [self.applicationController showDetailsForNote:note readonly:YES];
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell ss_containsView:self.emailLabel])
    {
        [self sendEmail];
    }
    else if ([cell ss_containsView:self.phoneLabel])
    {
        [self callContact];
    }
    else if ([cell ss_containsView:self.addressLabel])
    {
        [self viewMap];
    }
}

- (IBAction)addNote:(id)sender
{
    [self.applicationController showDetailsForNote:[SSNote.alloc initWithContact:self.contact] readonly:NO];
}

- (void)sendEmail
{
    if (!MFMailComposeViewController.canSendMail) return;
    
    MFMailComposeViewController *controller = [MFMailComposeViewController.alloc init];
    controller.navigationBar.tintColor = UIColor.whiteColor;
    controller.mailComposeDelegate = self;
    controller.toRecipients = @[ self.contact.email ];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callContact
{
    NSString *phone = [NSString stringWithFormat:@"telprompt:%@", self.contact.mobile];
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:phone]];
}

- (void)viewMap
{
    CLGeocoder *geocoder = CLGeocoder.new;
    [geocoder geocodeAddressDictionary:self.addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) return;
        
        CLPlacemark *geocodedPlacemark = placemarks[0];
        MKPlacemark *placemark = [MKPlacemark.alloc initWithCoordinate:geocodedPlacemark.location.coordinate addressDictionary:geocodedPlacemark.addressDictionary];
        
        MKMapItem *mapItem = [MKMapItem.alloc initWithPlacemark:placemark];
        mapItem.name = self.contact.name;
        
//        [mapItem openInMapsWithLaunchOptions:nil];
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[ currentLocation, mapItem ] launchOptions:@{ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving }];
    }];
}

@end
