package main.java.com.example.smart_light_dashboard;

import java.nio.ByteBuffer;

import android.annotation.SuppressLint;
import android.content.res.Resources;
import android.graphics.SurfaceTexture;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.display.DisplayManager;
import android.hardware.HardwareBuffer;
import android.hardware.display.VirtualDisplay;
import android.media.projection.MediaProjection;
import android.media.ImageReader;
import android.media.Image;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.view.Surface;

import androidx.annotation.RequiresApi;

import io.flutter.Log;

public class ScreenCaptureManager {

    @SuppressLint("StaticFieldLeak")
    private static ScreenCaptureManager instance;

    private MediaProjection mMediaProjection = null;

    private volatile VirtualDisplay mVirtualDisplay = null;

    private volatile int mCaptureWidth;

    private volatile int mCaptureHeight;

    private volatile ImageReader mImageReader;

    private Handler mHandler = null;

    private volatile Surface mSurface = null;

    private boolean isCapturing = false;

    public static ScreenCaptureManager getInstance() {
        Log.i("CREATEINSTANCE", "Instance Created");
        if (instance == null) {
            synchronized (ScreenCaptureManager.class) {
                if (instance == null) {
                    instance = new ScreenCaptureManager();
                }
            }
        }
        return instance;
    }

    public void setScreenCaptureInfo(MediaProjection mediaProjection, int captureWidth, int captureHeight) {
        // width = 1080
        // height = 2252
        Log.i("SetScreenCaptureInfo", "called");
        mMediaProjection = mediaProjection;
        mCaptureWidth = captureWidth;
        mCaptureHeight = captureHeight;
        Log.i("SetScreenCaptureInfo",
                "Width: " + String.valueOf(captureWidth) + " | Height: " + String.valueOf(captureHeight));

        Log.i("SetScreenCaptureInfo", "creating texture");
        SurfaceTexture texture = new SurfaceTexture(0);
        texture.setDefaultBufferSize(mCaptureWidth, mCaptureHeight);
        mSurface = new Surface(texture);

        long flags = HardwareBuffer.USAGE_CPU_READ_OFTEN | HardwareBuffer.USAGE_CPU_WRITE_RARELY;
        mImageReader = ImageReader.newInstance(captureWidth, captureHeight, PixelFormat.RGBA_8888, 3, flags);

        startCapture();
    }

    public int getRGB() {
        Image image = mImageReader.acquireLatestImage();
        Image.Plane[] planes = image.getPlanes();
        ByteBuffer buffer = planes[0].getBuffer();
        int capacity = buffer.capacity();
        byte[] data = new byte[capacity];
        buffer.get(data);
        image.close();
        int r = 0;
        int g = 0;
        int b = 0;
        for (int i = 0; i < capacity / 4; i++) {
            int _r = data[i * 4];
            int _g = data[i * 4 + 1];
            int _b = data[i * 4 + 2];
            r = (r + _r) / 2;
            g = (g + _g) / 2;
            b = (b + _b) / 2;
        }
        int rgb = (r << 16) | (g << 8) | b;
        Log.i("Capacity: ", String.valueOf(capacity));
        return rgb;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startCapture() {
        Log.i("SCREENCAPTURE", "capture started");

        if (mMediaProjection == null) {
            Log.e("SCREENCAPTURE", "MediaProjection is null");
            return;
        }

        if (isCapturing) {
            Log.i("SCREENCAPTURE", "Screen is already being captured");
            return;
        }

        mVirtualDisplay = mMediaProjection.createVirtualDisplay(
                "ScreenCapture",
                mCaptureWidth,
                mCaptureHeight,
                1,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                mImageReader.getSurface(),
                null,
                null);

        isCapturing = true;
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public void stopCapture() {
        if (!isCapturing)
            return;

        isCapturing = false;

        if (mVirtualDisplay != null) {
            mVirtualDisplay.release();
            mVirtualDisplay = null;
        }

        if (mSurface != null) {
            mSurface.release();
            mSurface = null;
        }
    }

}