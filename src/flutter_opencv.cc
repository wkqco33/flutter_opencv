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

FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2rgb(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat rgb;
    cv::cvtColor(*(cv::Mat*)mat, rgb, cv::COLOR_BGR2RGB);
    return (CvMat*)new cv::Mat(rgb);
}

FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2hsv(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat hsv;
    cv::cvtColor(*(cv::Mat*)mat, hsv, cv::COLOR_BGR2HSV);
    return (CvMat*)new cv::Mat(hsv);
}

FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_hsv2bgr(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat bgr;
    cv::cvtColor(*(cv::Mat*)mat, bgr, cv::COLOR_HSV2BGR);
    return (CvMat*)new cv::Mat(bgr);
}

FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2lab(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat lab;
    cv::cvtColor(*(cv::Mat*)mat, lab, cv::COLOR_BGR2Lab);
    return (CvMat*)new cv::Mat(lab);
}

FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_lab2bgr(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat bgr;
    cv::cvtColor(*(cv::Mat*)mat, bgr, cv::COLOR_Lab2BGR);
    return (CvMat*)new cv::Mat(bgr);
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

FFI_PLUGIN_EXPORT CvMat* cv_median_blur(CvMat* mat, int kernelSize) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    if (kernelSize % 2 == 0) kernelSize++; // 홀수로 보정
    cv::medianBlur(*(cv::Mat*)mat, dst, kernelSize);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_bilateral_filter(CvMat* mat, int d, double sigmaColor, double sigmaSpace) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::bilateralFilter(*(cv::Mat*)mat, dst, d, sigmaColor, sigmaSpace);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_canny(CvMat* mat, double threshold1, double threshold2) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Canny(*(cv::Mat*)mat, dst, threshold1, threshold2);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_sobel(CvMat* mat, int dx, int dy, int ksize) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Sobel(*(cv::Mat*)mat, dst, CV_8U, dx, dy, ksize);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_laplacian(CvMat* mat, int ksize) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Laplacian(*(cv::Mat*)mat, dst, CV_8U, ksize);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_sharpen(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Mat kernel = (cv::Mat_<float>(3,3) << 
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0);
    cv::filter2D(*(cv::Mat*)mat, dst, -1, kernel);
    return (CvMat*)new cv::Mat(dst);
}

// 형태학 연산
FFI_PLUGIN_EXPORT CvMat* cv_erode(CvMat* mat, int kernelSize, int iterations) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(kernelSize, kernelSize));
    cv::erode(*(cv::Mat*)mat, dst, kernel, cv::Point(-1, -1), iterations);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_dilate(CvMat* mat, int kernelSize, int iterations) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(kernelSize, kernelSize));
    cv::dilate(*(cv::Mat*)mat, dst, kernel, cv::Point(-1, -1), iterations);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_morphology_ex(CvMat* mat, int op, int kernelSize) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(kernelSize, kernelSize));
    cv::morphologyEx(*(cv::Mat*)mat, dst, op, kernel);
    return (CvMat*)new cv::Mat(dst);
}

// 임계값 처리
FFI_PLUGIN_EXPORT CvMat* cv_threshold(CvMat* mat, double thresh, double maxval, int type) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::threshold(*(cv::Mat*)mat, dst, thresh, maxval, type);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_adaptive_threshold(CvMat* mat, double maxValue, int adaptiveMethod, int thresholdType, int blockSize, double C) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    if (blockSize % 2 == 0) blockSize++; // 홀수로 보정
    cv::adaptiveThreshold(*(cv::Mat*)mat, dst, maxValue, adaptiveMethod, thresholdType, blockSize, C);
    return (CvMat*)new cv::Mat(dst);
}

// 히스토그램
FFI_PLUGIN_EXPORT CvMat* cv_equalize_hist(CvMat* mat) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::Mat src = *(cv::Mat*)mat;
    
    // 그레이스케일인 경우
    if (src.channels() == 1) {
        cv::equalizeHist(src, dst);
    } else {
        // 컬러 이미지는 YCrCb로 변환 후 Y 채널만 평활화
        cv::Mat ycrcb;
        cv::cvtColor(src, ycrcb, cv::COLOR_BGR2YCrCb);
        std::vector<cv::Mat> channels;
        cv::split(ycrcb, channels);
        cv::equalizeHist(channels[0], channels[0]);
        cv::merge(channels, ycrcb);
        cv::cvtColor(ycrcb, dst, cv::COLOR_YCrCb2BGR);
    }
    return (CvMat*)new cv::Mat(dst);
}

// 노이즈 제거
FFI_PLUGIN_EXPORT CvMat* cv_fast_nl_means_denoising(CvMat* mat, float h, int templateWindowSize, int searchWindowSize) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::fastNlMeansDenoising(*(cv::Mat*)mat, dst, h, templateWindowSize, searchWindowSize);
    return (CvMat*)new cv::Mat(dst);
}

FFI_PLUGIN_EXPORT CvMat* cv_fast_nl_means_denoising_colored(CvMat* mat, float h, float hColor, int templateWindowSize, int searchWindowSize) {
    if (mat == nullptr) return nullptr;
    cv::Mat dst;
    cv::fastNlMeansDenoisingColored(*(cv::Mat*)mat, dst, h, hColor, templateWindowSize, searchWindowSize);
    return (CvMat*)new cv::Mat(dst);
}

// 컨투어
FFI_PLUGIN_EXPORT struct ContoursResult cv_find_contours(CvMat* mat, int mode, int method) {
    struct ContoursResult result = {nullptr, nullptr, 0};
    if (mat == nullptr) return result;
    
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(*(cv::Mat*)mat, contours, mode, method);
    
    result.num_contours = contours.size();
    if (result.num_contours == 0) return result;
    
    result.contours = (int**)malloc(sizeof(int*) * result.num_contours);
    result.contour_sizes = (int*)malloc(sizeof(int) * result.num_contours);
    
    for (int i = 0; i < result.num_contours; i++) {
        result.contour_sizes[i] = contours[i].size();
        result.contours[i] = (int*)malloc(sizeof(int) * 2 * contours[i].size());
        for (size_t j = 0; j < contours[i].size(); j++) {
            result.contours[i][j * 2] = contours[i][j].x;
            result.contours[i][j * 2 + 1] = contours[i][j].y;
        }
    }
    
    return result;
}

FFI_PLUGIN_EXPORT void cv_free_contours(struct ContoursResult result) {
    if (result.contours != nullptr) {
        for (int i = 0; i < result.num_contours; i++) {
            free(result.contours[i]);
        }
        free(result.contours);
    }
    if (result.contour_sizes != nullptr) {
        free(result.contour_sizes);
    }
}

FFI_PLUGIN_EXPORT void cv_draw_contours(CvMat* mat, struct ContoursResult contours, int contourIdx, int r, int g, int b, int thickness) {
    if (mat == nullptr || contours.contours == nullptr) return;
    
    std::vector<std::vector<cv::Point>> cvContours;
    for (int i = 0; i < contours.num_contours; i++) {
        std::vector<cv::Point> contour;
        for (int j = 0; j < contours.contour_sizes[i]; j++) {
            contour.push_back(cv::Point(
                contours.contours[i][j * 2],
                contours.contours[i][j * 2 + 1]
            ));
        }
        cvContours.push_back(contour);
    }
    
    cv::drawContours(*(cv::Mat*)mat, cvContours, contourIdx, cv::Scalar(b, g, r), thickness);
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
