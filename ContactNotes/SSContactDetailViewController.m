//
//  SSContactDetailViewController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/17/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSContactDetailViewController.h"
#import "SSContact.h"
#import "SSAddress.h"
#import "SSNote.h"
#import <AddressBookUI/AddressBookUI.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import "SSContactNotesViewController.h"
#import "SSSDataManager.h"


@interface SSContactDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation SSContactDetailViewController

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
    [SSSDataManager.sharedManager loadNotesForContact:self.contact completion:^(NSSet *notes, NSError *error) {
        NSLog(@"%@", self.contact.notes);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContact:(SSContact *)contact
{
    _contact = contact;
    [self updateContent];
}

- (void)updateContent
{
    self.contactNameLabel.text = [self.contact.name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    self.addressLabel.text = [self stringFromAddressWithStreet:self.contact.address.address1 locality:self.contact.address.city region:self.contact.address.state postalCode:self.contact.address.postalCode country:nil];
    
    NSError *error = nil;
    NBPhoneNumber *phone = [NBPhoneNumberUtil.sharedInstance parse:self.contact.mobile defaultRegion:@"US" error:&error];
    self.phoneLabel.text = [NBPhoneNumberUtil.sharedInstance format:phone numberFormat:NBEPhoneNumberFormatNATIONAL error:&error];
    
    self.emailLabel.text = [self.contact.email stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (NSString *)stringFromAddressWithStreet:(NSString *)street
                                 locality:(NSString *)locality
                                   region:(NSString *)region
                               postalCode:(NSString *)postalCode
                                  country:(NSString *)country
{
    NSMutableDictionary *mutableAddressComponents = [NSMutableDictionary dictionary];
    
    if (street) {
        [mutableAddressComponents setValue:street forKey:(__bridge NSString *)kABPersonAddressStreetKey];
    }
    
    if (locality) {
        [mutableAddressComponents setValue:locality forKey:(__bridge NSString *)kABPersonAddressCityKey];
    }
    
    if (region) {
        [mutableAddressComponents setValue:region forKey:(__bridge NSString *)kABPersonAddressStateKey];
    }
    
    if (postalCode) {
        [mutableAddressComponents setValue:postalCode forKey:(__bridge NSString *)kABPersonAddressZIPKey];
    }
    
    if (country) {
        [mutableAddressComponents setValue:country forKey:(__bridge NSString *)kABPersonAddressCountryKey];
    }
    
    [mutableAddressComponents setValue:[NSLocale.currentLocale objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
    
    return ABCreateStringWithAddressDictionary(mutableAddressComponents, !!country);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addNote"])
    {
        SSContactNotesViewController *notesController = (SSContactNotesViewController *)segue.destinationViewController;
        notesController.note = [SSNote.alloc initWithContact:self.contact];
    }
}

@end
