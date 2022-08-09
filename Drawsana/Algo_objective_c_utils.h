//
//  Algo_objective_c_utils.h
//  Drugi_iOS
//
//  Created by mikolaj on 21/09/2018.
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.
//

#ifndef Algo_objective_c_utils_h
#define Algo_objective_c_utils_h
#include <os/log.h>

#import <Foundation/Foundation.h>
@interface Algo_signal: NSObject{
    
}
@property (assign,nonatomic) bool sig_value;
+(Algo_signal*_Nonnull) v:(bool) freshValue;
@end

@interface Algo_pair<T,V> : NSObject{
@public
    T p_0;
    V p_1;
    
}
@property (strong,nonatomic) T _Nullable first;
@property (strong,nonatomic) V _Nullable second;

+ (Algo_pair<T,V>* _Nonnull) first:(T _Nullable) f second:(V  _Nullable) s;
@end


@interface Algo_three<T,V,W> : NSObject{
@public
    T p_0;
    V p_1;
    W p_2;
}
@property (strong,nonatomic) T _Nullable first;
@property (strong,nonatomic) V _Nullable second;
@property (strong,nonatomic) W _Nullable third;

+ (Algo_three<T,V,W>* _Nonnull) first:(T _Nullable) f second:(V _Nullable ) s third:(W _Nullable ) t;
@end

@interface Algo_five<T,V,W,X,Y> : NSObject{
@public
    T _first;
    V _second;
    W _third;
    X _fourth;
    Y _fifth;
}
@property (strong,nonatomic) T _Nullable first;
@property (strong,nonatomic) V _Nullable second;
@property (strong,nonatomic) W _Nullable third;
@property (strong,nonatomic) X _Nullable fourth;
@property (strong,nonatomic) Y _Nullable fifth;

+ (Algo_five<T,V,W,X,Y>* _Nonnull) first:(T _Nullable) f1 second:(V _Nullable) f2 third:(W _Nullable) f3 fourth:(X _Nullable) f4 fifth:(Y _Nullable) f5;
@end

// ------ Create Directory in Documents
@interface Algo_Obj_Utils :NSObject
+ ( Algo_five<NSURL*/*path*/, NSNumber* /*error*/,NSError*, NSNumber* /*was there before*/, NSNumber* /*created*/>* _Nonnull) Create_Directory_In_Documents_Folder: (NSString* _Nullable)dir_name_to_create;

+ (NSString* _Nullable) stringWithUTF8String:(const char* _Nullable) nullable_c_string;
+(BOOL /*ok*/) deleteFile:(NSURL* _Nullable)file ;
+(BOOL /*ok*/) moveFile:(NSURL* _Nullable)file to:(NSURL* _Nullable)destination;
+(NSArray<NSURL*>* _Nullable) getContentsOfDirectoryAtURL:(NSURL* _Nullable) dir_url orPath:(NSString* _Nullable) dir_path filteredBy:(NSString* _Nonnull) predicate andArgumentToPredicate:(NSString* _Nonnull) argument ;

+(Algo_five<NSURL*/*Documents*/,NSURL*/*Documents/Inbox*/,NSURL*/*Library*/,NSURL*/*tmp*/,NSURL*>*_Nullable) Main_URLS_For_App;
+(NSURL* _Nullable) fuse_paths:(NSURL* _Nullable) base_url second_path:(NSString* _Nullable) second third_path:(NSString* _Nullable) third;

+ (BOOL) isInSimulator;
+ (BOOL) debuggerIsAttached;

// set value for key but catching an exception - this is safe version. Catches NSUndefinedKeyException
+ (void) setValue:(NSObject* _Nullable) value_to_insert forKeyPath:(NSString* _Nonnull) keyPath inObject:(NSObject* _Nonnull) object;
+ (NSObject* _Nullable) getValueFromObject:(NSObject* _Nullable) object forKeyPath:(NSString* _Nonnull) keyPath;
+ (void) add_value:(NSObject* _Nullable) value toArray:(NSObject* _Nullable) object forKeyPath:(NSString* _Nonnull) keyPath;
+ (NSArray<NSString*>*_Nullable) match_regular_expression:(NSString*_Nullable) regexp inString:(NSString*_Nullable) string_to_analyze caseSensitive: (BOOL) _caseSensitive ;
+ (BOOL) set_property_with_a_method:(nullable NSString*) selector_string object: (nullable  NSObject*) my_object value:(nullable NSObject*) value ;
+ (Algo_pair<NSString*,NSString*>* _Nullable) split_string_into_2_parts:(nullable NSString*) string_to_split separator:(nullable NSString*) sep;
+ (os_log_t) algo_log_uifunctions;
@end
#endif /* Algo_objective_c_utils_h */
