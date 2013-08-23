/*
 * Copyright 2012-2013 StackMob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Kiwi/Kiwi.h>
#import "StackMob.h"
#import "SMIntegrationTestHelpers.h"
#import "SMCoreDataIntegrationTestHelpers.h"
#import "SMTestProperties.h"

SPEC_BEGIN(SMSavePolicySpec)
/*
describe(@"SMSavePolicy, default networkThenCache", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        
        [error shouldBeNil];
        
        SM_CACHE_ENABLED = NO;
    });
    it(@"Saves in both places on create", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
    
    it(@"Saves in both places on update", ^{
        
        dispatch_queue_t queue = dispatch_queue_create("createQueue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        // Create 5 new objects
        NSMutableArray *theObjects = [NSMutableArray array];
        for (int i=0; i < 5; i++) {
            [theObjects addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", nil]];
        }
        
        dispatch_group_enter(group);
        [[testProperties.client dataStore] createObjects:theObjects inSchema:@"todo" options:[SMRequestOptions options] successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSArray *succeeded, NSArray *failed, NSString *schema) {
            [[succeeded should] haveCountOf:5];
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSArray *objects, NSString *schema) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Pull down objects
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
    
    it(@"Saves in both places on create and update", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        error = nil;
        success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
});

describe(@"SMSavePolicy, explicitly setting networkThenCache", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
        [testProperties.cds setSavePolicy:SMSavePolicyNetworkThenCache];
    });
    afterEach(^{
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        
        [error shouldBeNil];
        
        SM_CACHE_ENABLED = NO;
    });
    it(@"Saves in both places on create", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
    
    it(@"Saves in both places on update", ^{
        
        dispatch_queue_t queue = dispatch_queue_create("createQueue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        // Create 5 new objects
        NSMutableArray *theObjects = [NSMutableArray array];
        for (int i=0; i < 5; i++) {
            [theObjects addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", nil]];
        }
        
        dispatch_group_enter(group);
        [[testProperties.client dataStore] createObjects:theObjects inSchema:@"todo" options:[SMRequestOptions options] successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSArray *succeeded, NSArray *failed, NSString *schema) {
            [[succeeded should] haveCountOf:5];
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSArray *objects, NSString *schema) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Pull down objects
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
    
    it(@"Saves in both places on create and update", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        error = nil;
        success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        //sleep(1);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
});

describe(@"SMSavePolicy, setting networkOnly", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
        [testProperties.cds setSavePolicy:SMSavePolicyNetworkOnly];
    });
    afterEach(^{
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        
        [error shouldBeNil];
        
        SM_CACHE_ENABLED = NO;
    });
    it(@"Saves on the network only on create", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
    
    it(@"Saves on network only for update", ^{
        
        dispatch_queue_t queue = dispatch_queue_create("createQueue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        // Create 5 new objects
        NSMutableArray *theObjects = [NSMutableArray array];
        for (int i=0; i < 5; i++) {
            [theObjects addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", nil]];
        }
        
        dispatch_group_enter(group);
        [[testProperties.client dataStore] createObjects:theObjects inSchema:@"todo" options:[SMRequestOptions options] successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSArray *succeeded, NSArray *failed, NSString *schema) {
            [[succeeded should] haveCountOf:5];
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSArray *objects, NSString *schema) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Pull down objects
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        [testProperties.cds purgeCacheOfObjectsWithEntityName:@"Todo"];
        
        sleep(1);
        
        error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
    
    it(@"Saves on network only on create and update", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        [testProperties.cds purgeCacheOfObjectsWithEntityName:@"Todo"];
        
        sleep(1);
        
        error = nil;
        success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        //sleep(1);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
    });
});

describe(@"SMSavePolicy, setting cacheOnly", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
        [testProperties.cds setSavePolicy:SMSavePolicyCacheOnly];
    });
    afterEach(^{
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        
        [error shouldBeNil];
        
        SM_CACHE_ENABLED = NO;
    });
    it(@"Saves on the network only on create", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
    });
    
    it(@"Saves on network only on create and update", ^{
        
        // Create 5 new objects
        for (int i=0; i < 5; i++) {
            NSManagedObject *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [newTodo assignObjectId];
            [newTodo setValue:@"new todo" forKey:@"title"];
        }
        
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:cacheFetch returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:@"updated title" forKey:@"title"];
        }];
        
        error = nil;
        success = [testProperties.moc saveAndWait:&error];
        
        [[theValue(testProperties.cds.globalRequestOptions.cacheResults) should] beYes];
        
        [[theValue(success) should] beYes];
        [error shouldBeNil];
        
        //sleep(1);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch2 returnManagedObjectIDs:NO error:&error];
        
        [[results should] haveCountOf:5];
        [error shouldBeNil];
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *networkFetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:networkFetch2 returnManagedObjectIDs:NO options:[SMRequestOptions optionsWithCacheResults:NO] error:&error];
        
        [[results should] haveCountOf:0];
        [error shouldBeNil];
        
    });
});
*/

describe(@"Per Request Save Policy", ^{
    __block SMTestProperties *testProperties;
    beforeAll(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
        
    });
    afterAll(^{
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        [testProperties.cds setSavePolicy:SMSavePolicyNetworkThenCache];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        NSError *error = nil;
        NSArray *array = [testProperties.moc executeFetchRequestAndWait:request error:&error];
        
        [error shouldBeNil];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        
        if ([testProperties.moc hasChanges]) {
            error = nil;
            [testProperties.moc saveAndWait:&error];
            [error shouldBeNil];
        }
        
        SM_CACHE_ENABLED = NO;
    });
    it(@"not setting policy works, sync", ^{
        
        [[[testProperties.client.session oauthClientWithHTTPS:NO] should] receive:@selector(enqueueBatchOfHTTPRequestOperations:completionBlockQueue:progressBlock:completionBlock:) withCount:0];
        
        [testProperties.cds setSavePolicy:SMSavePolicyCacheOnly];
        
        for (int i=0; i < 10; i++) {
            NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [todo assignObjectId];
        }
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error];
        [[theValue(success) should] beYes];
        [error shouldBeNil];
    });
    it(@"setting request policy works, sync", ^{
        
        [testProperties.cds setSavePolicy:SMSavePolicyNetworkOnly];
        
        [[[testProperties.client.session oauthClientWithHTTPS:NO] should] receive:@selector(enqueueBatchOfHTTPRequestOperations:completionBlockQueue:progressBlock:completionBlock:) withCount:0];
        
        SMRequestOptions *options = [SMRequestOptions optionsWithSavePolicy:SMSavePolicyCacheOnly];
        [[theValue(options.savePolicySet) should] beYes];
        for (int i=0; i < 10; i++) {
            NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [todo assignObjectId];
        }
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error options:options];
        [[theValue(success) should] beYes];
        [error shouldBeNil];
    });
    it(@"setting request policy works, sync, reverse works", ^{
        
        [testProperties.cds setSavePolicy:SMSavePolicyCacheOnly];
        
        [[[testProperties.client.session oauthClientWithHTTPS:NO] should] receive:@selector(enqueueBatchOfHTTPRequestOperations:completionBlockQueue:progressBlock:completionBlock:) withCount:1];
        
        SMRequestOptions *options = [SMRequestOptions optionsWithSavePolicy:SMSavePolicyNetworkOnly];
        [[theValue(options.savePolicySet) should] beYes];
        for (int i=0; i < 10; i++) {
            NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [todo assignObjectId];
        }
        NSError *error = nil;
        BOOL success = [testProperties.moc saveAndWait:&error options:options];
        [[theValue(success) should] beYes];
        [error shouldBeNil];
    });
    it(@"not setting policy works, async", ^{
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("aQueue", NULL);
        
        [[[testProperties.client.session oauthClientWithHTTPS:NO] should] receive:@selector(enqueueBatchOfHTTPRequestOperations:completionBlockQueue:progressBlock:completionBlock:) withCount:0];
        
        [testProperties.cds setSavePolicy:SMSavePolicyCacheOnly];
        
        for (int i=0; i < 10; i++) {
            NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
            [todo assignObjectId];
        }
        
        dispatch_group_enter(group);
        
        [testProperties.moc saveWithSuccessCallbackQueue:queue failureCallbackQueue:queue onSuccess:^{
            NSLog(@"here");
            dispatch_group_leave(group);
        } onFailure:^(NSError *error) {
            NSLog(@"here");
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
                
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
    });
    /*
    it(@"setting request policy works, async", ^{
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        
        [[[testProperties.client.session oauthClientWithHTTPS:NO] should] receive:@selector(enqueueBatchOfHTTPRequestOperations:completionBlockQueue:progressBlock:completionBlock:) withCount:0];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        SMRequestOptions *options = [SMRequestOptions options];
        options.cachePolicy = SMCachePolicyTryCacheOnly;
        [[theValue(options.cachePolicySet) should] beYes];
        
        dispatch_group_enter(group);
        [testProperties.moc executeFetchRequest:request returnManagedObjectIDs:YES successCallbackQueue:queue failureCallbackQueue:queue options:options onSuccess:^(NSArray *results) {
            [[results should] haveCountOf:10];
            dispatch_group_leave(group);
        } onFailure:^(NSError *error) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    });
     */
});



SPEC_END