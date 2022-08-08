//
//  Algo_Other_Important_UI_ObjC.h
//  AlgoEngine_iOS
//
//  Created by mikolaj on 25/07/2019.
//  Copyright © 2022 Mikolaj Dawidowski All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Algo_Other_Important_UI_Object <NSObject>
@required
    -(NSString*) get_name_of_object;
    -(BOOL) this_object_receiving_data:(NSObject*) data; //OK OR false for not OK - like wrong type
    -(void) this_object_ordered_to_clean_its_data;
    -(void) view_will_apear_so_update_ui;
    -(void) view_will_reapear_so_update_ui;
    -(void) view_will_disappear_so_do_cleanup;
@optional
    -(NSObject*) return_nsobject;
    -(NSURL*) return_url;
    -(NSData*) return_nsdata;
    -(void) info_viewWillTransitionTo:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>) coordinator;

@end

NS_ASSUME_NONNULL_END
