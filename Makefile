CUBIOMES_SRC = $(addprefix cubiomes/,biomenoise.c biomes.c finders.c generator.c layers.c noise.c)
STRONGHOLD_GENERATOR_SRC = $(addprefix src/stronghold_generator/,BoundingBox.cpp Piece.cpp PiecePlaceCount.cpp PieceWeight.cpp StrongholdGenerator.cpp XrsrRandom.cpp)
LIB_SRC = src/lib.cpp src/lib.c $(STRONGHOLD_GENERATOR_SRC) $(CUBIOMES_SRC)

override NVCC_FLAGS += -std=c++20 -O3 --expt-relaxed-constexpr -arch=native --generate-line-info -g -ccbin g++-11
CLANG_FLAGS = -O3 -march=native -flto -g

ifeq ($(OS),Windows_NT)
	override NVCC_FLAGS += -Xcompiler /Zc:preprocessor -Xcompiler /GL -Xlinker /OPT:NOREF
	EXE = .exe
	DLL = .dll
	DLL_LINK = .lib
else
	FPIC = -fPIC
	DLL = .so
	DLL_LINK = .so
endif

main: FORCE
	nvcc src/12eye.cu $(LIB_SRC) -o main$(EXE) $(NVCC_FLAGS)

main-clang: FORCE
	rm -r obj; mkdir obj; cd obj; \
		clang -c ../src/lib.c -o lib1.o $(FPIC) $(CLANG_FLAGS); \
		clang -c $(addprefix ../,$(CUBIOMES_SRC)) -Wno-all $(FPIC) $(CLANG_FLAGS); \
		clang -c ../src/lib.cpp $(addprefix ../,$(STRONGHOLD_GENERATOR_SRC)) -std=c++20 $(FPIC) $(CLANG_FLAGS)
	clang -shared obj/* -o lib$(DLL) -std=c++20 $(FPIC) $(CLANG_FLAGS) -fuse-ld=lld
	nvcc src/12eye.cu lib$(DLL_LINK) -o main$(EXE) $(NVCC_FLAGS)

main-ptx: FORCE
	nvcc -ptx src/12eye.cu -o main.ptx $(NVCC_FLAGS)

test-clang: FORCE
	clang++ src/test.cpp src/lib.cpp $(STRONGHOLD_GENERATOR_SRC) -o test$(EXE) -std=c++20 $(CLANG_FLAGS) -fuse-ld=lld
# 	-fprofile-use=code.profdata
# 	-fprofile-generate

test-gcc: FORCE
	g++ src/test.cpp src/lib.cpp $(STRONGHOLD_GENERATOR_SRC) -o test$(EXE) -std=c++20 -O3 -march=native

test-msvc: FORCE
	nvcc src/test.cpp src/lib.cpp $(STRONGHOLD_GENERATOR_SRC) -o test$(EXE) $(NVCC_FLAGS) -Xcompiler /arch:AVX2

WASM_EXPORTED = -sEXPORTED_FUNCTIONS=_malloc,_free,_generate_layouts,_test_world_seed

wasm: FORCE
	emcc $(LIB_SRC) -o web/src/wasm/lib.mjs -O3 $(WASM_EXPORTED)

wasm-single: FORCE
	emcc $(LIB_SRC) -o web/src/wasm/lib_single.mjs -O3 $(WASM_EXPORTED) -sSINGLE_FILE

FORCE: