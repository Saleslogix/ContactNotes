//
//  SSContact.m
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSContact.h"
#import "SSAddress.h"
#import "SSNote.h"

@implementation SSContact
{
    NSMutableArray *_notes;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    SSContact *c = nil;
    NSMutableDictionary *keyPaths = super.JSONKeyPathsByPropertyKey.mutableCopy;
    keyPaths[@keypath(c, entityId)] = @"$key";
    keyPaths[@keypath(c, accountId)] = @"Account.$key";
    
    return keyPaths;
}

+ (NSValueTransformer *)addressJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:SSAddress.class];
}

+ (NSValueTransformer *)notesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SSNote.class];
}

- (void)setNotes:(NSArray *)notes
{
    _notes = notes.mutableCopy;
}

- (void)addNote:(SSNote *)note
{
    if (note.contact == self) return;
    note.contact = self;
    [self insertObject:note inNotesAtIndex:self.countOfNotes];
}

- (NSUInteger)countOfNotes
{
    return self.notes.count;
}

- (SSNote *)objectInNotesAtIndex:(NSUInteger)index
{
    return self.notes[index];
}

- (NSArray *)notesAtIndexes:(NSIndexSet *)indexes
{
    return [self.notes objectsAtIndexes:indexes];
}

- (void)insertObject:(SSNote *)object inNotesAtIndex:(NSUInteger)index
{
    [_notes insertObject:object atIndex:index];
}

- (void)insertNotes:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [_notes insertObjects:array atIndexes:indexes];
}

- (void)removeObjectFromNotesAtIndex:(NSUInteger)index
{
    [_notes removeObjectAtIndex:index];
}

- (void)removeNotesAtIndexes:(NSIndexSet *)indexes
{
    [_notes removeObjectsAtIndexes:indexes];
}

@end
