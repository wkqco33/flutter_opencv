#include "flutter_opencv.h"
#include <opencv2/opencv.hpp>
#include <string>

// A very short-lived native function.
FFI_PLUGIN_EXPORT const char* opencv_version() {
  return CV_VERSION;
}

FFI_PLUGIN_EXPORT CvMat* cv_mat_create() {
    return (CvMat*)new cv::Mat();
}

FFI_PLUGIN_EXPORT void cv_mat_release(CvMat* mat) {
    if (mat != nullptr) {
        delete (cv::Mat*)mat;
    }
}

FFI_PLUGIN_EXPORT CvMat* cv_imread(const char* filename) {
    cv::Mat image = cv::imread(filename);
    if (image.empty()) {
        return nullptr;
    }
    return (CvMat*)new cv::Mat(image);
}

FFI_PLUGIN_EXPORT int cv_imwrite(const char* filename, CvMat* mat) {
    if (mat == nullptr) return 0;
    return cv::imwrite(filename, *(cv::Mat*)mat) ? 1 : 0;
}

FFI_PLUGIN_EXPORT CvMat* cv_imdecode(const uint8_t* data, int len) {
    std::vector<uint8_t> buffer(data, data + len);
    cv::Mat image = cv::imdecode(buffer, cv::IMREAD_COLOR);
    if (image.empty()) {
        return nullptr;
    }
    return (CvMat*)new cv::Mat(image);
}

FFI_PLUGIN_EXPORT struct BytesResult cv_imencode(const char* ext, CvMat* mat) {
    struct BytesResult result = {nullptr, 0};
    if (mat == nullptr) return result;

    std::vector<uint8_t> buffer;
    if (cv::imencode(ext, *(cv::Mat*)mat, buffer)) {
        result.len = buffer.size();
        result.data = (uint8_t*)malloc(result.len);
        memcpy(result.data, buffer.data(), result.len);
    }
    return result;
}

FFI_PLUGIN_EXPORT void cv_free_bytes(struct BytesResult bytes) {
    if (bytes.data != nullptr) {
        free(bytes.data);
    }
}

FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2gray(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat gray;
    cv::cvtColor(*(cv::Mat*)mat, gray, cv::COLOR_BGR2GRAY);
    return (CvMat*)new cv::Mat(gray);
}

FFI_PLUGIN_EXPORT CvMat* cv_resize(CvMat* mat, int width, int height, int interpolation) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::resize(*(cv::Mat*)mat, dst, cv::Size(width, height), 0, 0, interpolation);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_flip(CvMat* mat, int mode) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::flip(*(cv::Mat*)mat, dst, mode);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_rotate(CvMat* mat, int code) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::rotate(*(cv::Mat*)mat, dst, code);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_gaussian_blur(CvMat* mat, int kernelSize, double sigma) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    if (kernelSize % 2 == 0) kernelSize++; // 홀수로 보정
    cv::GaussianBlur(*(cv::Mat*)mat, dst, cv::Size(kernelSize, kernelSize), sigma);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_canny(CvMat* mat, double threshold1, double threshold2) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Canny(*(cv::Mat*)mat, dst, threshold1, threshold2);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT void cv_rectangle(CvMat* mat, int x, int y, int width, int height, int r, int g, int b, int thickness) {
    if (mat == nullptr) return;
    cv::rectangle(*(cv::Mat*)mat, cv::Rect(x, y, width, height), cv::Scalar(b, g, r), thickness);
}

FFI_PLUGIN_EXPORT void cv_circle(CvMat* mat, int centerX, int centerY, int radius, int r, int g, int b, int thickness) {
    if (mat == nullptr) return;
    cv::circle(*(cv::Mat*)mat, cv::Point(centerX, centerY), radius, cv::Scalar(b, g, r), thickness);
}

FFI_PLUGIN_EXPORT void cv_line(CvMat* mat, int x1, int y1, int x2, int y2, int r, int g, int b, int thickness) {
    if (mat == nullptr) return;
    cv::line(*(cv::Mat*)mat, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(b, g, r), thickness);
}

FFI_PLUGIN_EXPORT int cv_mat_width(CvMat* mat) {
    if (mat == nullptr) return 0;
    return ((cv::Mat*)mat)->cols;
}

FFI_PLUGIN_EXPORT int cv_mat_height(CvMat* mat) {
    if (mat == nullptr) return 0;
    return ((cv::Mat*)mat)->rows;
}

FFI_PLUGIN_EXPORT int cv_mat_channels(CvMat* mat) {
    if (mat == nullptr) return 0;
    return ((cv::Mat*)mat)->channels();
}

FFI_PLUGIN_EXPORT const uint8_t* cv_mat_data(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    return ((cv::Mat*)mat)->data;
}

FFI_PLUGIN_EXPORT CvVideoCapture* cv_videocapture_create(int index) {
    cv::VideoCapture* cap = new cv::VideoCapture(index);
    if (!cap->isOpened()) {
        delete cap;
        return nullptr;
    }
    return (CvVideoCapture*)cap;
}

FFI_PLUGIN_EXPORT void cv_videocapture_release(CvVideoCapture* cap) {
    if (cap != nullptr) {
        delete (cv::VideoCapture*)cap;
    }
}

FFI_PLUGIN_EXPORT int cv_videocapture_read(CvVideoCapture* cap, CvMat* dst) {
    if (cap == nullptr || dst == nullptr) return 0;
    cv::Mat* frame = (cv::Mat*)dst;
    if (((cv::VideoCapture*)cap)->read(*frame)) {
        return 1;
    }
    return 0;
}

FFI_PLUGIN_EXPORT double cv_videocapture_get(CvVideoCapture* cap, int propId) {
    if (cap == nullptr) return 0.0;
    return ((cv::VideoCapture*)cap)->get(propId);
}

FFI_PLUGIN_EXPORT void cv_videocapture_set(CvVideoCapture* cap, int propId, double value) {
    if (cap == nullptr) return;
    ((cv::VideoCapture*)cap)->set(propId, value);
}

FFI_PLUGIN_EXPORT int cv_mat_data_len(CvMat* mat) {
    if (mat == nullptr) return 0;
    cv::Mat* m = (cv::Mat*)mat;
    return m->total() * m->elemSize();
}
