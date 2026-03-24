# 12-Eye Minecraft Seed Finder

A **CUDA-accelerated seed finder** that searches for rare end portals with 11 or 12 pre-filled eyes in Minecraft Java Edition (1.19.3+). Achieves speeds of **10+ billion seeds per second** on consumer GPUs.

## ✨ Features

- 🚀 **Blazing fast** – 10-22 Gsps on RTX 3080/4070
- 👁️ **Multiple eye counts** – Finds 11 and 12 eye portals
- 🔀 **Chunk-split portal detection** – Identifies portals that span chunk boundaries (corrupted portals)
- 📍 **Spawn distance calculation** – Shows distance from world spawn to portal
- 💾 **Saves results** – Automatically writes seeds to `11eyes.txt` and `12eyes.txt`
- 🎮 **Minecraft 1.19.3+ compatible** – Uses modern structure generation

## 📥 Download

```bash
git clone --recursive https://github.com/lilyrokin01-beep/12-eye.git
cd 12-eye
```

## 🔨 Build

### CUDA Executable (Recommended)

```bash
make main
```

The executable will be named `main` (or `main.exe` on Windows).

### WebAssembly Version

```bash
make wasm
```

Serve the `web/src` folder through a web server.

### Standalone HTML

```bash
make wasm-single
cd web
npm i
npm run build
```

The output is `web/dist/index.html`.

## 🚀 Usage

### Basic Search (Random Start)

```bash
./main
```

### Search a Specific Range

```bash
# Search 100 ranges starting from 0
./main --start 0 --count 100
```

### Search with Bloom Filter (Faster for 12-Eye Only)

```bash
./main --filter bloom
```

### Adjust CPU Threads

```bash
# Use 32 threads (default uses all available)
./main --threads 32
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `--start <n>` | Starting high 32-bit seed value (random if omitted) |
| `--count <n>` | Number of seed ranges to search |
| `--end <n>` | Ending high 32-bit seed value |
| `--threads <n>` | Number of CPU threads to use |
| `--superflat` | Search in superflat worlds (faster, less accurate) |
| `--filter bloom` | Use bloom filter for faster 12-eye searching |
| `--print-interval <n>` | Print performance stats every n ranges |

## 📊 Output Format

### Console Output

```
Seed: -5043223749094712440 Eyes: 12 Spawn: (-37,-168) Portal: (-576,-2736) Distance: 0 blocks

```

### Saved Files

- `11eyes.txt` – Seeds with 11 eyes
- `12eyes.txt` – Seeds with 12 eyes

Each file contains tab-separated values: `Seed`, `Start_X`, `Start_Z`, `Portal_X`, `Portal_Z`, `Distance`

ie: -5087685212357556483	-35	140	-576	2192	2336 (11eye) portal is at (-576	2192)

ie: 1040587980606700923	-1	-91	-64	-1456	982 (12 eye) portal is at (-64	-1456)

## 🧠 How It Works

1. **CPU Stage**: Generates possible stronghold layouts using the `cubiomes` library
2. **GPU Stage**: CUDA kernels apply the skip optimization to count portal eyes
3. **Eye Counting**: Each chunk of the portal is evaluated independently – detects chunk-boundary portals
4. **Output**: Seeds with 11 or 12 eyes are printed and saved

## ⚙️ Performance

| GPU | Speed (Skip Mode) | Speed (Bloom Mode) |
|-----|-------------------|-------------------|
| RTX 3080 | ~11 Gsps | ~22 Gsps |
| RTX 4070 Ti | ~12 Gsps | ~24 Gsps |
| RTX 4090 | ~15 Gsps | ~30 Gsps |

*Gsps = billion seeds per second*

## 🙏 Credits

This project is based on the original work by **[Gaider10](https://github.com/Gaider10/12-eye)**.

### Original Repository

- [Gaider10/12-eye](https://github.com/Gaider10/12-eye)

### Dependencies

- **[cubiomes](https://github.com/Cubitect/cubiomes)** – Minecraft biome and structure generation library (MIT License)
- **CUDA Toolkit** – GPU acceleration (NVIDIA)

### Modifications Made

- Added support for **11-eye seeds**
- Added **spawn distance calculation**
- Added **corrupted portal detection** (chunk-boundary portals)
- Removed superflat-only output restrictions
- Optimized for RTX 3080 and similar consumer GPUs

## 📜 License

This project inherits the license from the original repository. See the [LICENSE](LICENSE) file for details.

## 🎯 Found a Rare Seed?

Share it with the community! 12-eye seeds (especially chunk-split/corrupted ones) are highly sought after by speedrunners and seed collectors.

---

**Happy seed hunting!** 🎮🔍
