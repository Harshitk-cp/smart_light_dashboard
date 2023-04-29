package main.java.com.example.smart_light_dashboard;

import java.nio.ByteBuffer;
import java.util.*;

import android.annotation.SuppressLint;
import android.content.res.Resources;
import android.graphics.SurfaceTexture;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
    private static ScreenCaptureManager mInstance;

    private volatile MediaProjection mMediaProjection;

    private volatile VirtualDisplay mVirtualDisplay;

    private volatile int mCaptureWidth;

    private volatile int mCaptureHeight;

    private volatile ImageReader mImageReader;

    private volatile boolean mIsCapturing = false;

    private volatile int mRGB = 0;

    public static ScreenCaptureManager getInstance() {
        if (mInstance == null) {
            synchronized (ScreenCaptureManager.class) {
                if (mInstance == null) {
                    mInstance = new ScreenCaptureManager();
                    Log.i("SCM", "instance created");
                }
            }
        }
        return mInstance;
    }

    public void setScreenCaptureInfo(MediaProjection mediaProjection, int captureWidth, int captureHeight) {
        mMediaProjection = mediaProjection;
        mCaptureWidth = captureWidth;
        mCaptureHeight = captureHeight;
        Log.i("SCM",
                "Width: " + String.valueOf(captureWidth) + " | Height: " + String.valueOf(captureHeight));

        startCapture();
    }

    public int getRGB() {
        
        return mRGB;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startCapture() {
        Log.i("SCM", "capture started");

        if (mMediaProjection == null) {
            Log.e("SCM", "MediaProjection is null");
            return;
        }

        if (mIsCapturing) {
            Log.i("SCM", "screen is already being captured");
            return;
        }

        long flags = HardwareBuffer.USAGE_CPU_READ_OFTEN | HardwareBuffer.USAGE_CPU_WRITE_RARELY;
        mImageReader = ImageReader.newInstance(mCaptureWidth, mCaptureHeight, PixelFormat.RGBA_8888, 2, flags);
        mImageReader.setOnImageAvailableListener(new ImageReader.OnImageAvailableListener() {
            public void onImageAvailable(ImageReader reader) {
                Image image = reader.acquireLatestImage();
                if (image != null) {
                    int width = image.getWidth();
                    int height = image.getHeight();
                    Bitmap bitmap = Bitmap.createBitmap(image.getWidth(), image.getHeight(), Bitmap.Config.ARGB_8888);
                    bitmap.copyPixelsFromBuffer(image.getPlanes()[0].getBuffer());
                    mRGB = getAmbientColor(bitmap);
                    image.close();
                }
            }
        }, null);

        mVirtualDisplay = mMediaProjection.createVirtualDisplay(
                "ScreenCapture",
                mCaptureWidth,
                mCaptureHeight,
                1,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                mImageReader.getSurface(),
                null,
                null);

        mIsCapturing = true;
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public void stopCapture() {
        if (!mIsCapturing) {
            return;
        }

        mIsCapturing = false;

        if (mMediaProjection != null) {
            mMediaProjection.stop();
            mMediaProjection = null;
        }

        if (mVirtualDisplay != null) {
            mVirtualDisplay.release();
            mVirtualDisplay = null;
        }

        if (mImageReader != null) {
            mImageReader.close();
            mImageReader = null;
        }
    }

    private int getAmbientColor(Bitmap bitmap) {      
        int size = 100;
        int width = mCaptureWidth;
        int height = mCaptureHeight;
        int cx = width / 2;
        int cy = height / 2;
        int r = 0;
        int g = 0;
        int b = 0;
        for (int i = cx - size; i <= cx + size; i++) {
            for (int j = cy - size; j <= cy + size; j++) {
                int color = bitmap.getPixel(i, j);
                r += (color & 0xff0000) >> 16;
                g += (color & 0xff00) >> 8;
                b += color & 0xff;
            }
        }
        int side = size * 2 + 1;
        int total = side * side;
        r /= total;
        g /= total;
        b /= total;
        return (r << 16) | (g << 8) | b;
    }

    

}