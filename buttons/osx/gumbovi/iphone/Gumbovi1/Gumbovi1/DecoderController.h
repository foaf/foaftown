/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "DecoderDelegate.h"
//#import "Gumbovi1AppDelegate.h"
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@class OverlayView;
@class Decoder;
@class Gumbovi1AppDelegate;


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface DecoderController : UIViewController <
  UIAlertViewDelegate,
  UINavigationControllerDelegate,
  UIImagePickerControllerDelegate,
  DecoderDelegate
> {
  UIImagePickerController*  _imagePicker;
  OverlayView*              _overlayView;
  NSTimer*                  _timer;

  Decoder*                  _decoder;
}

// QR TestCard stuff
//UIWindow*           decoder_window; //qr, maybe doesn't need creating so early?

//IBOutlet UITextView *qr_result;
//@property (nonatomic, retain) IBOutlet UITextView *qr_result;

- (IBAction) buttonDone:(id) sender;
- (IBAction) startQRScan:(id) sender;

@end
