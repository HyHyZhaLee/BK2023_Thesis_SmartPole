#!/bin/bash

python3 detect.py --model ../all_models/mobilenet_ssd_v2_coco_quant_postprocess_edgetpu.tflite --labels ../all_models/coco_labels.txt --video "rtsp://admin:ACLAB2023@192.168.8.101/ISAPI/Streaming/channels/1"