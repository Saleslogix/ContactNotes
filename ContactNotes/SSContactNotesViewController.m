//
//  SSContactNotesViewController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/17/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSContactNotesViewController.h"
#import <SHActionSheetBlocks/SHActionSheetBlocks.h>
#import "SSSDataManager.h"
#import "SSNote.h"
#import "SSContact.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SSContactNotesViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *notesView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation SSContactNotesViewController

@synthesize sDataManager;

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self updateContent];
    [self.notesView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNote:(SSNote *)note
{
    _note = note;
    [self updateContent];
}

- (void)updateContent
{
    self.notesView.text = self.note.text;
}

- (IBAction)saveNotes:(id)sender
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving", nil) maskType:SVProgressHUDMaskTypeClear];
    
    [self.notesView resignFirstResponder];
    self.note.text = self.notesView.text;
    
    @weakify(self);
    [self.sDataManager saveNote:self.note completion:^(NSURLSessionTask *task, SSNote *note, NSError *error) {
        @strongify(self);
        
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            return;
        }
        
        if (note)
        {
            [self.note.contact addNote:note];
        }
        [self dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Saved", nil)];
    }];
}

- (IBAction)cancel:(id)sender
{
    [self.notesView resignFirstResponder];
    if (self.readonly || !self.notesView.text.length)
    {
        [self dismiss];
        return;
    }
    
    @weakify(self);
    UIActionSheet *confirmationSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
    [confirmationSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Delete Note", nil) withBlock:^(NSInteger theButtonIndex) {
        @strongify(self);
        [self dismiss];
    }];
    [confirmationSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", nil) withBlock:nil];
    [confirmationSheet showInView:self.view];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)note
{
//    CGRect textViewRect = [self.view convertRect:self.notesView.frame toView:self.view.window];
//    CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey].CGRectValue;
}

- (void)keyboardWillHide:(NSNotification *)note
{
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.saveButton.enabled = (self.notesView.text.length > 0);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return !self.readonly;
}

@end
