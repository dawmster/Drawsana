//
//  Algo_Centering_ScrollView.swift
//  AlgoEngine_iOS
//
//  Created by mikolaj on 03/10/2019.
//  Copyright © 2022 Mikołaj Dawidowski. All rights reserved.
//
// how to USE see Note/2019-10-03 Centering ScrollView.txt
import Foundation

public class Algo_Centering_ScrollView: UIScrollView, UIScrollViewDelegate,Algo_Other_Important_UI_Object, UIGestureRecognizerDelegate {
    private var binding_object = Algo_Binding()
    
    //HUGE leak fixed - Algo_Centering_ScrollView - stopped observing and removing
    //    Should be probably placed in separate method from Algo_Other_Import_UI_Object - not willMoveToSuperView - this'll prevent in future moving this between views
    public override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            self.binding_object.stop_observing()
            self.binding_object.observed_nsobject = nil
            self.view_to_zoom_in_scroll_view = nil
            self.binding_object.value_changed = nil
          
          
            
            return
        }
        
    }
   public weak var view_second: UIView?
    @IBOutlet weak var view_to_zoom_in_scroll_view:UIImageView? {
        didSet {
            self.binding_object.stop_observing()
            self.binding_object.observed_nsobject = view_to_zoom_in_scroll_view
            self.binding_object.keyPath_to_observe = "image"
            self.binding_object.value_changed = { ( obj:NSObject?) ->Void in
                self.single_fire = false
                self.no_animation = true
                self.setNeedsLayout()

            }
            self.binding_object.start_observing()
            single_fire = false
            self.no_animation = true
            //self.setNeedsLayout()
        }
    }
    @IBInspectable var classic_scroll:Bool = true
    @IBInspectable var keep_centered_if_smaller:Bool = true
    @IBInspectable var zoom_to_width:Bool = false {
        didSet {
            self.single_fire = false
            self.no_animation = true
            self.setNeedsLayout()
        }
    }
    @IBInspectable var zoom_to_height: Bool = true {
       didSet {
           //self.single_fire = false
           //self.no_animation = true
           self.setNeedsLayout()
       }
   }
    
    
    
    public override func prepareForInterfaceBuilder() {
        self.classic_scroll = true
        self.keep_centered_if_smaller = true
    }
    private var single_fire:Bool = false
    private var no_animation:Bool = true
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        self.delegate = self
    }
    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
        self.delegate = self
      
        self.pinchGestureRecognizer?.delegate = self
      self.panGestureRecognizer.isEnabled = false
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if( keep_centered_if_smaller == true ){
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    }
    
    //for scrollView for zooming
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if((self.view_to_zoom_in_scroll_view) != nil) {
            return self.view_to_zoom_in_scroll_view
        }
        else{
            return nil
        }
    }

    public func view_will_apear_so_update_ui() {
        
        
    }
    public func view_will_disappear_so_do_cleanup() {

    }
    public func return_nsdata() -> Data {
        return Data()
    }
    public func this_object_ordered_to_clean_its_data() {

    }
    public func this_object_receiving_data(_ data: NSObject) -> Bool {
        return false
    }
    
    public func info_viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//            self.device_rotated()
        self.single_fire = false
        self.setNeedsLayout()
    }
    public func get_name_of_object()->String{ return self.restorationIdentifier ?? "" };
    public func view_will_reapear_so_update_ui(){};
//    public func return_url ()->NSURL{};
//    -(NSData*) return_nsdata;
//    -(void) info_viewWillTransitionTo:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>) coordinator;


    private var  oldVerticalSizeClass: UIUserInterfaceSizeClass = UIScreen.main.traitCollection.verticalSizeClass

    private var  oldHorizontalSizeClass: UIUserInterfaceSizeClass = UIScreen.main.traitCollection.horizontalSizeClass
    
    private var algo_old_size:CGSize?
    public func algo_layout_subviews(){
        if  let myimg = self.view_to_zoom_in_scroll_view , keep_centered_if_smaller==true, self.single_fire == false {
        //            UIView.performWithoutAnimation {
                        
                    
                        self.single_fire = true

                        oldHorizontalSizeClass = self.traitCollection.horizontalSizeClass
                        oldVerticalSizeClass = self.traitCollection.verticalSizeClass
                        
                        let sv = self
                        
            //            myimg.sizeToFit()
                        
                        guard let img_size = myimg.image?.size else { return }
                        
//                        myimg.frame.size = img_size
//                        myimg.frame.origin.x = 0.0
//                        myimg.frame.origin.y = CGFloat(0.0)
                        sv.contentSize = img_size
                        
                        let maxSize = self.frame.size;
                        let widthRatio = maxSize.width / img_size.width;
                        let heightRatio = maxSize.height / img_size.height;
                        
                        //initial zoom is set so that picture fills whole space - akin to Aspect Fill
                        var initialZoom:CGFloat = 0.0
                        if(self.zoom_to_height == true){
                            initialZoom = (widthRatio > heightRatio) ? widthRatio : heightRatio;
                        }
                        else {
                            initialZoom = (widthRatio < heightRatio) ? widthRatio : heightRatio;
                        }
                        
                        //minimal zoom is set so that whole image (but not more) is visible - akin to Aspect Fit
                        let minZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
                        self.minimumZoomScale = minZoom
                        self.zoomScale = initialZoom
          
                        myimg.frame.size.width = img_size.width * initialZoom
                        myimg.frame.size.height = img_size.height * initialZoom
          
          myimg.frame.origin.x = 0.0
          myimg.frame.origin.y = CGFloat(0.0)
          view_second?.frame = myimg.frame
          view_second?.bounds = myimg.bounds

                        self.contentSize = myimg.frame.size

                        var topInset:CGFloat = (maxSize.height - (img_size.height*self.zoomScale)) / 2.0;
                        var sideInset:CGFloat =  (maxSize.width - (img_size.width*self.zoomScale)) / 2.0;
                        if (topInset < 0.0) {topInset = 0.0}
                        if (sideInset < 0.0) {sideInset = 0.0}
                        self.contentInset = UIEdgeInsets(top: topInset, left: sideInset, bottom:topInset, right:sideInset)

                        //below is function that moves picture to the center if it is smaller that scrollView
                        //   so that zooming out will keep picture centered
                        if(topInset > 0.0 || sideInset > 0.0 ){
                            self.scrollViewDidZoom( self)
                        }
                        
                        //if on the other hand picture is bigger - than we move scrollview viewport to the middle of picture
                        if(topInset==0 && sideInset == 0){
                            let new_vis_x = (myimg.frame.size.width)/2.0 - self.frame.size.width/2.0
                            let new_vis_y = (myimg.frame.size.height)/2.0 - self.frame.size.height/2.0
                            sv.scrollRectToVisible(CGRect(x: new_vis_x, y: new_vis_y, width: self.frame.size.width, height: self.frame.size.height), animated: false)
                        }

                }
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        if( self.bounds.size == CGSize(width: 0, height: 0) ){
            return
        }
        
        if let myOldSize = self.algo_old_size {
            if( myOldSize != self.bounds.size ){
              self.single_fire = false

//              if #available(iOS 14.0, *) {
//                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.mac {
//
//                }
//                else{
//                  self.single_fire = false
//                }
//              } else {
//                self.single_fire = false
//                // Fallback on earlier versions
//              }
            }
        }
        else {
            self.single_fire = false
        }
        self.algo_old_size = self.bounds.size
        
        
        if(self.no_animation == true){
            self.no_animation = false
            UIView.performWithoutAnimation {
                algo_layout_subviews()
            }
        
        }
        else{
            algo_layout_subviews()
        }
      if( view_second?.frame != view_to_zoom_in_scroll_view?.frame){
        view_second?.frame = view_to_zoom_in_scroll_view!.frame
      }
        

            //this is execute when image changes
            //its updates so called "contentSize" - AFTER the layout of subviews is calculated
            //   this is needed because when subview has constraint to center then:
            //          if image(view) is smaller (slimmer) then this scrollview - it is not needed
            //          if image(view) is WIDER then horizontal-centering constrain MOVES it so we cannot scroll to left
            //
            //      so 1) subview (ScaleAspectFitImage) updates this horizontal.constraint.constatnt to move it back into scrollview
            //         2) this scrollview updates contentSize to its full width
            //         3) this scrollview scrolls to center of the image(subview)
        
        if(
            oldHorizontalSizeClass != self.traitCollection.horizontalSizeClass ||
            oldVerticalSizeClass != self.traitCollection.verticalSizeClass
            ){
                UIView.performWithoutAnimation {
           
                    self.scrollViewDidZoom( self)
                    oldHorizontalSizeClass = self.traitCollection.horizontalSizeClass
                    oldVerticalSizeClass = self.traitCollection.verticalSizeClass
                 }
            }
        
    }
    
    deinit {
//        print("Algo_Centering_ScrollView deinit")
//        self.view_to_zoom_in_scroll_view?.removeFromSuperview()
    }
  
  override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if gestureRecognizer.numberOfTouches == 1 {
      
      if gestureRecognizer.view == view_second {
        if( (gestureRecognizer.state == .possible) || (gestureRecognizer.state == .ended) || (gestureRecognizer.state == .cancelled) || (gestureRecognizer.state == .failed) ){
          
          return true
        }
        
      }
      
      //gestureRecognizer.cancelsTouchesInView = false
      return false
    }
    return true
  }
  
  public func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    if(gestureRecognizer.view == self.view_second ){
      return true
    }
    return false
  }
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
          -> Bool {
            return true
  }
  
}


