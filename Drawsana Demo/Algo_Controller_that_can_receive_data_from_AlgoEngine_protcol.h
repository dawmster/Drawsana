//
//  Algo_Controller_that_can_receive_data_from_AlgoEngine_protcol.h
//  Drugi_iOS
//
//  Created by Mikolaj Dawidowski on 9/8/18.
//  Copyright © 2022 Mikolaj Dawidowski All rights reserved.
//

#ifndef Algo_Controller_that_can_receive_data_from_AlgoEngine_protcol_h
#define Algo_Controller_that_can_receive_data_from_AlgoEngine_protcol_h

#import <UIKit/UIKit.h>

//*******************************************************************************************************
//**************** ALGO CONTROLLER THAT CAN RECEIVE DATA FROM ALGO ENGINE *******************************
//*******************************************************************************************************

//!@ this protocol need be implemented by Algo_ViewControllers - so that they will receive inputs from AlgoEngine
//      via Controller Delegates (that implement Algo_UIViewController_Delegate_Proto or  Algo_UITableViewController_Delegate_Proto)
// this protocol is used by normal (external) processes that send data from AlgoEngine to Views, View Controllers, other controllers (for example communication controllers)
//    in response to prepareForSegue - AlgoEngine will send data to segue destination controller
//      in response to configureCell - AlgoEngine can send data to UIViewCell subclass
@protocol Algo_Controller_that_can_receive_data_from_AlgoEngine
@required
-(void) SendSingleData:(NSObject* _Nullable) data withKey:(NSString* _Nullable) key  ;
-(void) SendBunchOfData:(NSDictionary<NSString*,NSObject*>* _Nullable) dict_of_data;

@property (nonatomic, copy) void (^ _Nullable DataReceivingBlock)(NSDictionary<NSString*,NSObject*>* _Nullable keys_with_data) ;
@end

@protocol Algo_Controller_with_targeted_unwind_segue
@required
- (NSString*_Nullable) return_unwind_destination_view_controller_name;
- (void) set_unwind_segue_destination_view_controller:(NSString*_Nullable) new_dest_vc_name ;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray * _Nullable important_elements;
@property (nonatomic, strong) IBOutletCollection(NSObject) NSArray<NSObject*>* _Nullable other_important_objects;

@end

@protocol Algo_Object_With_Algorithm
@required
@property (nonatomic,strong) NSString* _Nullable algorithm_name;
@property (nonatomic,strong) NSString* _Nullable algorithm_library;
@property (nonatomic,assign) void* _Nullable process_executor_main;
@property (nonatomic,assign) void* _Nullable process_executor_cell_1;
@property (nonatomic,assign) void* _Nullable process_executor_cell_2;
@property (nonatomic,assign) void* _Nullable process_executor_cell_3;
- (void) algo_initialize;
- (void) algo_delete_delegate;
@end

#endif /* Algo_Controller_that_can_receive_data_from_AlgoEngine_protcol_h */
