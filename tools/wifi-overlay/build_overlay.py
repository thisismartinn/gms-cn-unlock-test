#!/usr/bin/env python3
"""Build a static RRO that replaces "WLAN" with "Wi-Fi" in a target app's default strings.

Needs: androguard (pip), aapt2, an android.jar, and the JDK's keytool/jarsigner.
The target's resources.arsc can be pulled from the device with:
    unzip -p /system_ext/priv-app/Settings/Settings.apk resources.arsc > Settings.arsc

Usage:
    build_overlay.py --arsc Settings.arsc --target com.android.settings \
        --out WifiLabelSettings.apk --aapt2 aapt2 --android-jar android.jar
"""
import argparse, os, re, shutil, subprocess, sys, tempfile

from androguard.core.axml import ARSCParser

OLD, NEW = 'WLAN', 'Wi-Fi'


def default_strings(arsc_path):
    arsc = ARSCParser(open(arsc_path, 'rb').read())
    pkg = arsc.get_packages_names()[0]
    xml = arsc.get_string_resources(pkg, '\x00\x00')
    if isinstance(xml, bytes):
        xml = xml.decode('utf-8', 'replace')
    out = {}
    for m in re.finditer(r'<string name="([^"]+)"[^>]*>(.*?)</string>', xml, re.S):
        if OLD in m.group(2):
            out[m.group(1)] = m.group(2)
    return out


def escape(value):
    """Re-escape a decoded string value for aapt2's resource XML rules."""
    cdata = value.startswith('<![CDATA[') and value.endswith(']]>')
    if cdata:
        value = value[len('<![CDATA['):-len(']]>')]
    value = value.replace('\\', '\\\\').replace("'", "\\'").replace('"', '\\"')
    value = value.replace('\n', '\\n').replace('\t', '\\t')
    if value[:1] in '@?':
        value = '\\' + value
    return f'<![CDATA[{value}]]>' if cdata else value


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--arsc', required=True)
    ap.add_argument('--target', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--aapt2', default='aapt2')
    ap.add_argument('--android-jar', required=True)
    ap.add_argument('--keystore', help='existing keystore (alias "overlay", password "overlay")')
    ap.add_argument('--priority', default='9999')
    a = ap.parse_args()

    strings = default_strings(a.arsc)
    if not strings:
        sys.exit('no default strings containing %r found' % OLD)

    work = tempfile.mkdtemp(prefix='wifi-overlay-')
    res = os.path.join(work, 'res', 'values')
    os.makedirs(res)
    with open(os.path.join(res, 'strings.xml'), 'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n')
        for name, value in strings.items():
            fmt = ' formatted="false"' if '%' in value else ''
            f.write(f'    <string name="{name}"{fmt}>{escape(value.replace(OLD, NEW))}</string>\n')
        f.write('</resources>\n')

    # targetSdk < 29 on purpose: Q+ overlays are always checked against the
    # target's <overlayable> declarations, and Xiaomi's apps declare none.
    pkg = 'com.fei_ke.unlockcngms.wifilabel.' + a.target.split('.')[-1]
    with open(os.path.join(work, 'AndroidManifest.xml'), 'w') as f:
        f.write(f'''<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="{pkg}">
    <uses-sdk android:minSdkVersion="28" android:targetSdkVersion="28"/>
    <overlay android:targetPackage="{a.target}" android:priority="{a.priority}" android:isStatic="true"/>
    <application android:hasCode="false"/>
</manifest>
''')

    run = lambda *c: subprocess.run(c, check=True, cwd=work)
    run(a.aapt2, 'compile', '--dir', 'res', '-o', 'compiled.zip')
    run(a.aapt2, 'link', '-I', a.android_jar, '--manifest', 'AndroidManifest.xml',
        '-o', 'unsigned.apk', 'compiled.zip')

    ks = a.keystore or os.path.join(work, 'overlay.jks')
    if not a.keystore:
        run('keytool', '-genkeypair', '-keystore', ks, '-storepass', 'overlay', '-keypass', 'overlay',
            '-alias', 'overlay', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000',
            '-dname', 'CN=unlockcngms')
    run('jarsigner', '-keystore', ks, '-storepass', 'overlay', '-sigalg', 'SHA256withRSA',
        '-digestalg', 'SHA-256', '-signedjar', 'signed.apk', 'unsigned.apk', 'overlay')

    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    shutil.copy(os.path.join(work, 'signed.apk'), a.out)
    shutil.rmtree(work)
    print(f'{a.target}: {len(strings)} strings -> {a.out}')


if __name__ == '__main__':
    main()
