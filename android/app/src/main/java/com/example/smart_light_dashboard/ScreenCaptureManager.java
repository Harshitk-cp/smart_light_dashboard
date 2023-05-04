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
import android.media.AudioRecord;
import android.media.AudioPlaybackCaptureConfiguration;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import main.java.com.example.smart_light_dashboard.fft_implementation.Complex;
import main.java.com.example.smart_light_dashboard.fft_implementation.FFT;
import android.content.Context;




import android.media.AudioPlaybackCaptureConfiguration;




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

    private volatile AudioRecord audioRecord;

    private volatile AudioManager audioManager;

    private volatile  AudioFormat audioFormat;

    private volatile  AudioPlaybackCaptureConfiguration config;

    private volatile boolean mIsCapturing = false;

    private volatile boolean mIsCapturingAudio = false;

    private volatile Context appContext;

    private volatile int mRGB = 0;

    private volatile double frequency = 0.0;

    private volatile int bufferSizeInBytes = 4096; 

    private volatile short[] buffer = new short[bufferSizeInBytes];

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

    public void setScreenCaptureInfo(MediaProjection mediaProjection, int captureWidth, int captureHeight, Context context) {
        mMediaProjection = mediaProjection;
        mCaptureWidth = captureWidth;
        mCaptureHeight = captureHeight;
        Log.i("SCM",
                "Width: " + String.valueOf(captureWidth) + " | Height: " + String.valueOf(captureHeight));

        startCapture(context);
    }

    public int getRGB() {
        
        return mRGB;
    }

    public double getAudioOutput(){
        return frequency;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startCapture(Context context) {
        Log.i("SCM", "capture started");

        if (mMediaProjection == null) {
            Log.e("SCM", "MediaProjection is null");
            return;
        }

        if (mIsCapturing) {
            Log.i("SCM", "screen is already being captured");
            return;
        }

        appContext = context.getApplicationContext();
        //Audio Capture
        audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        audioManager.setAllowedCapturePolicy(AudioAttributes.ALLOW_CAPTURE_BY_ALL);

         config = new AudioPlaybackCaptureConfiguration.Builder(mMediaProjection)
         .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
         .build();

        audioFormat = new AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(44100)
            .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
            .build();

        audioRecord = new AudioRecord.Builder()
         .setAudioFormat(audioFormat)
         .setAudioPlaybackCaptureConfig(config)
         .build();


         
         if (audioRecord.getState() == AudioRecord.STATE_INITIALIZED) {
            Log.i("AUDIO RECORD ", "RECORDING INITIALISED");
            audioRecord.startRecording();
            if (audioRecord.getRecordingState() == AudioRecord.STATE_UNINITIALIZED) {
                Log.i("AUDIO RECORD ", "RECORDING STATE NOT RECORDING");
            } else {
                Log.i("AUDIO RECORD ", "RECORDING STATE GOOD");

                mIsCapturingAudio = true;

                Thread t1 = new Thread(new Runnable() {
                    @Override
                    public void run(){
                        // try {
                            while (true) {
                                // Log.i("SCM", "Audio loop");
                                int bufferReadResult = audioRecord.read(buffer, 0, bufferSizeInBytes); // record data from mic into buffer
                                if (bufferReadResult > 0) {
                                    calculate();
                                    // Log.i("AUDIO RECORD ", "RECORDING STATE GOOD");
                                }
                                if (!mIsCapturingAudio) break;
                        //         Thread.sleep(1);
                            }
                        // } catch (InterruptedException e) {
                        //     e.printStackTrace();
                        // }
                    }
                });  
                t1.start();
            }
        } else {
            Log.i("AUDIO RECORD", "IS NOT INITIALISED");
        }

        
    

        //Video capture
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

    public void calculate() {
        // Log.i("AUDIO RECORD ", "Calculations started");
        double[] magnitude = new double[bufferSizeInBytes / 2];

        //Create Complex array for use in FFT
        Complex[] fftTempArray = new Complex[bufferSizeInBytes];
        for (int i = 0; i < bufferSizeInBytes; i++) {
            fftTempArray[i] = new Complex(buffer[i], 0);
        }

        //Obtain array of FFT data
        final Complex[] fftArray = FFT.fft(fftTempArray);
        // calculate power spectrum (magnitude) values from fft[]
        for (int i = 0; i < (bufferSizeInBytes / 2) - 1; ++i) {
            double real = fftArray[i].re();
            double imaginary = fftArray[i].im();
            magnitude[i] = Math.sqrt(real * real + imaginary * imaginary);

        }

        // find largest peak in power spectrum
        double mag_total = 0;
        for (int i = 0; i < magnitude.length; ++i) {
            double Fs = i * audioFormat.getSampleRate() / bufferSizeInBytes;
            if (Fs > 400.0) break;
            mag_total += magnitude[i];
        }

        frequency = (int)(mag_total / 100000000);
        
        // Log.i("SCM", "A: " + Integer.toString((int)mag_total / 1000000));
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public void stopCapture() {
        if (!mIsCapturing) {
            return;
        }

        mIsCapturing = false;
        mIsCapturingAudio = false;

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
        int width = mCaptureWidth;
        int height = mCaptureHeight;
        int r = 0;
        int g = 0;
        int b = 0;
        int count = 0;
        for (int i = 0; i < width; i += 50 ) {
            for (int j = 0; j < height; j += 50) {
                int color = bitmap.getPixel(i, j);
                r += (color & 0xff0000) >> 16;
                g += (color & 0xff00) >> 8;
                b += color & 0xff;
                count++;
            }
        }
        r /= count;
        g /= count;
        b /= count;
        return (r << 16) | (g << 8) | b;
    }

    

}