//
//  NSObject+Algo_UIKit_Binding.h
//  AlgoEngine_iOS
//
//  Created by mikolaj on 28/08/2019.
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Algo_objective_c_utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Algo_Binding : NSObject
    @property (weak,nonatomic,nullable) NSObject* observed_nsobject;
    @property (weak,nonatomic,nullable) UIViewController* vc;
    @property (strong,nonatomic,nullable) NSString* element_name;
    @property (strong,nonatomic,nullable) NSString* keyPath_to_observe;

@property (nonatomic, copy, nullable) void (^value_changed)( NSObject* _Nullable  new_value);
    -(void) start_observing;
    -(void) stop_observing;

+(NSObject*) find_object_in_VC:(UIViewController*) vc element_name:(NSString*) recorder_name;

@end

@interface Algo_Binding_2_elements : NSObject
    @property (strong,nonatomic,nonnull) Algo_Binding* binding_object;

    @property (weak,nonatomic,nullable) NSObject* observed_nsobject;
    @property (weak,nonatomic,nullable) UIViewController* vc;
    @property (strong,nonatomic,nullable) NSString* element_name;
    @property (strong,nonatomic,nullable) NSString* keyPath_to_observe;

    @property (weak,nonatomic) NSObject* destination_object;
    @property (strong,nonatomic,nullable) NSString* dest_element_name;
    @property (strong,nonatomic,nullable) NSString* dest_keyPath_to_set;

    @property (nonatomic, copy, nullable) void (^value_changed)( NSObject* _Nullable  new_value);


    -(void) start_observing;
    -(void) stop_observing;

    -(void) set_dest_value_with:(NSObject*) new_value;
@end

@interface Algo_Setting_Properties: NSObject

+(BOOL) set_property_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name value:(nullable NSObject*) new_value;
+(BOOL) perform_Selector_on_NSObject_0_args_0_rets:(NSObject*) target withName:(const char*) selector_name ;
+(BOOL) perform_Selector_0_args_0_rets:(UIViewController*) vc objectName:(const char*) el_name_cstr selector_name:(const char*) selector_name_cstr ;
+(Algo_three<NSObject*,NSNumber*,NSNumber*>*) get_property_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name;

+(Algo_three<NSString*,NSNumber*/*OK*/,NSNumber*/*error*/>*) get_property_nsstring_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name;

+(Algo_three<NSNumber*,NSNumber*/*OK*/,NSNumber*/*error*/>*) get_property_nsnumber_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name;
+(NSObject*) create_object_with_initializer_and_parameter:(NSString*) class_name selector_name:(NSString*) sel_name  parameter:(NSObject*) param ;
@end
NS_ASSUME_NONNULL_END
