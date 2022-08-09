//
//  Algo_objective_c_utils.m
//  Drugi_iOS
//
//  Created by mikolaj on 21/09/2018.
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Algo_objective_c_utils.h"
#include <os/log.h>

#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@implementation Algo_signal
@synthesize sig_value;
-(id)init
{
    if(self = [super init]){
    }
    return self;
}
+(Algo_signal*) v:(bool) freshValue{
    Algo_signal* s = [Algo_signal new];
    s.sig_value = freshValue;
    return s;
}

@end
@implementation  Algo_pair

+ (Algo_pair<id,id>*) first:(id) f second:(id) s
{
    Algo_pair<id,id> *p = [Algo_pair<id,id> new];
    p->p_0 = f;
    p->p_1 = s;
    return p;
}

-(id)init
{
    if(self = [super init]){
        
    }
    return self;
}
- (id) first{
    return p_0;
}
-(void) setFirst:(id) obj{
    self->p_0 = obj;
}
- (id) second{
    return p_1;
}
-(void) setSecond:(id) obj{
    self->p_1 = obj;
}
@end

@implementation  Algo_three

-(id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}
- (id) first{
    return p_0;
}
-(void) setFirst:(id) obj{
    self->p_0 = obj;
}
- (id) second{
    return p_1;
}
-(void) setSecond:(id) obj{
    self->p_1 = obj;
}
- (id) third{
    return p_2;
}
-(void) setThird:(id) obj{
    self->p_2 = obj;
}

+ (Algo_three<id,id,id>* _Nonnull) first:(id) f second:(id) s third:(id) t
{
    Algo_three<id,id,id> *p = [Algo_three<id,id,id> new];
    p->p_0 = f;
    p->p_1 = s;
    p->p_2 = t;
    return p;
}

@end

@implementation Algo_five

@synthesize first = _first;
@synthesize second = _second;
@synthesize third = _third;
@synthesize fourth = _fourth;
@synthesize fifth = _fifth;
+ (Algo_five<id,id,id,id,id>*) first:(id) f1 second:(id) f2 third:(id) f3 fourth:(id) f4 fifth:(id) f5
{
    Algo_five<id,id,id,id,id>*p = [Algo_five<id,id,id,id,id> new];
    p->_first = f1;
    p->_second = f2;
    p->_third = f3;
    p->_fourth = f4;
    p->_fifth = f5;
    
    return p;
}
@end
@implementation Algo_Obj_Utils
// ------ Create Directory in Documents
+ ( Algo_five<NSURL*/*path*/,NSNumber* /*error*/,NSError*, NSNumber* /*was there before*/, NSNumber* /*created*/>*) Create_Directory_In_Documents_Folder: (NSString*)dir_name_to_create
{
    NSURL* path_to_new_dir;
    NSError* ret_err = nil;
    bool ret_error = false;
    bool ret_was_before = false;
    bool ret_dir_created = false;
    
    
    
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    
    if(dir_name_to_create!=nil){
//        dir_name_to_create = [NSString stringWithUTF8String:c_dir_name_to_create];
    }
    else{
        //in case no c_dir_name_to_create was given - we will return documents directory. It is legitimate use.
        //  This enables using the same functions for saving a file in documents directory
        ret_error = false;
        path_to_new_dir = [NSURL fileURLWithPath:documentsDirectory isDirectory:YES];
        ret_was_before = true;
        return  [Algo_five first:path_to_new_dir second:[NSNumber numberWithBool:ret_error] third:ret_err fourth:[NSNumber numberWithBool:ret_was_before] fifth:[NSNumber numberWithBool:ret_dir_created]];

    }
    
    NSString* dir_to_create = [documentsDirectory stringByAppendingPathComponent:dir_name_to_create];
    
    NSFileManager* fs = [NSFileManager defaultManager];
    NSURL* dir_to_create_url = [NSURL fileURLWithPath:dir_to_create isDirectory:YES];
    path_to_new_dir = dir_to_create_url;
    
    BOOL dir_to_create_is_dir;
    bool dir_to_create_exists = [fs fileExistsAtPath:dir_to_create isDirectory:&dir_to_create_is_dir];
    if(dir_to_create_exists == NO || dir_to_create_is_dir==NO){
        
        ret_was_before = false;
        
        NSError *e = nil;
        BOOL success = [fs createDirectoryAtURL:dir_to_create_url withIntermediateDirectories:NO attributes:NULL error:&e];
        if(success == NO) {
            ret_err = e;
            ret_error = true;
            
            os_log_error(OS_LOG_DEFAULT,"AlgoEngine: error while creating %@ directory:%@",dir_name_to_create,e.description);
            
            return  [Algo_five first:path_to_new_dir second:[NSNumber numberWithBool:ret_error] third:ret_err fourth:[NSNumber numberWithBool:ret_was_before] fifth:[NSNumber numberWithBool:ret_dir_created]];
        }
        ret_err = nil;
        ret_error = false;
        ret_dir_created = true;
    }
    else{
        ret_was_before = true;
    }
    return  [Algo_five first:path_to_new_dir second:[NSNumber numberWithBool:ret_error] third:ret_err fourth:[NSNumber numberWithBool:ret_was_before] fifth:[NSNumber numberWithBool:ret_dir_created]];
    }


+ (NSString*) stringWithUTF8String:(const char*) nullable_c_string{
    NSString* output = nil;
    @try{
        if(nullable_c_string == NULL){
            output = nil;
        }
        else{
            output = [NSString stringWithUTF8String:nullable_c_string];
        }
    }
    @catch(NSException *exception) {
        output = nil;
    }
    @finally {
        return output;
    }
}

+(BOOL /*ok*/) moveFile:(NSURL*)file to:(NSURL*)destination {
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err = nil;
    if(file==nil || destination==nil){ return NO;}
    if( [fm fileExistsAtPath:destination.path ] == YES){
        [fm removeItemAtURL:destination error:&err];
        if(err != nil){
            NSLog(@"algo_obj moving file(remove destination failed):%@ dest:%@",err,destination);
            err = nil;
        }
    }
    
    [fm moveItemAtURL:file toURL:destination error:&err];
    if(err!=nil){
        NSLog(@"algo_obj move file failed:%@ to %@ err:%@",err,file,destination);
        err=nil;
    }
    return YES;
}

//!@brief deletes files - and only files
//!@return YES - if url was a file and was succesfully deleted, if url on input was a directory, then it returns NO
+(BOOL /*ok*/) deleteFile:(NSURL*)file {
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err = nil;
    if(file==nil ){ return NO;}
    if([file isFileURL]==YES){
        [fm removeItemAtURL:file error:&err];
        if(err!=nil){
            return NO;
        }
    }
    return YES;
}
//!@brief returns urls of files whose NAMES match given predicate+argument
//!@discussion NSPredicate is formed as follows: @"%@ %@"
//!@discussion  @"self.lastPathComponent STARTSWITH argument"
//!@param predicate self.lastPathComponent  STARTSWITH or CONTAINS[c]
//!@param argument  last part of predicate - depending on predicate, value of matching string
+(NSArray<NSURL*>*) getContentsOfDirectoryAtURL:(NSURL*) dir_url orPath:(NSString*) dir_path filteredBy:(NSString*) predicate andArgumentToPredicate:(NSString*) argument {
    NSError* err;
    NSArray<NSURL*>* dir_contents = nil;
    if( dir_url == nil){
        if(dir_path!=nil){
            dir_url = [NSURL fileURLWithPath:dir_path isDirectory:YES];
        };
    }
    
    if(dir_url == nil){
        return nil;
    }
    
    dir_contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dir_url includingPropertiesForKeys:nil options:0 error:&err];
    //predicate == STARTSWITH or CONTAINS[c]
    //argument == uuid.string
    NSString* pred_string = [NSString stringWithFormat:@"%@ %@",predicate,@" %@"];
    NSPredicate* pred = [NSPredicate predicateWithFormat:pred_string argumentArray:@[argument] ];
    NSArray<NSURL*> *filteredFiles = [dir_contents filteredArrayUsingPredicate:pred] ;
//NSArray *filteredFiles = [dir_contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.absoluteString ENDSWITH '.jpg'"]] ;
    return filteredFiles;
}


+(Algo_five<NSURL*/*Documents*/,NSURL*/*Documents/Inbox*/,NSURL*/*Library*/,NSURL*/*tmp*/,NSURL*>*) Main_URLS_For_App {
   NSFileManager* main_fm =  [NSFileManager defaultManager];
   NSURL* document_path = [main_fm URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask].firstObject;
   NSURL* temp_path = [NSURL fileURLWithPath: NSTemporaryDirectory() isDirectory: YES];   //[main_fm temporaryDirectory];
   NSURL* lib_path = [main_fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject;
   NSURL* inbox_path = [document_path URLByAppendingPathComponent:@"Inbox" isDirectory:YES];
  
    return [Algo_five first:document_path second:inbox_path third:lib_path fourth:temp_path fifth:nil];
 }

+(NSURL*) fuse_paths:(NSURL*) base_url second_path:(NSString*) second third_path:(NSString*) third {
    NSURL* result = nil;
    if(second){
        result = [base_url URLByAppendingPathComponent:second];
    }
    if(third){
        result = [result URLByAppendingPathComponent:third];
    }
    
    return result;
    
}

+ (BOOL) isInSimulator
{
    #if TARGET_IPHONE_SIMULATOR
        // Simulator
    return YES;
    #else
        // Device
    return NO;
    #endif
}

//!@brief add environmental variable algo_debug to true under XCode->Product->Edit Scheme. Then under the Debug scheme's Arguments
+ (BOOL) debuggerIsAttached
{
    NSDictionary* env = [NSProcessInfo processInfo].environment;

    if ([env[@"algo_debug"] isEqual:@"true"]) {
        return YES;
    }
    else {
        return NO;
    }
    
    //COMMENTS:
//    It is possible to instruct the debugger to set environment variables when it launches a process it is about to debug. This can be done in Xcode by going to the menu item Product->Edit Scheme. Then under the Debug scheme's Arguments tab add a new environment variable. The variable should be named "debugger" with the value "true". Then the following code snippet can be used to determine if the debugger launched your process:
    
}

+ (void) setValue:(NSObject* _Nullable) value_to_insert forKeyPath:(NSString* _Nonnull) keyPath inObject:(NSObject* _Nonnull) object{
    @try {
        if(object==nil || keyPath==nil){ return ;}
        [object setValue:value_to_insert forKeyPath:keyPath ];
    } @catch( NSException* exc){
        //ble
    }
}

+ (NSObject*) getValueFromObject:(NSObject* _Nullable) object forKeyPath:(NSString* _Nonnull) keyPath {
    
    @try{
        if(object == nil) {
            return nil;
        }
        NSObject* res = [object valueForKeyPath:keyPath];
        return res;
    } @catch( NSException* exc ){
        return nil;
    }
}

+ (void) add_value:(NSObject* _Nullable) value toArray:(NSObject* _Nullable) object forKeyPath:(NSString* _Nonnull) keyPath {
    @try {
        if(object == nil || value == nil){
            return;
        }
        NSObject* array_obj = [object valueForKeyPath:keyPath];
        if(array_obj !=nil && [array_obj isKindOfClass:[NSArray class]]==NO){
            return;
        }
        NSArray* array = (NSArray*) array_obj;
        if( array == nil ){
            array = [[NSArray alloc] initWithObjects:value, nil];
        }
        else{
            array = [array arrayByAddingObject:value];
        }
        [object setValue:array forKeyPath:keyPath];
    }
    @catch(NSException* exc) {
        
    }
}




//----------- MATCH REGEX
// GOAL IS TO GET VALUES FROM THIS STRING:
//            V1.L==V2.R*10+5@1000
//            V1.T==V3.B*1+8@1000
//             V1.T==SV(superview) lub SA(safe area)
//      =, < or >
//      L-left, T-top,  X - X center, Y-Y center   W-width,H-height
//        +[0-9]+  - offset
//          @1000 - priority
//INPUTS:
//  input string
//  expression

//OUTPUTS:
//  list of matched strings
//      s1, int1, float1
//      s2, int2, float2
//      s3, int3, float3
//      s4, int4, float4

+ (NSArray<NSString*>*) match_regular_expression:(NSString*) regexp inString:(NSString*) string_to_analyze caseSensitive: (BOOL) _caseSensitive  {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
        regularExpressionWithPattern:regexp //@"(NS|UI)+(\\w+)"
        options:NSRegularExpressionCaseInsensitive
        error:&error];
    __block NSMutableArray<NSString*>* string_results = [NSMutableArray new];
    [regex enumerateMatchesInString:string_to_analyze options:0 range:NSMakeRange(0, [string_to_analyze length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        // your code to handle matches here
        for (int match_index = 1; match_index< [match numberOfRanges]; ++match_index) {
            NSRange r = [match rangeAtIndex:match_index];
            NSString* matched_string = [string_to_analyze substringWithRange:r];
            [string_results addObject:matched_string];
            
        }
        
    }];
    
    return string_results;
    
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (BOOL) set_property_with_a_method:(NSString*) selector_string object: (NSObject*) my_object value:(NSObject*) value {
    SEL selector = NSSelectorFromString(selector_string);
    if ([my_object respondsToSelector:selector]) {
        [(id)my_object performSelector:selector withObject:value];
//        [(id)my_object ble_ble:value];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma clang diagnostic pop

+ (Algo_pair<NSString*,NSString*>*) split_string_into_2_parts:(NSString*) string_to_split separator:(NSString*) sep {
    //we split string with ,
    
    NSArray* components = [string_to_split componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:sep]]; //[string componentsSeparatedByString:@","];
    __block NSMutableArray<NSString*>* parts = [NSMutableArray new];
    [components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* part = (NSString*) obj;
        [parts addObject:part];
    }];
    
    NSString* algo_library = [parts firstObject];
    NSString* algo_algorithm ;
    if( [parts count]>1){
        algo_algorithm = parts[1];
    }
    
    Algo_pair<NSString*,NSString*>* res = [Algo_pair first:algo_library second:algo_algorithm];
    return res;
    
}

+(void) get_property_of_object:(NSObject*) object with_name:(NSString*) property_name {
    objc_property_t property = class_getProperty( [object class], [property_name UTF8String]);
    if(property == NULL) return;
    const char * type = property_getAttributes(property);
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:0];
    NSString * propertyType = [typeAttribute substringFromIndex:1];
    const char * rawPropertyType = [propertyType UTF8String];

    if (strcmp(rawPropertyType, @encode(float)) == 0) {
        //it's a float
    } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
        //it's an int
    } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
        //it's some sort of object
    } else {
        // According to Apples Documentation you can determine the corresponding encoding values
    }

    if ([typeAttribute hasPrefix:@"T@"]) {
//This has a tricky bug with id types -- The encoding for id properties is just "T@", so it will pass the last if check, but [typeAttribute length]-4 will be negative and things will blow up.
        NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
        Class typeClass = NSClassFromString(typeClassName);
        if (typeClass != nil) {
            // Here is the corresponding class even for nil values
        }
    }

    
}

//so we will make static cases for typical properties like frame, color, background color etc
//we need to split keypath for keypath components
//
//https://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c

+ (void) get_property_list:(NSObject*) object {
    NSObject* MyObject =  object;
    
    unsigned int count;
    objc_property_t* props = class_copyPropertyList([MyObject class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = props[i];
        const char * name = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        const char * type = property_getAttributes(property);
        NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];

        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        const char * rawPropertyType = [propertyType UTF8String];

        if (strcmp(rawPropertyType, @encode(float)) == 0) {
            //it's a float
        } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
            //it's an int
        } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
            //it's some sort of object
        } else {
            // According to Apples Documentation you can determine the corresponding encoding values
        }

        if ([typeAttribute hasPrefix:@"T@"]) {
//This has a tricky bug with id types -- The encoding for id properties is just "T@", so it will pass the last if check, but [typeAttribute length]-4 will be negative and things will blow up.
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
            Class typeClass = NSClassFromString(typeClassName);
            if (typeClass != nil) {
                // Here is the corresponding class even for nil values
            }
        }

    }
    free(props);
}

+ (os_log_t) algo_log_uifunctions {
    static os_log_t _log;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _log = os_log_create("com.AUTOMATYKA.iFindMyStuff", "AlgoUIFunctionsErrors");
    });

    return _log;
}

@end
