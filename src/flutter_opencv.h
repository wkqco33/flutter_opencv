#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// cv::Mat 포인터
typedef void CvMat;

// 버전
FFI_PLUGIN_EXPORT const char* opencv_version();

// 메모리 관리
FFI_PLUGIN_EXPORT CvMat* cv_mat_create();
FFI_PLUGIN_EXPORT void cv_mat_release(CvMat* mat);

// 이미지 입출력
FFI_PLUGIN_EXPORT CvMat* cv_imread(const char* filename);
FFI_PLUGIN_EXPORT int cv_imwrite(const char* filename, CvMat* mat);
FFI_PLUGIN_EXPORT CvMat* cv_imdecode(const uint8_t* data, int len);

struct BytesResult {
    uint8_t* data;
    int len;
};

FFI_PLUGIN_EXPORT struct BytesResult cv_imencode(const char* ext, CvMat* mat);
FFI_PLUGIN_EXPORT void cv_free_bytes(struct BytesResult bytes);

// 색상 변환
FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2gray(CvMat* mat);
FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2rgb(CvMat* mat);
FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2hsv(CvMat* mat);
FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_hsv2bgr(CvMat* mat);
FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_bgr2lab(CvMat* mat);
FFI_PLUGIN_EXPORT CvMat* cv_cvtColor_lab2bgr(CvMat* mat);

// 변환
FFI_PLUGIN_EXPORT CvMat* cv_resize(CvMat* mat, int width, int height, int interpolation);
FFI_PLUGIN_EXPORT CvMat* cv_flip(CvMat* mat, int mode); // mode: 0=x축, 1=y축, -1=양축
FFI_PLUGIN_EXPORT CvMat* cv_rotate(CvMat* mat, int code); // code: 0=90도CW, 1=180도, 2=90도CCW

// 필터
FFI_PLUGIN_EXPORT CvMat* cv_gaussian_blur(CvMat* mat, int kernelSize, double sigma);
FFI_PLUGIN_EXPORT CvMat* cv_median_blur(CvMat* mat, int kernelSize);
FFI_PLUGIN_EXPORT CvMat* cv_bilateral_filter(CvMat* mat, int d, double sigmaColor, double sigmaSpace);
FFI_PLUGIN_EXPORT CvMat* cv_canny(CvMat* mat, double threshold1, double threshold2);
FFI_PLUGIN_EXPORT CvMat* cv_sobel(CvMat* mat, int dx, int dy, int ksize);
FFI_PLUGIN_EXPORT CvMat* cv_laplacian(CvMat* mat, int ksize);
FFI_PLUGIN_EXPORT CvMat* cv_sharpen(CvMat* mat);

// 형태학 연산
FFI_PLUGIN_EXPORT CvMat* cv_erode(CvMat* mat, int kernelSize, int iterations);
FFI_PLUGIN_EXPORT CvMat* cv_dilate(CvMat* mat, int kernelSize, int iterations);
FFI_PLUGIN_EXPORT CvMat* cv_morphology_ex(CvMat* mat, int op, int kernelSize);

// 임계값 처리
FFI_PLUGIN_EXPORT CvMat* cv_threshold(CvMat* mat, double thresh, double maxval, int type);
FFI_PLUGIN_EXPORT CvMat* cv_adaptive_threshold(CvMat* mat, double maxValue, int adaptiveMethod, int thresholdType, int blockSize, double C);

// 히스토그램
FFI_PLUGIN_EXPORT CvMat* cv_equalize_hist(CvMat* mat);

// 노이즈 제거
FFI_PLUGIN_EXPORT CvMat* cv_fast_nl_means_denoising(CvMat* mat, float h, int templateWindowSize, int searchWindowSize);
FFI_PLUGIN_EXPORT CvMat* cv_fast_nl_means_denoising_colored(CvMat* mat, float h, float hColor, int templateWindowSize, int searchWindowSize);

// 컨투어 관련
struct ContoursResult {
    int** contours;
    int* contour_sizes;
    int num_contours;
};

FFI_PLUGIN_EXPORT struct ContoursResult cv_find_contours(CvMat* mat, int mode, int method);
FFI_PLUGIN_EXPORT void cv_free_contours(struct ContoursResult result);
FFI_PLUGIN_EXPORT void cv_draw_contours(CvMat* mat, struct ContoursResult contours, int contourIdx, int r, int g, int b, int thickness);

// 그리기
FFI_PLUGIN_EXPORT void cv_rectangle(CvMat* mat, int x, int y, int width, int height, int r, int g, int b, int thickness);
FFI_PLUGIN_EXPORT void cv_circle(CvMat* mat, int centerX, int centerY, int radius, int r, int g, int b, int thickness);
FFI_PLUGIN_EXPORT void cv_line(CvMat* mat, int x1, int y1, int x2, int y2, int r, int g, int b, int thickness);

// cv::VideoCapture 포인터
typedef void CvVideoCapture;

FFI_PLUGIN_EXPORT CvVideoCapture* cv_videocapture_create(int index);
FFI_PLUGIN_EXPORT void cv_videocapture_release(CvVideoCapture* cap);
FFI_PLUGIN_EXPORT int cv_videocapture_read(CvVideoCapture* cap, CvMat* dst);
FFI_PLUGIN_EXPORT double cv_videocapture_get(CvVideoCapture* cap, int propId);
FFI_PLUGIN_EXPORT void cv_videocapture_set(CvVideoCapture* cap, int propId, double value);

// 속성 접근자
FFI_PLUGIN_EXPORT int cv_mat_width(CvMat* mat);
FFI_PLUGIN_EXPORT int cv_mat_height(CvMat* mat);
FFI_PLUGIN_EXPORT int cv_mat_channels(CvMat* mat);
FFI_PLUGIN_EXPORT const uint8_t* cv_mat_data(CvMat* mat);
FFI_PLUGIN_EXPORT int cv_mat_data_len(CvMat* mat);

#ifdef __cplusplus
}
#endif
