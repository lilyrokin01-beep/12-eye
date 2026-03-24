#include <cstdio>
#include <cstdint>
#include "lib.h"

int main() {
    printf("Running CPU 12-eye test\n");

    uint64_t start = 0;
    uint64_t end   = 65536;

    // Example buffer
    const uint32_t MAX = 1 << 16;
    Layout layouts[MAX];

    uint32_t count = generate_layouts(
        start,
        end,
        false,       // superflat
        layouts,
        MAX
    );

    printf("Generated %u layouts\n", count);

    for (uint32_t i = 0; i < count && i < 5; i++) {
        bool ok = test_world_seed(
            layouts[i].world_seed,
            layouts[i].start_chunk_x,
            layouts[i].start_chunk_z
        );
        printf("Seed %llu valid=%s\n",
               (unsigned long long)layouts[i].world_seed,
               ok ? "YES" : "no");
    }

    return 0;
}
