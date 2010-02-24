#ifndef __DATA_BLOCK_H__
#define __DATA_BLOCK_H__

/*
 *  DataBlock.h
 *  zxing
 *
 *  Created by Christian Brunschen on 19/05/2008.
 *  Copyright 2008 ZXing authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <valarray>
#include <vector>
#include "../../common/Counted.h"
#include "../../common/Array.h"
#include "Version.h"
#include "ErrorCorrectionLevel.h"

namespace qrcode {
  namespace decoder {
    
    using namespace std;
    using namespace common;
    
    class DataBlock : public Counted {
    private:
      int numDataCodewords_;
      ArrayRef<unsigned char> codewords_;
      
      DataBlock(int numDataCodewords, ArrayRef<unsigned char> codewords) :
      numDataCodewords_(numDataCodewords), 
      codewords_(codewords) { }
      
    public:
      static ArrayRef<Ref<DataBlock> > 
      getDataBlocks(ArrayRef<unsigned char> rawCodewords,
                    Version *version,
                    ErrorCorrectionLevel &ecLevel);
      
      int getNumDataCodewords() { return numDataCodewords_; }
      ArrayRef<unsigned char> getCodewords() { return codewords_; }
    };
    
  }
}

#endif // __DATA_BLOCK_H__
