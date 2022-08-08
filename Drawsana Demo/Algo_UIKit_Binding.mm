//
//  Algo_UIKit_Binding.m
//  AlgoEngine_iOS
//
//  Created by mikolaj on 28/08/2019.
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Algo_UIKit_Binding.h"
#import "Algo_Controller_that_can_receive_data_from_AlgoEngine_protcol.h"
#import "Algo_objective_c_utils.h"
@interface Algo_Binding () {
    __weak NSObject* currently_observing_object;
    NSString* current_keypath;
}
@end

@implementation Algo_Binding
@synthesize observed_nsobject,vc,element_name,keyPath_to_observe;
@synthesize value_changed;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//  if ([keyPath isEqualToString:@"state"]) {
//  }
    if(self.value_changed != nil){
        NSObject* newVal_Obj = [change objectForKey:NSKeyValueChangeNewKey];
        if(newVal_Obj!=nil && newVal_Obj != [NSNull null]){
            if([newVal_Obj isKindOfClass:[NSNumber class]]){
//                NSNumber* newNumber = (NSNumber*) newVal_Obj;
            }
            else if( [newVal_Obj isKindOfClass:[NSString class]]){
            }
            if( self.value_changed !=nil){
                self.value_changed( newVal_Obj );
            }
        }
        else{
            if( self.value_changed !=nil){
                self.value_changed( nil );
            }
        }
    }
}

-(void) start_observing{
        [self stop_observing];
    
        if(self.keyPath_to_observe == nil){
            return; //this is error
        }
    
        self->current_keypath = self.keyPath_to_observe;
    
        if(self.observed_nsobject!=nil ) {
            self->currently_observing_object = self.observed_nsobject;
        }
        else if( self.vc!=nil && self.element_name!=nil && self.keyPath_to_observe!=nil ){
            NSObject* local_object_to_observe = [Algo_Binding find_object_in_VC:vc element_name: self.element_name ];
            if(local_object_to_observe != nil){
                self->currently_observing_object = (NSObject*) local_object_to_observe;
            }
            else{
                self->currently_observing_object =  nil;
            }
        }
    
        [self->currently_observing_object addObserver:self
             forKeyPath:self->current_keypath
            options:NSKeyValueObservingOptionNew
            context:nil];
}
-(void) stop_observing{
    __strong NSObject* obs_obj = self->currently_observing_object;
    if(obs_obj!=nil){
        @try {
                  [obs_obj removeObserver:self forKeyPath:current_keypath];
        }
        @catch (NSException * __unused exception) {}
    }
    self->currently_observing_object = nil;
    self->current_keypath = nil;
}


//!@brief - looks for picker object in ViewController
//!@discussion used by algorithm to find and connect to a picker created in Interface Builder
+(NSObject*) find_object_in_VC:(UIViewController*) vc element_name:(NSString*) recorder_name
{
    if(vc==nil){ return nil; }
    if( recorder_name == nil){ return nil; }
    if([vc conformsToProtocol:@protocol(Algo_Controller_with_targeted_unwind_segue)]==YES){
        id<Algo_Controller_with_targeted_unwind_segue> avc = (id<Algo_Controller_with_targeted_unwind_segue>) vc;
        for (UIView* ob in avc.important_elements) {
            if( [ob.restorationIdentifier isEqualToString:recorder_name] == YES ){
                return (NSObject*) ob;
            }
        }

        for (NSObject* ob in avc.other_important_objects)
        {
            @try
            {
                NSString* object_name = [ob valueForKey:@"name"];
                if(object_name!=nil &&([object_name isEqualToString:recorder_name] == YES) )
                {
                    return ob; //picker found !
                }
            } @catch (NSException *exception)
            {
                //well this object doesn't have a name
            } @finally {
            }
            
        }
    }
    else{
        return nil;
    }
    return nil;
}
@end

/* *********************************************************** */
/* *******  Algo_Binding_2_elements VC/UI or NSObjects ******* */
/* *********************************************************** */

@interface Algo_Binding_2_elements(){
    __weak NSObject* internal_destination_object;
    NSString* internal_destination_property_name;
}
@end
@implementation Algo_Binding_2_elements
    - (instancetype)init
{
    self = [super init];
    if (self) {
        self.binding_object = [[Algo_Binding alloc] init];
    }
    return self;
}
    -(void) start_observing {
        self.binding_object.vc= self.vc;
        self.binding_object.element_name = self.element_name;
        self.binding_object.keyPath_to_observe = self.keyPath_to_observe;
        self.binding_object.observed_nsobject = self.observed_nsobject;
        
        self->internal_destination_property_name = self.dest_keyPath_to_set;
        if(self.destination_object!=nil && self.dest_keyPath_to_set!=nil){
            self->internal_destination_object = self.destination_object;
        }
        else if( self.vc != nil && self.dest_element_name != nil){
            self->internal_destination_object = [Algo_Binding find_object_in_VC:self.vc element_name:self.dest_element_name];
        }
        
        __weak Algo_Binding_2_elements* myself = self;
        self.binding_object.value_changed = ^(NSObject * _Nullable new_value) {
            if(myself!=nil){
                Algo_Binding_2_elements* strong_myself = myself;
                [strong_myself set_dest_value_with:new_value];
            }
        };
        
        [self.binding_object start_observing];
    }

    -(void) stop_observing {
        [self.binding_object stop_observing];
    }

    -(void) set_dest_value_with:(NSObject*) new_value{
        if(self->internal_destination_object!=nil && self->internal_destination_property_name!=nil){
            NSObject* strong_destination_object = self->internal_destination_object;
            [strong_destination_object setValue:(id) new_value forKey:self->internal_destination_property_name];
        }
        
        if(self.value_changed != nil){
            self.value_changed(new_value);
        }
    }

@end

@implementation Algo_Setting_Properties
+(BOOL) set_property_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name value:(nullable NSObject*) new_value
{
    NSObject* destination_object = [Algo_Binding find_object_in_VC:vc element_name:el_name];
    if(destination_object != nil){
        [destination_object setValue:(id)new_value forKeyPath:prop_name];
    }
    else{
       return NO;
    }
    return YES;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


+(BOOL) perform_Selector_on_NSObject_0_args_0_rets:(NSObject*) target withName:(const char*) selector_name {
    NSString* ns_selector_name = [Algo_Obj_Utils stringWithUTF8String:selector_name];
    if(ns_selector_name == nil){
        return NO;
    }
    SEL selector_to_perform = NSSelectorFromString(ns_selector_name);
    
    if(target == nil){
        return NO;
    }
    
    if([target respondsToSelector:selector_to_perform] == NO){ return NO;}
    
    [target performSelector:selector_to_perform];
    return YES;
}

+(BOOL) perform_Selector_0_args_0_rets:(UIViewController*) vc objectName:(const char*) el_name_cstr selector_name:(const char*) selector_name_cstr {
    NSString* el_name = [Algo_Obj_Utils stringWithUTF8String:el_name_cstr];
    if(el_name == nil){
        return NO;
    }
    
    NSString* ns_selector_name = [Algo_Obj_Utils stringWithUTF8String:selector_name_cstr];
    if(ns_selector_name == nil){
        return NO;
    }
    SEL selector_to_perform = NSSelectorFromString(ns_selector_name);
    
    NSObject* destination_object = [Algo_Binding find_object_in_VC:vc element_name:el_name];
    if(destination_object != nil){
        if([destination_object respondsToSelector:selector_to_perform] == NO){ return NO;}
        [destination_object performSelector:selector_to_perform];
    }
    else{
       return NO;
    }
    return YES;
}
#pragma clang diagnostic pop

+(Algo_three<NSObject*,NSNumber*,NSNumber*>*) get_property_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name
{
    NSObject* val = nil;
    @try {
        NSObject* destination_object = [Algo_Binding find_object_in_VC:vc element_name:el_name];
        if(destination_object != nil){
            val = [destination_object valueForKeyPath:prop_name];
            return [Algo_three first:val second:@YES third:@NO];
        }
        else{
           return [Algo_three first:val second:@NO third:@YES];
        }
    } @catch (NSException *exception) {
        return [Algo_three first:val second:@NO third:@YES];
    }
}

+(Algo_three<NSString*,NSNumber*/*OK*/,NSNumber*/*error*/>*) get_property_nsstring_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name
{
    Algo_three<NSObject*,NSNumber*,NSNumber*>* prop = [Algo_Setting_Properties get_property_in_algo_object_by_name:vc element_name:el_name property_name:prop_name];
    if ( prop.first!=nil && [prop.first isKindOfClass:[NSString class]]==YES) {
        return [Algo_three first:prop.first second:@YES third:@NO];
    }
    else {
        return [Algo_three first:nil second:@NO third:@YES];
    }
}

+(Algo_three<NSNumber*,NSNumber*/*OK*/,NSNumber*/*error*/>*) get_property_nsnumber_in_algo_object_by_name:(nullable UIViewController*)vc element_name:(nullable NSString*) el_name property_name:(nullable NSString*) prop_name
{
    Algo_three<NSObject*,NSNumber*,NSNumber*>* prop = [Algo_Setting_Properties get_property_in_algo_object_by_name:vc element_name:el_name property_name:prop_name];
    if ( prop.first!=nil && [prop.first isKindOfClass:[NSNumber class]]==YES) {
        return [Algo_three first:prop.first second:@YES third:@NO];
    }
    else {
        return [Algo_three first:nil second:@NO third:@YES];
    }
}


+(NSObject*) create_object_with_initializer_and_parameter:(NSString*) class_name selector_name:(NSString*) sel_name  parameter:(NSObject*) param {
    //for example you can create NSUserActivity* ua = [NSUserActivity initialize_with_type:blabla_string];
    
//    Class class = NSClassFromString(@"MyClass");
//    SEL selector = NSSelectorFromString(@"doSomething");

    Class cls = NSClassFromString(class_name);
    SEL sel_sel = NSSelectorFromString(sel_name);

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSObject* obj = [cls alloc];
    id ret_val = [obj performSelector:sel_sel withObject:param];
    #pragma clang diagnostic pop
    NSObject* ret_obj = (NSObject*) ret_val;
    
    return ret_obj;
    
}

@end



