import subprocess

result = subprocess.run(["lib12eye_cpu.exe", "--start", "0", "--count", "65536"], capture_output=True, text=True)
print(result.stdout)
