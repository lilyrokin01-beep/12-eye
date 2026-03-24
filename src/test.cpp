#include "lib.h"

#include <cstdio>
#include <cinttypes>
#include <vector>
#include <chrono>

extern uint64_t total_find_collision_count;
extern uint64_t total_find_collision_intersects;
extern uint64_t total_find_collision_null;

void bench_layout() {
    uint32_t out_len = 1 << 19;
    std::vector<Layout> out(out_len);

    auto start = std::chrono::steady_clock::now();

    for (uint64_t i = 0; i < 8; i++) {
        total_find_collision_count = 0;
        total_find_collision_intersects = 0;
        total_find_collision_null = 0;

        uint32_t count = generate_layouts(i * out_len, i * out_len + out_len, false, out.data(), out_len);
        std::printf("%" PRIu32 " / %" PRIu32 "\n", count, out_len);

        uint64_t print_interval = 1;
        uint64_t new_i = i + 1;
        if (new_i % print_interval == 0) {
            auto end = std::chrono::steady_clock::now();
            double delta = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() * 1E-9;
            double per_sec = print_interval * out_len / delta;
            std::printf("%" PRIu64 " %.3f s %.3f sps | %.2f %.2f\n", new_i, delta, per_sec, 1.0 * total_find_collision_intersects / total_find_collision_count, 1.0 * total_find_collision_null / total_find_collision_count);
            start = end;
        }
    }
}

int findBiomeAllValidReverseIndex(uint64_t seed);

int main() {
    for (int i = 0; i < 40; i++) {
        std::printf("%d\n", findBiomeAllValidReverseIndex(i));
    }
    // return 0;

    bench_layout();
}