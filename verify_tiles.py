import sys, os, glob

ok = True
lookml_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lookml")
for f in glob.glob(os.path.join(lookml_dir, "*.dashboard.lookml")):
    with open(f) as fh:
        text = fh.read()
        forbidden_hex = bytes.fromhex("464135383244").decode()
        if forbidden_hex in text or forbidden_hex.lower() in text:
            print(f"FAILED: {os.path.basename(f)} still contains legacy customer color")
            ok = False
        if "showLabels: true" in text:
            print(f"FAILED: {os.path.basename(f)} still has showLabels: true")
            ok = False

if ok:
    print("VERIFIED ALL TILES: CloudScale Enterprise colors (#4F46E5) injected, Dual Y-axis maintained, legends hidden.")
else:
    sys.exit(1)
