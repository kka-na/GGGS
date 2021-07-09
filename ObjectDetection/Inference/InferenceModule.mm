// Copyright (c) 2020 Facebook, Inc. and its affiliates.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

#import "InferenceModule.h"
#import <LibTorch/LibTorch.h>

// 640x640 is the default image size used in the export.py in the yolov5 repo to export the TorchScript model, 25200*85 is the model output size
const int input_width = 640;
const int input_height = 640;
const int output_size = 25200*14;


@implementation InferenceModule {
    @protected torch::jit::script::Module _impl;
}

//torch script 모듈 로딩하기.
//pytorch모델을 -> C++ -> Swift로 로드하기 위해, libTorch API를 사용해서 직렬화된 pytorch 모델을 읽고 실행해야한다.
- (nullable instancetype)initWithFileAtPath:(NSString*)filePath {
    self = [super init]; // 리턴되는 모듈
    if (self) {
        try {
            _impl = torch::jit::load(filePath.UTF8String); //파일경로를 인자로 받고 ㅕㄱ직렬화 실행.
            _impl.eval();
        } catch (const std::exception& exception) {
            NSLog(@"%s", exception.what());
            return nil;
        }
    }
    return self;
}

//torch script module 실행하기.
- (NSArray<NSNumber*>*)detectImage:(void*)imageBuffer {
    try {
        //입력값 벡터를 생성
        at::Tensor tensor = torch::from_blob(imageBuffer, { 1, 3, input_width, input_height }, at::kFloat);
        torch::autograd::AutoGradMode guard(false);
        at::AutoNonVariableTypeMode non_var_type_mode(true);
        //모델을 실행한 뒤 리턴값을 텐서로 변환.
        auto outputTuple = _impl.forward({ tensor }).toTuple();
        auto outputTensor = outputTuple->elements()[0].toTensor();

        float* floatBuffer = outputTensor.data_ptr<float>();
        if (!floatBuffer) {
            return nil;
        }
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        for (int i = 0; i < output_size; i++) {
          [results addObject:@(floatBuffer[i])];
        }
        return [results copy];
        
    } catch (const std::exception& exception) {
        NSLog(@"%s", exception.what());
    }
    return nil;
}

@end
