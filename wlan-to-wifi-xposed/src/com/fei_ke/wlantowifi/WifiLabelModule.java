package com.fei_ke.wlantowifi;

import android.content.res.Resources;
import android.content.res.TypedArray;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.util.Log;

import io.github.libxposed.api.XposedModule;

import java.lang.reflect.Method;

/**
 * Replaces "WLAN" with "Wi-Fi" in text that apps load from their resources.
 *
 * Only resource lookups are hooked, not TextView.setText, so dynamic text such as
 * a network called "WLAN-1234" is left alone. Formatted lookups
 * (getString(int, Object...)) call getString(int) internally, so the format
 * arguments are never rewritten either.
 */
public class WifiLabelModule extends XposedModule {
    private static final String TAG = "WlanToWifi";
    private static final String OLD = "WLAN";
    private static final String NEW = "Wi-Fi";

    private boolean installed;

    @Override
    public void onPackageLoaded(PackageLoadedParam param) {
        if (!param.isFirstPackage() || installed) {
            return;
        }
        installed = true;

        int count = 0;
        count += hookResources(Resources.class);
        count += hookTypedArray(TypedArray.class);
        // Xiaomi ships a Resources subclass in some builds; hook it too if present.
        try {
            Class<?> miui = Class.forName("android.content.res.MiuiResources", false, param.getDefaultClassLoader());
            count += hookResources(miui);
        } catch (Throwable ignored) {
            // not present on this ROM
        }
        log(Log.INFO, TAG, "hooked " + count + " methods in " + param.getPackageName());
    }

    private int hookResources(Class<?> c) {
        int n = 0;
        n += hookResult(c, "getText", int.class);
        n += hookResult(c, "getText", int.class, CharSequence.class);
        n += hookResult(c, "getString", int.class);
        n += hookResult(c, "getQuantityText", int.class, int.class);
        n += hookResult(c, "getQuantityString", int.class, int.class);
        n += hookResult(c, "getTextArray", int.class);
        n += hookResult(c, "getStringArray", int.class);
        return n;
    }

    private int hookTypedArray(Class<?> c) {
        int n = 0;
        n += hookResult(c, "getText", int.class);
        n += hookResult(c, "getString", int.class);
        n += hookResult(c, "getTextArray", int.class);
        return n;
    }

    /** Hooks one method so its return value goes through {@link #fix}. Skips it if it does not exist. */
    private int hookResult(Class<?> c, String name, Class<?>... params) {
        try {
            Method m = c.getDeclaredMethod(name, params);
            hook(m).intercept(chain -> fix(chain.proceed()));
            return 1;
        } catch (NoSuchMethodException e) {
            return 0;
        } catch (Throwable t) {
            log(Log.WARN, TAG, "could not hook " + c.getSimpleName() + "#" + name, t);
            return 0;
        }
    }

    private static Object fix(Object result) {
        if (result instanceof String) {
            return fixString((String) result);
        }
        if (result instanceof CharSequence) {
            return fixText((CharSequence) result);
        }
        if (result instanceof String[]) {
            String[] in = (String[]) result;
            String[] out = null;
            for (int i = 0; i < in.length; i++) {
                String f = in[i] == null ? null : fixString(in[i]);
                if (f != in[i]) {
                    if (out == null) out = in.clone();
                    out[i] = f;
                }
            }
            return out == null ? result : out;
        }
        if (result instanceof CharSequence[]) {
            CharSequence[] in = (CharSequence[]) result;
            CharSequence[] out = null;
            for (int i = 0; i < in.length; i++) {
                CharSequence f = fixText(in[i]);
                if (f != in[i]) {
                    if (out == null) out = in.clone();
                    out[i] = f;
                }
            }
            return out == null ? result : out;
        }
        return result;
    }

    private static String fixString(String s) {
        return s.contains(OLD) ? s.replace(OLD, NEW) : s;
    }

    private static CharSequence fixText(CharSequence cs) {
        if (cs == null) {
            return null;
        }
        if (!(cs instanceof Spanned)) {
            return fixString(cs.toString());
        }
        String s = cs.toString();
        if (!s.contains(OLD)) {
            return cs;
        }
        // Keep the spans (bold, links, ...) while replacing the text.
        SpannableStringBuilder sb = new SpannableStringBuilder(cs);
        int from = 0;
        int i;
        while ((i = s.indexOf(OLD, from)) >= 0) {
            sb.replace(i, i + OLD.length(), NEW);
            s = sb.toString();
            from = i + NEW.length();
        }
        return sb;
    }
}
